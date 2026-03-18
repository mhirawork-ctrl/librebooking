#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ENV_FILE="$PROJECT_ROOT/.env"
DOCKER_BIN=""

resolve_docker_bin() {
  if command -v docker >/dev/null 2>&1; then
    DOCKER_BIN="$(command -v docker)"
    return
  fi

  if [ -x "/Applications/Docker.app/Contents/Resources/bin/docker" ]; then
    DOCKER_BIN="/Applications/Docker.app/Contents/Resources/bin/docker"
    return
  fi

  if [ -x "$HOME/Applications/Docker.app/Contents/Resources/bin/docker" ]; then
    DOCKER_BIN="$HOME/Applications/Docker.app/Contents/Resources/bin/docker"
    return
  fi
}

resolve_app_port() {
  local port='8080'
  if [ -f "$ENV_FILE" ]; then
    local raw
    raw="$(awk -F= '/^APP_PORT=/{print $2}' "$ENV_FILE" | tail -n 1 || true)"
    raw="${raw//[[:space:]]/}"
    raw="${raw//\"/}"
    raw="${raw//\'/}"
    if [ -n "$raw" ]; then
      port="$raw"
    fi
  fi
  printf '%s' "$port"
}

wait_for_docker_engine() {
  if "$DOCKER_BIN" info >/dev/null 2>&1; then
    return 0
  fi

  echo '[INFO] Docker Desktop を起動します...'
  open -ga Docker >/dev/null 2>&1 || true

  echo '[INFO] Docker エンジン起動待ち...'
  for _ in $(seq 1 60); do
    if "$DOCKER_BIN" info >/dev/null 2>&1; then
      return 0
    fi
    sleep 2
  done

  echo '[ERROR] Docker エンジンが起動しませんでした。Docker Desktop の状態を確認してください。' >&2
  return 1
}

if [ ! -f "$PROJECT_ROOT/docker-compose.yml" ]; then
  echo "[ERROR] docker-compose.yml が見つかりません: $PROJECT_ROOT/docker-compose.yml" >&2
  exit 1
fi

resolve_docker_bin
if [ -z "$DOCKER_BIN" ]; then
  echo '[ERROR] docker コマンドが見つかりません。Docker Desktop をインストールしてください。' >&2
  exit 1
fi

wait_for_docker_engine

echo '[INFO] LibreBooking コンテナを起動します...'
cd "$PROJECT_ROOT"
"$DOCKER_BIN" compose up -d --build

APP_PORT="$(resolve_app_port)"
echo '[OK] 起動しました。'
echo "[INFO] アクセスURL: http://localhost:${APP_PORT}/Web/"
