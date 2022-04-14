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

if [ ! -d tests/output/template ]; then
    mkdir tests/output/template
else
    rm -rf tests/output/template/*
fi

###################################

export DSO_ALLOW_STAGE_TEMPLATES=yes


###################################
### delete existing templates, in order to also test overriding configurartions, they will be set later

printf "\n\ndso template list -v5 -w \"${working_dir}\" --config \"namespace=${namespace}, application=${application}, template.provider.id=${provider}\" --global-scope --uninherited | dso template delete -v5 -w \"${working_dir}\" --config \"namespace=${namespace}, application=${application}, template.provider.id=${provider}\" --global-scope -i -\n\n"
dso template list -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, template.provider.id=${provider}" --global-scope --uninherited | dso template delete -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, template.provider.id=${provider}" --global-scope -i - > /dev/null

printf "\n\ndso template list -v5 -w \"${working_dir}\" --config \"namespace=${namespace}, application=${application}, template.provider.id=${provider}\" -s ${stage} --global-scope --uninherited | dso template delete  -v5 -w \"${working_dir}\" --config \"namespace=${namespace}, application=${application}, template.provider.id=${provider}\" -s ${stage} -global-scope -i -\n\n"
dso template list -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, template.provider.id=${provider}" -s ${stage} --global-scope --uninherited | dso template delete -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, template.provider.id=${provider}" -s ${stage} --global-scope -i -> /dev/null

printf "\n\ndso template list -v5 -w \"${working_dir}\" --config \"namespace=${namespace}, application=${application}, template.provider.id=${provider}\" --namespace-scope --uninherited | dso template delete -v5 -w \"${working_dir}\" --config \"namespace=${namespace}, application=${application}, template.provider.id=${provider}\" --namespace-scope -i -\n\n"
dso template list -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, template.provider.id=${provider}" --namespace-scope --uninherited | dso template delete -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, template.provider.id=${provider}" --namespace-scope -i - -v5 > /dev/null

printf "\n\ndso template list -v5 -w \"${working_dir}\" --config \"namespace=${namespace}, application=${application}, template.provider.id=${provider}\" -s ${stage} --namespace-scope --uninherited -f json | dso template delete -v5 -w \"${working_dir}\" --config \"namespace=${namespace}, application=${application}, template.provider.id=${provider}\" -s ${stage} --namespace-scope -i - -f json\n\n"
dso template list -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, template.provider.id=${provider}" -s ${stage} --namespace-scope --uninherited -f json | dso template delete -v5  -w "${working_dir}" --config "namespace=${namespace}, application=${application}, template.provider.id=${provider}" -s ${stage} --namespace-scope -i - -f json> /dev/null

printf "\n\ndso template list -v5 -w \"${working_dir}\" --config \"namespace=${namespace}, application=${application}, template.provider.id=${provider}\" --uninherited -f yaml | dso template delete -v5 -w \"${working_dir}\" --config \"namespace=${namespace}, application=${application}, template.provider.id=${provider}\" -i - -f yaml\n\n"
dso template list -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, template.provider.id=${provider}" --uninherited -f yaml | dso template delete -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, template.provider.id=${provider}" -i - -f yaml> /dev/null

printf "\n\ndso template list -v5 -w \"${working_dir}\" --config \"namespace=${namespace}, application=${application}, template.provider.id=${provider}\" -s ${stage} --uninherited -f json | dso template delete -v5 -w \"${working_dir}\" --config \"namespace=${namespace}, application=${application}, template.provider.id=${provider}\" -s ${stage} -i - -f json\n\n"
dso template list -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, template.provider.id=${provider}" -s ${stage} --uninherited -f json | dso template delete -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, template.provider.id=${provider}" -s ${stage} -i - -f json > /dev/null

printf "\n\ndso template list -v5 -w \"${working_dir}\" --config \"namespace=${namespace}, application=${application}, template.provider.id=${provider}\" -s ${stage}/2 --uninherited -f json | dso template delete -v5 -w \"${working_dir}\" --config \"namespace=${namespace}, application=${application}, template.provider.id=${provider}\" -s ${stage}/2 -i - -f json\n\n"
dso template list -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, template.provider.id=${provider}" -s ${stage}/2 --uninherited -f json | dso template delete -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, template.provider.id=${provider}" -s ${stage}/2 -i - -f json > /dev/null

###################################
### Setting configurations
printf "\n\ndso config set -v5 -w \"${working_dir}\" namespace ${namespace}\n\n"
dso config set -v5 -w "${working_dir}" namespace ${namespace}

printf "\n\ndso config set -v5 -w \"${working_dir}\" application ${application}\n\n"
dso config set -v5 -w "${working_dir}" application ${application}

printf "\n\ndso config set -v5 -w \"${working_dir}\" template.provider.id \"${provider}\"\n\n"
dso config set -v5 -w "${working_dir}" template.provider.id "${provider}"


###################################
### add context-specific templates

printf "\n\ndso template add -v5 -w \"${working_dir}\" global.template -r 'tests/output/template/*' --global-scope -c tests/sample-templates/global-template\n\n"
dso template add -v5 -w "${working_dir}" global.template -r 'tests/output/template/*' --global-scope -c tests/sample-templates/global-template > /dev/null

printf "\n\ndso template add -v5 -w \"${working_dir}\" global.stage_template -r 'tests/output/template/*' -s ${stage} --global-scope -c tests/sample-templates/global-stage-template\n\n"
dso template add -v5 -w "${working_dir}" global.stage_template -r 'tests/output/template/*' -s ${stage} --global-scope -c tests/sample-templates/global-stage-template > /dev/null

printf "\n\ndso template add -v5 -w \"${working_dir}\" namespace.template -r 'tests/output/template/*' --namespace-scope -c tests/sample-templates/namespace-template\n\n"
dso template add -v5 -w "${working_dir}" namespace.template -r 'tests/output/template/*' --namespace-scope -c tests/sample-templates/namespace-template > /dev/null

printf "\n\ndso template add -v5 -w \"${working_dir}\" namespace.stage_template -r 'tests/output/template/*' -s ${stage} --namespace-scope -c tests/sample-templates/namespace-stage-template\n\n"
dso template add -v5 -w "${working_dir}" namespace.stage_template -r 'tests/output/template/*' -s ${stage} --namespace-scope -c tests/sample-templates/namespace-stage-template > /dev/null

printf "\n\ndso template add -v5 -w \"${working_dir}\" app.template -r 'tests/output/template/*' -c tests/sample-templates/app-template\n\n"
dso template add -v5 -w "${working_dir}" app.template -r 'tests/output/template/*' -c tests/sample-templates/app-template > /dev/null

printf "\n\ndso template add -v5 -w \"${working_dir}\" app.stage_template -r 'tests/output/template/*' -s ${stage} -c tests/sample-templates/app-stage-template\n\n"
dso template add -v5 -w "${working_dir}" app.stage_template -r 'tests/output/template/*' -s ${stage} -c tests/sample-templates/app-stage-template > /dev/null

printf "\n\ndso template add -v5 -w \"${working_dir}\" app.stage2_template -r 'tests/output/template/*' -s ${stage}/2 -c tests/sample-templates/app-stage2-template\n\n"
dso template add -v5 -w "${working_dir}" app.stage2_template -r 'tests/output/template/*' -s ${stage}/2 -c tests/sample-templates/app-stage2-template > /dev/null

###################################
### add overriden templates

printf "\n\ndso template add -v5 -w \"${working_dir}\" overriden_template -r 'tests/output/template/*' --global-scope -c tests/sample-templates/global-template-overriden\n\n"
dso template add -v5 -w "${working_dir}" overriden_template -r 'tests/output/template/*' --global-scope -c tests/sample-templates/global-template-overriden > /dev/null

printf "\n\ndso template add -v5 -w \"${working_dir}\" overriden_template -r 'tests/output/template/*' -s ${stage} --global-scope -c tests/sample-templates/global-stage-template-overriden\n\n"
dso template add -v5 -w "${working_dir}" overriden_template -r 'tests/output/template/*' -s ${stage} --global-scope -c tests/sample-templates/global-stage-template-overriden > /dev/null

printf "\n\ndso template add -v5 -w \"${working_dir}\" overriden_template -r 'tests/output/template/*' --namespace-scope -c tests/sample-templates/namespace-template-overriden\n\n"
dso template add -v5 -w "${working_dir}" overriden_template -r 'tests/output/template/*' --namespace-scope -c tests/sample-templates/namespace-template-overriden > /dev/null

printf "\n\ndso template add -v5 -w \"${working_dir}\" overriden_template -r 'tests/output/template/*' -s ${stage} --namespace-scope -c tests/sample-templates/namespace-stage-template-overriden\n\n"
dso template add -v5 -w "${working_dir}" overriden_template -r 'tests/output/template/*' -s ${stage} --namespace-scope -c tests/sample-templates/namespace-stage-template-overriden > /dev/null

printf "\n\ndso template add -v5 -w \"${working_dir}\" overriden_template -r 'tests/output/template/*' -c tests/sample-templates/app-template-overriden\n\n"
dso template add -v5 -w "${working_dir}" overriden_template -r 'tests/output/template/*' -c tests/sample-templates/app-template-overriden > /dev/null

printf "\n\ndso template add -v5 -w \"${working_dir}\" overriden_template -r 'tests/output/template/*' -s ${stage} -c tests/sample-templates/app-stage-template-overriden\n\n"
dso template add -v5 -w "${working_dir}" overriden_template -r 'tests/output/template/*' -s ${stage} -c tests/sample-templates/app-stage-template-overriden > /dev/null

printf "\n\ndso template add -v5 -w \"${working_dir}\" overriden_template -r 'tests/output/template/*' -s ${stage}/2 -c tests/sample-templates/app-stage2-template-overriden\n\n"
dso template add -v5 -w "${working_dir}" overriden_template -r 'tests/output/template/*' -s ${stage}/2 -c tests/sample-templates/app-stage2-template-overriden > /dev/null

###################################
### get some templates

printf "\n\ndso template get -v5 -w \"${working_dir}\" overriden_template --scope Global -f raw\n\n"
dso template get overriden_template -v5 -w "${working_dir}" --scope Global -f raw > /dev/null

printf "\n\ndso template get -v5 -w \"${working_dir}\" overriden_template -s ${stage} -f raw\n\n"
dso template get overriden_template -v5 -w "${working_dir}" -s ${stage} -f raw > /dev/null

printf "\n\ndso template get -v5 -w \"${working_dir}\" overriden_template -s ${stage}/2 -f raw\n\n"
dso template get overriden_template -v5 -w "${working_dir}" -s ${stage}/2 -f raw > /dev/null

printf "\n\ndso template get -v5 -w \"${working_dir}\" app.template -s ${stage} -f raw\n\n"
dso template get -v5 -w "${working_dir}" app.template -s ${stage} -f raw > /dev/null

printf "\n\ndso template get -v5 -w \"${working_dir}\" app.stage_template -s ${stage} -f raw\n\n"
dso template get -v5 -w "${working_dir}" app.stage_template -s ${stage} -f raw > /dev/null

printf "\n\ndso template get -v5 -w \"${working_dir}\" app.stage2_template -s ${stage}/2 -f raw\n\n"
dso template get -v5 -w "${working_dir}" app.stage2_template -s ${stage}/2 -f raw > /dev/null


###################################
### edit some templates

printf "\n\ndso template edit -v5 -w \"${working_dir}\" overriden_template --global-scope\n\n"
dso template edit overriden_template -v5 -w "${working_dir}" --global-scope

printf "\n\ndso template edit -v5 -w \"${working_dir}\" overriden_template  -s ${stage} --namespace-scope\n\n"
dso template edit overriden_template -v5 -w "${working_dir}"  -s ${stage} --namespace-scope

printf "\n\ndso template edit -v5 -w \"${working_dir}\" app.template\n\n"
dso template edit -v5 -w "${working_dir}" app.template

printf "\n\ndso template edit -v5 -w \"${working_dir}\" app.stage_template -s ${stage}\n\n"
dso template edit -v5 -w "${working_dir}" app.stage_template -s ${stage}

printf "\n\ndso template edit -v5 -w \"${working_dir}\" app.stage2_template -s ${stage}/2\n\n"
dso template edit -v5 -w "${working_dir}" app.stage2_template -s ${stage}/2


###################################
### getting history of some templates

printf "\n\ndso template history -v5 -w \"${working_dir}\" overriden_template -f json\n\n"
dso template history -v5 -w "${working_dir}" overriden_template -f json -v5 > /dev/null

printf "\n\ndso template history -v5 -w \"${working_dir}\" overriden_template -s ${stage} -f json\n\n"
dso template history -v5 -w "${working_dir}" overriden_template -s ${stage} -f json -v5 > /dev/null

printf "\n\ndso template history -v5 -w \"${working_dir}\" app.template -s ${stage} --query-all -f json\n\n"
dso template history -v5 -w "${working_dir}" app.template -s ${stage} --query-all -f json -v5 > /dev/null

printf "\n\ndso template history -v5 -w \"${working_dir}\" app.stage_template -s ${stage} --query-all -f json\n\n"
dso template history -v5 -w "${working_dir}" app.stage_template -s ${stage} --query-all -f json -v5 > /dev/null

printf "\n\ndso template history -v5 -w \"${working_dir}\" app.stage2_template -s ${stage}/2 --query-all -f json\n\n"
dso template history -v5 -w "${working_dir}" app.stage2_template -s ${stage}/2 --query-all -f json -v5 > /dev/null

###################################
### listing some templates

printf "\n\ndso template list -v5 -w \"${working_dir}\" -s ${stage} --uninherited --query-all --filter overriden_template\n\n"
dso template list -v5 -w "${working_dir}" -s ${stage} --uninherited --query-all --filter overriden_template > /dev/null

printf "\n\ndso template list -v5 -w \"${working_dir}\" -s ${stage} --uninherited -c --query-all -f json\n\n"
dso template list -v5 -w "${working_dir}" -s ${stage} --uninherited --contents --query-all -f json > tests/output/template/app-uninherited-${provider%%/*}.json

printf "\n\ndso template list -v5 -w \"${working_dir}\" -s ${stage} -c --query-all -f yaml\n\n"
dso template list -v5 -w "${working_dir}" -s ${stage} --contents --query-all -f yaml > tests/output/template/app-stage-all-${provider%%/*}.yaml

printf "\n\ndso template list -v5 -w \"${working_dir}\" -s ${stage}/2 -c --query-all -f yaml\n\n"
dso template list -v5 -w "${working_dir}" -s ${stage}/2 --contents --query-all -f yaml > tests/output/template/app-stage2-all-${provider%%/*}.yaml

###################################
### rendering templates

printf "\n\ndso template render -v5 -w \"${working_dir}\" -s ${stage} --filter overriden_template\n\n"
dso template render -v5 -w "${working_dir}" -s ${stage} --filter overriden_template > /dev/null 

# printf "\n\ndso template render -v5 -w \"${working_dir}\" -s ${stage}\n\n"
# dso template render -v5 -w "${working_dir}" -s ${stage} > /dev/null

printf "\n\ndso template render -v5 -w \"${working_dir}\" -s ${stage}/2\n\n"
dso template render -v5 -w "${working_dir}" -s ${stage}/2 > /dev/null



