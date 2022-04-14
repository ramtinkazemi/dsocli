set -e

default_provider=local/v1
default_namespace=test-ns
default_namespace=test-namespace
default_application=test-app
default_stage=test-stage
default_working_dir=.

printf "\n\nUSAGE: $0 <namespace [${default_namespace}]> <application [${default_application}]> <stage [${default_stage}]> <working_dir [${default_working_dir}]> <provider [${default_provider}]>\n\n"

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
    working_dir=$4
else
    working_dir=${default_working_dir}
fi

if [ $5 ]; then
    provider=$5
else
    provider=${default_provider}
fi

###################################

if [ ! -d tests/output/parameter ]; then
    mkdir tests/output/parameter
else
    rm -rf tests/output/parameter/*
fi


###################################
### delete existing parameters, in order to also test overriding configurartions, they will be set later

printf "\n\ndso parameter list -v5 -w \"${working_dir}\" --config \"namespace=${namespace}, application=${application}, parameter.provider.id=${provider}\" --global-scope --uninherited -f json | dso parameter delete -v5 -w \"${working_dir}\" --config \"namespace=${namespace}, application=${application}, parameter.provider.id=${provider}\" --global-scope -i - -f json\n\n"
dso parameter list -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, parameter.provider.id=${provider}" --global-scope --uninherited -f json | dso parameter delete -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, parameter.provider.id=${provider}" --global-scope -i - -f json > /dev/null

printf "\n\ndso parameter list -v5 -w \"${working_dir}\" --config \"namespace=${namespace}, application=${application}, parameter.provider.id=${provider}\" -s ${stage} --global-scope --uninherited -f yaml | dso parameter delete -v5 -w \"${working_dir}\" --config \"namespace=${namespace}, application=${application}, parameter.provider.id=${provider}\" -s ${stage} --global-scope -i - -f yaml\n\n"
dso parameter list -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, parameter.provider.id=${provider}" -s ${stage} --global-scope --uninherited -f yaml | dso parameter delete -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, parameter.provider.id=${provider}" -s ${stage} --global-scope -i - -f yaml > /dev/null

printf "\n\ndso parameter list -v5 -w \"${working_dir}\" --config \"namespace=${namespace}, application=${application}, parameter.provider.id=${provider}\" --namespace-scope --uninherited | dso parameter delete -v5 -w \"${working_dir}\" --config \"namespace=${namespace}, application=${application}, parameter.provider.id=${provider}\" --namespace-scope -i -\n\n"
dso parameter list -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, parameter.provider.id=${provider}" --namespace-scope --uninherited | dso parameter delete -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, parameter.provider.id=${provider}" --namespace-scope -i - > /dev/null

printf "\n\ndso parameter list -v5 -w \"${working_dir}\" --config \"namespace=${namespace}, application=${application}, parameter.provider.id=${provider}\" -s ${stage} --namespace-scope --uninherited -f shell | dso parameter delete -v5 -w \"${working_dir}\" --config \"namespace=${namespace}, application=${application}, parameter.provider.id=${provider}\" -s ${stage} --namespace-scope -i - -f shell\n\n"
dso parameter list -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, parameter.provider.id=${provider}" -s ${stage} --namespace-scope --uninherited -f shell | dso parameter delete -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, parameter.provider.id=${provider}" -s ${stage} --namespace-scope -i - -f shell > /dev/null

printf "\n\ndso parameter list -v5 -w \"${working_dir}\" --config \"namespace=${namespace}, application=${application}, parameter.provider.id=${provider}\" --uninherited | dso parameter delete -v5 -w \"${working_dir}\" --config \"namespace=${namespace}, application=${application}, parameter.provider.id=${provider}\" -i -\n\n"
dso parameter list -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, parameter.provider.id=${provider}" --uninherited | dso parameter delete -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, parameter.provider.id=${provider}" -i - > /dev/null

printf "\n\ndso parameter list -v5 -w \"${working_dir}\" --config \"namespace=${namespace}, application=${application}, parameter.provider.id=${provider}\" -s ${stage} --uninherited | dso parameter delete -v5 -w \"${working_dir}\" --config \"namespace=${namespace}, application=${application}, parameter.provider.id=${provider}\" -s ${stage} -i -\n\n"
dso parameter list -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, parameter.provider.id=${provider}" -s ${stage} --uninherited | dso parameter delete -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, parameter.provider.id=${provider}" -s ${stage} -i - > /dev/null

printf "\n\ndso parameter list -v5 -w \"${working_dir}\" --config \"namespace=${namespace}, application=${application}, parameter.provider.id=${provider}\" -s ${stage}/2 --uninherited | dso parameter delete -v5 -w \"${working_dir}\" --config \"namespace=${namespace}, application=${application}, parameter.provider.id=${provider}\" -s ${stage}/2 -i -\n\n"
dso parameter list -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, parameter.provider.id=${provider}" -s ${stage}/2 --uninherited | dso parameter delete -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, parameter.provider.id=${provider}" -s ${stage}/2 -i - > /dev/null


###################################
### Setting configurations
printf "\n\ndso config set -v5 -w \"${working_dir}\" namespace ${namespace}\n\n"
dso config set -v5 -w "${working_dir}" namespace ${namespace}

printf "\n\ndso config set -v5 -w \"${working_dir}\" application ${application}\n\n"
dso config set -v5 -w "${working_dir}" application ${application}

printf "\n\ndso config set -v5 -w \"${working_dir}\" parameter.provider.id \"${provider}\"\n\n"
dso config set -v5 -w "${working_dir}" parameter.provider.id "${provider}"


###################################
### add context-specific parameters

printf "\n\ndso parameter add -v5 -w \"${working_dir}\" global.parameter global_parameter --global-scope\n\n"
dso parameter add -v5 -w "${working_dir}" global.parameter global_parameter --global-scope > /dev/null

printf "\n\ndso parameter add -v5 -w \"${working_dir}\" global.stage_parameter global_stage_parameter -s ${stage} --global-scope\n\n"
dso parameter add -v5 -w "${working_dir}" global.stage_parameter global_stage_parameter -s ${stage} --global-scope > /dev/null


printf "\n\ndso parameter add -v5 -w \"${working_dir}\" namespace.parameter namespace_parameter --namespace-scope\n\n"
dso parameter add -v5 -w "${working_dir}" namespace.parameter namespace_parameter --namespace-scope > /dev/null

printf "\n\ndso parameter add -v5 -w \"${working_dir}\" namespace_stage_parameter namespace_stage_parameter -s ${stage} --namespace-scope\n\n"
dso parameter add -v5 -w "${working_dir}" namespace.stage_parameter namespace_stage_parameter -s ${stage} --namespace-scope > /dev/null


printf "\n\ndso parameter add -v5 -w \"${working_dir}\" app.parameter app_parameter-value\n\n"
dso parameter add -v5 -w "${working_dir}" app.parameter app_parameter > /dev/null

printf "\n\ndso parameter add -v5 -w \"${working_dir}\" app.stage_parameter app_stage_parameter -s ${stage}\n\n"
dso parameter add -v5 -w "${working_dir}" app.stage_parameter app_stage_parameter -s ${stage} > /dev/null

printf "\n\ndso parameter add -v5 -w \"${working_dir}\" app.stage2_parameter app_stage2_parameter -s ${stage}/2\n\n"
dso parameter add -v5 -w "${working_dir}" app.stage2_parameter app_stage2_parameter -s ${stage}/2 > /dev/null


###################################
### add overriden parameters

printf "\n\ndso parameter add -v5 -w \"${working_dir}\" overriden_parameter global_overriden_parameter --global-scope\n\n"
dso parameter add -v5 -w "${working_dir}" overriden_parameter global_overriden_parameter --global-scope > /dev/null

printf "\n\ndso parameter add -v5 -w \"${working_dir}\" overriden_parameter global_stage_overriden_parameter -s ${stage} --global-scope\n\n"
dso parameter add -v5 -w "${working_dir}" overriden_parameter global_stage_overriden_parameter -s ${stage} --global-scope > /dev/null

printf "\n\ndso parameter add -v5 -w \"${working_dir}\" overriden_parameter namespace_overriden_parameter --namespace-scope\n\n"
dso parameter add -v5 -w "${working_dir}" overriden_parameter namespace_overriden_parameter --namespace-scope > /dev/null

printf "\n\ndso parameter add -v5 -w \"${working_dir}\" overriden_parameter namespace_stage_overriden_parameter -s ${stage} --namespace-scope\n\n"
dso parameter add -v5 -w "${working_dir}" overriden_parameter namespace_stage_overriden_parameter -s ${stage} --namespace-scope > /dev/null

printf "\n\ndso parameter add -v5 -w \"${working_dir}\" overriden_parameter app_overriden_parameter-value\n\n"
dso parameter add -v5 -w "${working_dir}" overriden_parameter app_overriden_parameter > /dev/null

printf "\n\ndso parameter add -v5 -w \"${working_dir}\" overriden_parameter app_stage_overriden_parameter -s ${stage}\n\n"
dso parameter add -v5 -w "${working_dir}" overriden_parameter app_stage_overriden_parameter -s ${stage} > /dev/null

printf "\n\ndso parameter add -v5 -w \"${working_dir}\" overriden_parameter app_stage2_overriden_parameter -s ${stage}/2\n\n"
dso parameter add -v5 -w "${working_dir}" overriden_parameter app_stage2_overriden_parameter -s ${stage}/2 > /dev/null

###################################
### get some parameters

printf "\n\ndso parameter get -v5 -w \"${working_dir}\" overriden_parameter -f raw\n\n"
dso parameter get -v5 -w "${working_dir}" overriden_parameter -f raw > /dev/null

printf "\n\ndso parameter get -v5 -w \"${working_dir}\" overriden_parameter -s ${stage} -f raw\n\n"
dso parameter get -v5 -w "${working_dir}" overriden_parameter -s ${stage} -f raw > /dev/null

printf "\n\ndso parameter get -v5 -w \"${working_dir}\" app.parameter -s ${stage} -f raw\n\n"
dso parameter get -v5 -w "${working_dir}" app.parameter -s ${stage} -f raw > /dev/null

printf "\n\ndso parameter get -v5 -w \"${working_dir}\" app.stage_parameter -s ${stage} -f raw\n\n"
dso parameter get -v5 -w "${working_dir}" app.stage_parameter -s ${stage} -f raw > /dev/null

printf "\n\ndso parameter get -v5 -w \"${working_dir}\" app.stage2_parameter -s ${stage}/2 -f raw\n\n"
dso parameter get -v5 -w "${working_dir}" app.stage2_parameter -s ${stage}/2 -f raw > /dev/null

###################################
### edit some parameters

printf "\n\ndso parameter edit -v5 -w \"${working_dir}\" overriden_parameter --global-scope\n\n"
dso parameter edit -v5 -w "${working_dir}" overriden_parameter --global-scope

printf "\n\ndso parameter edit -v5 -w \"${working_dir}\" overriden_parameter -s ${stage} --namespace-scope\n\n"
dso parameter edit -v5 -w "${working_dir}" overriden_parameter -s ${stage} --namespace-scope

printf "\n\ndso parameter edit -v5 -w \"${working_dir}\" app.parameter\n\n"
dso parameter edit -v5 -w "${working_dir}" app.parameter

printf "\n\ndso parameter edit -v5 -w \"${working_dir}\" app.stage_parameter -s ${stage}\n\n"
dso parameter edit -v5 -w "${working_dir}" app.stage_parameter -s ${stage}

printf "\n\ndso parameter edit -v5 -w \"${working_dir}\" app.stage2_parameter -s ${stage}/2\n\n"
dso parameter edit -v5 -w "${working_dir}" app.stage2_parameter -s ${stage}/2

###################################
### getting history of some parameters

printf "\n\ndso parameter history -v5 -w \"${working_dir}\" overriden_parameter -f json\n\n"
dso parameter history -v5 -w "${working_dir}" overriden_parameter -f json > /dev/null
printf "\n\ndso parameter history -v5 -w \"${working_dir}\" overriden_parameter -s ${stage} -f json\n\n"
dso parameter history -v5 -w "${working_dir}" overriden_parameter -s ${stage} -f json > /dev/null

printf "\n\ndso parameter history -v5 -w \"${working_dir}\" app.parameter -s ${stage} --query-all -f json\n\n"
dso parameter history -v5 -w "${working_dir}" app.parameter -s ${stage} --query-all -f json > /dev/null

printf "\n\ndso parameter history -v5 -w \"${working_dir}\" app.stage_parameter -s ${stage} --query-all -f json\n\n"
dso parameter history -v5 -w "${working_dir}" app.stage_parameter -s ${stage} --query-all -f json > /dev/null

printf "\n\ndso parameter history -v5 -w \"${working_dir}\" app.stage2_parameter -s ${stage}/2 --query-all -f json\n\n"
dso parameter history -v5 -w "${working_dir}" app.stage2_parameter -s ${stage}/2 --query-all -f json > /dev/null

###################################
### listing some parameters

printf "\n\ndso parameter list -v5 -w \"${working_dir}\" -s ${stage} --uninherited --query-all --filter overriden_parameter\n\n"
dso parameter list -v5 -w "${working_dir}" -s ${stage} --uninherited --query-all --filter overriden_parameter > /dev/null

printf "\n\ndso parameter list -v5 -w \"${working_dir}\" -s ${stage} --uninherited --query-all -f json\n\n"
dso parameter list -v5 -w "${working_dir}" -s ${stage} --uninherited --query-all -f json > tests/output/parameter/app-uninherited-${provider%%/*}.json

printf "\n\ndso parameter list -v5 -w \"${working_dir}\" -s ${stage} --query-all -f yaml\n\n"
dso parameter list -v5 -w "${working_dir}" -s ${stage} --query-all -f yaml > tests/output/parameter/app-stage-all-${provider%%/*}.yaml

printf "\n\ndso parameter list -v5 -w \"${working_dir}\" -s ${stage}/2 --query-all -f yaml\n\n"
dso parameter list -v5 -w "${working_dir}" -s ${stage}/2 --query-all -f yaml > tests/output/parameter/app-stage2-all-${provider%%/*}.yaml




