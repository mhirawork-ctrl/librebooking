# ローカル開発手順

## 1. Docker Desktop を起動する

- `~/Applications/Docker.app` または `/Applications/Docker.app` を開く
- メニューバーに Docker のアイコンが出て、起動完了になるまで待つ

## 2. コンテナを起動する

```bash
cd /Users/masahira/Agent_macmini/reservation_system
./scripts/up.sh
```

ブラウザでは `http://localhost:8080` を開きます。

## 3. DB と管理者を自動初期化する

```bash
cd /Users/masahira/Agent_macmini/reservation_system
./scripts/init_local_instance.sh
```

このスクリプトで次をまとめて実行します。

- DB 初期化
- LibreBooking のスキーマ適用
- 管理者ユーザー作成
- 会議室 7 室と研究室グループ投入

初期ログイン情報は `.env` の以下です。

- ユーザー名: `admin`
- パスワード: `local-admin-password`

## 4. 手動でインストール画面を使いたい場合

1. `http://localhost:8080/install` を開く
2. インストールパスワードに `.env` の `LB_INSTALL_PASSWORD` を入れる
3. DB root ユーザーは `root`
4. DB root パスワードは `.env` の `MARIADB_ROOT_PASSWORD`
5. `Create the database` と `Create the database user` を選んで登録する
6. 管理者ユーザーを 1 人登録する

## 5. 会議室・研究室の初期データだけ入れ直す

```bash
cd /Users/masahira/Agent_macmini/reservation_system
./scripts/bootstrap_meeting_room_data.sh
```

このスクリプトで次を投入します。

- デフォルトスケジュールを `会議室予約` に変更
- タイムゾーンを `Asia/Tokyo` に変更
- 研究室グループ `研究室A` から `研究室E` を作成
- 会議室 7 室を作成
  `G1-420 セミナー室（３単位）`, `G1-419 セミナー室（２単位）`, `G1-617 招へい研究者室（１単位）`, `G1-813 セミナー室（２単位）`, `G1-820 セミナー室（３単位）`, `G1-821 非常勤講師室（１単位）`, `G1-1013 セミナー室（２単位）`
- 既存ユーザーの初期表示を月間カレンダーに変更

## 6. 最初に確認すること

- 管理画面で会議室 7 件が見える
- 一般ユーザーを手動で追加できる
- 一般ユーザーでログインすると月間カレンダーに入る
- 予約作成後に他ユーザーから埋まり状態が見える

## 補足

- アプリの主要設定は `.env` で管理しています
- 画面の軽い見た目調整は `Web/css/custom-style.css` にあります
- ナビゲーションの軽い導線調整は `tpl/globalheader.tpl` に入れています
- Windows 本番運用手順は `docs/operations-windows-ja.md` を参照してください
