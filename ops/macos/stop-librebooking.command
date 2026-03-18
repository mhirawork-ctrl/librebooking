#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [ ! -f "$PROJECT_ROOT/docker-compose.yml" ]; then
  echo "[ERROR] docker-compose.yml が見つかりません: $PROJECT_ROOT/docker-compose.yml" >&2
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  if [ -x "/Applications/Docker.app/Contents/Resources/bin/docker" ]; then
    export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"
  elif [ -x "$HOME/Applications/Docker.app/Contents/Resources/bin/docker" ]; then
    export PATH="$HOME/Applications/Docker.app/Contents/Resources/bin:$PATH"
  fi
fi

if ! command -v docker >/dev/null 2>&1; then
  echo '[ERROR] docker コマンドが見つかりません。' >&2
  exit 1
fi

echo '[INFO] LibreBooking コンテナを停止します...'
cd "$PROJECT_ROOT"
docker compose stop
echo '[OK] 停止しました。'
