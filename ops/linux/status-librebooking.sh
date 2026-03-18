#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ENV_FILE="$PROJECT_ROOT/.env"
APP_PORT='8080'

if ! command -v docker >/dev/null 2>&1; then
  echo '[ERROR] docker コマンドが見つかりません。' >&2
  exit 1
fi

if [ -f "$ENV_FILE" ]; then
  raw="$(awk -F= '/^APP_PORT=/{print $2}' "$ENV_FILE" | tail -n 1 || true)"
  raw="${raw//[[:space:]]/}"
  raw="${raw//\"/}"
  raw="${raw//\'/}"
  if [ -n "$raw" ]; then
    APP_PORT="$raw"
  fi
fi

echo '[INFO] Docker Compose 状態'
cd "$PROJECT_ROOT"
docker compose ps || echo '[WARN] docker compose ps に失敗しました。'
echo "[INFO] アクセスURL: http://localhost:${APP_PORT}/Web/"
