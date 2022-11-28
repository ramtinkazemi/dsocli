#!/bin/bash
set -e -o pipefail

## printf "\n\nUSAGE: $0 <namespace [test-ns]> <application [test-app]> <stage [test-stage]> <provider [secret/local/v1]>\n\n"

bin_path=$(realpath $(dirname $0))
root_path=$(realpath ${bin_path}/../../..)

namespace=${1:-"test-ns"}
application=${2:-"test-app"}
stage=${3:-"test-stage"}
provider=${4:-"local/v1"}

[ -d .dso/output ] || mkdir .dso/output

###################################

export DSO_USE_PAGER=${DSO_USE_PAGER:=no}
export TEST_INTRACTIVELY=${TEST_INTRACTIVELY:=yes}

###################################
export global_secret='global secret'
export global_stage_secret='global stage secret'
export namespace_secret='namespace secret'
export namespace_stage_secret='namespace stage secret'
export app_secret='app secret'
export app_stage_secret='app stage secret'
export global_overriden_secret='global overriden secret'
export global_stage_overriden_secret='global stage overriden secret'
export namespace_overriden_secret='namespace overriden secret'
export namespace_stage_overriden_secret='namespace stage overriden secret'
export app_overriden_secret='app overriden secret'
export app_stage_overriden_secret='app stage overriden secret'
export app_stage2_overriden_secret='app stage2 overriden secret'


###################################
### delete existing secrets, in order to also test overriding configurartions, they will be set later

printf "\n\ndso secret list -v6 --config \"namespace=$namespace, application=$application, secret.provider.id=$provider\" --global-scope --uninherited -f json | dso secret delete -v6 --config \"namespace=$namespace, application=$application, secret.provider.id=$provider\" --global-scope -i -\n\n"
dso secret list -v6 --config "namespace=$namespace, application=$application, secret.provider.id=$provider" --global-scope --uninherited -f json | dso secret delete -v6 --config "namespace=$namespace, application=$application, secret.provider.id=$provider" --global-scope -i -

printf "\n\ndso secret list -v6 -s $stage --config \"namespace=$namespace, application=$application, secret.provider.id=$provider\" --global-scope --uninherited -f yaml | dso secret delete -v6 -s $stage --config \"namespace=$namespace, application=$application, secret.provider.id=$provider\" --global-scope -i - -f yaml\n\n"
dso secret list -v6 -s $stage --config "namespace=$namespace, application=$application, secret.provider.id=$provider" --global-scope --uninherited -f yaml | dso secret delete -v6 -s $stage --config "namespace=$namespace, application=$application, secret.provider.id=$provider" --global-scope -i - -f yaml

printf "\n\ndso secret list -v6 --config \"namespace=$namespace, application=$application, secret.provider.id=$provider\" --namespace-scope --uninherited -f compact | dso secret delete -v6 --config \"namespace=$namespace, application=$application, secret.provider.id=$provider\" --namespace-scope -i - -f compact\n\n"
dso secret list -v6 --config "namespace=$namespace, application=$application, secret.provider.id=$provider" --namespace-scope --uninherited -f compact | dso secret delete -v6 --config "namespace=$namespace, application=$application, secret.provider.id=$provider" --namespace-scope -i - -f compact

printf "\n\ndso secret list -v6 -s $stage --config \"namespace=$namespace, application=$application, secret.provider.id=$provider\" --namespace-scope --uninherited -f json | dso secret delete -v6 -s $stage --config \"namespace=$namespace, application=$application, secret.provider.id=$provider\" --namespace-scope -i - -f json\n\n"
dso secret list -v6 -s $stage --config "namespace=$namespace, application=$application, secret.provider.id=$provider" --namespace-scope --uninherited -f json | dso secret delete -v6 -s $stage --config "namespace=$namespace, application=$application, secret.provider.id=$provider" --namespace-scope -i - -f json

printf "\n\ndso secret list -v6 --config \"namespace=$namespace, application=$application, secret.provider.id=$provider\" --uninherited -f yaml | dso secret delete -v6 --config \"namespace=$namespace, application=$application, secret.provider.id=$provider\" -i - -f yaml\n\n"
dso secret list -v6 --config "namespace=$namespace, application=$application, secret.provider.id=$provider" --uninherited -f yaml | dso secret delete -v6 --config "namespace=$namespace, application=$application, secret.provider.id=$provider" -i - -f yaml

printf "\n\ndso secret list -v6 -s $stage --config \"namespace=$namespace, application=$application, secret.provider.id=$provider\" --uninherited -f json | dso secret delete -v6 -s $stage --config \"namespace=$namespace, application=$application, secret.provider.id=$provider\" -i - -f json\n\n"
dso secret list -v6 -s $stage --config "namespace=$namespace, application=$application, secret.provider.id=$provider" --uninherited -f json | dso secret delete -v6 -s $stage --config "namespace=$namespace, application=$application, secret.provider.id=$provider" -i - -f json

printf "\n\ndso secret list -v6 -s $stage/2 --config \"namespace=$namespace, application=$application, secret.provider.id=$provider\" --uninherited -f json | dso secret delete -v6 -s $stage/2 --config \"namespace=$namespace, application=$application, secret.provider.id=$provider\" -i - -f json\n\n"
dso secret list -v6 -s $stage/2 --config "namespace=$namespace, application=$application, secret.provider.id=$provider" --uninherited -f json | dso secret delete -v6 -s $stage/2 --config "namespace=$namespace, application=$application, secret.provider.id=$provider" -i - -f json


###################################
### Setting configurations
printf "\n\ndso config set -v6 namespace $namespace\n\n"
dso config set -v6 namespace $namespace

printf "\n\ndso config set -v6 application $application\n\n"
dso config set -v6 application $application

printf "\n\ndso config set -v6 parameter.provider.id \"$provider\"\n\n"
dso config set -v6 parameter.provider.id "$provider"


###################################
### add context-specific secrets

printf "\n\ncat <<EOF | dso secret add -v6 --global-scope -f compact -i -
global_secret=global_secret
EOF\n\n"
cat <<EOF | dso secret add -v6 --global-scope -f compact -i -
global_secret=global_secret
EOF

printf "\n\ncat <<EOF | dso secret add -v6 -s $stage --global-scope -f compact -i -
global_stage_secret=global_stage_secret
EOF\n\n"
cat <<EOF | dso secret add -v6 -s $stage --global-scope -f compact -i -
global_stage_secret=global_stage_secret
EOF

printf "\n\ncat <<EOF | dso secret add -v6 --namespace-scope -f compact -i -
namespace_secret=namespace_secret
EOF\n\n"
cat <<EOF | dso secret add -v6 --namespace-scope -f compact -i -
namespace_secret=namespace_secret
EOF

printf "\n\ncat <<EOF | dso secret add -v6 -s $stage --namespace-scope -f compact -i -
namespace_stage_secret=namespace_stage_secret
EOF\n\n"
cat <<EOF | dso secret add -v6 -s $stage --namespace-scope -f compact -i -
namespace_stage_secret=namespace_stage_secret
EOF

printf "\n\ncat <<EOF | dso secret add -v6 -f compact -i -
app_secret=app_secret
EOF\n\n"
cat <<EOF | dso secret add -v6 -f compact -i -
app_secret=app_secret
EOF

printf "\n\ncat <<EOF | dso secret add -v6 -s $stage -f compact -i - 
app_stage_secret=app_stage_secret
EOF\n\n"
cat <<EOF | dso secret add -v6 -s $stage -f compact -i -
app_stage_secret=app_stage_secret
EOF

printf "\n\ndso secret add app_stage2_secret app_stage2_secret -v6 -s $stage/2\n\n"
dso secret add app_stage2_secret app_stage2_secret -v6 -s $stage/2

###################################
### add overriden secrets

printf "\n\ncat <<EOF | dso secret add -v6 --global-scope -f compact -i -
overriden_secret=global_overriden_secret
EOF\n\n"
cat <<EOF | dso secret add -v6 --global-scope -f compact -i -
overriden_secret=global_overriden_secret
EOF

printf "\n\ncat <<EOF | dso secret add -v6 -s $stage --global-scope -f compact -i -
overriden_secret=global_stage_overriden_secret
EOF\n\n"
cat <<EOF | dso secret add -v6 -s $stage --global-scope -f compact -i -
overriden_secret=global_stage_overriden_secret
EOF

printf "\n\ncat <<EOF | dso secret add -v6 --namespace-scope -f compact -i - 
overriden_secret=namespace_overriden_secret
EOF\n\n"
cat <<EOF | dso secret add -v6 --namespace-scope -f compact -i -
overriden_secret=namespace_overriden_secret
EOF

printf "\n\ncat <<EOF | dso secret add -v6 -s $stage --namespace-scope -f compact -i - 
overriden_secret=namespace_stage_overriden_secret
EOF\n\n"
cat <<EOF | dso secret add -v6 -s $stage --namespace-scope -f compact -i -
overriden_secret=namespace_stage_overriden_secret
EOF

printf "\n\ncat <<EOF | dso secret add -v6 -f compact -i -
overriden_secret=app_overriden_secret
EOF\n\n"
cat <<EOF | dso secret add -v6 -f compact -i -
overriden_secret=app_overriden_secret
EOF

printf "\n\ncat <<EOF | dso secret add -v6 -s $stage -f compact -i - 
overriden_secret=app_stage_overriden_secret
EOF\n\n"
cat <<EOF | dso secret add -v6 -s $stage -f compact -i -
overriden_secret=app_stage_overriden_secret
EOF

printf "\n\ndso secret add overriden_secret app_stage2_overriden_secret -v6 -s $stage/2\n\n"
dso secret add overriden_secret app_stage2_overriden_secret -v6 -s $stage/2


###################################
### get some secrets

printf "\n\ndso secret get -v6 overriden_secret -f text\n\n"
dso secret get -v6 overriden_secret -f text

printf "\n\ndso secret get -v6  overriden_secret -s $stage -f text\n\n"
dso secret get -v6 overriden_secret -s $stage -f text

printf "\n\ndso secret get -v6 app_secret -f text\n\n"
dso secret get -v6 app_secret -f text

printf "\n\ndso secret get -v6 app_stage_secret -s $stage -f text\n\n"
dso secret get -v6 app_stage_secret -s $stage -f text

printf "\n\ndso secret get -v6 app_stage2_secret -s $stage/2 -f text\n\n"
dso secret get -v6 app_stage2_secret -s $stage/2 -f text


###################################
### edit some secrets

if [ ${TEST_INTRACTIVELY} = 'yes' ]; then 

    printf "\n\ndso secret edit -v6 overriden_secret --global-scope\n\n"
    dso secret edit -v6 overriden_secret --global-scope -v6

    printf "\n\ndso secret edit -v6 overriden_secret -s $stage --namespace-scope\n\n"
    dso secret edit -v6 overriden_secret -s $stage --namespace-scope

    printf "\n\ndso secret edit -v6 app_secret\n\n"
    dso secret edit -v6 app_secret

    printf "\n\ndso secret edit -v6 app_stage_secret -s $stage\n\n"
    dso secret edit -v6 app_stage_secret -s $stage

    printf "\n\ndso secret edit -v6 app_stage2_secret -s $stage/2\n\n"
    dso secret edit -v6 app_stage2_secret -s $stage/2

fi

###################################
### getting history of some secrets

printf "\n\ndso secret history -v6 overriden_secret -f json\n\n"
dso secret history -v6 overriden_secret -f json

printf "\n\ndso secret history -v6 overriden_secret -s $stage -f json\n\n"
dso secret history -v6 overriden_secret -s $stage -f json

printf "\n\ndso secret history -v6 app_secret  --query-all -f json\n\n"
dso secret history -v6 app_secret --query-all -f json

printf "\n\ndso secret history -v6 app_stage_secret -s $stage --query-all -f json\n\n"
dso secret history -v6 app_stage_secret -s $stage --query-all -f json

printf "\n\ndso secret history -v6 app_stage2_secret -s $stage/2 --query-all -f json\n\n"
dso secret history -v6 app_stage2_secret -s $stage/2 --query-all -f json


###################################
### listing some secrets

printf "\n\ndso secret list -v6 -s $stage --uninherited --query-all overriden_secret\n\n"
dso secret list -v6 -s $stage --uninherited --query-all overriden_secret

printf "\n\ndso secret list -v6 -s $stage --uninherited -d --query-all -f json\n\n"
dso secret list -v6 -s $stage --uninherited -d --query-all -f json > .dso/output/app-stage-uninherited-${provider%%/*}.json

printf "\n\ndso secret list -v6 -s $stage -d --query-all -f yaml\n\n"
dso secret list -v6 -s $stage -d --query-all -f yaml > .dso/output/app-stage-all-${provider%%/*}.yaml

printf "\n\ndso secret list -v6 -s $stage/2 -d --query-all -f yaml\n\n"
dso secret list -v6 -s $stage/2 -d --query-all -f yaml > .dso/output/app-stage2-all-${provider%%/*}.yaml
