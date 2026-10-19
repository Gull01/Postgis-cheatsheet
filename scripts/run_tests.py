#!/usr/bin/env python3
"""Cross-platform test runner for PostGIS spatial queries.
Runs every queries/*.sql and validates row counts against '-- expect_rows: N'.

Works on Windows, macOS, and Linux. Automatically falls back to docker compose
if psql is not installed on the host machine.
"""
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

DATABASE_URL = os.environ.get("DATABASE_URL")
PGHOST = os.environ.get("PGHOST", "localhost")
PGPORT = os.environ.get("PGPORT", "5433")
PGUSER = os.environ.get("PGUSER", "postgres")
PGPASSWORD = os.environ.get("PGPASSWORD", "postgres")
PGDATABASE = os.environ.get("PGDATABASE", "gis")


def find_psql() -> str | None:
    p = shutil.which("psql")
    if p:
        return p
    # Search common Windows PostgreSQL paths
    for cand in sorted(Path(r"C:\Program Files\PostgreSQL").glob("*/bin/psql.exe"), reverse=True):
        if cand.exists():
            return str(cand)
    return None


def execute_sql_count(sql_body: str) -> str:
    count_query = f"SELECT count(*) FROM ({sql_body}) q;"
    psql_bin = find_psql()

    if psql_bin:
        env = os.environ.copy()
        if PGPASSWORD:
            env["PGPASSWORD"] = PGPASSWORD
        if DATABASE_URL:
            cmd = [
                psql_bin,
                "-d", DATABASE_URL,
                "-X", "-At",
                "-v", "ON_ERROR_STOP=1",
                "-c", count_query,
            ]
        else:
            cmd = [
                psql_bin,
                "-h", PGHOST,
                "-p", PGPORT,
                "-U", PGUSER,
                "-d", PGDATABASE,
                "-X", "-At",
                "-v", "ON_ERROR_STOP=1",
                "-c", count_query,
            ]
        res = subprocess.run(cmd, env=env, capture_output=True, text=True)
        if res.returncode != 0:
            raise RuntimeError(res.stderr.strip() or res.stdout.strip())
        return res.stdout.strip()
    else:
        # Fallback to docker compose
        cmd = [
            "docker", "compose", "exec", "-T", "db",
            "psql", "-U", "postgres", "-d", "gis",
            "-X", "-At", "-v", "ON_ERROR_STOP=1",
            "-c", count_query,
        ]
        res = subprocess.run(cmd, cwd=ROOT, capture_output=True, text=True)
        if res.returncode != 0:
            raise RuntimeError(res.stderr.strip() or res.stdout.strip())
        return res.stdout.strip()


def main():
    query_files = sorted((ROOT / "queries").glob("*.sql"))
    if not query_files:
        print("No query files found in queries/")
        sys.exit(1)

    print(f"Running {len(query_files)} PostGIS spatial queries against {PGDATABASE} on port {PGPORT}...\n")
    passed = 0
    failed = 0

    for qfile in query_files:
        content = qfile.read_text(encoding="utf-8")
        expect_match = re.search(r"^--\s*expect_rows:\s*(\d+)", content, re.MULTILINE)
        if not expect_match:
            print(f"SKIP  {qfile.name:<40} (missing '-- expect_rows: N' header)")
            continue

        expected = expect_match.group(1).strip()
        lines = [line for line in content.splitlines() if not line.strip().startswith("--")]
        body = "\n".join(lines).strip().rstrip(";")

        try:
            actual = execute_sql_count(body)
            if actual == expected:
                print(f"PASS  {qfile.name:<40} {actual} rows")
                passed += 1
            else:
                print(f"FAIL  {qfile.name:<40} expected {expected}, got {actual}")
                failed += 1
        except Exception as e:
            print(f"FAIL  {qfile.name:<40} error: {e}")
            failed += 1

    print("\n" + "-" * 55)
    print(f"{passed} passed, {failed} failed out of {len(query_files)} queries")
    sys.exit(0 if failed == 0 else 1)


if __name__ == "__main__":
    main()
