#!/bin/sh
##
##  sign-user-cert.sh - sign using our root CA the user cert
##  Copyright (c) 2000 Yeak Nai Siew, All Rights Reserved. 
##

CERT=$1
if [ $# -ne 1 ]; then
        echo "Usage: $0 user@email.address.com"
        exit 1
fi
if [ ! -f $CERT.csr ]; then
        echo "No $CERT.csr round. You must create that first."
	exit 1
fi
# Check for root CA key
if [ ! -f ca.key -o ! -f ca.crt ]; then
	echo "You must have root CA key generated first."
	exit 1
fi

# Sign it with our CA key #

#   make sure environment exists
if [ ! -d ca.db.certs ]; then
    mkdir ca.db.certs
fi
if [ ! -f ca.db.serial ]; then
    echo '01' >ca.db.serial
fi
if [ ! -f ca.db.index ]; then
    cp /dev/null ca.db.index
fi

#  create the CA requirement to sign the cert
cat >ca.config <<EOT
[ ca ]
default_ca              = default_CA
[ default_CA ]
dir                     = .
certs                   = \$dir
new_certs_dir           = \$dir/ca.db.certs
database                = \$dir/ca.db.index
serial                  = \$dir/ca.db.serial
RANDFILE                = \$dir/random-bits
certificate             = \$dir/ca.crt
private_key             = \$dir/ca.key
default_days            = 730
default_crl_days        = 30
default_md              = SHA1
preserve                = yes
x509_extensions		= user_cert
policy                  = policy_anything
[ policy_anything ]
countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = supplied
[ user_cert ]
#SXNetID		= 3:yeak
subjectAltName		= DNS:mywebsite.com
#subjectAltName		= IP:192.168.7.1
basicConstraints	= critical,CA:false
authorityKeyIdentifier	= keyid:always
authorityInfoAccess     = OCSP;URI:http://ocsp.us.oracle.com:6060
extendedKeyUsage	= clientAuth,1.3.6.1.4.1.311.20.2.2
EOT

#extendedKeyUsage        = clientAuth,emailProtection,OCSPSigning,1.3.6.1.4.1.311.20.2.2

#  sign the certificate
echo "CA signing: $CERT.csr -> $CERT.crt:"
openssl ca -config ca.config -out $CERT.crt -infiles $CERT.csr
echo "CA verifying: $CERT.crt <-> CA cert"
openssl verify -CAfile ca.crt $CERT.crt

#  cleanup after SSLeay 
rm -f ca.config
rm -f ca.db.serial.old
rm -f ca.db.index.old

