#!/bin/bash
set -e -o pipefail

default_provider=local/v1
default_namespace=test-ns
default_namespace=test-namespace
default_application=test-app
default_stage=test-stage
default_working_dir=.

printf "\n\nUSAGE: $0 <namespace [${default_namespace}]> <application [${default_application}]> <stage [${default_stage}]> <provider [${default_provider}]>\n\n"

if [ $1 ]; then
    namespace=$1
else
    namespace=${default_namespace}
fi

if [ $2 ]; then
    application=$2
else
    application=${default_application}
fi

if [ $3 ]; then
    stage=$3
else
    stage=${default_stage}
fi

if [ $4 ]; then
    provider=$4
else
    provider=${default_provider}
fi

###################################

if [ ! -d tests/output/template ]; then
    mkdir tests/output/template
else
    rm -rf tests/output/template/*
fi

###################################

export DSO_ALLOW_STAGE_TEMPLATES=yes


###################################
### delete existing templates, in order to also test overriding configurartions, they will be set later

printf "\n\ndso template list -v5 --config \"namespace=${namespace}, application=${application}, template.provider.id=${provider}\" --global-scope --uninherited -f json | dso template delete -v5 --config \"namespace=${namespace}, application=${application}, template.provider.id=${provider}\" --global-scope -i -\n\n"
dso template list -v5 --config "namespace=${namespace}, application=${application}, template.provider.id=${provider}" --global-scope --uninherited -f json | dso template delete -v5 --config "namespace=${namespace}, application=${application}, template.provider.id=${provider}" --global-scope -i - > /dev/null

printf "\n\ndso template list -v5 --config \"namespace=${namespace}, application=${application}, template.provider.id=${provider}\" -s ${stage} --global-scope --uninherited -f json | dso template delete  -v5 --config \"namespace=${namespace}, application=${application}, template.provider.id=${provider}\" -s ${stage} -global-scope -i - -f json\n\n"
dso template list -v5 --config "namespace=${namespace}, application=${application}, template.provider.id=${provider}" -s ${stage} --global-scope --uninherited -f json | dso template delete -v5 --config "namespace=${namespace}, application=${application}, template.provider.id=${provider}" -s ${stage} --global-scope -i - -f json > /dev/null

printf "\n\ndso template list -v5 --config \"namespace=${namespace}, application=${application}, template.provider.id=${provider}\" --namespace-scope --uninherited -f json | dso template delete -v5 --config \"namespace=${namespace}, application=${application}, template.provider.id=${provider}\" --namespace-scope -i -\n\n"
dso template list -v5 --config "namespace=${namespace}, application=${application}, template.provider.id=${provider}" --namespace-scope --uninherited -f json | dso template delete -v5 --config "namespace=${namespace}, application=${application}, template.provider.id=${provider}" --namespace-scope -i - -v5 > /dev/null

printf "\n\ndso template list -v5 --config \"namespace=${namespace}, application=${application}, template.provider.id=${provider}\" -s ${stage} --namespace-scope --uninherited -f json | dso template delete -v5 --config \"namespace=${namespace}, application=${application}, template.provider.id=${provider}\" -s ${stage} --namespace-scope -i - -f json\n\n"
dso template list -v5 --config "namespace=${namespace}, application=${application}, template.provider.id=${provider}" -s ${stage} --namespace-scope --uninherited -f json | dso template delete -v5  --config "namespace=${namespace}, application=${application}, template.provider.id=${provider}" -s ${stage} --namespace-scope -i - -f json> /dev/null

printf "\n\ndso template list -v5 --config \"namespace=${namespace}, application=${application}, template.provider.id=${provider}\" --uninherited -f yaml | dso template delete -v5 --config \"namespace=${namespace}, application=${application}, template.provider.id=${provider}\" -i - -f yaml\n\n"
dso template list -v5 --config "namespace=${namespace}, application=${application}, template.provider.id=${provider}" --uninherited -f yaml | dso template delete -v5 --config "namespace=${namespace}, application=${application}, template.provider.id=${provider}" -i - -f yaml> /dev/null

printf "\n\ndso template list -v5 --config \"namespace=${namespace}, application=${application}, template.provider.id=${provider}\" -s ${stage} --uninherited -f json | dso template delete -v5 --config \"namespace=${namespace}, application=${application}, template.provider.id=${provider}\" -s ${stage} -i - -f json\n\n"
dso template list -v5 --config "namespace=${namespace}, application=${application}, template.provider.id=${provider}" -s ${stage} --uninherited -f json | dso template delete -v5 --config "namespace=${namespace}, application=${application}, template.provider.id=${provider}" -s ${stage} -i - -f json > /dev/null

printf "\n\ndso template list -v5 --config \"namespace=${namespace}, application=${application}, template.provider.id=${provider}\" -s ${stage}/2 --uninherited -f json | dso template delete -v5 --config \"namespace=${namespace}, application=${application}, template.provider.id=${provider}\" -s ${stage}/2 -i - -f json\n\n"
dso template list -v5 --config "namespace=${namespace}, application=${application}, template.provider.id=${provider}" -s ${stage}/2 --uninherited -f json | dso template delete -v5 --config "namespace=${namespace}, application=${application}, template.provider.id=${provider}" -s ${stage}/2 -i - -f json > /dev/null

###################################
### Setting configurations
printf "\n\ndso config add -v5 namespace ${namespace}\n\n"
dso config add -v5 namespace ${namespace} > /dev/null

printf "\n\ndso config add -v5 application ${application}\n\n"
dso config add -v5 application ${application} > /dev/null

printf "\n\ndso config add -v5 template.provider.id \"${provider}\"\n\n"
dso config add -v5 template.provider.id "${provider}" > /dev/null


###################################
### add context-specific templates

pwd 

printf "\n\ndso template add sample-templates/global-template global_template -r 'tests/output/template/*' --global-scope -v5\n\n"
dso template add sample-templates/global-template global_template -r 'tests/output/template/*' --global-scope -v5 > /dev/null

printf "\n\ndso template add sample-templates/global-stage-template global_stage_template -r 'tests/output/template/*' -s ${stage} --global-scope -v5\n\n"
dso template add sample-templates/global-stage-template global_stage_template -r 'tests/output/template/*' -s ${stage} --global-scope -v5 > /dev/null

printf "\n\ndso template add sample-templates/namespace-template namespace_template -r 'tests/output/template/*' --namespace-scope -v5\n\n"
dso template add sample-templates/namespace-template namespace_template -r 'tests/output/template/*' --namespace-scope -v5 > /dev/null

printf "\n\ndso template add sample-templates/namespace-stage-template namespace_stage_template -r 'tests/output/template/*' -s ${stage} --namespace-scope -v5\n\n"
dso template add sample-templates/namespace-stage-template namespace_stage_template -r 'tests/output/template/*' -s ${stage} --namespace-scope -v5 > /dev/null

printf "\n\ndso template add sample-templates/app-template app_template -r 'tests/output/template/*' -v5\n\n"
dso template add sample-templates/app-template app_template -r 'tests/output/template/*' -v5 > /dev/null

printf "\n\ndso template add sample-templates/app-stage-template app_stage_template -r 'tests/output/template/*' -s ${stage} -v5\n\n"
dso template add sample-templates/app-stage-template app_stage_template -r 'tests/output/template/*' -s ${stage} -v5 > /dev/null

printf "\n\ndso template add sample-templates/app-stage2-template app_stage2_template -r 'tests/output/template/*' -s ${stage}/2 -v5\n\n"
dso template add sample-templates/app-stage2-template app_stage2_template -r 'tests/output/template/*' -s ${stage}/2 -v5 > /dev/null

###################################
### add overriden templates

printf "\n\ndso template add sample-templates/global-template-overriden overriden_template -r 'tests/output/template/*' --global-scope -v5\n\n"
dso template add sample-templates/global-template-overriden overriden_template -r 'tests/output/template/*' --global-scope > /dev/null

printf "\n\ndso template add sample-templates/global-stage-template-overriden overriden_template -r 'tests/output/template/*' -s ${stage} --global-scope -v5\n\n"
dso template add sample-templates/global-stage-template-overriden overriden_template -r 'tests/output/template/*' -s ${stage} --global-scope > /dev/null

printf "\n\ndso template add sample-templates/namespace-template-overriden overriden_template -r 'tests/output/template/*' --namespace-scope -v5\n\n"
dso template add sample-templates/namespace-template-overriden overriden_template -r 'tests/output/template/*' --namespace-scope > /dev/null

printf "\n\ndso template add sample-templates/namespace-stage-template-overriden overriden_template -r 'tests/output/template/*' -s ${stage} --namespace-scope -v5\n\n"
dso template add sample-templates/namespace-stage-template-overriden overriden_template -r 'tests/output/template/*' -s ${stage} --namespace-scope > /dev/null

printf "\n\ndso template add sample-templates/app-template-overriden overriden_template -r 'tests/output/template/*' -v5\n\n"
dso template add sample-templates/app-template-overriden overriden_template -r 'tests/output/template/*' > /dev/null

printf "\n\ndso template add sample-templates/app-stage-template-overriden overriden_template -r 'tests/output/template/*' -s ${stage} -v5\n\n"
dso template add sample-templates/app-stage-template-overriden overriden_template -r 'tests/output/template/*' -s ${stage} > /dev/null

printf "\n\ndso template add sample-templates/app-stage2-template-overriden overriden_template -r 'tests/output/template/*' -s ${stage}/2 -v5\n\n"
dso template add -v5 sample-templates/app-stage2-template-overriden overriden_template -r 'tests/output/template/*' -s ${stage}/2 > /dev/null

###################################
### get some templates

printf "\n\ndso template get -v5 overriden_template --scope Global -f text\n\n"
dso template get overriden_template -v5 --scope Global -f text > /dev/null

printf "\n\ndso template get -v5 overriden_template -s ${stage} -f text\n\n"
dso template get overriden_template -v5 -s ${stage} -f text > /dev/null

printf "\n\ndso template get -v5 overriden_template -s ${stage}/2 -f text\n\n"
dso template get overriden_template -v5 -s ${stage}/2 -f text > /dev/null

printf "\n\ndso template get -v5 app_template -s ${stage} -f text\n\n"
dso template get -v5 app_template -s ${stage} -f text > /dev/null

printf "\n\ndso template get -v5 app_stage_template -s ${stage} -f text\n\n"
dso template get -v5 app_stage_template -s ${stage} -f text > /dev/null

printf "\n\ndso template get -v5 app_stage2_template -s ${stage}/2 -f text\n\n"
dso template get -v5 app_stage2_template -s ${stage}/2 -f text > /dev/null


###################################
### edit some templates

printf "\n\ndso template edit -v5 overriden_template --global-scope\n\n"
dso template edit overriden_template -v5 --global-scope

printf "\n\ndso template edit -v5 overriden_template  -s ${stage} --namespace-scope\n\n"
dso template edit overriden_template -v5  -s ${stage} --namespace-scope

printf "\n\ndso template edit -v5 app_template\n\n"
dso template edit -v5 app_template

printf "\n\ndso template edit -v5 app_stage_template -s ${stage}\n\n"
dso template edit -v5 app_stage_template -s ${stage}

printf "\n\ndso template edit -v5 app_stage2_template -s ${stage}/2\n\n"
dso template edit -v5 app_stage2_template -s ${stage}/2


###################################
### getting history of some templates

printf "\n\ndso template history -v5 overriden_template -f json\n\n"
dso template history -v5 overriden_template -f json -v5 > /dev/null

printf "\n\ndso template history -v5 overriden_template -s ${stage} -f json\n\n"
dso template history -v5 overriden_template -s ${stage} -f json -v5 > /dev/null

printf "\n\ndso template history -v5 app_template -s ${stage} --query-all -f json\n\n"
dso template history -v5 app_template -s ${stage} --query-all -f json -v5 > /dev/null

printf "\n\ndso template history -v5 app_stage_template -s ${stage} --query-all -f json\n\n"
dso template history -v5 app_stage_template -s ${stage} --query-all -f json -v5 > /dev/null

printf "\n\ndso template history -v5 app_stage2_template -s ${stage}/2 --query-all -f json\n\n"
dso template history -v5 app_stage2_template -s ${stage}/2 --query-all -f json -v5 > /dev/null

###################################
### listing some templates

printf "\n\ndso template list -v5 -s ${stage} --uninherited --query-all --filter overriden_template\n\n"
dso template list -v5 -s ${stage} --uninherited --query-all --filter overriden_template > /dev/null

printf "\n\ndso template list -v5 -s ${stage} --uninherited --query-all -f json\n\n"
dso template list -v5 -s ${stage} --uninherited --contents --query-all -f json > tests/output/template/app-uninherited-${provider%%/*}.json

printf "\n\ndso template list -v5 -s ${stage} --query-all -f yaml\n\n"
dso template list -v5 -s ${stage} --contents --query-all -f yaml > tests/output/template/app-stage-all-${provider%%/*}.yaml

printf "\n\ndso template list -v5 -s ${stage}/2 --query-all -f yaml\n\n"
dso template list -v5 -s ${stage}/2 --contents --query-all -f yaml > tests/output/template/app-stage2-all-${provider%%/*}.yaml

###################################
### rendering templates

printf "\n\ndso template render -v5 -s ${stage} --filter overriden_template\n\n"
dso template render -v5 -s ${stage} --filter overriden_template > /dev/null 

printf "\n\ndso template render -v5 -s ${stage}\n\n"
dso template render -v5 -s ${stage} > /dev/null

printf "\n\ndso template render -v5 -s ${stage}/2\n\n"
dso template render -v5 -s ${stage}/2 > /dev/null


