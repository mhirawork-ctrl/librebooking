#!/usr/bin/env bash

set -euo pipefail

if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  echo '[ERROR] root 権限で実行してください。' >&2
  exit 1
fi

if [ "$#" -lt 1 ]; then
  echo 'Usage: apply-firewall-rules.sh <CIDR1> [CIDR2 ...]' >&2
  exit 1
fi

CIDRS=("$@")
PORTS=(80 443 8080)

if command -v ufw >/dev/null 2>&1; then
  echo '[INFO] UFW で学内CIDR許可ルールを設定します。'
  for port in "${PORTS[@]}"; do
    ufw delete allow "$port/tcp" >/dev/null 2>&1 || true
    for cidr in "${CIDRS[@]}"; do
      ufw allow proto tcp from "$cidr" to any port "$port"
    done
  done
  echo '[WARN] UFW のデフォルト受信ポリシーが deny であることを確認してください。'
  ufw status verbose
  exit 0
fi

if command -v firewall-cmd >/dev/null 2>&1; then
  echo '[INFO] firewalld で学内CIDR許可ルールを設定します。'
  for port in "${PORTS[@]}"; do
    for cidr in "${CIDRS[@]}"; do
      firewall-cmd --permanent --add-rich-rule="rule family=ipv4 source address=${cidr} port protocol=tcp port=${port} accept"
    done
  done
  firewall-cmd --reload
  echo '[WARN] 広範囲許可ルールが残っていないかを確認してください。'
  firewall-cmd --list-rich-rules
  exit 0
fi

echo '[ERROR] ufw または firewall-cmd が見つかりません。手動でFW設定してください。' >&2
exit 1
