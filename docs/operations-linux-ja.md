# Linux運用手順（シェル運用）

このドキュメントは、LibreBooking を Linux + Docker Engine で運用する担当者向けの手順です。

## 1. 事前準備

- Docker Engine / Docker Compose を導入
- リポジトリを配置
- `ops/linux/.env.production.template` を `.env` にコピーして本番値を設定

```bash
cd /path/to/reservation_system
cp ops/linux/.env.production.template .env
```

## 2. 日常運用

```bash
cd /path/to/reservation_system
bash ops/linux/start-librebooking.sh
bash ops/linux/status-librebooking.sh
bash ops/linux/stop-librebooking.sh
```

## 3. ジョブ運用（cron）

登録:

```bash
cd /path/to/reservation_system
bash ops/linux/register-cron-jobs.sh
```

削除:

```bash
cd /path/to/reservation_system
bash ops/linux/unregister-cron-jobs.sh
```

手動実行:

```bash
bash ops/linux/run-job.sh sendreminders.php
```

ログは `output/tasklogs/*.log` に出力されます。

## 4. 学内CIDR制限

`ufw` または `firewalld` がある環境で root 実行:

```bash
cd /path/to/reservation_system
sudo bash ops/linux/apply-firewall-rules.sh 131.112.0.0/16 10.0.0.0/8
```

## 5. バックアップ

```bash
cd /path/to/reservation_system
mkdir -p output/backups
TS="$(date +%Y%m%d-%H%M%S)"
docker compose exec -T db sh -lc 'mariadb-dump -uroot -p"$MARIADB_ROOT_PASSWORD" "$MARIADB_DATABASE"' > "output/backups/db-${TS}.sql"
docker compose cp app:/config "output/backups/config-${TS}"
docker compose cp app:/var/www/html/Web/uploads "output/backups/uploads-${TS}"
```

## 6. 受け入れチェック

- 起動後に `http://localhost:8080/Web/` が開ける
- 停止後に `docker compose ps` が停止状態
- cron 登録後にジョブログが生成される
