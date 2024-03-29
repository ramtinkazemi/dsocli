#!/bin/bash
set -e -o pipefail
set +x

## printf "\n\nUSAGE: $0 <namespace [test-ns]> <application [test-app]> <stage [test-stage]> <provider [parameter/local/v1]>\n\n"

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

export global_parameter='global parameter'
export global_stage_parameter='global stage parameter'
export namespace_parameter='namespace parameter'
export namespace_stage_parameter='namespace stage parameter'
export app_parameter='app parameter'
export app_stage_parameter='app stage parameter'
export global_overriden_parameter='global overriden parameter'
export global_stage_overriden_parameter='global stage overriden parameter'
export namespace_overriden_parameter='namespace overriden parameter'
export namespace_stage_overriden_parameter='namespace stage overriden parameter'
export app_overriden_parameter='app overriden parameter'
export app_stage_overriden_parameter='app stage overriden parameter'
export app_stage2_overriden_parameter='app stage2 overriden parameter'

###################################
### delete existing parameters, in order to also test overriding configurartions, they will be set later

printf "\n\ndso parameter list -v6 --config \"namespace=$namespace, application=$application, parameter.provider.id=$provider\" --global-scope --uninherited -f json | dso parameter delete -v6 --config \"namespace=$namespace, application=$application, parameter.provider.id=$provider\" --global-scope -i - -f json\n\n"
dso parameter list -v6 --config "namespace=$namespace, application=$application, parameter.provider.id=$provider" --global-scope --uninherited -f json | dso parameter delete -v6 --config "namespace=$namespace, application=$application, parameter.provider.id=$provider" --global-scope -i - -f json 

printf "\n\ndso parameter list -v6 --config \"namespace=$namespace, application=$application, parameter.provider.id=$provider\" -s $stage --global-scope --uninherited -f yaml | dso parameter delete -v6 --config \"namespace=$namespace, application=$application, parameter.provider.id=$provider\" -s $stage --global-scope -i - -f yaml\n\n"
dso parameter list -v6 --config "namespace=$namespace, application=$application, parameter.provider.id=$provider" -s $stage --global-scope --uninherited -f yaml | dso parameter delete -v6 --config "namespace=$namespace, application=$application, parameter.provider.id=$provider" -s $stage --global-scope -i - -f yaml 

printf "\n\ndso parameter list -v6 --config \"namespace=$namespace, application=$application, parameter.provider.id=$provider\" --namespace-scope --uninherited -f json | dso parameter delete -v6 --config \"namespace=$namespace, application=$application, parameter.provider.id=$provider\" --namespace-scope -i -\n\n"
dso parameter list -v6 --config "namespace=$namespace, application=$application, parameter.provider.id=$provider" --namespace-scope --uninherited -f json | dso parameter delete -v6 --config "namespace=$namespace, application=$application, parameter.provider.id=$provider" --namespace-scope -i - 

printf "\n\ndso parameter list -v6 --config \"namespace=$namespace, application=$application, parameter.provider.id=$provider\" -s $stage --namespace-scope --uninherited -f compact | dso parameter delete -v6 --config \"namespace=$namespace, application=$application, parameter.provider.id=$provider\" -s $stage --namespace-scope -i - -f compact\n\n"
dso parameter list -v6 --config "namespace=$namespace, application=$application, parameter.provider.id=$provider" -s $stage --namespace-scope --uninherited -f compact | dso parameter delete -v6 --config "namespace=$namespace, application=$application, parameter.provider.id=$provider" -s $stage --namespace-scope -i - -f compact

printf "\n\ndso parameter list -v6 --config \"namespace=$namespace, application=$application, parameter.provider.id=$provider\" --uninherited -f json | dso parameter delete -v6 --config \"namespace=$namespace, application=$application, parameter.provider.id=$provider\" -i -\n\n"
dso parameter list -v6 --config "namespace=$namespace, application=$application, parameter.provider.id=$provider" --uninherited -f json | dso parameter delete -v6 --config "namespace=$namespace, application=$application, parameter.provider.id=$provider" -i - 

printf "\n\ndso parameter list -v6 --config \"namespace=$namespace, application=$application, parameter.provider.id=$provider\" -s $stage --uninherited -f json | dso parameter delete -v6 --config \"namespace=$namespace, application=$application, parameter.provider.id=$provider\" -s $stage -i -\n\n"
dso parameter list -v6 --config "namespace=$namespace, application=$application, parameter.provider.id=$provider" -s $stage --uninherited -f json | dso parameter delete -v6 --config "namespace=$namespace, application=$application, parameter.provider.id=$provider" -s $stage -i - 

printf "\n\ndso parameter list -v6 --config \"namespace=$namespace, application=$application, parameter.provider.id=$provider\" -s $stage/2 --uninherited -f json | dso parameter delete -v6 --config \"namespace=$namespace, application=$application, parameter.provider.id=$provider\" -s $stage/2 -i -\n\n"
dso parameter list -v6 --config "namespace=$namespace, application=$application, parameter.provider.id=$provider" -s $stage/2 --uninherited -f json | dso parameter delete -v6 --config "namespace=$namespace, application=$application, parameter.provider.id=$provider" -s $stage/2 -i - 


###################################
### Setting configurations
printf "\n\ndso config set -v6 namespace $namespace\n\n"
dso config set -v6 namespace $namespace 

printf "\n\ndso config set -v6 application $application\n\n"
dso config set -v6 application $application 

printf "\n\ndso config set -v6 parameter.provider.id \"$provider\"\n\n"
dso config set -v6 parameter.provider.id "$provider" 


###################################
### add context-specific parameters

printf "\n\ndso parameter add -v6 global_parameter global_parameter --global-scope\n\n"
dso parameter add -v6 global_parameter global_parameter --global-scope 

printf "\n\ndso parameter add -v6 global_stage_parameter global_stage_parameter -s $stage --global-scope\n\n"
dso parameter add -v6 global_stage_parameter global_stage_parameter -s $stage --global-scope 

printf "\n\ndso parameter add -v6 namespace_parameter namespace_parameter --namespace-scope\n\n"
dso parameter add -v6 namespace_parameter namespace_parameter --namespace-scope 

printf "\n\ndso parameter add -v6 namespace_stage_parameter namespace_stage_parameter -s $stage --namespace-scope\n\n"
dso parameter add -v6 namespace_stage_parameter namespace_stage_parameter -s $stage --namespace-scope 

printf "\n\ndso parameter add -v6 app_parameter app_parameter\n\n"
dso parameter add -v6 app_parameter app_parameter 

printf "\n\ndso parameter add -v6 app_stage_parameter app_stage_parameter -s $stage\n\n"
dso parameter add -v6 app_stage_parameter app_stage_parameter -s $stage 

printf "\n\ndso parameter add -v6 app_stage2_parameter app_stage2_parameter -s $stage/2\n\n"
dso parameter add -v6 app_stage2_parameter app_stage2_parameter -s $stage/2 


###################################
### add overriden parameters

printf "\n\ndso parameter add -v6 overriden_parameter global_overriden_parameter --global-scope\n\n"
dso parameter add -v6 overriden_parameter global_overriden_parameter --global-scope 

printf "\n\ndso parameter add -v6 overriden_parameter global_stage_overriden_parameter -s $stage --global-scope\n\n"
dso parameter add -v6 overriden_parameter global_stage_overriden_parameter -s $stage --global-scope 

printf "\n\ndso parameter add -v6 overriden_parameter namespace_overriden_parameter --namespace-scope\n\n"
dso parameter add -v6 overriden_parameter namespace_overriden_parameter --namespace-scope 

printf "\n\ndso parameter add -v6 overriden_parameter namespace_stage_overriden_parameter -s $stage --namespace-scope\n\n"
dso parameter add -v6 overriden_parameter namespace_stage_overriden_parameter -s $stage --namespace-scope 

printf "\n\ndso parameter add -v6 overriden_parameter app_overriden_parameter\n\n"
dso parameter add -v6 overriden_parameter app_overriden_parameter 

printf "\n\ndso parameter add -v6 overriden_parameter app_stage_overriden_parameter -s $stage\n\n"
dso parameter add -v6 overriden_parameter app_stage_overriden_parameter -s $stage 

printf "\n\ndso parameter add -v6 overriden_parameter app_stage2_overriden_parameter -s $stage/2\n\n"
dso parameter add -v6 overriden_parameter app_stage2_overriden_parameter -s $stage/2 

###################################
### get some parameters

printf "\n\ndso parameter get -v6 overriden_parameter -f text\n\n"
dso parameter get -v6 overriden_parameter -f text 

printf "\n\ndso parameter get -v6 overriden_parameter -s $stage -f text\n\n"
dso parameter get -v6 overriden_parameter -s $stage -f text 

printf "\n\ndso parameter get -v6 app_parameter -s $stage -f text\n\n"
dso parameter get -v6 app_parameter -s $stage -f text 

printf "\n\ndso parameter get -v6 app_stage_parameter -s $stage -f text\n\n"
dso parameter get -v6 app_stage_parameter -s $stage -f text 

printf "\n\ndso parameter get -v6 app_stage2_parameter -s $stage/2 -f text\n\n"
dso parameter get -v6 app_stage2_parameter -s $stage/2 -f text 

###################################
### edit some parameters

if [ ${TEST_INTRACTIVELY} = 'yes' ]; then 
    printf "\n\ndso parameter edit -v6 overriden_parameter --global-scope\n\n"
    dso parameter edit -v6 overriden_parameter --global-scope

    printf "\n\ndso parameter edit -v6 overriden_parameter -s $stage --namespace-scope\n\n"
    dso parameter edit -v6 overriden_parameter -s $stage --namespace-scope

    printf "\n\ndso parameter edit -v6 app_parameter\n\n"
    dso parameter edit -v6 app_parameter

    printf "\n\ndso parameter edit -v6 app_stage_parameter -s $stage\n\n"
    dso parameter edit -v6 app_stage_parameter -s $stage

    printf "\n\ndso parameter edit -v6 app_stage2_parameter -s $stage/2\n\n"
    dso parameter edit -v6 app_stage2_parameter -s $stage/2
fi

###################################
### getting history of some parameters

printf "\n\ndso parameter history -v6 overriden_parameter -f json\n\n"
dso parameter history -v6 overriden_parameter -f json 

printf "\n\ndso parameter history -v6 overriden_parameter -s $stage -f json\n\n"
dso parameter history -v6 overriden_parameter -s $stage -f json 

printf "\n\ndso parameter history -v6 app_parameter --query-all -f json\n\n"
dso parameter history -v6 app_parameter --query-all -f json 

printf "\n\ndso parameter history -v6 app_stage_parameter -s $stage --query-all -f json\n\n"
dso parameter history -v6 app_stage_parameter -s $stage --query-all -f json 

printf "\n\ndso parameter history -v6 app_stage2_parameter -s $stage/2 --query-all -f json\n\n"
dso parameter history -v6 app_stage2_parameter -s $stage/2 --query-all -f json 

###################################
### listing some parameters

printf "\n\ndso parameter list -v6 -s $stage --uninherited --query-all overriden_parameter\n\n"
dso parameter list -v6 -s $stage --uninherited --query-all overriden_parameter 

printf "\n\ndso parameter list -v6 -s $stage --uninherited --query-all -f json\n\n"
dso parameter list -v6 -s $stage --uninherited --query-all -f json > .dso/output/app-uninherited-${provider%%/*}.json

printf "\n\ndso parameter list -v6 -s $stage --query-all -f yaml\n\n"
dso parameter list -v6 -s $stage --query-all -f yaml > .dso/output/app-stage-all-${provider%%/*}.yaml

printf "\n\ndso parameter list -v6 -s $stage/2 --query-all -f yaml\n\n"
dso parameter list -v6 -s $stage/2 --query-all -f yaml > .dso/output/app-stage2-all-${provider%%/*}.yaml




