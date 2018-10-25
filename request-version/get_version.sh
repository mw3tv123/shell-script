#!/usr/bin/env bash

#### Author: Hung Tran
#### Date: 17/10/2018
#### Description: Get version from the server and echo to screen.

# Check if user have input then inform user --help flag
if [[ $# -eq 0 || $1 == "--help" ]]; then
  cat help
  exit 0
fi

# Check if client can connect to server or not
curl -sSf http://vxupdate.chn.eng.velocix.com/rpms/dist/bundles/full/ &>/dev/null
if [ $? -ne 0 ]; then
  echo -e '[\e[31m ERROR \e[0m] Cannot connect to server! Please try again later!'
  exit 1
fi

# If $2 contain 'LATEST' string then request website to print it to STDOUT
if [[ $2 == *"LATEST" ]]; then
  curl -s "http://vxupdate.chn.eng.velocix.com/rpms/dist/bundles/full/$1/$2" \
  | grep "config bundle_id" | awk '{print $3}' 
  exit 0
fi
# Else echo $2 to STDOUT
echo "=> Version: $2"
