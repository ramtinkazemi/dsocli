dso secret list -u -g -f json | dso secret delete -g -f json -i - > /dev/null
dso secret list -u -g -s dev -f json | dso secret delete -g -s dev -f json -i - > /dev/null
dso secret list -u -n -f json | dso secret delete -n -f json -i - > /dev/null
dso secret list -u -n -s dev -f json | dso secret delete -n -s dev -f json -i - > /dev/null
dso secret list -u -f json | dso secret delete -f json -i - > /dev/null
dso secret list -u -s dev -f json | dso secret delete -s dev -f json -i - > /dev/null


dso secret add gs gs_value -g > /dev/null
dso secret add gss gss_value -g -s dev > /dev/null
dso secret add ns ns_value -n > /dev/null
dso secret add nss nss_value -n -s dev > /dev/null
dso secret add as as_value > /dev/null
dso secret add ass ass_value -s dev > /dev/null

dso secret add os gos_value -g > /dev/null
dso secret add os gsos_value -g -s dev > /dev/null
dso secret add os nos_value -n > /dev/null
dso secret add os nsos_value -n -s dev > /dev/null
dso secret add os aos_value > /dev/null
dso secret add os asos_value -s dev > /dev/null

