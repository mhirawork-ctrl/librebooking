# macOS運用手順（ワンクリック運用）

このドキュメントは、LibreBooking を macOS + Docker Desktop で運用する担当者向けの手順です。

## 1. 事前準備

- Docker Desktop for Mac をインストールして起動
- リポジトリを配置
- `ops/macos/.env.production.template` を `.env` にコピーして本番値を設定

```bash
cd /path/to/reservation_system
cp ops/macos/.env.production.template .env
```

## 2. 日常運用

- 起動: `ops/macos/start-librebooking.command` をダブルクリック
- 停止: `ops/macos/stop-librebooking.command` をダブルクリック
- 状態確認: `ops/macos/status-librebooking.command` をダブルクリック

デスクトップ運用にする場合は、上記 3 ファイルのエイリアスを配置してください。

## 3. ジョブ運用（cron）

登録:

```bash
cd /path/to/reservation_system
bash ops/macos/register-cron-jobs.sh
```

削除:

```bash
cd /path/to/reservation_system
bash ops/macos/unregister-cron-jobs.sh
```

手動実行:

```bash
bash ops/macos/run-job.sh sendreminders.php
```

ログは `output/tasklogs/*.log` に出力されます。

## 4. バックアップ

```bash
cd /path/to/reservation_system
mkdir -p output/backups
TS="$(date +%Y%m%d-%H%M%S)"
docker compose exec -T db sh -lc 'mariadb-dump -uroot -p"$MARIADB_ROOT_PASSWORD" "$MARIADB_DATABASE"' > "output/backups/db-${TS}.sql"
docker compose cp app:/config "output/backups/config-${TS}"
docker compose cp app:/var/www/html/Web/uploads "output/backups/uploads-${TS}"
```

## 5. 受け入れチェック

- 起動後に `http://localhost:8080/Web/` が開ける
- 停止後に `docker compose ps` が停止状態
- cron 登録後にジョブログが生成される
