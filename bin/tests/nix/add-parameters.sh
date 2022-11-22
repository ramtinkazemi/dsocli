stage=$1

dso parameter add gp gp_value -g > /dev/null
dso parameter add gsp gsp_value -g -s $stage > /dev/null
dso parameter add np np_value -n > /dev/null
dso parameter add nsp nsp_value -n -s $stage > /dev/null
dso parameter add ap ap_value > /dev/null
dso parameter add asp asp_value -s $stage > /dev/null
dso parameter add as2p as2p_value -s $stage/2 > /dev/null

dso parameter add op gop_value -g > /dev/null
dso parameter add op gsop_value -g -s $stage > /dev/null
dso parameter add op nop_value -n > /dev/null
dso parameter add op nsop_value -n -s $stage > /dev/null
dso parameter add op aop_value > /dev/null
dso parameter add op asop_value -s $stage > /dev/null
dso parameter add op as2op_value -s $stage/2 > /dev/null

