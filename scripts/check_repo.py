"""Repository rules: nothing private or internal is tracked by git. Run from the repo root: python3 scripts/check_repo.py"""
import re
import subprocess
import sys

FORBIDDEN_PATHS = [r"^reference/", r"^report/", r"\.pem$", r"(^|/)\.env($|\.)", r"(^|/)target/", r"(^|/)logs/", r"(^|/)dbt_packages/"]
SECRET_PATTERNS = {
    "private key": r"-----BEGIN [A-Z ]*PRIVATE KEY-----",
    "AWS access key": r"AKIA[0-9A-Z]{16}",
    "GitHub token": r"gh[pousr]_[A-Za-z0-9]{30,}",
    "Azure storage key": r"AccountKey=[A-Za-z0-9+/=]{40,}",
}

files = subprocess.run(["git", "ls-files"], capture_output=True, text=True, check=True).stdout.split("\n")
errors = []
for f in filter(None, files):
    for pattern in FORBIDDEN_PATHS:
        if re.search(pattern, f):
            errors.append(f"{f}: must not be tracked (matches {pattern})")
    try:
        text = open(f, encoding="utf-8").read()
    except (UnicodeDecodeError, FileNotFoundError, IsADirectoryError):
        continue
    for name, pattern in SECRET_PATTERNS.items():
        if re.search(pattern, text):
            errors.append(f"{f}: looks like a {name}")

if errors:
    print("\n".join(errors))
    sys.exit(1)
print(f"OK: {len(files) - 1} tracked files checked")
