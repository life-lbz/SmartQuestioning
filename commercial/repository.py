"""SQLite platform metadata; business MySQL remains read-only."""
from __future__ import annotations
import asyncio
import hashlib
import hmac
import json
import os
from pathlib import Path
import secrets
import sqlite3
import time
from contextlib import contextmanager

from backend.app.schemas import QuestionRecord, utc_now


class LoginBlockedError(Exception):
    """登录失败次数过多，临时封锁。"""


class LoginFailedError(Exception):
    """用户名或密码错误。"""


def password_hash(password: str, salt: str | None = None) -> str:
    salt = salt or secrets.token_hex(16)
    key = hashlib.scrypt(password.encode(), salt=bytes.fromhex(salt), n=16384, r=8, p=1).hex()
    return f'{salt}:{key}'

def password_matches(password: str, stored: str) -> bool:
    return hmac.compare_digest(password_hash(password, stored.split(':')[0]), stored)

def token_hash(token: str) -> str:
    return hashlib.sha256(token.encode()).hexdigest()

class Repository:
    def __init__(self, path: Path):
        self.path = Path(path)
        self.path.parent.mkdir(parents=True, exist_ok=True)
        with self.connect() as c:
            c.executescript('''
            PRAGMA journal_mode=WAL;
            CREATE TABLE IF NOT EXISTS users(id INTEGER PRIMARY KEY, username TEXT NOT NULL UNIQUE,
              display_name TEXT NOT NULL, role TEXT NOT NULL CHECK(role IN ('admin','analyst','viewer')),
              password_hash TEXT NOT NULL, active INTEGER NOT NULL DEFAULT 1, created_at REAL NOT NULL);
            CREATE TABLE IF NOT EXISTS sessions(token TEXT PRIMARY KEY, user_id INTEGER NOT NULL REFERENCES users(id),
              csrf TEXT NOT NULL, expires REAL NOT NULL);
            CREATE TABLE IF NOT EXISTS questions(id TEXT PRIMARY KEY, owner TEXT NOT NULL,
              status TEXT NOT NULL, body TEXT NOT NULL, created_at TEXT NOT NULL);
            CREATE INDEX IF NOT EXISTS question_owner ON questions(owner,created_at);
            CREATE TABLE IF NOT EXISTS favorites(id INTEGER PRIMARY KEY, owner TEXT NOT NULL,
              title TEXT NOT NULL, question TEXT NOT NULL, UNIQUE(owner,title));
            CREATE TABLE IF NOT EXISTS audit(id INTEGER PRIMARY KEY, actor TEXT NOT NULL,
              action TEXT NOT NULL, object TEXT NOT NULL, detail TEXT NOT NULL, at REAL NOT NULL);
            CREATE TABLE IF NOT EXISTS login_attempts(identity TEXT NOT NULL, at REAL NOT NULL);
            ''')
            if c.execute('SELECT COUNT(*) FROM users').fetchone()[0] == 0:
                password = os.getenv('PLATFORM_ADMIN_PASSWORD') or secrets.token_urlsafe(18)
                if len(password) < 12:
                    raise ValueError('PLATFORM_ADMIN_PASSWORD must contain at least 12 characters')
                c.execute('INSERT INTO users(username,display_name,role,password_hash,created_at) VALUES (?,?,?,?,?)',
                          ('admin','系统管理员','admin',password_hash(password),time.time()))
                if not os.getenv('PLATFORM_ADMIN_PASSWORD'):
                    secret = self.path.parent/'initial-admin.txt'
                    secret.write_text(f'username=admin\npassword={password}\n',encoding='utf-8')

    @contextmanager
    def connect(self):
        c=sqlite3.connect(self.path, timeout=15)
        c.row_factory=sqlite3.Row
        c.execute('PRAGMA foreign_keys=ON')
        try:
            with c:
                yield c
        finally:
            c.close()

    def event(self, actor, action, obj='', detail=''):
        """同步接口，供同步路由直接调用。"""
        with self.connect() as c:
            c.execute('INSERT INTO audit(actor,action,object,detail,at) VALUES (?,?,?,?,?)',
                      (actor,action,str(obj),detail,time.time()))

    async def event_async(self, actor, action, obj='', detail=''):
        return await asyncio.to_thread(self.event, actor, action, obj, detail)

    def save_question(self, record):
        """同步版本，供初始化/迁移等场景。"""
        record.updated_at=utc_now()
        with self.connect() as c:
            c.execute('INSERT INTO questions VALUES (?,?,?,?,?) ON CONFLICT(id) DO UPDATE SET status=excluded.status,body=excluded.body',
                      (record.id,record.requested_by,str(record.status),record.model_dump_json(),record.created_at.isoformat()))
        return record.model_copy(deep=True)

    def get_question(self, key):
        """同步版本。"""
        with self.connect() as c:
            row=c.execute('SELECT body FROM questions WHERE id=?',(key,)).fetchone()
        return QuestionRecord.model_validate_json(row['body']) if row else None

    async def save(self, record):
        return await asyncio.to_thread(self.save_question, record)

    async def get(self, key):
        return await asyncio.to_thread(self.get_question, key)

    async def list(self):
        def _list():
            with self.connect() as c:
                rows=c.execute('SELECT body FROM questions ORDER BY created_at DESC LIMIT 1000').fetchall()
            return [QuestionRecord.model_validate_json(row['body']) for row in rows]
        return await asyncio.to_thread(_list)

    def session(self, token):
        """同步接口，供 auth dependency 和同步路由。"""
        with self.connect() as c:
            row=c.execute('SELECT u.id,u.username,u.display_name,u.role,s.csrf FROM sessions s JOIN users u ON u.id=s.user_id WHERE s.token=? AND s.expires>? AND u.active=1',
                          (token_hash(token),time.time())).fetchone()
        return dict(row) if row else None

    # ------------------------------------------------------------------
    # 登录事务：单一 connection 内完成失败锁 + 鉴权 + session 写入，
    # 避免两次 connect 带来的 race，也让 async 路由可以整体丢进 to_thread。
    # ------------------------------------------------------------------
    def login_sync(self, identity: str, username: str, password: str) -> tuple[str, str, dict]:
        """返回 (token, csrf, user_dict)。失败时抛 LoginBlockedError / LoginFailedError。

        attempts 计数和鉴权+session 写入是两个独立事务：attempts 先落地，
        鉴权失败时只回滚 session 写入，不会丢失 attempts 记录。
        """
        now = time.time()

        # 事务 1：attempts 计数 —— 无论后续鉴权是否成功，这里的写入都要落地
        with self.connect() as c:
            c.execute('DELETE FROM login_attempts WHERE at<?', (now - 900,))
            count = c.execute('SELECT COUNT(*) FROM login_attempts WHERE identity=?', (identity,)).fetchone()[0]
            if count >= 5:
                raise LoginBlockedError('登录失败次数过多，请15分钟后重试')
            c.execute('INSERT INTO login_attempts VALUES (?,?)', (identity, now))

        # 事务 2：鉴权 + session
        with self.connect() as c:
            user = c.execute('SELECT * FROM users WHERE username=?', (username,)).fetchone()
            stored = user['password_hash'] if user else '00' * 16 + ':' + '00' * 64
            valid = password_matches(password, stored)

            if not user or not valid or not user['active']:
                raise LoginFailedError('用户名或密码错误')

            c.execute('DELETE FROM sessions WHERE expires<?', (now,))
            c.execute('DELETE FROM login_attempts WHERE identity=?', (identity,))

            token = secrets.token_urlsafe(32)
            csrf = secrets.token_urlsafe(24)
            c.execute('INSERT INTO sessions VALUES (?,?,?,?)', (token_hash(token), user['id'], csrf, now + 28800))

            user_dict = {k: user[k] for k in ('id', 'username', 'display_name', 'role')}
            return token, csrf, user_dict
