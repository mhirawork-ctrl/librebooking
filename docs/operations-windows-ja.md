# Windows本番運用手順（既存データ維持モード）

この手順は、LibreBooking を Windows に本番導入するときに、既存の「部屋名称・ユーザー一覧・予約履歴」をそのまま維持するための手順です。  
ポイントは **新規初期化をしない** ことです。

## 0. 最重要ルール（データ維持）

本番で既存データを維持するため、次の3点を必ず守ってください。

1. 本番で `/install` の DB 作成を実行しない
2. `create-schema.sql` / 初期化スクリプトを本番で実行しない
3. 旧環境の最新DBダンプを本番へ `restore-db.cmd` で復元する

## 1. 実施順序（本番・データ維持）

1. 旧環境で DB フルバックアップ取得
2. SQL バックアップを新サーバへ搬送
3. 新サーバに Docker Desktop 導入
4. リポジトリ配置と `.env` 本番設定
5. 学内CIDR制限（Windows Firewall）適用
6. コンテナ起動
7. DB リストア（丸ごと移行）
8. Task Scheduler ジョブ登録
9. 受け入れ確認
10. 利用者へURL案内

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
- `LB_DATABASE_NAME`
- `LB_DATABASE_USER`
- `LB_DATABASE_PASSWORD`
- `LB_SCRIPT_URL`

設定例（値は必ず変更）:

```dotenv
MARIADB_ROOT_PASSWORD=ChangeThisRootPass_2026
LB_DATABASE_NAME=librebooking
LB_DATABASE_USER=lb_user
LB_DATABASE_PASSWORD=ChangeThisDbPass_2026
LB_SCRIPT_URL=http://131.112.159.12:8080
```

`LB_INSTALL_PASSWORD` / `LB_ADMIN_PASSWORD` / `LB_ADMIN_EMAIL` は新規構築時に使う値です。  
**既存DB移行のみの場合は実運用で未使用でも問題ありません。**

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

## 5. コンテナ起動

- 起動: `ops\windows\start-librebooking.cmd`
- 状態確認: `ops\windows\status-librebooking.cmd`

この時点ではDB未移行ならログインできなくても問題ありません。次の手順で既存DBを復元します。

## 6. DB丸ごと移行（部屋名・ユーザー一覧を維持）

### 6.1 旧環境でDBバックアップ取得

旧環境が同じリポジトリ構成なら、管理者コマンドプロンプトで以下を実行:

```cmd
ops\windows\backup-db.cmd
```

生成先:

- `output\backups\db-YYYYMMDD-HHMMSS.sql`

任意ファイル名で出力する場合:

```cmd
ops\windows\backup-db.cmd D:\backup\librebooking-full.sql
```

### 6.2 SQLファイルを新サーバへ搬送

- USBメモリなどで `*.sql` を新サーバへコピー
- 例: `C:\work\reservation_system\output\backups\librebooking-full.sql`

### 6.3 新サーバでDBリストア

管理者コマンドプロンプトで実行:

```cmd
cd C:\work\reservation_system
ops\windows\restore-db.cmd .\output\backups\librebooking-full.sql
```

`restore-db.cmd` は以下を自動実行します。

- `db` コンテナ起動
- `app` コンテナ停止
- 既存DBを再作成
- SQLインポート
- `app` コンテナ再起動

### 6.4 リストア確認（件数確認）

PowerShellで件数確認:

```powershell
docker compose exec -T db sh -lc 'mariadb -u"$MARIADB_USER" -p"$MARIADB_PASSWORD" "$MARIADB_DATABASE" -e "SELECT COUNT(*) AS users_count FROM users; SELECT COUNT(*) AS resources_count FROM resources;"'
```

`users_count` と `resources_count` が期待値に近ければOKです。

### 6.5 絶対に実行しない操作（データ維持時）

- `http://<host>/install` で `Create the database` を実行する
- `database_schema/create-schema.sql` を本番DBへ流す
- `scripts/init_local_instance.sh` を本番で実行する
- `docker/sql/meeting-room-bootstrap.sql` を本番で実行する

## 7. ジョブ運用（Task Scheduler）

### 7.1 目的

- LibreBooking の裏処理（定期バッチ）を自動実行し続けるため
- 止まると通知未送信、自動解放未実行、旧データ未清掃などが発生

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

## 8. 立ち上げ・公開完了の判定

次を満たせば公開完了です。

1. 学内CIDR制限が有効
2. `status-librebooking.cmd` で `app/db` が稼働中
3. URLへアクセスしてログイン可能
4. 既存の部屋名称・ユーザー一覧が表示される
5. Task Scheduler の実行結果が成功

## 9. 日常運用（担当者向け）

担当者が使うファイルは次の3つのみです。

- 起動: `start-librebooking.cmd`
- 停止: `stop-librebooking.cmd`
- 状態確認: `status-librebooking.cmd`

## 10. 定期バックアップ

DBバックアップ（推奨: 毎日）:

```cmd
cd C:\work\reservation_system
ops\windows\backup-db.cmd
```

設定/アップロードを含める場合:

```powershell
cd C:\work\reservation_system
$ts = Get-Date -Format "yyyyMMdd-HHmmss"
docker compose cp app:/config ".\output\backups\config-$ts"
docker compose cp app:/var/www/html/Web/uploads ".\output\backups\uploads-$ts"
```

## 11. 障害時の一次対応

1. `status-librebooking.cmd` で状態確認
2. ログ確認

```powershell
cd C:\work\reservation_system
docker compose logs --since 30m app db
```

3. 再起動

```powershell
docker compose restart
```

4. 必要時は直近バックアップからリストア

```cmd
ops\windows\restore-db.cmd .\output\backups\db-YYYYMMDD-HHMMSS.sql
```

## 12. 本番切替時に残る作業

- `131.112.159.12` への最終割当
- 学内DNS登録
- DNS名でのTLS証明書適用
- 学内CIDR制限の本番FW最終適用
