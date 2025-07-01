#!/bin/sh

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 設定ファイルの読み込み
test -f $SCRIPT_DIR/config && . $SCRIPT_DIR/config || { echo "config が見つかりません"; exit 1; }

echo "From: <$MAIL_FROM>
To: <$MAIL_TO>
Subject: $MAIL_SUBJECT
Content-Type: text/plain; charset=UTF-8

このメールは奇数月朔日に自動配信される $DOMAIN の証明書更新メールです。

ウェブサーバーのSSL/TLS証明書を更新してください。
「既存証明書のインストール」から「秘密鍵」「証明書」の順にインストールします。
「中間ＣＡ証明書」も別途インストールしてください。

下記のURLからパスワードを入力してログインしてください。

$LOGIN_URL

鍵をコピーする時は「-----」を含む行も含めてコピーしてください。

「秘密鍵」:" > $SCRIPT_DIR/mail.txt
sudo cat $CERT_PATH/privkey.pem >> $SCRIPT_DIR/mail.txt

echo "\n「証明書」:" >> $SCRIPT_DIR/mail.txt
sudo cat $CERT_PATH/cert.pem >> $SCRIPT_DIR/mail.txt

echo "\n「中間CA証明書」:" >> $SCRIPT_DIR/mail.txt
sudo cat $CERT_PATH/chain.pem >> $SCRIPT_DIR/mail.txt

/usr/sbin/sendmail -t < $SCRIPT_DIR/mail.txt
rm $SCRIPT_DIR/mail.txt
