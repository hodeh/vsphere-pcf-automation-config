#!/bin/bash
set -e

if [ $#  -lt 1 ] ; then
    echo " #1-foundation name,must present as arguments "
    exit 1

fi


PCF_DOMAIN_NAME="pez.pivotal.io"
PCF_SUBDOMAIN_NAME="haas-173"


cat > ./${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME}.cnf <<-EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
C=US
ST=Colorado
L=Boulder
O=PIVOTAL, INC.
OU=EDUCATION
CN = ${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME}

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = *.${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME}
DNS.2 = *.login.${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME}
DNS.3 = *.uaa.${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME}
DNS.4 = *.apps.${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME}
DNS.5 = *.run.${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME}
DNS.6 = *.login.run.${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME}
DNS.7 = *.uaa.run.${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME}
DNS.8 = *.cfapps.${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME}

EOF

openssl req -x509 \
  -newkey rsa:2048 \
  -nodes \
  -keyout ${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME}.key \
  -out ${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME}.cert \
  -config ./${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME}.cnf

PRIVATE_KEY=$(<${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME}.key)
echo "$PRIVATE_KEY"
CERT=$(<${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME}.cert)
echo "$CERT"

credhub set -n "/$1/srt-networking-pk" -t value -v "$PRIVATE_KEY"
credhub set -n "/$1/srt-uaa-pk" -t value -v "$PRIVATE_KEY"

credhub set -n "/$1/srt-networking-cert" -t value -v "$CERT"
credhub set -n "/$1/srt-uaa-cert" -t value -v "$CERT"
