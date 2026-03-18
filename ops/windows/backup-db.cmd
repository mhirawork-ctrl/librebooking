@echo off
setlocal enableextensions enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..\..") do set "PROJECT_ROOT=%%~fI"
set "COMPOSE_FILE=%PROJECT_ROOT%\docker-compose.yml"
set "DOCKER_EXE=docker"
set "OUTPUT_DIR=%PROJECT_ROOT%\output\backups"

if "%~1"=="" (
  for /f %%I in ('powershell -NoProfile -Command "(Get-Date).ToString(\"yyyyMMdd-HHmmss\")"') do set "TS=%%I"
  set "OUT_FILE=%OUTPUT_DIR%\db-!TS!.sql"
) else (
  set "OUT_FILE=%~f1"
)

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

for %%I in ("%OUT_FILE%") do set "OUT_DIR=%%~dpI"
if not exist "%OUT_DIR%" (
  mkdir "%OUT_DIR%"
  if errorlevel 1 (
    echo [ERROR] 出力ディレクトリの作成に失敗しました: "%OUT_DIR%"
    exit /b 1
  )
)

echo [INFO] DBコンテナを起動確認します...
pushd "%PROJECT_ROOT%" >nul
"%DOCKER_EXE%" compose up -d db >nul
if errorlevel 1 (
  popd >nul
  echo [ERROR] db コンテナの起動に失敗しました。
  exit /b 1
)

echo [INFO] DBバックアップを取得します: "%OUT_FILE%"
"%DOCKER_EXE%" compose exec -T db sh -lc "mariadb-dump --single-transaction --routines --triggers --events -uroot -p\"$MARIADB_ROOT_PASSWORD\" \"$MARIADB_DATABASE\"" > "%OUT_FILE%"
set "RC=%ERRORLEVEL%"
popd >nul

if not "%RC%"=="0" (
  echo [ERROR] DBバックアップに失敗しました。
  exit /b %RC%
)

for %%I in ("%OUT_FILE%") do set "OUT_SIZE=%%~zI"
if not defined OUT_SIZE (
  echo [ERROR] バックアップファイルサイズを確認できませんでした。
  exit /b 1
)
if "%OUT_SIZE%"=="0" (
  echo [ERROR] バックアップファイルが空です: "%OUT_FILE%"
  exit /b 1
)

echo [OK] DBバックアップが完了しました: "%OUT_FILE%"
exit /b 0
