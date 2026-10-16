.PHONY: up down psql test demo cheatsheet data

up:          ## start PostGIS and load the sample data
	docker compose up -d --wait

down:        ## stop and delete the database volume
	docker compose down -v

psql:        ## open a psql shell
	PGPASSWORD=postgres psql -h localhost -p 5433 -U postgres -d gis

test:        ## run all 20 queries and check row counts
	./scripts/run_tests.sh

demo: up    ## run a guided demonstration against the sample database
	docker compose exec -T db psql -U postgres -d gis -v ON_ERROR_STOP=1 -f - < scripts/demo.sql

cheatsheet:  ## rebuild CHEATSHEET.md and the README query table
	python3 scripts/build_cheatsheet.py

data:        ## regenerate sql/02_sample_data.sql (deterministic)
	python3 scripts/generate_sample_data.py > sql/02_sample_data.sql
