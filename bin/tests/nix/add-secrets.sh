stage=$1

dso secret add gs gs_value -g > /dev/null
dso secret add gss gss_value -g -s $stage > /dev/null
dso secret add ns ns_value -n > /dev/null
dso secret add nss nss_value -n -s $stage > /dev/null
dso secret add as as_value > /dev/null
dso secret add ass ass_value -s $stage > /dev/null
dso secret add as2s as2s_value -s $stage/2 > /dev/null

dso secret add os gos_value -g > /dev/null
dso secret add os gsos_value -g -s $stage > /dev/null
dso secret add os nos_value -n > /dev/null
dso secret add os nsos_value -n -s $stage > /dev/null
dso secret add os aos_value > /dev/null
dso secret add os asos_value -s $stage > /dev/null
dso secret add os as2os_value -s $stage/2 > /dev/null

