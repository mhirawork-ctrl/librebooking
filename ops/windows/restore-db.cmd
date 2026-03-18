@echo off
setlocal enableextensions enabledelayedexpansion

if "%~1"=="" goto :usage

set "SQL_FILE=%~f1"
set "ASSUME_YES=%~2"

if not exist "%SQL_FILE%" (
  echo [ERROR] SQLファイルが見つかりません: "%SQL_FILE%"
  exit /b 1
)

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

if /I not "%ASSUME_YES%"=="--yes" (
  echo [WARN] この操作は現在のDBを上書きします。
  set /p CONFIRM="続行する場合は YES と入力してください: "
  if /I not "!CONFIRM!"=="YES" (
    echo [INFO] キャンセルしました。
    exit /b 1
  )
)

echo [INFO] DBリストアを開始します: "%SQL_FILE%"
pushd "%PROJECT_ROOT%" >nul

"%DOCKER_EXE%" compose up -d db >nul
if errorlevel 1 (
  popd >nul
  echo [ERROR] db コンテナの起動に失敗しました。
  exit /b 1
)

"%DOCKER_EXE%" compose stop app >nul 2>&1

echo [INFO] 既存DBを初期化します...
"%DOCKER_EXE%" compose exec -T db sh -lc "mariadb -uroot -p\"$MARIADB_ROOT_PASSWORD\" -e \"DROP DATABASE IF EXISTS $MARIADB_DATABASE; CREATE DATABASE $MARIADB_DATABASE CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;\""
if errorlevel 1 (
  popd >nul
  echo [ERROR] DB初期化に失敗しました。
  exit /b 1
)

echo [INFO] SQLをインポートします...
"%DOCKER_EXE%" compose exec -T db sh -lc "mariadb -uroot -p\"$MARIADB_ROOT_PASSWORD\" \"$MARIADB_DATABASE\"" < "%SQL_FILE%"
set "IMPORT_RC=%ERRORLEVEL%"
if not "%IMPORT_RC%"=="0" (
  popd >nul
  echo [ERROR] SQLインポートに失敗しました。
  exit /b %IMPORT_RC%
)

echo [INFO] app コンテナを起動します...
"%DOCKER_EXE%" compose up -d app >nul
set "APP_RC=%ERRORLEVEL%"
popd >nul

if not "%APP_RC%"=="0" (
  echo [WARN] app コンテナの起動に失敗しました。status-librebooking.cmd で状態確認してください。
  exit /b %APP_RC%
)

echo [OK] DBリストアが完了しました。
echo [INFO] 状態確認: ops\windows\status-librebooking.cmd
exit /b 0

:usage
echo Usage: %~nx0 ^<backup-sql-path^> [--yes]
exit /b 1
