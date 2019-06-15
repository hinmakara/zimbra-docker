#!/bin/sh

## Preparing all the variables like IP, Hostname, etc, all of them from the container
sleep 5

RANDOMHAM=$(date +%s|sha256sum|base64|head -c 10)
RANDOMSPAM=$(date +%s|sha256sum|base64|head -c 10)
RANDOMVIRUS=$(date +%s|sha256sum|base64|head -c 10)

## Config resolv.conf ##
echo "Config resolv.conf"
echo 'nameserver=127.0.0.1'>/etc/resolv.conf

## Installing the DNS Server ##
echo "Configuring DNS Server"
rm /etc/dnsmasq.conf
cat <<EOF >>/etc/dnsmasq.conf
server=8.8.8.8
listen-address=127.0.0.1
domain=$DOMAIN
mx-host=$DOMAIN,$HOSTNAME.$DOMAIN,0
address=/$HOSTNAME.$DOMAIN/$CONTAINERIP
user=root
EOF
sudo service dnsmasq restart

## setting up sshd server ##
echo "Setting up sshd server."
/usr/bin/ssh-keygen -A
sudo service ssh restart

##Creating the Zimbra Collaboration Config File ##
mkdir -p /tmp/zimbra-install
touch /tmp/zimbra-install/installZimbra-keystrokes
cat <<EOF >/tmp/zimbra-install/installZimbra-keystrokes
Y
Y
Y
Y
Y
N
Y
Y
Y
Y
Y
Y
N
Y
N
Y
EOF

cat <<EOF >/tmp/zimbra-install/installZimbra-keystrokes.hints
Y - License agreement
Y - Use Zimbra's package repository
Y - zimbra-ldap
Y - zimbra-logger
Y - zimbra-mta
N - zimbra-dnscache
Y - zimbra-snmp
Y - zimbra-store
Y - zimbra-apache
Y - zimbra-spell
Y - zimbra-memcached
Y - zimbra-proxy
N - zimbra-drive
Y - zimbra-imapd
N - zimbra-chat
Y - continue
EOF

touch /tmp/zimbra-install/installZimbraScript
cat <<EOF >/tmp/zimbra-install/installZimbraScript
AVDOMAIN="$DOMAIN"
AVUSER="admin@$DOMAIN"
CREATEADMIN="admin@$DOMAIN"
CREATEADMINPASS="$PASSWORD"
CREATEDOMAIN="$DOMAIN"
DOADDUPSTREAMIMAP="no"
DOCREATEADMIN="yes"
DOCREATEDOMAIN="yes"
DOTRAINSA="yes"
EXPANDMENU="no"
HOSTNAME="$HOSTNAME.$DOMAIN"
HTTPPORT="8080"
HTTPPROXY="TRUE"
HTTPPROXYPORT="80"
HTTPSPORT="8443"
HTTPSPROXYPORT="443"
IMAPPORT="7143"
IMAPPROXYPORT="143"
IMAPSSLPORT="7993"
IMAPSSLPROXYPORT="993"
INSTALL_WEBAPPS="service zimlet zimbra zimbraAdmin"
JAVAHOME="/opt/zimbra/common/lib/jvm/java"
LDAPBESSEARCHSET="set"
LDAPHOST="$HOSTNAME.$DOMAIN"
LDAPPORT="389"
LDAPREPLICATIONTYPE="master"
LDAPSERVERID="2"
MAILBOXDMEMORY="4812"
MAILPROXY="TRUE"
MODE="https"
MYSQLMEMORYPERCENT="30"
POPPORT="7110"
POPPROXYPORT="110"
POPSSLPORT="7995"
POPSSLPROXYPORT="995"
PROXYMODE="https"
REMOVE="no"
RUNARCHIVING="no"
RUNAV="yes"
RUNCBPOLICYD="no"
RUNDKIM="yes"
RUNSA="yes"
RUNVMHA="no"
SERVICEWEBAPP="yes"
SMTPDEST="admin@$DOMAIN"
SMTPHOST="$HOSTNAME.$DOMAIN"
SMTPNOTIFY="yes"
SMTPSOURCE="admin@$DOMAIN"
SNMPNOTIFY="yes"
SNMPTRAPHOST="$HOSTNAME.$DOMAIN"
SPELLURL="http://$HOSTNAME.$DOMAIN:7780/aspell.php"
STARTSERVERS="yes"
STRICTSERVERNAMEENABLED="TRUE"
SYSTEMMEMORY="23.5"
TRAINSAHAM="ham.$RANDOMHAM@$DOMAIN"
TRAINSASPAM="spam.$RANDOMSPAM@$DOMAIN"
UIWEBAPPS="yes"
UPGRADE="yes"
USEEPHEMERALSTORE="no"
USESPELL="yes"
VERSIONUPDATECHECKS="TRUE"
VIRUSQUARANTINE="virus-quarantine.$RANDOMVIRUS@$DOMAIN"
ZIMBRA_REQ_SECURITY="yes"
imapd_keystore="/opt/zimbra/conf/imapd.keystore"
imapd_keystore_password="$PASSWORD"
ldap_bes_searcher_password="$PASSWORD"
ldap_dit_base_dn_config="cn=zimbra"
ldap_nginx_password="$PASSWORD"
mailboxd_directory="/opt/zimbra/mailboxd"
mailboxd_keystore="/opt/zimbra/mailboxd/etc/keystore"
mailboxd_keystore_password="$PASSWORD"
mailboxd_server="jetty"
mailboxd_truststore="/opt/zimbra/common/lib/jvm/java/lib/security/cacerts"
mailboxd_truststore_password="changeit"
postfix_mail_owner="postfix"
postfix_setgid_group="postdrop"
ssl_default_digest="sha256"
zimbraFeatureBriefcasesEnabled="Enabled"
zimbraFeatureTasksEnabled="Enabled"
zimbraIPMode="ipv4"
zimbraMailProxy="TRUE"
zimbraMtaMyNetworks="127.0.0.0/8 $CONTAINERIP/32 [::1]/128 [fe80::]/64"
zimbraPrefTimeZoneId="Asia/Phnom_Penh"
zimbraReverseProxyLookupTarget="TRUE"
zimbraVersionCheckNotificationEmail="admin@$DOMAIN"
zimbraVersionCheckNotificationEmailFrom="admin@$DOMAIN"
zimbraVersionCheckSendNotifications="TRUE"
zimbraWebProxy="TRUE"
zimbra_ldap_userdn="uid=zimbra,cn=admins,cn=zimbra"
zimbra_require_interprocess_security="1"
INSTALL_PACKAGES="zimbra-core zimbra-ldap zimbra-logger zimbra-mta zimbra-snmp zimbra-store zimbra-apache zimbra-spell zimbra-memcached zimbra-proxy zimbra-imapd "
EOF

echo "Downloading Zimbra Collaboration 8.8.12"
wget -O /tmp/zimbra-install/zimbra-zcs-8.8.12.tar.gz https://files.zimbra.com/downloads/8.8.12_GA/zcs-8.8.12_GA_3794.UBUNTU16_64.20190329045002.tgz

echo "Extracting files from the archive"
tar xzvf /tmp/zimbra-install/zimbra-zcs-8.8.12.tar.gz -C /tmp/zimbra-install/

echo "Installing Zimbra Collaboration just the Software"
cd /tmp/zimbra-install/zcs-* && ./install.sh -s < /tmp/zimbra-install/installZimbra-keystrokes

echo "Installing Zimbra Collaboration injecting the configuration"
/opt/zimbra/libexec/zmsetup.pl -c /tmp/zimbra-install/installZimbraScript

sudo service ssh restart

sudo service dnsmasq restart

su - zimbra -c 'zmcontrol restart'

if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi
