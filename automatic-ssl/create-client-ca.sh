#!/usr/bin/env bash

#### Author: HUNG TRAN
#### Date: 10/10/2018
#### Descriptions: This script uses to create Server Certificate.

# Install 'expect' command
which expect | grep 'expect' &> /dev/null
if [ $? -ne 0 ]; then
  apt install -y expect
fi

cd $ROOT_CA_DIR

# Create the Intermediate key using expect
openssl genrsa -out intermediate/private/$SERVER_NAME.key.pem 2048

# Change permission of the key for root only
chmod 400 intermediate/private/$SERVER_NAME.key.pem

# Create the Server Certificate Signing Request - CSR file
if [ -e $SERVER_NAME.csr.pem ]; then
  rm $SERVER_NAME.csr.pem
fi

expect << END
  spawn openssl req -config intermediate/openssl.cnf -new -sha256 -key intermediate/private/$SERVER_NAME.key.pem -out intermediate/csr/$SERVER_NAME.csr.pem
  expect "Country Name*"
  sleep 2
  send "US\r"
  expect "*Province Name*"
  sleep 2
  send "California\r"
  expect "Locality Name*"
  sleep 2
  send "Mountain View\r"
  expect "Organization Name*"
  sleep 2
  send "$ORGANIZATION\r"
  expect "Organization Unit Name*"
  sleep 2
  send "Local Ltd Web Services\r"
  expect "Common Name*"
  sleep 2
  send "$SERVER_NAME\r"
  expect "Email Address*"
  sleep 2
  send "\r"
  expect "#"
END

# Using Intermediate CA to sign for Server CSR file to create Server Certificate
if [ -e $SERVER_NAME.cert.pem]; then
  rm $SERVER_NAME.cert.pem
fi

expect << END
  spawn openssl ca -config intermediate/openssl.cnf -extensions server_cert -days 375 -notext -md sha256 -in intermediate/csr/$SERVER_NAME.csr.pem -out intermediate/certs/$SERVER_NAME.cert.pem
  expect "Enter pass phrase for*"
  sleep 2
  send "$INTERMEDIATE_CA_PASSWORD\r"
  expect "Sign the  certificate?*"
  sleep 5
  send "y\r"
  expect "*commit?*"
  sleep 2
  send "y\r"
  expect "#"
END

# Change permission of the root certificate to Read only
chmod 444 intermediate/certs/$SERVER_NAME.cert.pem

# Verify the root certificate
openssl x509 -noout -text -in intermediate/certs/$SERVER_NAME.cert.pem

# Create the certificate chain file
cat intermediate/certs/$SERVER_NAME.cert.pem intermediate/certs/intermediate.cert.pem certs/ca.cert.pem > intermediate/certs/ca-chain.cert.pem

# Inform user after completed the process
echo "==> Progress generate Server CA was completed!"
echo "- Server CA directory: $ROOT_CA_DIR/intermediate"
echo "- Private key: $ROOT_CA_DIR/intermediate/private"
echo "- Certificate: $ROOT_CA_DIR/intermediate/certs"
