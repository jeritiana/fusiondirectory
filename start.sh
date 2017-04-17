#!/bin/sh

LDAP_DOMAIN_DC1=`echo $LDAP_DOMAIN|cut -d. -f1`
LDAP_DOMAIN_DC2=`echo $LDAP_DOMAIN|cut -d. -f2`
LDAP_DOMAIN_DC3=`echo $LDAP_DOMAIN|cut -d. -f3`

export LDAP_DOMAIN_DC="dc=$LDAP_DOMAIN_DC1"
if [ _$LDAP_DOMAIN_DC2 != _ ]; then
    LDAP_DOMAIN_DC="$LDAP_DOMAIN_DC,dc=$LDAP_DOMAIN_DC2"
fi
if [ _$LDAP_DOMAIN_DC3 != _ ]; then
    LDAP_DOMAIN_DC="$LDAP_DOMAIN_DC,dc=$LDAP_DOMAIN_DC3"
fi

envsubst < /fusiondirectory.conf > /etc/fusiondirectory/fusiondirectory.conf

if [ ! -e "/etc/ldap/fusionready" ]; then
    yes Yes | fusiondirectory-setup --check-config
    fusiondirectory-setup --yes --check-ldap << EOF
admin
$FUSIONDIRECTORY_PASSWORD
$FUSIONDIRECTORY_PASSWORD
EOF
    touch /etc/ldap/fusionready
fi

if [ "$SMTP_ENABLED" = "true" ]; then
    envsubst < /msmtp.conf > /etc/msmtprc
fi

. /etc/apache2/envvars
/usr/sbin/apache2 -D FOREGROUND
