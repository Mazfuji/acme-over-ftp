#!/bin/bash

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set environment variables if needed
export PATH=/usr/local/bin:/usr/bin:/bin

# Create a virtual TTY session and execute expect script
script -c "/bin/expect $SCRIPT_DIR/cert.expect" /dev/null
