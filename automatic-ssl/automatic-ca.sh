#!/usr/bin/env bash

#### Author: Hung Tran
#### Date: 08/10/2018
#### Descriptions: Automated generate SSL Certificate for Web Server


## ---> CONSTAIN VARIABLES <---
ROOT_PW="secretpassword"
INTERMEDIATE_PW="secretpassword"
COUNTRY="VN"
PROVIDE="Ho Chi Minh"
ORGANIZATION="My Org Ltd"
ORGANIZATION_UNIT="My Org Ltd Certificate Authority"
ROOT_COMMON_NAME="My Org Ltd Root CA"
INTERMEDIATE_COMMON_NAME=$(XXX:-"My Org Ltd Intermediate CA")

### Install EXPECT package
which expect | grep 'expect' &> /dev/null
if [ ! $? -eq 0 ]; then
  apt-get install -y expect
fi

echo '[ DONE ]'

### Step 2: Create the Root pair
## - Prepare the Root directory
echo '[ Creating Root directory ... ]'

if [ ! -d /etc/nginx/ssl ]; then
  mkdir /etc/nginx/ssh
fi

cd /etc/nginx/ssh
mkdir certs crl newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial

echo '[ DONE ]'

## - Prepare the configuration file
cp ~/local_ca/openssl.cnf /etc/nginx/ssl/openssl.cnf

## - Create the root key
echo '[ Generating Root Key ... ]'

cd /etc/nginx/ssh

# Using 'expect' to automatic fullfill password
expect << END
  spawn openssl genrsa -aes256 -out private/ca.key.pem 4096
  expect "Enter pass phrase for ca.key.pem: "
  send "$ROOT_PW\r"
  expect "Verifying - Enter pass phrase for ca.key.pem: "
  send "$ROOT_PW"
END

chmod 400 private/ca.key.pem

echo '[ DONE ]'

## - Create the Root Certificate
echo '[ Generating Root Certificate ... ]'

cd /etc/nginx/ssl

expect << END
  spawn openssl req -config openssl.cnf -key private/ca.key.pem -new -x509 -days 7300 -sha256 -extensions v3_ca -out certs/ca.cert.pem
  expect "Enter pass phrase for ca.key.pem: "
  send "$ROOT_PW\r"
  expect "[XX]:"
  send "$COUNTRY\r"
  expect "State or Province Name []:"
  send "$PROVIDE\r"
  expect "Locality Name []:"
  send "\r"
  expect "Organization Name []:"
  send "$ORGANIZATION\r"
  expect "Organizational Unit Name []:"
  send "$ORGANIZATION_UNIT\r"
  expect "Common Name []:"
  send "$ROOT_COMMON_NAME\r"
  expect "Email Address []:"
  send "\r"
END

chmod 444 certs/ca.cert.pem

echo '[ DONE ]'

### Step 3: Create Intermediate pair
## - Prepare the Intermediate directory
echo '[ Creating Intermediate directory ... ]'

mkdir /etc/nginx/ssl/intermediate
cd /etc/nginx/ssl/intermediate

mkdir certs crl newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial
echo 1000 > /etc/nginx/ssl/intermediate/crlnumber

echo '[ DONE ]'

## - Create the Intermediate key
echo '[ Generating the Intermediate key ... ]'

cd /etc/nginx/ssl
expect << END
  spawn openssl genrsa -aes256 -out intermediate/private/intermediate.key.pem 4096
  expect "Enter pass phrase for intermediate.key.pem: "
  send "$INTERMEDIATE_PW\r"
  expect "Verifying - Enter pass phrase for intermediate.key.pem: "
  send "$INTERMEDIATE_PW\r"
END

chmod 400 intermediate/private/intermediate.key.pem

echo '[ DONE ]'

## - Create the Intermediate Certificate
echo '[ Generating Intermediate Certificate ... ]'

cd /etc/nginx/ssl

# This generate a CSR file for signing the Intermediate Certificate
expect << END
  spawn openssl req -config intermediate/openssl.cnf -new -sha256 -key intermediate/private/intermediate.keey.pem -out intermediate/csr/intermediate.csr.pem
  expect "Enter pass phrase for intermediate.key.pem: "
  send "$INTERMEDIATE_PW\r"
  expect "Country Name (2 letter code) [XX]: "
  send "$COUNTRY\r"
  expect "State or Province Name []:"
  send "$PROVIDE\r"
  expect "Locality Name []:"
  send "\r"
  expect "Organization Name []:"
  send "$ORGANIZATION\r"
  expect "Organizational Unit Name []:"
  send "$ORGANIZATION_UNIT\r"
  expect "Common Name []:"
  send "$INTERMEDIATE_COMMON_NAME\r"
  expect "Email Address []:"
  send "\r"
END

# Using Root Certificate to sign Intermediate CSR file
expect << END
  spawn openssl ca -config openssl.cnf -extensions v3_intermediate_ca -days 3650 -notext -md sha256 -in intermediate/csr/intermediate.csr.pem -out intermediate/certs/intermediate.cert.pem
  expect "Enter pass phrase for ca.key.pem: "
  sent "$INTERMEDIATE_PW\r"
  expect "*[y/n]:"
  sent "y\r"
END

chmod 444 intermediate/certs/intermediate.cert.pem

echo '[ DONE ]'

## - Create the certificate chain file
echo '[ Creating certificate chain file ... ]'

# File ca-chain.cert.pem must contains contents of Intermediate Cert and Root Cert in order like this:
# Intermediate -> Root
cat intermediate/certs/intermediate.cert.pem certs/ca.cert.pem > intermediate/certs/ca-chain.cert.pem

chmod 444 intermediate/certs/ca-chain.cert.pem

echo '[ DONE ]'

### Step 4: Create Server pair
## - Create Server key
echo '[ Generating Server Key ... ]'

cd /etc/nginx/ssl

openssl genrsa -out intermediate/private/sv2.abc.key.pem 2048

chmod 400 intermediate/private/sv2.abc.key.pem

echo '[ DONE ]'

## - Create Server certificate
echo '[ Generating Server Certificate ... ]'

cd /etc/nginx/ssl

# Create a CSR file from Server Key
expect << END
  expect "Country Name (2 letter code) [XX]:"
  send "$COUNTRY\r"
  expect "State or Province Name []:"
  send "$PROVIDE\r"
  expect "Locality Name []:"
  send "Test Server 2"
  expect "Organization Name []:"
  send "$ORGANIZATION\r"
  expect "Organizational Unit Name []:"
  send "My Web Services\r"
  expect "Common Name []:"
  send "sv2.abc\r"
  expect "Email Address []:"
  send "\r"
END

# Using Intermediate Cert to sign Server CSR file
openssl ca -config intermediate/openssl.cnf -extensions server_cert -days 375 -notext -md sha256 -in intermediate/csr/sv2.abc.csr.pem -out intermediate/certs/sv2.abc.cert.pem

chmod 444 intermediate/certs/sv2.abc.cert.pem

# Update ca-chain Certificate to contain Server Cert in top of the file as the following order:
# Server -> Intermediate -> Root
cat intermediate/certs/sv2.abc.cert.pem intermediate/certs/intermediate.cert.pem certs/ca.cert.pem > intermediate/certs/ca-chain.cert.pem

echo '[ DONE ]'
