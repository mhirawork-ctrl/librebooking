@echo off
setlocal enableextensions enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..\..") do set "PROJECT_ROOT=%%~fI"
set "COMPOSE_FILE=%PROJECT_ROOT%\docker-compose.yml"
set "ENV_FILE=%PROJECT_ROOT%\.env"
set "DOCKER_EXE=docker"
set "DOCKER_DESKTOP=%ProgramFiles%\Docker\Docker\Docker Desktop.exe"

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
    echo [ERROR] docker コマンドが見つかりません。Docker Desktop をインストールしてください。
    exit /b 1
  )
) else (
  if not exist "%DOCKER_EXE%" (
    echo [ERROR] docker 実行ファイルが見つかりません: "%DOCKER_EXE%"
    exit /b 1
  )
)

call :wait_for_docker
if errorlevel 1 exit /b 1

echo [INFO] LibreBooking コンテナを起動します...
pushd "%PROJECT_ROOT%" >nul
"%DOCKER_EXE%" compose up -d --build
if errorlevel 1 (
  popd >nul
  echo [ERROR] docker compose up に失敗しました。
  exit /b 1
)
popd >nul

call :resolve_app_port
echo [OK] 起動しました。
echo [INFO] アクセスURL: http://localhost:%APP_PORT%/Web/
exit /b 0

:wait_for_docker
"%DOCKER_EXE%" info >nul 2>&1
if not errorlevel 1 goto :eof

echo [INFO] Docker Desktop を起動します...
if exist "%DOCKER_DESKTOP%" (
  start "" "%DOCKER_DESKTOP%" >nul 2>&1
)

echo [INFO] Docker エンジン起動待ち...
for /l %%N in (1,1,60) do (
  "%DOCKER_EXE%" info >nul 2>&1
  if not errorlevel 1 goto :eof
  timeout /t 2 /nobreak >nul
)

echo [ERROR] Docker エンジンが起動しませんでした。Docker Desktop の状態を確認してください。
exit /b 1

:resolve_app_port
set "APP_PORT=8080"
if not exist "%ENV_FILE%" goto :eof
for /f "tokens=1,* delims==" %%A in ('findstr /b /i "APP_PORT=" "%ENV_FILE%"') do (
  set "VAL=%%B"
)
if not defined VAL goto :eof
set "VAL=%VAL: =%"
set "VAL=%VAL:'=%"
set "VAL=%VAL:"=%"
if "%VAL%"=="" goto :eof
set "APP_PORT=%VAL%"
goto :eof
