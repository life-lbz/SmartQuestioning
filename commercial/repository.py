"""SQLite platform metadata; business MySQL remains read-only."""
from __future__ import annotations
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
        with self.connect() as c:
            c.execute('INSERT INTO audit(actor,action,object,detail,at) VALUES (?,?,?,?,?)',
                      (actor,action,str(obj),detail,time.time()))

    def save_question(self, record):
        record.updated_at=utc_now()
        with self.connect() as c:
            c.execute('INSERT INTO questions VALUES (?,?,?,?,?) ON CONFLICT(id) DO UPDATE SET status=excluded.status,body=excluded.body',
                      (record.id,record.requested_by,str(record.status),record.model_dump_json(),record.created_at.isoformat()))
        return record.model_copy(deep=True)

    def get_question(self, key):
        with self.connect() as c:
            row=c.execute('SELECT body FROM questions WHERE id=?',(key,)).fetchone()
        return QuestionRecord.model_validate_json(row['body']) if row else None

    async def save(self, record):
        return self.save_question(record)

    async def get(self, key):
        return self.get_question(key)

    async def list(self):
        with self.connect() as c:
            rows=c.execute('SELECT body FROM questions ORDER BY created_at DESC LIMIT 1000').fetchall()
        return [QuestionRecord.model_validate_json(row['body']) for row in rows]

    def session(self, token):
        with self.connect() as c:
            row=c.execute('SELECT u.id,u.username,u.display_name,u.role,s.csrf FROM sessions s JOIN users u ON u.id=s.user_id WHERE s.token=? AND s.expires>? AND u.active=1',
                          (token_hash(token),time.time())).fetchone()
        return dict(row) if row else None
