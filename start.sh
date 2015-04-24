#!/bin/sh

# slapd, phpLDAPadmin startded
/opt/slapd/slapd.sh
/opt/phpldapadmin/ldapadmin.sh

# nginx started
echo "starting php5-fpm"
/etc/init.d/php5-fpm start
echo "starting nginx"
/etc/init.d/nginx restart

# wait until the server is started.
sleep 3
/opt/slapd/setup.sh

# CLI started
echo "export LDAP_DOMAIN=${LDAP_DOMAIN}"       >  /opt/cli/env
echo "export LDAP_ADMIN_PWD=${LDAP_ADMIN_PWD}" >> /opt/cli/env
echo "export LDAP_HOST=${LDAP_HOST}"           >> /opt/cli/env

echo 'readonly DEF_CLIPROMPT="LDAP>"'                          >  /opt/cli/configure
echo 'export readonly DEF_COMMAND_PATH=${DEF_CLI_PATH}/command/' >> /opt/cli/configure

/opt/sshd/start.sh

touch /opt/started
exec tail -f /opt/started
