#!/bin/sh
#
# env  
#
# LDAP_DOMAIN			ldap domain
# LDAP_ADMIN_PWD		ldap admin passwd
# LDAP_ORGANISATION		orignation

# -e Exit immediately if a command exits with a non-zero status
set -eu

status () {
  echo "---> ${@}" >&2
}

getBaseDn () {
  IFS="."
  export IFS

  domain=$1
  init=1

  for s in $domain; do
    dc="dc=$s"
    if [ "$init" -eq 1 ]; then
      baseDn=$dc
      init=0
    else
      baseDn="$baseDn,$dc"
    fi
  done
}

set -x
: LDAP_ADMIN_PWD=${LDAP_ADMIN_PWD}
: LDAP_DOMAIN=${LDAP_DOMAIN}
: LDAP_ORGANISATION=${LDAP_ORGANISATION}

# Get base dn from ldap domain
getBaseDn ${LDAP_DOMAIN}
LDAP_BASE_DN=$baseDn
LDAP_ADMIN="cn=admin,$baseDn"

if [ ! -e /etc/phpldapadmin/docker_bootstrapped ]; then
  status "configuring LDAP for first run"

  # phpLDAPadmin config
  sed -i "s/'dc=example,dc=com'/'${LDAP_BASE_DN}'/g" /etc/phpldapadmin/config.php
  sed -i "s/'cn=admin,dc=example,dc=com'/'${LDAP_ADMIN}'/g" /etc/phpldapadmin/config.php
  sed -i "s/'My LDAP Server'/'${LDAP_ORGANISATION}'/g" /etc/phpldapadmin/config.php

  # nginx config
  ln -s /etc/nginx/sites-available/phpldapadmin /etc/nginx/sites-enabled/phpldapadmin
  rm /etc/nginx/sites-enabled/default

  touch /etc/phpldapadmin/docker_bootstrapped
else
  status "found already-configured phpLDAPadmin"
fi
