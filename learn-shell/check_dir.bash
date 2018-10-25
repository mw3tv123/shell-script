#!/bin/bash

dir=$1
if [ $# -eq 0 ]; then
  read -p "Please provide the directory : " dir
fi

if [ -e $dir ]; then
  for file in $(ls $dir)
  do
    if [ -d $dir$file ]; then
      echo "$dir$file is a directory."
      echo "==========================="
      ls -l $dir$file
      echo "==========================="
    else
      echo "$dir$file is a plain file = Total line : $(wc -l < $dir$file)."
    fi
  done
else
  echo "[ERROR] The input directory does not exist."
fi
