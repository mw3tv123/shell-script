#!/bin/bash

while [[ $num -ne 3 ]]; do
  printf "\t1 - Execute list.bash\n\t2 - Execute month.bash\n\t3 - Quit\n\n"
  read -p "Please input a number : " num
  case $num in
    1) echo "=== Executing list.bash ===" && ./list.bash ;;
    2) echo "=== Executing month.bash ===" && ./month.bash ;;
    3) ;;
    *) echo "Invalid Input. Please try again." ;;
  esac
done
