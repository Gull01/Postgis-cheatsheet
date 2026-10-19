.PHONY: up down psql test test-py demo cheatsheet data tiles pgadmin

up:          ## start PostGIS, pg_tileserv, and pgAdmin services
	docker compose up -d --wait

down:        ## stop and delete the database volume
	docker compose down -v

psql:        ## open a psql shell
	PGPASSWORD=postgres psql -h localhost -p 5433 -U postgres -d gis

test:        ## run all 25 queries and check row counts (bash)
	./scripts/run_tests.sh

test-py:     ## run all 25 queries cross-platform (python)
	python3 scripts/run_tests.py

demo: up     ## run a guided demonstration against the sample database
	docker compose exec -T db psql -U postgres -d gis -v ON_ERROR_STOP=1 -f - < scripts/demo.sql

tiles:       ## print pg_tileserv web map preview URL
	@echo "Vector Tile Server running at http://localhost:7800/"

pgadmin:     ## print pgAdmin web interface URL
	@echo "pgAdmin running at http://localhost:5050/ (User: admin@gis.local, Pass: admin)"

cheatsheet:  ## rebuild CHEATSHEET.md and the README query table
	python3 scripts/build_cheatsheet.py

data:        ## regenerate sql/02_sample_data.sql (deterministic)
	python3 -c "import subprocess, pathlib; res = subprocess.check_output(['python3', 'scripts/generate_sample_data.py'], encoding='utf-8'); pathlib.Path('sql/02_sample_data.sql').write_text(res, encoding='utf-8', newline='\n')"
