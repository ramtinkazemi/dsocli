#!/bin/bash

dso template list -u -g -f json | dso template delete -g -f json -i - > /dev/null
dso template list -u -g -s dev -f json | dso template delete -g -s dev -f json -i - > /dev/null
dso template list -u -n -f json | dso template delete -n -f json -i - > /dev/null
dso template list -u -n -s dev -f json | dso template delete -n -s dev -f json -i - > /dev/null
dso template list -u -f json | dso template delete -f json -i - > /dev/null
dso template list -u -s dev -f json | dso template delete -s dev -f json -i - > /dev/null
