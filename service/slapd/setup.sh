#!/bin/sh
#
# env  
#
# LDAP_DOMAIN			ldap domain
# LDAP_ADMIN_PWD		ldap admin passwd
# LDAP_ORGANISATION		orignation
######################################################################
# 

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

getBaseDn ${LDAP_DOMAIN}
LDAP_BASE_DN=$baseDn
LDAP_ADMIN="cn=admin,$baseDn"

if [ ! -e /var/lib/ldap/docker_bootstrapped_settings ]; then
  echo "configuring initialize for first run"

cat << EOF | ldapadd -x -w ${LDAP_ADMIN_PWD} -D ${LDAP_ADMIN}
dn: ou=People,${LDAP_BASE_DN}
objectclass: organizationalUnit
ou: Users

dn: ou=Groups,${LDAP_BASE_DN}
objectclass: organizationalUnit
ou: Groups

dn: ou=Computers,${LDAP_BASE_DN}
objectclass: organizationalUnit
ou: Computers
EOF

  touch /var/lib/ldap/docker_bootstrapped_settings
else
  echo "found already-initialize slapd"
fi
