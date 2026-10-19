# PostGIS Cheat Sheet - Windows PowerShell Helper
param(
    [Parameter(Position=0)]
    [string]$Command = "help"
)

function Show-Help {
    Write-Host "PostGIS Cheat Sheet - PowerShell Commands:" -ForegroundColor Cyan
    Write-Host "  .\run.ps1 up          - Start PostGIS, pg_tileserv, and pgAdmin containers"
    Write-Host "  .\run.ps1 down        - Stop and delete database volumes"
    Write-Host "  .\run.ps1 demo        - Run guided demonstration in container"
    Write-Host "  .\run.ps1 test        - Run Python test runner for all 25 queries"
    Write-Host "  .\run.ps1 psql        - Open psql shell inside the database container"
    Write-Host "  .\run.ps1 tiles       - Open pg_tileserv web preview (http://localhost:7800)"
    Write-Host "  .\run.ps1 pgadmin     - Open pgAdmin web interface (http://localhost:5050)"
    Write-Host "  .\run.ps1 cheatsheet  - Rebuild CHEATSHEET.md and README.md query tables"
    Write-Host "  .\run.ps1 data        - Regenerate sql/02_sample_data.sql"
}

switch ($Command.ToLower()) {
    "up" {
        Write-Host "Starting Docker containers..." -ForegroundColor Green
        docker compose up -d --wait
        Write-Host "Services ready:" -ForegroundColor Green
        Write-Host "  PostGIS Database: localhost:5433"
        Write-Host "  Vector Tile Server: http://localhost:7800/"
        Write-Host "  pgAdmin Web UI:     http://localhost:5050/ (admin@gis.local / admin)"
    }
    "down" {
        Write-Host "Stopping and cleaning volumes..." -ForegroundColor Yellow
        docker compose down -v
    }
    "demo" {
        Write-Host "Running demo..." -ForegroundColor Green
        docker compose exec -T db psql -U postgres -d gis -v ON_ERROR_STOP=1 -f - < scripts/demo.sql
    }
    "test" {
        Write-Host "Running test suite..." -ForegroundColor Green
        python scripts/run_tests.py
    }
    "psql" {
        docker compose exec -it db psql -U postgres -d gis
    }
    "tiles" {
        Start-Process "http://localhost:7800/"
    }
    "pgadmin" {
        Start-Process "http://localhost:5050/"
    }
    "cheatsheet" {
        python scripts/build_cheatsheet.py
    }
    "data" {
        python -c "import subprocess, pathlib; res = subprocess.check_output(['python', 'scripts/generate_sample_data.py'], encoding='utf-8'); pathlib.Path('sql/02_sample_data.sql').write_text(res, encoding='utf-8', newline='\n')"
        Write-Host "sql/02_sample_data.sql regenerated successfully." -ForegroundColor Green
    }
    default {
        Show-Help
    }
}
