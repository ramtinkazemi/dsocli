#!/bin/bash

[ "$1" = "$2" ] || { printf "Assertion failed!\nExpected:\n$1\n\nReceived:\n$2\n"
                      exit 1
                    }
