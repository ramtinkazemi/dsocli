stage=$1

dso template list -u -g -f json | dso template delete -g -f json -i - > /dev/null
dso template list -u -g -s $stage -f json | dso template delete -g -s $stage -f json -i - > /dev/null
dso template list -u -n -f json | dso template delete -n -f json -i - > /dev/null
dso template list -u -n -s $stage -f json | dso template delete -n -s $stage -f json -i - > /dev/null
dso template list -u -f json | dso template delete -f json -i - > /dev/null
dso template list -u -s $stage -f json | dso template delete -s $stage -f json -i - > /dev/null
dso template list -u -s $stage/2 -f json | dso template delete -s $stage/2 -f json -i - > /dev/null
