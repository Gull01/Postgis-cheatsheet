#!/usr/bin/env bash
# Runs every queries/*.sql file and checks it executes and returns the row count
# declared in its "-- expect_rows: N" header.
#
# Connection comes from the standard libpq variables. Defaults match docker-compose.yml.
set -euo pipefail

export PGHOST="${PGHOST:-localhost}"
export PGPORT="${PGPORT:-5433}"
export PGUSER="${PGUSER:-postgres}"
export PGPASSWORD="${PGPASSWORD:-postgres}"
export PGDATABASE="${PGDATABASE:-gis}"

cd "$(dirname "$0")/.."
pass=0; fail=0

for f in queries/*.sql; do
    expected=$(sed -n 's/^-- expect_rows: *//p' "$f" | head -n1)
    # Strip the trailing semicolon so the query can be wrapped in a subselect.
    body=$(perl -0pe 's/;\s*\z//' "$f")
    if actual=$(psql -X -At -v ON_ERROR_STOP=1 -c "SELECT count(*) FROM (${body}) q" 2>&1); then
        if [[ "$actual" == "$expected" ]]; then
            printf 'PASS  %-40s %s rows\n' "$(basename "$f")" "$actual"; pass=$((pass+1))
        else
            printf 'FAIL  %-40s expected %s, got %s\n' "$(basename "$f")" "$expected" "$actual"; fail=$((fail+1))
        fi
    else
        printf 'FAIL  %-40s error: %s\n' "$(basename "$f")" "$actual"; fail=$((fail+1))
    fi
done

echo "----"
echo "$pass passed, $fail failed"
[[ $fail -eq 0 ]]
