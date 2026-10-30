"""Fail on obvious credentials/private artifacts in the Git index, without printing secrets.

This lightweight guard supplements review; it is not a complete secret detector.
Run from the repository root after git add.
"""
from pathlib import Path
import re
import subprocess
import sys

PATTERNS = {
    'private-key': re.compile(rb'-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----'),
    'github-token': re.compile(rb'(?:gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{40,})'),
    'openai-token': re.compile(rb'sk-(?:proj-|svcacct-)[A-Za-z0-9_-]{35,}'),
    'aws-access-key': re.compile(rb'(?:AKIA|ASIA)[A-Z0-9]{16}'),
    'credential-url': re.compile(rb'https?://[^\s/:]+:[^\s/@]{8,}@'),
}

def main():
    result=subprocess.run(['git','ls-files','--cached','-z'],capture_output=True,check=True)
    paths=[p.decode('utf-8') for p in result.stdout.split(b'\0') if p]
    if not paths: raise SystemExit('No staged/tracked files: run git add before scanning.')
    requests=('\n'.join(':'+name for name in paths)+'\n').encode()
    batch=subprocess.run(['git','cat-file','--batch'],input=requests,capture_output=True,check=True).stdout
    offset=0
    findings=[]
    for name in paths:
        path=Path(name)
        public_env=name.startswith('frontend-vben/apps/web-business/.env')
        if '.runtime' in path.parts or 'node_modules' in path.parts or path.name=='initial-admin.txt' or (path.name=='.env' and not public_env) or path.suffix in {'.sqlite3','.pem','.p12','.pfx'}:
            findings.append((name,'private-artifact'))
        end=batch.index(b'\n',offset)
        size=int(batch[offset:end].split()[-1])
        content=batch[end+1:end+1+size]
        offset=end+size+2
        for label,pattern in PATTERNS.items():
            if pattern.search(content): findings.append((name,label))
    for name,label in findings: print(f'{name}: {label} [value redacted]')
    print(f'Scanned {len(paths)} indexed files; findings={len(findings)}')
    return 1 if findings else 0

if __name__=='__main__':sys.exit(main())
