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

SALT="$(python3 - <<'PY'
import random
print(f"{random.getrandbits(32):08x}")
PY
)"
export SALT

PASSWORD_HASH="$(python3 - <<'PY'
import hashlib
import os
password = os.environ["LB_ADMIN_PASSWORD"]
salt = os.environ["SALT"]
print(hashlib.sha1((password + salt).encode("utf-8")).hexdigest())
PY
)"

DB_ROOT=(docker compose exec -T db mariadb -uroot "-p${MARIADB_ROOT_PASSWORD}")
DB_APP=(docker compose exec -T db mariadb -uroot "-p${MARIADB_ROOT_PASSWORD}" "${LB_DATABASE_NAME}")

"${DB_ROOT[@]}" <<SQL
DROP DATABASE IF EXISTS \`${LB_DATABASE_NAME}\`;
CREATE DATABASE \`${LB_DATABASE_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${LB_DATABASE_USER}'@'%' IDENTIFIED BY '${LB_DATABASE_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${LB_DATABASE_NAME}\`.* TO '${LB_DATABASE_USER}'@'%';
FLUSH PRIVILEGES;
SQL

"${DB_APP[@]}" < database_schema/create-schema.sql

for dir in $(find database_schema/upgrades -mindepth 1 -maxdepth 1 -type d | sort); do
  for file in schema.sql data.sql; do
    if [ -f "${dir}/${file}" ]; then
      "${DB_APP[@]}" < "${dir}/${file}"
    fi
  done
done

"${DB_APP[@]}" < database_schema/create-data.sql

"${DB_APP[@]}" <<SQL
SET @default_schedule_id := COALESCE(
  (SELECT schedule_id FROM schedules WHERE isdefault = 1 ORDER BY schedule_id LIMIT 1),
  1
);
INSERT INTO groups (name)
SELECT 'Application Administrators'
WHERE NOT EXISTS (SELECT 1 FROM groups WHERE name = 'Application Administrators');

SET @app_admin_group_id := (
  SELECT group_id
  FROM groups
  WHERE name = 'Application Administrators'
  LIMIT 1
);

INSERT INTO group_roles (group_id, role_id)
SELECT @app_admin_group_id, 2
WHERE NOT EXISTS (
  SELECT 1
  FROM group_roles
  WHERE group_id = @app_admin_group_id AND role_id = 2
);

INSERT INTO users (
  email,
  password,
  fname,
  lname,
  phone,
  organization,
  position,
  username,
  salt,
  timezone,
  language,
  homepageid,
  status_id,
  date_created,
  public_id,
  default_schedule_id,
  terms_date_accepted
) VALUES (
  '${LB_ADMIN_EMAIL}',
  '${PASSWORD_HASH}',
  '${LB_ADMIN_FIRST_NAME}',
  '${LB_ADMIN_LAST_NAME}',
  '',
  'Local Development',
  'Administrator',
  '${LB_ADMIN_USERNAME}',
  '${SALT}',
  'Asia/Tokyo',
  'ja_jp',
  2,
  1,
  NOW(),
  SUBSTRING(REPLACE(UUID(), '-', ''), 1, 20),
  @default_schedule_id,
  NOW()
);

INSERT INTO user_groups (user_id, group_id)
SELECT user_id, @app_admin_group_id
FROM users
WHERE username = '${LB_ADMIN_USERNAME}';
SQL

./scripts/bootstrap_meeting_room_data.sh

echo "初期化が完了しました。"
echo "ログインURL: http://localhost:8080/Web/"
echo "管理者ユーザー: ${LB_ADMIN_USERNAME}"
echo "管理者パスワード: ${LB_ADMIN_PASSWORD}"
