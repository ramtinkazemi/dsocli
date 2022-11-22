stage=$1

dso secret list -u -g -f json | dso secret delete -g -f json -i - > /dev/null
dso secret list -u -g -s $stage -f json | dso secret delete -g -s $stage -f json -i - > /dev/null
dso secret list -u -n -f json | dso secret delete -n -f json -i - > /dev/null
dso secret list -u -n -s $stage -f json | dso secret delete -n -s $stage -f json -i - > /dev/null
dso secret list -u -f json | dso secret delete -f json -i - > /dev/null
dso secret list -u -s $stage -f json | dso secret delete -s $stage -f json -i - > /dev/null
dso secret list -u -s $stage/2 -f json | dso secret delete -s $stage/2 -f json -i - > /dev/null
