#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

if [ ! -f .env ]; then
  echo ".env が見つかりません。" >&2
  exit 1
fi

set -a
source .env
set +a

docker compose exec -T db mariadb \
  -uroot \
  "-p${MARIADB_ROOT_PASSWORD}" \
  "${LB_DATABASE_NAME}" \
  < docker/sql/meeting-room-bootstrap.sql

echo "会議室と研究室の初期データを投入しました。"
