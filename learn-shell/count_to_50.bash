#!/bin/bash

num=$1
if [ $# -eq 0 ]; then
  read -p "Please provide time delay in seconds : " num
fi

if [[ $num =~ ^[0-9]+$ ]]; then
  for i in {0..50}
  do
    printf "$i "
    sleep $num
  done
else
  echo "[ERROR] Time delay must be an integer."
fi
