#!/usr/bin/expect

spawn openssl req -config intermediate/openssl.cnf -new -sha256 -key intermediate/private/$1
