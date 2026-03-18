@echo off
setlocal enableextensions

if "%~1"=="" goto :usage

set "JOB_NAME=%~1"
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

call :validate_job "%JOB_NAME%"
if errorlevel 1 (
  echo [ERROR] 指定ジョブは許可されていません: %JOB_NAME%
  goto :usage
)

echo [INFO] 実行ジョブ: %JOB_NAME%
pushd "%PROJECT_ROOT%" >nul
"%DOCKER_EXE%" compose exec -T app php -f "/var/www/html/Jobs/%JOB_NAME%"
set "RC=%ERRORLEVEL%"
popd >nul

if not "%RC%"=="0" (
  echo [ERROR] ジョブ実行に失敗しました: %JOB_NAME%
  exit /b %RC%
)

echo [OK] ジョブ実行完了: %JOB_NAME%
exit /b 0

:validate_job
set "TARGET=%~1"
for %%J in (
  autorelease.php
  sendreminders.php
  sendmissedcheckin.php
  sendwaitlist.php
  sendseriesend.php
  sessioncleanup.php
  deleteolddata.php
) do (
  if /I "%TARGET%"=="%%~J" exit /b 0
)
exit /b 1

:usage
echo Usage: %~nx0 ^<jobfile^>
echo Allowed: autorelease.php, sendreminders.php, sendmissedcheckin.php, sendwaitlist.php, sendseriesend.php, sessioncleanup.php, deleteolddata.php
exit /b 1
