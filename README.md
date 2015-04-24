docker-ldap
================

# はじめに
dockerにてldapサーバ、phpLDAPadmin、CLIを提供するコンテナです。  
このコンテナはnickstenning/slapdをベースとしています。

また、コンテナ内のファイルはホスト側からは隔離されます。永続的なファイルの保存が必要な場合は-vオプションを使用してホスト側のディレクトリを以下へマウントしてください。  

+ /var/lib/ldap
+ /etc/ldap/slapd.d

利用上の注意：  
このコンテナの起動には1G以上のfreeメモリが必要です。これ以下の場合、slapdの起動でエラーを起こします。  
起動後、phpLDAPadmin経由でログインできない場合、CLI経由でコマンドが失敗する場合はメモリ量を確認してください。  
目安として、sameersbn/gitlab(gitlab+mysql+redis) + sameersbn/redmine(redmine+mysql) + jenkins + sharaku/ldap で2Gメモリでは足りませんでした。


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
      -p 10022:22 \
      sharaku/ldap

グループ、ユーザの追加はCLIを使用します。
Quick Startの例では、10022へsshで接続します。ユーザ名はadmin, パスワードはLDAP_ADMIN_PWDで指定したものです。
接続後、以下のようにグループを追加します。

    LDAP> addgroup -name test_group -gid 10000

グループ追加後、ユーザを追加します。

    LDAP> adduser -name test_user -passwd passwd_passwd -uid 10000 -group test_group -sn test_user -email test_user@example.com

グループ、ユーザの追加は必要に応じて実施します。

内容の確認
GUIを使用すると、登録されているユーザ、グループを参照・編集することができます。
Quick Startの例では、80へhttpで接続します。ユーザ名はcn=admin,dc=example,dc=com, パスワードはLDAP_ADMIN_PWDで指定したものです。

LDAP登録ユーザ自身によるパスワードの変更
Userminを使用すると、登録されているユーザ自身が自分のパスワードを変更することができます。
Quick Startの例では、20000へhttpsで接続します。

# Argument

+   `-v /path/to/ldap/data/:/var/lib/ldap:rw` :  
    永続的に保存するデータのディレクトリを指定します。任意の数の-vオプションを使用可能です。この設定をしない場合、コンテナを起動するたびにLDAP設定が消えます。

+   `-v /path/to/ldap/etc/ldap/slapd.d/:/etc/ldap/slapd.d:rw` :  
    永続的に保存するデータのディレクトリを指定します。任意の数の-vオプションを使用可能です。この設定をしない場合、コンテナを起動するたびにLDAP設定が消えます。

+   `-e LDAP_DOMAIN=example.com` :  
    LDAPのドメインを設定します。

+   `-e LDAP_ADMIN_PWD=toor` :  
    LDAPの管理者のパスワードを設定します。

+   `-e LDAP_ORGANISATION="docker.io Example Inc."` :  
    LDAPの説明を追加します。

+   -p port:389 :  
    LDAPを外部公開するポートを設定します。

+   -p port:80 :  
    GUIを外部公開するポートを設定します。

+   -p port:22 :  
    CLIを外部公開するポートを設定します。

+   -p port:20000 :  
    Userminを外部公開するポートを設定します。

# CLI

CLIを使用することでわずらわしいユーザ登録、グループ登録の操作が簡略化できます。    

## add group -name groupname -gid gid

グループの登録を行います

+ -name groupname : 登録するグループ名を指定します

+ -gid gid : 登録するグループIDを指定します

## add user -name username -passwd passwd -uid uid -group group_name -sn sn -email email [-home home_dir] [-shell login_shell]

ユーザの登録を行います

+ -name username : 登録するユーザ名を指定します

+ -passwd passwd : 登録する初期パスワードを指定します

+ -uid uid : ユーザIDを指定します

+ -group group_name : ユーザの所属するグループ名を指定します。あらかじめ登録されている必要があります

+ -sn sn : ユーザフルネームを指定します

+ -email email : ユーザのemailアドレスを指定します

+ -home home_dir : ユーザのホームディレクトリを指定します

+ -shell login_shell : ユーザのログインシェルを指定します

## delete group -name groupname

グループの削除を行います。グループに属しているユーザがいる場合はエラーになります。

+ -name groupname : 削除するグループ名を指定します

## delete user -name username

ユーザの削除を行います。

+ -name username : 削除するユーザ名を指定します

## help

使用可能なコマンド一覧を表示します

## set passwd -name username -passwd passwd

ユーザのパスワード変更を行います。

+ -name username : パスワード変更するユーザ名を指定します

+ -passwd passwd : パスワードを指定します

## show groups

登録済みグループ一覧を表示します

## show users [-group groupname]

登録済みユーザ一覧を表示します

+ -name groupname : 指定すると、グループに所属するユーザのみを表示します


# LDAP と gitlab, redmine を連携させる

以下の条件でLDAP と gitlab, redmine を連携させるを構築する例です。

+ dockerが動作するホストのIP：192.168.0.10
+ ドメイン：example.com
+ ldap CLI port：20022
+ redmine port ：10080
+ gitlab port  ：10180

## ldap
### ldapを起動する

    docker run -d \
      --name ldap \
      -v /path/to/ldap/data:/var/lib/ldap:rw \
      -v /path/to/ldap/etc/ldap/slapd.d:/etc/ldap/slapd.d:rw \
      -e LDAP_DOMAIN=example.com \
      -e LDAP_ADMIN_PWD=toor \
      -e LDAP_ORGANISATION="docker.io Example Inc." \
      -p 389:389 -p 20022:22 \
      sharaku/ldap


### ldapへ必要なユーザ、グループを追加
ldapのCLIへ接続し、必要なユーザ、グループを追加する

## redmine
### redmineを起動する

    docker run -d \
      --name redmine-mysql \
      -v /path/to/redmine/mysql:/var/lib/mysql:rw \
      -e "DB_NAME=redmine_production" -e "DB_USER=redmine" -e "DB_PASS=password" \
      sameersbn/mysql:latest
    docker run -d \
      --name redmine \
      --link redmine-mysql:mysql \
      -v /path/to/redmine/data:/home/redmine/data:rw \
      -v /path/to/redmine/public:/home/redmine/redmine/public:rw \
      -p 10080:80 \
      sameersbn/redmine

### ldapサーバを登録する
1. redmineへadmin/adminでログインする
2. 起動後の設定（adminの初期パスワード設定など）を行う
3. "管理" → "LDAP認証"を選択
4. 以下の通り設定する。（以下以外すべてブランク）
  + 名称                    任意
  + ホスト                  192.168.0.10
  + ポート                  389
  + アカウント              cn=admin,dc=aegis,dc=dip,dc=jp
  + パスワード              toor
  + 検索範囲                dc=aegis,dc=dip,dc=jp
  + ログイン名属性          cn
5. "保存"を選択
6. ログアウトする
7. "Sign in"にて"LDAP"タブを選択し、LDAPのユーザ、パスワードでログインする


## gitlab
### gitlabを起動する

    docker run --name gitlab-redis -d \
      -v /path/to/gitlab/redis:/var/lib/redis \
      sameersbn/redis:latest
    docker run --name gitlab-mysql -d \
      -v /path/to/gitlab/mysql:/var/lib/mysql:rw \
      -e "DB_NAME=gitlabhq_production" -e "DB_USER=gitlab" -e "DB_PASS=password" \
      sameersbn/mysql:latest
    docker run -d \
      --name gitlab \
      --link gitlab-mysql:mysql \
      --link gitlab-redis:redisio \
      -v /path/to/gitlab/data:/home/git/data:rw \
      -e "LDAP_ENABLED=true" \
      -e "LDAP_HOST=192.168.0.10" \
      -e "LDAP_PORT=389" \
      -e "LDAP_METHOD=plain" \
      -e "LDAP_UID=uid" \
      -e "LDAP_BIND_DN=cn=admin,dc=example,dc=com" \
      -e "LDAP_PASS=toor" \
      -e "LDAP_ACTIVE_DIRECTORY=false" \
      -e "LDAP_ALLOW_USERNAME_OR_EMAIL_LOGIN=false" \
      -e "LDAP_BASE=ou=People,dc=example,dc=com" \
      -p 10180:80 \
      sameersbn/gitlab

### gitlabへログインする
1. "Sign in"にて"Standard"タブを選択し、root/5iveL!feでログインする
2. 起動後の設定（rootの初期パスワード設定など）を行う
3. ログアウトする
4. "Sign in"にて"LDAP"タブを選択し、LDAPのユーザ、パスワードでログインする

ToDo
------

- ユーザがパスワードを変更できるwebインタフェース追加
- CLIで登録済みユーザのパラメータ変更できるコマンド追加
