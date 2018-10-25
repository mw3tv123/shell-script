#!/bin/bash

HIDDEN=$(($RANDOM%10))

echo "The HIDDEN number is already generated between [0-9]. Try to guess in 3 attempts."

attempt=0

while [ $attempt -ne 3 ]
do
  let attempt+=1

  while : ; do
    read -p "Attempt No.$attempt : " guess
    if ! [[ $guess =~ ^[0-9]$ ]]; then
      echo "Invalid input. Input must be a numberical digit (1-digit number)."
    else
      break
    fi
  done

  [ $guess -gt $HIDDEN ] && echo "$guess greater than the HIDDEN number."
  [ $guess -lt $HIDDEN ] && echo "$guess less than the HIDDEN number."
  if [ $guess -eq $HIDDEN ]; then
    echo "Correct ! CONGRATULATIONS !!! You WIN THE GAME !!!"
    break
  fi

  if [ $attempt -eq 3 ]; then
    echo "YOU LOSE !!! The HIDDEN number is $HIDDEN."
  fi
done
