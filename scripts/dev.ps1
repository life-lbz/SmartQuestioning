$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot

Write-Host 'Start these in two terminals:'
Write-Host "  Backend: cd '$projectRoot'; uv run uvicorn backend.app.main:app --reload"
Write-Host "  Frontend: cd '$projectRoot\frontend'; npm run dev"
