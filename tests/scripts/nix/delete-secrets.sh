#!/bin/bash

dso secret list -u -g -f json | dso secret delete -g -f json -i - > /dev/null
dso secret list -u -g -s dev -f json | dso secret delete -g -s dev -f json -i - > /dev/null
dso secret list -u -n -f json | dso secret delete -n -f json -i - > /dev/null
dso secret list -u -n -s dev -f json | dso secret delete -n -s dev -f json -i - > /dev/null
dso secret list -u -f json | dso secret delete -f json -i - > /dev/null
dso secret list -u -s dev -f json | dso secret delete -s dev -f json -i - > /dev/null
