@echo off
setlocal enableextensions

set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..\..") do set "PROJECT_ROOT=%%~fI"
set "COMPOSE_FILE=%PROJECT_ROOT%\docker-compose.yml"
set "ENV_FILE=%PROJECT_ROOT%\.env"
set "DOCKER_EXE=docker"
set "APP_PORT=8080"

if exist "%ProgramFiles%\Docker\Docker\resources\bin\docker.exe" (
  set "DOCKER_EXE=%ProgramFiles%\Docker\Docker\resources\bin\docker.exe"
)

if not exist "%COMPOSE_FILE%" (
  echo [ERROR] docker-compose.yml が見つかりません: "%COMPOSE_FILE%"
  exit /b 1
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

if exist "%ENV_FILE%" (
  for /f "tokens=1,* delims==" %%A in ('findstr /b /i "APP_PORT=" "%ENV_FILE%"') do (
    set "APP_PORT=%%B"
  )
)
set "APP_PORT=%APP_PORT: =%"
set "APP_PORT=%APP_PORT:'=%"
set "APP_PORT=%APP_PORT:"=%"
if "%APP_PORT%"=="" set "APP_PORT=8080"

echo [INFO] Docker Compose 状態
pushd "%PROJECT_ROOT%" >nul
"%DOCKER_EXE%" compose ps
set "PS_RC=%ERRORLEVEL%"
popd >nul
if not "%PS_RC%"=="0" (
  echo [WARN] docker compose ps に失敗しました。
)

echo [INFO] アクセスURL: http://localhost:%APP_PORT%/Web/
echo [INFO] 疎通確認: ブラウザで上記URLを開いて確認してください。
exit /b 0
