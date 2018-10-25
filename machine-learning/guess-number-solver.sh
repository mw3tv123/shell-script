#!/usr/bin/env bash

#### Author: Hung Tran Quoc
#### Date: 24/10/2018
#### Description: learn to guess number in shell

if [ $# -eq 0 || [ $1 == '-h' || $1 == '--help' ]]; then
  ./help
  exit 0
fi
