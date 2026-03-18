#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ENV_FILE="$PROJECT_ROOT/.env"

if [ ! -f "$PROJECT_ROOT/docker-compose.yml" ]; then
  echo "[ERROR] docker-compose.yml が見つかりません: $PROJECT_ROOT/docker-compose.yml" >&2
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo '[ERROR] docker コマンドが見つかりません。Docker Engine / Docker Compose を導入してください。' >&2
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo '[ERROR] Docker Engine に接続できません。docker サービス状態を確認してください。' >&2
  exit 1
fi

APP_PORT='8080'
if [ -f "$ENV_FILE" ]; then
  raw="$(awk -F= '/^APP_PORT=/{print $2}' "$ENV_FILE" | tail -n 1 || true)"
  raw="${raw//[[:space:]]/}"
  raw="${raw//\"/}"
  raw="${raw//\'/}"
  if [ -n "$raw" ]; then
    APP_PORT="$raw"
  fi
fi

echo '[INFO] LibreBooking コンテナを起動します...'
cd "$PROJECT_ROOT"
docker compose up -d --build
echo '[OK] 起動しました。'
echo "[INFO] アクセスURL: http://localhost:${APP_PORT}/Web/"
