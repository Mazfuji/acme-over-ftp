#!/bin/sh

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 設定ファイルの読み込み
test -f $SCRIPT_DIR/config && . $SCRIPT_DIR/config || { echo "config が見つかりません"; exit 1; }

# 引数チェック
if [ $# -lt 2 ]; then
  echo "Usage: $0 <filename> <extension>"
  exit 1
fi

FILENAME="$1"
EXT="$2"
TARGET_FILE="$FILENAME.$EXT"

# ファイル作成
echo "$TARGET_FILE" > "$FILENAME"

# FTPアップロード
echo "open $FTP_HOST\nuser $FTP_USER $FTP_PASS\ncd $FTP_PATH\nput $FILENAME $FILENAME" | ftp -n

# アップロード元ファイルを削除
rm -f "$FILENAME"