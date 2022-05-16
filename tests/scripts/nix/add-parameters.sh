#!/bin/bash

dso parameter add gp gp_value -g > /dev/null
dso parameter add gsp gsp_value -g -s dev > /dev/null
dso parameter add np np_value -n > /dev/null
dso parameter add nsp nsp_value -n -s dev > /dev/null
dso parameter add ap ap_value > /dev/null
dso parameter add asp asp_value -s dev > /dev/null

dso parameter add op gop_value -g > /dev/null
dso parameter add op gsop_value -g -s dev > /dev/null
dso parameter add op nop_value -n > /dev/null
dso parameter add op nsop_value -n -s dev > /dev/null
dso parameter add op aop_value > /dev/null
dso parameter add op asop_value -s dev > /dev/null

