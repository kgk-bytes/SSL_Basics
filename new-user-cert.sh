#!/bin/sh
##
##  new-user-cert.sh - create the user cert for personal use.
##  Copyright (c) 2000 Yeak Nai Siew, All Rights Reserved. 
##

# Create the key. This should be done once per cert.
CERT=$1
if [ $# -ne 1 ]; then
        echo "Usage: $0 user@email.address.com"
        exit 1
fi
if [ ! -f $CERT.key ]; then
	echo "No $CERT.key round. Generating one"
	openssl genrsa -out $CERT.key 2048
	echo ""
fi

# Fill the necessary certificate data
CONFIG="user-cert.conf"
cat >$CONFIG <<EOT
[ req ]
default_bits			= 2048
default_keyfile			= user.key
distinguished_name		= req_distinguished_name
string_mask			= nombstr
req_extensions			= v3_req
[ req_distinguished_name ]
countryName                     = Country Name (2 letter code)
countryName_default             = MY
countryName_min                 = 2
countryName_max                 = 2
stateOrProvinceName             = State or Province Name (full name)
stateOrProvinceName_default     = Perak
localityName                    = Locality Name (eg, city)
localityName_default            = Sitiawan
0.organizationName              = Organization Name (eg, company)
0.organizationName_default      = My Directory Sdn Bhd
organizationalUnitName          = Organizational Unit Name (eg, section)
organizationalUnitName_default  = Secure Web Server
commonName			= Common Name (eg, John Doe)
commonName_max			= 64
emailAddress			= Email Address
emailAddress_max		= 40
[ req_ext ]
subjectAltName = @alt_names
[alt_names]
DNS.1   = oracleexample.com
[ v3_req ]
nsCertType			= client,email
basicConstraints		= critical,CA:false
EOT

echo "Fill in certificate data"
openssl req -new -config $CONFIG -key $CERT.key -out $CERT.csr

rm -f $CONFIG

echo ""
echo "You may now run ./sign-user-cert.sh to get it signed"
