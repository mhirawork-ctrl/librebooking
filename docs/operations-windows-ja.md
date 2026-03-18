# Windows本番運用手順（Dockerインストールから公開まで）

この手順は、Windows サーバに LibreBooking を本番導入するための実施手順です。  
本番では「学内CIDR制限を先に適用してから起動する」ことを前提にしています。

## 1. 実施順序（本番）

1. Docker Desktop 導入
2. リポジトリ配置（USB持ち込み）
3. `.env` 本番設定
4. 学内CIDR制限（Windows Firewall）
5. コンテナ起動
6. Webインストーラ初期化
7. Task Scheduler ジョブ登録
8. 受け入れ確認
9. 利用者へURL案内

## 2. 事前準備

### 2.1 前提条件

- Windows 10/11 または Windows Server（管理者権限あり）
- CPU仮想化有効（BIOS/UEFI の Intel VT-x / AMD-V）
- Docker Desktop インストーラを取得できる環境
- `reservation_system` 一式（USB持ち込み可）

### 2.2 Docker Desktop インストーラ取得

1. インターネット接続可能なPCで公式ページを開く  
   `https://www.docker.com/products/docker-desktop/`
2. `Download for Windows` を押して `Docker Desktop Installer.exe` を取得
3. 対象サーバがオフラインの場合、取得した `Docker Desktop Installer.exe` をUSBメモリに保存

### 2.3 Docker Desktop インストール

1. USBメモリを対象Windows機に接続
2. `Docker Desktop Installer.exe` をローカルディスクへコピー
3. インストーラを右クリックして「管理者として実行」
4. 既定オプションでインストール
5. 再起動要求が出た場合は再起動

### 2.4 Docker 動作確認

PowerShellで確認:

```powershell
docker version
docker compose version
docker info
```

`docker info` が通れば準備完了です。

### 2.5 リポジトリ配置（USB持ち込み）

1. 開発PCで `reservation_system` フォルダを最新化
2. フォルダをUSBメモリへコピー
3. 本番Windows機の `C:\work\reservation_system` へコピー
4. PowerShellで移動

```powershell
cd C:\work\reservation_system
```

## 3. `.env` 本番設定

### 3.1 テンプレートコピー

```powershell
cd C:\work\reservation_system
Copy-Item .\ops\windows\.env.production.template .\.env
```

### 3.2 必須項目の設定

最低限、次を本番値に変更してください。

- `MARIADB_ROOT_PASSWORD`
- `LB_DATABASE_PASSWORD`
- `LB_INSTALL_PASSWORD`
- `LB_ADMIN_PASSWORD`
- `LB_ADMIN_EMAIL`
- `LB_SCRIPT_URL`

設定例（値は必ず変更）:

```dotenv
MARIADB_ROOT_PASSWORD=ChangeThisRootPass_2026
LB_DATABASE_PASSWORD=ChangeThisDbPass_2026
LB_INSTALL_PASSWORD=ChangeThisInstallPass_2026
LB_ADMIN_PASSWORD=ChangeThisAdminPass_2026
LB_ADMIN_EMAIL=reserve-admin@example.ac.jp
LB_SCRIPT_URL=http://131.112.159.12:8080
```

`LB_SCRIPT_URL` の使い分け:

- IP運用時: `http://131.112.159.12:8080`
- DNS+HTTPS運用時: `https://reserve.example.ac.jp`

## 4. 学内CIDR制限（起動前に実施）

本番では **起動前** に実施してください。  
理由: `docker compose up` 後はネットワーク条件次第で即アクセス可能になるため。

### 4.1 ルール適用

管理者PowerShellで実行:

```powershell
cd C:\work\reservation_system
powershell -ExecutionPolicy Bypass -File .\ops\windows\apply-firewall-rules.ps1 `
  -CampusCidrs "131.112.0.0/16","10.0.0.0/8" `
  -Ports 80,443,8080
```

### 4.2 適用確認

```powershell
Get-NetFirewallRule -Group LibreBooking | Format-Table DisplayName, Enabled, Direction, Action
```

注意:

- 80/443/8080 を広く許可する既存ルールは無効化してください
- 既定受信ポリシーが `Block` 前提です

## 5. 初回起動と初期セットアップ

### 5.1 起動

`ops\windows\start-librebooking.cmd` をダブルクリック。

### 5.2 状態確認

`ops\windows\status-librebooking.cmd` をダブルクリックし、URL表示を確認。

### 5.3 Webインストーラ

1. `http://localhost:8080/install` にアクセス
2. `LB_INSTALL_PASSWORD` を入力
3. DB root ユーザー: `root`
4. DB root パスワード: `MARIADB_ROOT_PASSWORD`
5. `Create the database` と `Create the database user` を選択
6. 初期化完了後、管理者ユーザーを1名登録

補足: `.env` の `LB_ADMIN_EMAIL` と同じメールで登録したユーザーが管理者になります。

## 6. 担当者向け運用（ワンクリック）

担当者が使うファイルは次の3つのみです。

- 起動: `start-librebooking.cmd`
- 停止: `stop-librebooking.cmd`
- 状態確認: `status-librebooking.cmd`

### 6.1 デスクトップショートカット作成

1. 各 `.cmd` を右クリック
2. `送る` -> `デスクトップ (ショートカットを作成)`
3. 名前を以下へ変更

- `予約システム起動`
- `予約システム停止`
- `予約システム状態確認`

## 7. ジョブ運用（Task Scheduler）

### 7.1 目的

- LibreBooking の裏処理（定期バッチ）を自動実行し続けるためです
- 画面アクセスだけでは実行されない処理をTask Schedulerで補います
- 止まると「通知未送信」「自動解放未実行」「セッション/旧データ未清掃」などが起きます

### 7.2 登録

管理者PowerShellで実行:

```powershell
cd C:\work\reservation_system
powershell -ExecutionPolicy Bypass -File .\ops\windows\register-scheduled-tasks.ps1
```

登録される7ジョブ:

- 毎分: `autorelease.php`
- 毎分: `sendreminders.php`
- 毎分: `sendmissedcheckin.php`
- 毎分: `sendwaitlist.php`
- 毎日 00:00: `sendseriesend.php`
- 毎日 00:00: `sessioncleanup.php`
- 毎日 01:00: `deleteolddata.php`

### 7.3 登録確認

```powershell
schtasks /Query /TN LibreBooking-autorelease /V /FO LIST
schtasks /Query /TN LibreBooking-sendreminders /V /FO LIST
```

### 7.4 手動実行

```cmd
ops\windows\run-job.cmd sendreminders.php
```

### 7.5 削除

```powershell
cd C:\work\reservation_system
powershell -ExecutionPolicy Bypass -File .\ops\windows\unregister-scheduled-tasks.ps1
```

### 7.6 公開完了判定

本書の `## 1` から `## 7` まで完了し、次の3点を満たせば「立ち上げ・公開完了」と判断して利用者へ案内して構いません。

1. `## 4` の学内CIDR制限が有効（学内からのみ到達可能）
2. `## 5` のWeb画面表示とログインが成功
3. `## 7` のジョブ登録後、Task Scheduler の実行結果が成功

## 8. バックアップ

### 8.1 DBバックアップ

```powershell
cd C:\work\reservation_system
New-Item -ItemType Directory -Force -Path .\output\backups | Out-Null
$ts = Get-Date -Format "yyyyMMdd-HHmmss"
docker compose exec -T db sh -lc 'mariadb-dump -uroot -p"$MARIADB_ROOT_PASSWORD" "$MARIADB_DATABASE"' > ".\output\backups\db-$ts.sql"
```

### 8.2 設定・アップロードバックアップ

```powershell
docker compose cp app:/config ".\output\backups\config-$ts"
docker compose cp app:/var/www/html/Web/uploads ".\output\backups\uploads-$ts"
```

### 8.3 推奨保持方針

- DB: 日次 30世代
- config/uploads: 日次 14世代

## 9. 復旧リハーサル

1. `start-librebooking.cmd` で起動
2. DBを初期化または空状態にする
3. SQLバックアップをインポート
4. `config` と `uploads` を必要に応じて復元
5. ログイン・予約一覧・予約作成を確認

インポート例:

```powershell
Get-Content .\output\backups\db-YYYYMMDD-HHMMSS.sql | docker compose exec -T db sh -lc 'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" "$MARIADB_DATABASE"'
```

## 10. 更新手順

```powershell
cd C:\work\reservation_system
# 事前にバックアップ取得
git pull
docker compose build --no-cache
docker compose up -d
```

更新後確認:

- `status-librebooking.cmd` が正常表示
- ログイン可能
- 予約作成可能
- ジョブ直近実行が成功

## 11. 障害時の一次対応

1. `status-librebooking.cmd` で状態確認
2. ログ確認:

```powershell
cd C:\work\reservation_system
docker compose logs --since 30m app db
```

3. 再起動:

```powershell
docker compose restart
```

4. ジョブ遅延時は手動実行:

```cmd
ops\windows\run-job.cmd sendreminders.php
```

## 12. 実機導入前の受け入れチェック

- `start-librebooking.cmd` でWeb表示できる
- `stop-librebooking.cmd` で停止できる
- `status-librebooking.cmd` で状態とURLが表示される
- Task Scheduler 7ジョブが登録される
- ジョブ手動実行が成功する
- バックアップ取得とリストア試験が成功する

## 13. 本番切替時に残る作業

- `131.112.159.12` への最終割当
- 学内DNS登録
- DNS名でのTLS証明書適用
- 学内CIDR制限の本番FW最終適用
