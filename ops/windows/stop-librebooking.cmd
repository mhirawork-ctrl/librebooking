@echo off
setlocal enableextensions

set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..\..") do set "PROJECT_ROOT=%%~fI"
set "COMPOSE_FILE=%PROJECT_ROOT%\docker-compose.yml"
set "DOCKER_EXE=docker"

if not exist "%COMPOSE_FILE%" (
  echo [ERROR] docker-compose.yml が見つかりません: "%COMPOSE_FILE%"
  exit /b 1
)

if exist "%ProgramFiles%\Docker\Docker\resources\bin\docker.exe" (
  set "DOCKER_EXE=%ProgramFiles%\Docker\Docker\resources\bin\docker.exe"
)

if /I "%DOCKER_EXE%"=="docker" (
  where docker >nul 2>&1
  if errorlevel 1 (
    echo [ERROR] docker コマンドが見つかりません。
    exit /b 1
  )
) else (
  if not exist "%DOCKER_EXE%" (
    echo [ERROR] docker 実行ファイルが見つかりません: "%DOCKER_EXE%"
    exit /b 1
  )
)

echo [INFO] LibreBooking コンテナを停止します...
pushd "%PROJECT_ROOT%" >nul
"%DOCKER_EXE%" compose stop
set "RC=%ERRORLEVEL%"
popd >nul

if not "%RC%"=="0" (
  echo [ERROR] docker compose stop に失敗しました。
  exit /b %RC%
)

echo [OK] 停止しました。
exit /b 0
