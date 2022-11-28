#!/bin/bash
set -e -o pipefail

## printf "\n\nUSAGE: $0 <namespace [test-ns]> <application [test-app]> <stage [test-stage]> <provider [template/local/v1]>\n\n"

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
### delete existing templates, in order to also test overriding configurartions, they will be set later

printf "\n\ndso template list -v6 --config \"namespace=$namespace, application=$application, template.provider.id=$provider\" --global-scope --uninherited -f json | dso template delete -v6 --config \"namespace=$namespace, application=$application, template.provider.id=$provider\" --global-scope -i -\n\n"
dso template list -v6 --config "namespace=$namespace, application=$application, template.provider.id=$provider" --global-scope --uninherited -f json | dso template delete -v6 --config "namespace=$namespace, application=$application, template.provider.id=$provider" --global-scope -i -

printf "\n\ndso template list -v6 --config \"namespace=$namespace, application=$application, template.provider.id=$provider\" -s $stage --global-scope --uninherited -f json | dso template delete  -v6 --config \"namespace=$namespace, application=$application, template.provider.id=$provider\" -s $stage -global-scope -i - -f json\n\n"
dso template list -v6 --config "namespace=$namespace, application=$application, template.provider.id=$provider" -s $stage --global-scope --uninherited -f json | dso template delete -v6 --config "namespace=$namespace, application=$application, template.provider.id=$provider" -s $stage --global-scope -i - -f json

printf "\n\ndso template list -v6 --config \"namespace=$namespace, application=$application, template.provider.id=$provider\" --namespace-scope --uninherited -f json | dso template delete -v6 --config \"namespace=$namespace, application=$application, template.provider.id=$provider\" --namespace-scope -i -\n\n"
dso template list -v6 --config "namespace=$namespace, application=$application, template.provider.id=$provider" --namespace-scope --uninherited -f json | dso template delete -v6 --config "namespace=$namespace, application=$application, template.provider.id=$provider" --namespace-scope -i - -v6

printf "\n\ndso template list -v6 --config \"namespace=$namespace, application=$application, template.provider.id=$provider\" -s $stage --namespace-scope --uninherited -f json | dso template delete -v6 --config \"namespace=$namespace, application=$application, template.provider.id=$provider\" -s $stage --namespace-scope -i - -f json\n\n"
dso template list -v6 --config "namespace=$namespace, application=$application, template.provider.id=$provider" -s $stage --namespace-scope --uninherited -f json | dso template delete -v6  --config "namespace=$namespace, application=$application, template.provider.id=$provider" -s $stage --namespace-scope -i - -f json

printf "\n\ndso template list -v6 --config \"namespace=$namespace, application=$application, template.provider.id=$provider\" --uninherited -f yaml | dso template delete -v6 --config \"namespace=$namespace, application=$application, template.provider.id=$provider\" -i - -f yaml\n\n"
dso template list -v6 --config "namespace=$namespace, application=$application, template.provider.id=$provider" --uninherited -f yaml | dso template delete -v6 --config "namespace=$namespace, application=$application, template.provider.id=$provider" -i - -f yaml

printf "\n\ndso template list -v6 --config \"namespace=$namespace, application=$application, template.provider.id=$provider\" -s $stage --uninherited -f json | dso template delete -v6 --config \"namespace=$namespace, application=$application, template.provider.id=$provider\" -s $stage -i - -f json\n\n"
dso template list -v6 --config "namespace=$namespace, application=$application, template.provider.id=$provider" -s $stage --uninherited -f json | dso template delete -v6 --config "namespace=$namespace, application=$application, template.provider.id=$provider" -s $stage -i - -f json

printf "\n\ndso template list -v6 --config \"namespace=$namespace, application=$application, template.provider.id=$provider\" -s $stage/2 --uninherited -f json | dso template delete -v6 --config \"namespace=$namespace, application=$application, template.provider.id=$provider\" -s $stage/2 -i - -f json\n\n"
dso template list -v6 --config "namespace=$namespace, application=$application, template.provider.id=$provider" -s $stage/2 --uninherited -f json | dso template delete -v6 --config "namespace=$namespace, application=$application, template.provider.id=$provider" -s $stage/2 -i - -f json

###################################
### Setting configurations
printf "\n\ndso config set -v6 namespace $namespace\n\n"
dso config set -v6 namespace $namespace

printf "\n\ndso config set -v6 application $application\n\n"
dso config set -v6 application $application

printf "\n\ndso config set -v6 template.provider.id \"$provider\"\n\n"
dso config set -v6 template.provider.id "$provider"


###################################
### add context-specific templates

pwd 

printf "\n\ndso template add sample-templates/global-template --global-scope -v6\n\n"
dso template add sample-templates/global-template --global-scope -v6

printf "\n\ndso template add sample-templates/global-stage-template global_stage_template -s $stage --global-scope -v6\n\n"
dso template add sample-templates/global-stage-template global_stage_template -s $stage --global-scope -v6

printf "\n\ndso template add sample-templates/namespace-template namespace_template -r '**/*' --namespace-scope -v6\n\n"
dso template add sample-templates/namespace-template namespace_template -r '**/*' --namespace-scope -v6

printf "\n\ndso template add sample-templates/namespace-stage-template namespace_stage_template -r '.dso/output/*' -s $stage --namespace-scope -v6\n\n"
dso template add sample-templates/namespace-stage-template namespace_stage_template -r '.dso/output/*' -s $stage --namespace-scope -v6

printf "\n\ndso template add sample-templates/app-template app_template -r '.dso/output/*' -v6\n\n"
dso template add sample-templates/app-template app_template -r '.dso/output/*' -v6

printf "\n\ndso template add sample-templates/app-stage-template app_stage_template -r '.dso/output/*' -s $stage -v6\n\n"
dso template add sample-templates/app-stage-template app_stage_template -r '.dso/output/*' -s $stage -v6

printf "\n\ndso template add sample-templates/app-stage2-template app_stage2_template -r '.dso/output/*' -s $stage/2 -v6\n\n"
dso template add sample-templates/app-stage2-template app_stage2_template -r '.dso/output/*' -s $stage/2 -v6

###################################
### add overriden templates

printf "\n\ndso template add sample-templates/global-template-overriden overriden_template -r '.dso/output/*' --global-scope -v6\n\n"
dso template add sample-templates/global-template-overriden overriden_template -r '.dso/output/*' --global-scope

printf "\n\ndso template add sample-templates/global-stage-template-overriden overriden_template -r '.dso/output/*' -s $stage --global-scope -v6\n\n"
dso template add sample-templates/global-stage-template-overriden overriden_template -r '.dso/output/*' -s $stage --global-scope

printf "\n\ndso template add sample-templates/namespace-template-overriden overriden_template -r '.dso/output/*' --namespace-scope -v6\n\n"
dso template add sample-templates/namespace-template-overriden overriden_template -r '.dso/output/*' --namespace-scope

printf "\n\ndso template add sample-templates/namespace-stage-template-overriden overriden_template -r '.dso/output/*' -s $stage --namespace-scope -v6\n\n"
dso template add sample-templates/namespace-stage-template-overriden overriden_template -r '.dso/output/*' -s $stage --namespace-scope

printf "\n\ndso template add sample-templates/app-template-overriden overriden_template -r '.dso/output/*' -v6\n\n"
dso template add sample-templates/app-template-overriden overriden_template -r '.dso/output/*'

printf "\n\ndso template add sample-templates/app-stage-template-overriden overriden_template -r '.dso/output/*' -s $stage -v6\n\n"
dso template add sample-templates/app-stage-template-overriden overriden_template -r '.dso/output/*' -s $stage

printf "\n\ndso template add sample-templates/app-stage2-template-overriden overriden_template -r '.dso/output/*' -s $stage/2 -v6\n\n"
dso template add -v6 sample-templates/app-stage2-template-overriden overriden_template -r '.dso/output/*' -s $stage/2

###################################
### get some templates

printf "\n\ndso template get -v6 overriden_template --global-scope -f text\n\n"
dso template get overriden_template -v6 --global-scope -f text

printf "\n\ndso template get -v6 overriden_template -s $stage -f text\n\n"
dso template get overriden_template -v6 -s $stage -f text

printf "\n\ndso template get -v6 overriden_template -s $stage/2 -f text\n\n"
dso template get overriden_template -v6 -s $stage/2 -f text

printf "\n\ndso template get -v6 app_template -s $stage -f text\n\n"
dso template get -v6 app_template -s $stage -f text

printf "\n\ndso template get -v6 app_stage_template -s $stage -f text\n\n"
dso template get -v6 app_stage_template -s $stage -f text

printf "\n\ndso template get -v6 app_stage2_template -s $stage/2 -f text\n\n"
dso template get -v6 app_stage2_template -s $stage/2 -f text


###################################
### edit some templates

if [ ${TEST_INTRACTIVELY} = 'yes' ]; then 

    printf "\n\ndso template edit -v6 overriden_template --global-scope\n\n"
    dso template edit overriden_template -v6 --global-scope

    printf "\n\ndso template edit -v6 overriden_template  -s $stage --namespace-scope\n\n"
    dso template edit overriden_template -v6  -s $stage --namespace-scope

    printf "\n\ndso template edit -v6 app_template\n\n"
    dso template edit -v6 app_template

    printf "\n\ndso template edit -v6 app_stage_template -s $stage\n\n"
    dso template edit -v6 app_stage_template -s $stage

    printf "\n\ndso template edit -v6 app_stage2_template -s $stage/2\n\n"
    dso template edit -v6 app_stage2_template -s $stage/2
fi

###################################
### getting history of some templates

printf "\n\ndso template history -v6 overriden_template -f json\n\n"
dso template history -v6 overriden_template -f json -v6

printf "\n\ndso template history -v6 overriden_template -s $stage -f json\n\n"
dso template history -v6 overriden_template -s $stage -f json -v6

printf "\n\ndso template history -v6 app_template --query-all -f json\n\n"
dso template history -v6 app_template --query-all -f json -v6

printf "\n\ndso template history -v6 app_stage_template -s $stage --query-all -f json\n\n"
dso template history -v6 app_stage_template -s $stage --query-all -f json -v6

printf "\n\ndso template history -v6 app_stage2_template -s $stage/2 --query-all -f json\n\n"
dso template history -v6 app_stage2_template -s $stage/2 --query-all -f json -v6

###################################
### listing some templates

printf "\n\ndso template list -v6 -s $stage --uninherited --query-all overriden_template\n\n"
dso template list -v6 -s $stage --uninherited --query-all overriden_template

printf "\n\ndso template list -v6 -s $stage --uninherited --query-all -f json\n\n"
dso template list -v6 -s $stage --uninherited --include-contents --query-all -f json > .dso/output/app-uninherited-${provider%%/*}.json

printf "\n\ndso template list -v6 -s $stage --query-all -f yaml\n\n"
dso template list -v6 -s $stage --include-contents --query-all -f yaml > .dso/output/app-stage-all-${provider%%/*}.yaml

printf "\n\ndso template list -v6 -s $stage/2 --query-all -f yaml\n\n"
dso template list -v6 -s $stage/2 --include-contents --query-all -f yaml > .dso/output/app-stage2-all-${provider%%/*}.yaml

###################################
### rendering templates

printf "\n\ndso template render -v6 -s $stage overriden_template\n\n"
dso template render -v6 -s $stage overriden_template 

printf "\n\ndso template render -v6 -s $stage\n\n"
dso template render -v6 -s $stage

printf "\n\ndso template render -v6 -s $stage/2\n\n"
dso template render -v6 -s $stage/2


