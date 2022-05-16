dso parameter list -u -g -f json | dso parameter delete -g -f json -i - > /dev/null
dso parameter list -u -g -s dev -f json | dso parameter delete -g -s dev -f json -i - > /dev/null
dso parameter list -u -n -f json | dso parameter delete -n -f json -i - > /dev/null
dso parameter list -u -n -s dev -f json | dso parameter delete -n -s dev -f json -i - > /dev/null
dso parameter list -u -f json | dso parameter delete -f json -i - > /dev/null
dso parameter list -u -s dev -f json | dso parameter delete -s dev -f json -i - > /dev/null

dso parameter list -s dev

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

dso parameter list -s dev


