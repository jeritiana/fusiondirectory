#!/bin/sh

if [ ! -e "/.setup" ]; then

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

    echo "Insert schema: base..."
    LDAP_ARGS="-v -ZZ -H ldap://ldap:389 -D cn=admin,$LDAP_DOMAIN_DC -w $LDAP_PASSWORD"
    fusiondirectory-insert-schema -o "$LDAP_ARGS";

    echo "Insert schema: plugins..."
    fusiondirectory-insert-schema -o "$LDAP_ARGS" \
        --insert \
        /etc/ldap/schema/fusiondirectory/mail-fd.schema \
        /etc/ldap/schema/fusiondirectory/mail-fd-conf.schema \
        /etc/ldap/schema/fusiondirectory/systems-fd.schema \
        /etc/ldap/schema/fusiondirectory/service-fd.schema \
        /etc/ldap/schema/fusiondirectory/systems-fd-conf.schema

    envsubst < /fusiondirectory.conf > /etc/fusiondirectory/fusiondirectory.conf
    yes Yes | fusiondirectory-setup --check-config
    fusiondirectory-setup --yes --check-ldap << EOF
admin@$LDAP_DOMAIN
$FUSIONDIRECTORY_PASSWORD
$FUSIONDIRECTORY_PASSWORD
EOF
    touch /.setup
fi

. /etc/apache2/envvars
/usr/sbin/apache2 -D FOREGROUND
