#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v docker >/dev/null 2>&1; then
  if [ -x "$HOME/Applications/Docker.app/Contents/Resources/bin/docker" ]; then
    export PATH="$HOME/Applications/Docker.app/Contents/Resources/bin:$PATH"
  elif [ -x "/Applications/Docker.app/Contents/Resources/bin/docker" ]; then
    export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"
  fi
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "docker コマンドが見つかりません。Docker Desktop をインストールしてから再実行してください。" >&2
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  if [ -d "$HOME/Applications/Docker.app" ]; then
    open -ga "$HOME/Applications/Docker.app"
  elif [ -d "/Applications/Docker.app" ]; then
    open -ga "/Applications/Docker.app"
  fi

  echo "Docker Desktop の起動待ちです..."
  for _ in $(seq 1 60); do
    if docker info >/dev/null 2>&1; then
      break
    fi
    sleep 2
  done
fi

docker compose up -d --build
