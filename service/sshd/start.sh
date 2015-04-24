#!/bin/bash
set -e

# CLI用のユーザを登録し、起動shellをCLIへ変更する
useradd -s /opt/cli/cli.sh -m admin
echo "admin:${LDAP_ADMIN_PWD}" | chpasswd

# sshdを起動する
exec /usr/sbin/sshd -D
