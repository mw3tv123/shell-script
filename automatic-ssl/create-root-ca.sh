#!/usr/bin/env bash

#### Author: HUNG TRAN
#### Date: 09/10/2018
#### Descriptions: This script uses to create Root CA.

source_dir=$(pwd)

# Install 'expect' command
which expect | grep 'expect' &> /dev/null
if [ $? -ne 0 ]; then
  apt install -y expect
fi

# Check if Root directory exists or not
if [ -e $ROOT_CA_DIR ]; then
  rm -r $ROOT_CA_DIR
fi

mkdir -p $ROOT_CA_DIR && cd $ROOT_CA_DIR

# Prepare the Root directory
mkdir certs crl newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial

# Copy and modify OpenSSL's configuration file
cp $source_dir/root-config.txt $ROOT_CA_DIR/openssl.cnf

# Create the Root key using expect
expect << END
  spawn openssl genrsa -aes256 -out private/ca.key.pem 4096
  expect "Enter pass phrase for*"
  sleep 2
  send "$ROOT_CA_PASSWORD\r"
  expect "Verifying - Enter pass phrase for*"
  sleep 2
  send "$ROOT_CA_PASSWORD\r"
  expect "#"
END

# Change permission of the key for root only
chmod 400 private/ca.key.pem

# Create the Root Certificate
expect << END
  spawn openssl req -config openssl.cnf -key private/ca.key.pem -new -x509 -days 7300 -sha256 -extensions v3_ca -out certs/ca.cert.pem
  expect "Enter pass phrase for*"
  sleep 2
  send "$ROOT_CA_PASSWORD\r"
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
  send "$ROOT_COMMON_NAME\r"
  expect "Email Address*"
  sleep 2
  send "\r"
  expect "#"
END

# Change permission of the root certificate to Read only
chmod 444 certs/ca.cert.pem

# Verify the root certificate
openssl x509 -noout -text -in certs/ca.cert.pem

# Inform user after completed the process
echo "==> Progress generate Root CA was completed!"
echo "- Root CA directory: $ROOT_CA_DIR"
echo "- Private key: $ROOT_CA_DIR/private"
echo "- Certificate: $ROOT_CA_DIR/certs"
