#!/usr/bin/env bash

#### Author: Hung Tran
#### Date 08/10/2018
#### Description: Create Spinner for display progress bar (UI)

# Executing other process and grad its PID, plus dump output to somewhere else, & mean run in background
# /usr/bin/bash myshell.sh &>/dev/null &
# pid=$!

i=1
x=0
sp="/~\|"
while [ $x -lt 100 ] # kill -0 $pid &>/dev/null
do
  echo -ne "\r[${sp:i++%${#sp}:1}] | "
  
  for j in {0..x}
  do
    echo -n "#"
  done
  
  let "x+=1"
  sleep 0.1
done

# This is 'check mark'
# echo -e "\xE2\x9C\x94"

# This is 'cross mark'
# echo -e "\xE2\x9D\x8C"
