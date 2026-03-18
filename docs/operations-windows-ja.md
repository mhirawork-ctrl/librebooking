# Windows運用手順（ワンクリック運用）

このドキュメントは、LibreBooking を Windows + Docker で運用する担当者向けの手順です。  
通常操作は `ops/windows` 配下の 3 つの `.cmd` だけで実施します。

## 1. 事前準備

- Docker Desktop をインストールして起動しておく
- このリポジトリをローカルに配置する
- `ops/windows/.env.production.template` をコピーして `.env` を作成する
- `.env` のパスワード・URL・管理者情報を本番値に更新する

```powershell
cd C:\path\to\reservation_system
Copy-Item .\ops\windows\.env.production.template .\.env
```

## 2. 日常運用（担当者向け）

### 起動

`ops/windows/start-librebooking.cmd` をダブルクリックします。

- Docker が停止中なら自動起動を試行
- `docker compose up -d --build` を実行
- 最後にアクセス URL を表示

### 停止

`ops/windows/stop-librebooking.cmd` をダブルクリックします。

### 状態確認

`ops/windows/status-librebooking.cmd` をダブルクリックします。

- `docker compose ps` の結果を表示
- 現在のアクセス URL を表示

### デスクトップ運用にする場合

`start-librebooking.cmd` / `stop-librebooking.cmd` / `status-librebooking.cmd` のショートカットをデスクトップに配置してください。

## 3. ジョブ運用（Task Scheduler）

### 3.1 登録（管理者PowerShell）

```powershell
cd C:\path\to\reservation_system
powershell -ExecutionPolicy Bypass -File .\ops\windows\register-scheduled-tasks.ps1
```

登録されるジョブ:

- 毎分: `autorelease.php`
- 毎分: `sendreminders.php`
- 毎分: `sendmissedcheckin.php`
- 毎分: `sendwaitlist.php`
- 毎日 00:00: `sendseriesend.php`
- 毎日 00:00: `sessioncleanup.php`
- 毎日 01:00: `deleteolddata.php`

ログは `output/tasklogs/*.log` に出力されます。

### 3.2 削除（管理者PowerShell）

```powershell
cd C:\path\to\reservation_system
powershell -ExecutionPolicy Bypass -File .\ops\windows\unregister-scheduled-tasks.ps1
```

### 3.3 手動実行

```cmd
ops\windows\run-job.cmd sendreminders.php
```

## 4. 学内CIDR制限（Windows Firewall）

管理者PowerShellで実行します。

```powershell
cd C:\path\to\reservation_system
powershell -ExecutionPolicy Bypass -File .\ops\windows\apply-firewall-rules.ps1 `
  -CampusCidrs "131.112.0.0/16","10.0.0.0/8" `
  -Ports 80,443,8080
```

注意:

- このスクリプトは「学内CIDRからの受信許可ルール」を作成します
- Windows Firewall の既定受信ポリシーが `Block` である前提です
- 80/443/8080 を広く許可する既存ルールがある場合は無効化してください

## 5. バックアップ

### 5.1 DBバックアップ

```powershell
cd C:\path\to\reservation_system
New-Item -ItemType Directory -Force -Path .\output\backups | Out-Null
$ts = Get-Date -Format "yyyyMMdd-HHmmss"
docker compose exec -T db sh -lc 'mariadb-dump -uroot -p"$MARIADB_ROOT_PASSWORD" "$MARIADB_DATABASE"' > ".\output\backups\db-$ts.sql"
```

### 5.2 設定・アップロードのバックアップ

```powershell
docker compose cp app:/config ".\output\backups\config-$ts"
docker compose cp app:/var/www/html/Web/uploads ".\output\backups\uploads-$ts"
```

## 6. 復旧リハーサル（ローカル）

1. `start-librebooking.cmd` で起動
2. 空DBを作り直し、バックアップSQLをインポート
3. 必要に応じて `config` と `uploads` を戻す
4. ログインと予約一覧表示を確認

## 7. 更新手順

```powershell
cd C:\path\to\reservation_system
git pull
docker compose build --no-cache
docker compose up -d
```

更新前に必ず DB・`/config`・`uploads` のバックアップを取得してください。

## 8. 障害時一次対応

1. `status-librebooking.cmd` で状態確認
2. `docker compose logs --since 30m app db` で直近ログ確認
3. `docker compose restart` で再起動
4. ジョブ遅延がある場合は `run-job.cmd` で手動実行

## 9. 受け入れチェック（実機導入前）

- `start-librebooking.cmd` で `http://localhost:8080/Web/` にアクセスできる
- `stop-librebooking.cmd` 後に `docker compose ps` が停止状態
- `status-librebooking.cmd` で URL と状態が表示される
- Task Scheduler に 7 タスクが登録され、手動実行で成功する
- 本手順書だけで第三者が「起動 -> ログイン -> 停止」できる

## 10. 実機で残る作業

- `131.112.159.12` への最終割当
- 学内 DNS 登録
- DNS 名での TLS 証明書適用
- 学内 CIDR 制限の本番 FW 適用
