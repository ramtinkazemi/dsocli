stage=$1

dso parameter list -u -g -f json | dso parameter delete -g -f json -i - -v6 > /dev/null
dso parameter list -u -g -s $stage -f json | dso parameter delete -g -s $stage -f json -i - -v6 > /dev/null
dso parameter list -u -n -f json | dso parameter delete -n -f json -i - -v6 > /dev/null
dso parameter list -u -n -s $stage -f json | dso parameter delete -n -s $stage -f json -i - -v6 > /dev/null
dso parameter list -u -f json | dso parameter delete -f json -i - -v6 > /dev/null
dso parameter list -u -s $stage -f json | dso parameter delete -s $stage -f json -i - -v6 > /dev/null
dso parameter list -u -s $stage/2 -f json | dso parameter delete -s $stage/2 -f json -i - -v6 > /dev/null
