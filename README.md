# acme-over-ftp SSL証明書自動更新スクリプト

SSH 接続できないレンタルサーバーでも、FTP とメールで証明書取得を半自動化。
Let's EncryptのSSL証明書を自動的に更新し、FTPでアップロードしてメール通知を送信するスクリプト群です。

## 概要

このスクリプトは以下の処理を自動化します：

1. Let's Encrypt証明書の手動更新
2. ACMEチャレンジファイルのFTPアップロード
3. 更新された証明書のメール通知

## ファイル構成

```
scripts/
├── cert.sh          # メイン実行スクリプト
├── cert.expect      # expectスクリプト（対話処理）
├── upload.sh        # FTPアップロードスクリプト（アップロード完了後、アップロード元ファイルは自動的に削除されます）
├── sendmail.sh      # メール通知スクリプト
├── config           # 設定ファイル（機密情報）
├── config.example   # 設定ファイルテンプレート
├── .gitignore       # Git除外設定
└── README.md        # このファイル
```

## セットアップ

### 1. リポジトリのクローン

```bash
git clone https://github.com/Mazfuji/acme-over-ftp.git
cd acme-over-ftp
```

### 2. 設定ファイルの作成

```bash
cp config.example config
```

### 3. 設定ファイルの編集

`config`ファイルを編集して、実際の値を設定してください：

```bash
# FTP認証情報
FTP_HOST=your-domain.com
FTP_USER=your-username
FTP_PASS=your-password
FTP_PATH=www/htdocs/.well-known/acme-challenge

# メール設定
MAIL_FROM=your-email@domain.com
MAIL_TO=admin1@domain.com,admin2@domain.com,admin3@domain.com
MAIL_SUBJECT="Renewal certificate files of YOUR-DOMAIN.COM"

# ドメイン設定
DOMAIN=your-domain.com
LOGIN_URL=https://your-login-url.com/username/login

# 証明書パス
CERT_PATH=/etc/letsencrypt/live/your-domain.com
```

### 4. 実行権限の設定

```bash
chmod +x cert.sh cert.expect upload.sh sendmail.sh
```

### 5. 依存関係の確認

以下のコマンドが利用可能であることを確認してください：

- `certbot` - Let's Encrypt証明書管理
- `expect` - 対話処理
- `ftp` - FTP転送
- `sendmail` - メール送信

## 使用方法

### 手動実行

```bash
# スクリプトディレクトリに移動
cd /path/to/scripts

# 証明書更新を実行
./cert.sh
```

### 自動実行（cron）

奇数月の1日午前1時に自動実行する場合：

```bash
# crontabを編集
crontab -e

# 以下の行を追加
00 01 1 1,3,5,7,9,11 * /bin/sh /path/to/scripts/cert.sh
```

### 実行例

```bash
# 現在のディレクトリで実行
00 01 1 1,3,5,7,9,11 * /bin/sh /root/scripts/cert.sh

# または、絶対パスで実行
00 01 1 1,3,5,7,9,11 * cd /root/scripts && /bin/sh cert.sh
```

## 処理フロー

1. **cert.sh** → **cert.expect**を実行
2. **cert.expect** → certbotで証明書更新を開始
3. **cert.expect** → ACMEチャレンジが表示されたら**upload.sh**を実行
4. **upload.sh** → チャレンジファイルをFTPでアップロード（アップロード完了後、アップロード元ファイルは自動的に削除されます）
5. **cert.expect** → 証明書更新完了後、**sendmail.sh**を実行
6. **sendmail.sh** → 更新された証明書をメールで通知

## 設定項目の詳細

### FTP設定

| 項目 | 説明 | 例 |
|------|------|-----|
| `FTP_HOST` | FTPサーバーのホスト名 | `www.example.com` |
| `FTP_USER` | FTPユーザー名 | `username` |
| `FTP_PASS` | FTPパスワード | `password` |
| `FTP_PATH` | ACMEチャレンジファイルのアップロード先 | `www/htdocs/.well-known/acme-challenge` |

### メール設定

| 項目 | 説明 | 例 |
|------|------|-----|
| `MAIL_FROM` | 送信者メールアドレス | `admin@example.com` |
| `MAIL_TO` | 宛先メールアドレス（カンマ区切り） | `admin1@example.com,admin2@example.com` |
| `MAIL_SUBJECT` | メール件名 | `"証明書更新のお知らせ example.com"`<br>※スペースを含める場合はダブルクォーテーションで囲んでください |

### ドメイン設定

| 項目 | 説明 | 例 |
|------|------|-----|
| `DOMAIN` | 対象ドメイン名 | `example.com` |
| `LOGIN_URL` | 証明書管理画面のログインURL | `https://login.example.com/username/login` |
| `CERT_PATH` | 証明書ファイルの保存パス | `/etc/letsencrypt/live/example.com` |

## トラブルシューティング

### よくある問題

1. **設定ファイルが見つからない**
   ```
   config が見つかりません
   ```
   - `config`ファイルが存在することを確認
   - ファイルの読み取り権限を確認

2. **FTP接続エラー**
   - FTP認証情報が正しいことを確認
   - ネットワーク接続を確認
   - FTPサーバーが稼働していることを確認

3. **メール送信エラー**
   - `sendmail`がインストールされていることを確認
   - メール設定が正しいことを確認

4. **証明書更新エラー**
   - `certbot`がインストールされていることを確認
   - ドメインのDNS設定を確認
   - ACMEチャレンジファイルが正しくアップロードされていることを確認

### ログの確認

```bash
# cronのログを確認
tail -f /var/log/cron

# システムログを確認
tail -f /var/log/syslog

# メールログを確認
tail -f /var/log/mail.log
```

## セキュリティ

- `config`ファイルには機密情報が含まれているため、適切な権限を設定してください
- `.gitignore`に`config`が含まれているため、Gitにコミットされません
- 本番環境では、より安全な認証方法の使用を検討してください

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。

## 貢献

バグ報告や機能要望は、GitHubのIssueでお知らせください。

## 更新履歴

- v1.0.0 - 初期リリース
  - Let's Encrypt証明書自動更新機能
  - FTPアップロード機能
  - メール通知機能 