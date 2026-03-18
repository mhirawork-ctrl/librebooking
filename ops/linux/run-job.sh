#!/usr/bin/env bash

set -euo pipefail

if [ "${1-}" = '' ]; then
  echo 'Usage: run-job.sh <jobfile>' >&2
  exit 1
fi

JOB_NAME="$1"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

case "$JOB_NAME" in
  autorelease.php|sendreminders.php|sendmissedcheckin.php|sendwaitlist.php|sendseriesend.php|sessioncleanup.php|deleteolddata.php)
    ;;
  *)
    echo "[ERROR] 指定ジョブは許可されていません: $JOB_NAME" >&2
    exit 1
    ;;
esac

if ! command -v docker >/dev/null 2>&1; then
  echo '[ERROR] docker コマンドが見つかりません。' >&2
  exit 1
fi

echo "[INFO] 実行ジョブ: $JOB_NAME"
cd "$PROJECT_ROOT"
docker compose exec -T app php -f "/var/www/html/Jobs/$JOB_NAME"
echo "[OK] ジョブ実行完了: $JOB_NAME"
