if [ "$1" = "$2" ]; then
  printf "\n======================== TEST PASSED ========================\n\n"
  exit 0
else
  printf "\n======================== TEST FAILED ========================\nEXPECTED:\n$1\n\nRECEIVED:\n$2\n\n"
  exit 1
fi
