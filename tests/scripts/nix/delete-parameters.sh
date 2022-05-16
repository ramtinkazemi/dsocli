#!/bin/bash

dso parameter list -u -g -f json | dso parameter delete -g -f json -i - > /dev/null
dso parameter list -u -g -s dev -f json | dso parameter delete -g -s dev -f json -i - > /dev/null
dso parameter list -u -n -f json | dso parameter delete -n -f json -i - > /dev/null
dso parameter list -u -n -s dev -f json | dso parameter delete -n -s dev -f json -i - > /dev/null
dso parameter list -u -f json | dso parameter delete -f json -i - > /dev/null
dso parameter list -u -s dev -f json | dso parameter delete -s dev -f json -i - > /dev/null
