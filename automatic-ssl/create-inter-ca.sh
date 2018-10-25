#!/usr/bin/env bash

#### Author: HUNG TRAN
#### Date: 10/10/2018
#### Descriptions: This script uses to create Intermediate CA.

source_dir=$(pwd)

# Install 'expect' command
which expect | grep 'expect' &> /dev/null
if [ $? -ne 0 ]; then
  apt install -y expect
fi

# Check if Intermediate directory exists or not
if [ -e "$ROOT_CA_DIR/intermediate" ]; then
  rm -r $ROOT_CA_DIR/intermediate
fi

mkdir -p $ROOT_CA_DIR/intermediate && cd $ROOT_CA_DIR/intermediate

# Prepare the Intermediate directory
mkdir certs crl csr newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial
echo 1000 > crlnumber

# Copy and modify Intermediate OpenSSL's configuration file
cp $source_dir/intermediate-config.txt $ROOT_CA_DIR/intermediate/openssl.cnf

# Create the Intermediate key using expect
expect << END
  spawn openssl genrsa -aes256 -out private/intermediate.key.pem 4096
  expect "Enter pass phrase for*"
  sleep 2
  send "$INTERMEDIATE_CA_PASSWORD\r"
  expect "Verifying - Enter pass phrase for*"
  sleep 2
  send "$INTERMEDIATE_CA_PASSWORD\r"
  expect "#"
END

# Change permission of the key for root only
chmod 400 private/intermediate.key.pem

# Create the Intermediate Certificate Signing Request - CSR file
expect << END
  spawn openssl req -config openssl.cnf -new -sha256 -key private/intermediate.key.pem -out csr/intermediate.csr.pem
  expect "Enter pass phrase for*"
  sleep 2
  send "$INTERMEDIATE_CA_PASSWORD\r"
  expect "Country Name*"
  sleep 2
  send "$COUNTRY\r"
  expect "*Province Name*"
  sleep 2
  send "$PROVINCE\r"
  expect "Locality Name*"
  sleep 2
  send "\r"
  expect "Organization Name*"
  sleep 2
  send "$ORGANIZATION\r"
  expect "Organization Unit Name*"
  sleep 2
  send "$ORGANIZATION_UNIT\r"
  expect "Common Name*"
  sleep 2
  send "$INTERMEDIATE_COMMON_NAME\r"
  expect "Email Address*"
  sleep 2
  send "\r"
  expect "#"
END

# Using Root CA to sign for Intermediate CSR file to create Intermediate Certificate
cd $ROOT_CA_DIR
expect << END
  spawn openssl ca -config openssl.cnf -extensions v3_intermediate_ca -days 3650 -notext -md sha256 -in intermediate/csr/intermediate.csr.pem -out intermediate/certs/intermediate.cert.pem
  expect "Enter pass phrase for*"
  sleep 2
  send "$INTERMEDIATE_CA_PASSWORD\r"
  expect "Sign the  certificate?*"
  sleep 2
  send "y\r"
  expect "*commit?*"
  sleep 2
  send "y\r"
  expect "#"
END

# Change permission of the root certificate to Read only
chmod 444 intermediate/certs/intermediate.cert.pem

# Verify the root certificate
openssl x509 -noout -text -in intermediate/certs/intermediate.cert.pem

# Create the certificate chain file
cat intermediate/certs/intermediate.cert.pem certs/ca.cert.pem \
  > intermediate/certs/ca-chain.cert.pem

# Inform user after completed the process
echo "==> Progress generate Intermediate CA was completed!"
echo "- Intermediate CA directory: $ROOT_CA_DIR/intermediate"
echo "- Private key: $ROOT_CA_DIR/intermediate/private"
echo "- Certificate: $ROOT_CA_DIR/intermediate/certs"
