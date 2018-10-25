#!/bin/bash

# Inform the rules for the Player
echo "================================="
echo "RULES :"
echo "A 4-digit number will be generated, these digits are different from each other respectively."
echo "Players will have 9 attempts to guess the number."
echo "- For each digit matched perfectly with the hidden number's, players got a GREEN."
echo "- For each digit available but not positionally matched with the hidden number's, players got a WHITE."
echo "================================="

echo "If you are ready, enter any keys to play. Unless, enter \"QUIT\" to quit this game."

# Ask if Player want to play or not
read option
if [[ $option =~ ^[Qq][Ui][Ii][Tt]$ ]]; then
  exit 1
fi

# Generated the hidden number, one by one and unique
function GeneratedHidden {
  a=$(($RANDOM%10)) ;  b=$(($RANDOM%10)) ; c=$(($RANDOM%10)) ; d=$(($RANDOM%10))
  while [[ b -eq a ]]; do
    b=$(($RANDOM%10))
  done
  while [[ c -eq a || c -eq b ]]; do
    c=$(($RANDOM%10))
  done
  while [[ d -eq a || d -eq b || d -eq c ]]; do
    d=$(($RANDOM%10))
  done
  HIDDEN="$a$b$c$d"
}

GeneratedHidden
echo "The number is already generated. Try to guess in 8 attempts."

# Main function
attempt=0

while [[ attempt -ne 8 ]]; do
  let attempt+=1
  green=0
  white=0

  # Check each input valid or not
  while [[ true ]]; do
    read -p "Attempt No.$attempt : " num
    [[ $num =~ ^[1-9][0-9][0-9][0-9]$ ]] && break
  done

  [[ $num == $HIDDEN ]] && { echo "CONGRATULATIONS !!! You win the game." ; break; }
  # Check the number match with the hidden number or not
  for (( i = 0; i < ${#num}; i++ )); do
    for (( j = 0; j < ${#HIDDEN}; j++ )); do
      if [[ ${num:$i:1} == ${HIDDEN:$j:1} ]]; then
        [ $i -eq $j ] && let green+=1 || let white+=1
      fi
    done
  done

  echo "  ==> $num : $green GREEN(s) - $white WHITE(s)"
  echo

  [ $attempt -eq 8 ] && echo "YOU LOSE !!! The hidden number is $HIDDEN."
done
