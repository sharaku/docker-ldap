docker-ldap
================

# はじめに
dockerにてldapサーバ、phpLDAPadminを提供するコンテナです。  
このコンテナはnickstenning/slapdをベースとしています。

また、コンテナ内のファイルはホスト側からは隔離されます。永続的なファイルの保存が必要な場合は-vオプションを使用してホスト側のディレクトリを以下へマウントしてください。
+ /var/lib/ldap
+ /etc/ldap/slapd.d


使い方
------
# Installation
以下のようにdocker imageをpullします。

    docker pull sharaku/ldap


Docker imageを自分で構築することもできます。

    git clone https://github.com/sharaku/docker-ldap.git
    cd docker-ldap
    docker build --tag="$USER/ldap" .

# Quick Start
ldapのimageを実行します。

    docker run -d \
      -v /path/to/ldap/data/:/var/lib/ldap:rw \
      -v /path/to/ldap/etc/ldap/slapd.d/:/etc/ldap/slapd.d:rw \
      -e LDAP_DOMAIN=example.com \
      -e LDAP_ADMIN_PWD=toor \
      -e LDAP_ORGANISATION="docker.io Example Inc." \
      -p 389:389 \
      -p 80:80 \
      sharaku/ldap

