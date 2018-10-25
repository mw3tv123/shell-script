#!/bin/bash

read -p "Please provide the directory: " dic

if [ -d $dic ]; then
  echo "========== Contents of directory $dic =========="
  ls -l $dic
elif [ -f $dic ]; then
  echo "$dic is not a directory."
else
  echo "$dic dose not exist."
fi
