set -e

default_provider=local/v1
default_namespace=test-ns
default_project=test-project
default_application=test-app
default_stage=test-stage
default_working_dir=.

printf "\n\nUSAGE: $0 <namespace [${default_namespace}]> <project [${default_project}]> <application [${default_application}]> <stage [${default_stage}]> <working_dir [${default_working_dir}]> <provider [${default_provider}]>\n\n"


if [ $1 ]; then
    namespace=$1
else
    namespace=${default_namespace}
fi

if [ $2 ]; then
    project=$2
else
    project=${default_project}
fi

if [ $3 ]; then
    application=$3
else
    application=${default_application}
fi

if [ $4 ]; then
    stage=$4
else
    stage=${default_stage}
fi

if [ $5 ]; then
    working_dir=$5
else
    working_dir=${default_working_dir}
fi


if [ $6 ]; then
    provider=$6
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

printf "\n\ndso parameter list -b5 -w \"${working_dir}\" --config \"namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}\" --global-scope --uninherited -f json | dso parameter delete -b5 -w \"${working_dir}\" --config \"namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}\" --global-scope -i - -f json\n\n"
dso parameter list -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}" --global-scope --uninherited -f json | dso parameter delete -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}" --global-scope -i - -f json > /dev/null

printf "\n\ndso parameter list -b5 -w \"${working_dir}\" --config \"namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}\" -s ${stage} --global-scope --uninherited -f yaml | dso parameter delete -b5 -w \"${working_dir}\" --config \"namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}\" -s ${stage} --global-scope -i - -f yaml\n\n"
dso parameter list -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}" -s ${stage} --global-scope --uninherited -f yaml | dso parameter delete -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}" -s ${stage} --global-scope -i - -f yaml > /dev/null

printf "\n\ndso parameter list -b5 -w \"${working_dir}\" --config \"namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}\" --project-scope --uninherited | dso parameter delete -b5 -w \"${working_dir}\" --config \"namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}\" --project-scope -i -\n\n"
dso parameter list -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}" --project-scope --uninherited | dso parameter delete -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}" --project-scope -i - > /dev/null

printf "\n\ndso parameter list -b5 -w \"${working_dir}\" --config \"namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}\" -s ${stage} --project-scope --uninherited -f shell | dso parameter delete -b5 -w \"${working_dir}\" --config \"namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}\" -s ${stage} --project-scope -i - -f shell\n\n"
dso parameter list -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}" -s ${stage} --project-scope --uninherited -f shell | dso parameter delete -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}" -s ${stage} --project-scope -i - -f shell > /dev/null

printf "\n\ndso parameter list -b5 -w \"${working_dir}\" --config \"namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}\" --uninherited | dso parameter delete -b5 -w \"${working_dir}\" --config \"namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}\" -i -\n\n"
dso parameter list -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}" --uninherited | dso parameter delete -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}" -i - > /dev/null

printf "\n\ndso parameter list -b5 -w \"${working_dir}\" --config \"namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}\" -s ${stage} --uninherited | dso parameter delete -b5 -w \"${working_dir}\" --config \"namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}\" -s ${stage} -i -\n\n"
dso parameter list -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}" -s ${stage} --uninherited | dso parameter delete -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}" -s ${stage} -i - > /dev/null


###################################
### Setting confgiurations
printf "\n\ndso config set -b5 -w \"${working_dir}\" namespace ${namespace}\n\n"
dso config set -b5 -w "${working_dir}" namespace ${namespace}

printf "\n\ndso config set -b5 -w \"${working_dir}\" project ${project}\n\n"
dso config set -b5 -w "${working_dir}" project ${project} -w "${working_dir}"

printf "\n\ndso config set -b5 -w \"${working_dir}\" application ${application}\n\n"
dso config set -b5 -w "${working_dir}" application ${application}

printf "\n\ndso config set -b5 -w \"${working_dir}\" parameter.provider.id \"${provider}\"\n\n"
dso config set -b5 -w "${working_dir}" parameter.provider.id "${provider}"


###################################
### add context-specific parameters

printf "\n\ndso parameter add -b5 -w \"${working_dir}\" global.parameter global.parameter --global-scope\n\n"
dso parameter add -b5 -w "${working_dir}" global.parameter global.parameter --global-scope > /dev/null

printf "\n\ndso parameter add -b5 -w \"${working_dir}\" global.stage_parameter global.stage_parameter -s ${stage} --global-scope\n\n"
dso parameter add -b5 -w "${working_dir}" global.stage_parameter global.stage_parameter -s ${stage} --global-scope > /dev/null


printf "\n\ndso parameter add -b5 -w \"${working_dir}\" project.parameter project.parameter --project-scope\n\n"
dso parameter add -b5 -w "${working_dir}" project.parameter project.parameter --project-scope > /dev/null

printf "\n\ndso parameter add -b5 -w \"${working_dir}\" project.stage_parameter project.stage_parameter -s ${stage} --project-scope\n\n"
dso parameter add -b5 -w "${working_dir}" project.stage_parameter project.stage_parameter -s ${stage} --project-scope > /dev/null


printf "\n\ndso parameter add -b5 -w \"${working_dir}\" app.parameter app.parameter-value\n\n"
dso parameter add -b5 -w "${working_dir}" app.parameter app.parameter > /dev/null

printf "\n\ndso parameter add -b5 -w \"${working_dir}\" app.stage_parameter app.stage_parameter -s ${stage}\n\n"
dso parameter add -b5 -w "${working_dir}" app.stage_parameter app.stage_parameter -s ${stage} > /dev/null


###################################
### add overriden parameters

printf "\n\ndso parameter add -b5 -w \"${working_dir}\" overriden_parameter global.overriden_parameter --global-scope\n\n"
dso parameter add -b5 -w "${working_dir}" overriden_parameter global.overriden_parameter --global-scope > /dev/null

printf "\n\ndso parameter add -b5 -w \"${working_dir}\" overriden_parameter global-stage_overriden_parameter -s ${stage} --global-scope\n\n"
dso parameter add -b5 -w "${working_dir}" overriden_parameter global.stage_overriden_parameter -s ${stage} --global-scope > /dev/null

printf "\n\ndso parameter add -b5 -w \"${working_dir}\" overriden_parameter project.overriden_parameter --project-scope\n\n"
dso parameter add -b5 -w "${working_dir}" overriden_parameter project.overriden_parameter --project-scope > /dev/null

printf "\n\ndso parameter add -b5 -w \"${working_dir}\" overriden_parameter project-stage_overriden_parameter -s ${stage} --project-scope\n\n"
dso parameter add -b5 -w "${working_dir}" overriden_parameter project.stage_overriden_parameter -s ${stage} --project-scope > /dev/null

printf "\n\ndso parameter add -b5 -w \"${working_dir}\" overriden_parameter app.overriden_parameter-value\n\n"
dso parameter add -b5 -w "${working_dir}" overriden_parameter app.overriden_parameter > /dev/null

printf "\n\ndso parameter add -b5 -w \"${working_dir}\" overriden_parameter app.stage_overriden_parameter -s ${stage}\n\n"
dso parameter add -b5 -w "${working_dir}" overriden_parameter app.stage_overriden_parameter -s ${stage} > /dev/null


###################################
### getting some parameters

printf "\n\ndso parameter get -b5 -w \"${working_dir}\" overriden_parameter -f raw\n\n"
dso parameter get -b5 -w "${working_dir}" overriden_parameter -f raw > /dev/null

printf "\n\ndso parameter get -b5 -w \"${working_dir}\" overriden_parameter -s ${stage} -f raw\n\n"
dso parameter get -b5 -w "${working_dir}" overriden_parameter -s ${stage} -f raw > /dev/null

printf "\n\ndso parameter get -b5 -w \"${working_dir}\" app.parameter -s ${stage} -f raw\n\n"
dso parameter get -b5 -w "${working_dir}" app.parameter -s ${stage} -f raw > /dev/null

printf "\n\ndso parameter get -b5 -w \"${working_dir}\" app.stage_parameter -s ${stage} -f raw\n\n"
dso parameter get -b5 -w "${working_dir}" app.stage_parameter -s ${stage} -f raw > /dev/null


###################################
### edit some parameters

printf "\n\ndso parameter edit -b5 -w \"${working_dir}\" overriden_parameter --global-scope\n\n"
dso parameter edit -b5 -w "${working_dir}" overriden_parameter --global-scope

printf "\n\ndso parameter edit -b5 -w \"${working_dir}\" overriden_parameter -s ${stage} --project-scope\n\n"
dso parameter edit -b5 -w "${working_dir}" overriden_parameter -s ${stage} --project-scope

printf "\n\ndso parameter edit -b5 -w \"${working_dir}\" app.parameter\n\n"
dso parameter edit -b5 -w "${working_dir}" app.parameter

printf "\n\ndso parameter edit -b5 -w \"${working_dir}\" app.stage_parameter -s ${stage}\n\n"
dso parameter edit -b5 -w "${working_dir}" app.stage_parameter -s ${stage}


###################################
### getting history of some parameters

printf "\n\ndso parameter history -b5 -w \"${working_dir}\" overriden_parameter -f json\n\n"
dso parameter history -b5 -w "${working_dir}" overriden_parameter -f json > /dev/null
printf "\n\ndso parameter history -b5 -w \"${working_dir}\" overriden_parameter -s ${stage} -f json\n\n"
dso parameter history -b5 -w "${working_dir}" overriden_parameter -s ${stage} -f json > /dev/null


printf "\n\ndso parameter history -b5 -w \"${working_dir}\" app.parameter -s ${stage} --query-all -f json\n\n"
dso parameter history -b5 -w "${working_dir}" app.parameter -s ${stage} --query-all -f json > /dev/null

printf "\n\ndso parameter history -b5 -w \"${working_dir}\" app.stage_parameter -s ${stage} --query-all -f json\n\n"
dso parameter history -b5 -w "${working_dir}" app.stage_parameter -s ${stage} --query-all -f json > /dev/null


###################################
### listing some parameters

printf "\n\ndso parameter list -b5 -w \"${working_dir}\" -s ${stage} --uninherited --query-all --filter overriden_parameter\n\n"
dso parameter list -b5 -w "${working_dir}" -s ${stage} --uninherited --query-all --filter overriden_parameter > /dev/null

printf "\n\ndso parameter list -b5 -w \"${working_dir}\" -s ${stage} --uninherited --query-all -f json\n\n"
dso parameter list -b5 -w "${working_dir}" -s ${stage} --uninherited --query-all -f json > tests/output/parameter/app-uninherited-${provider%%/*}.json

printf "\n\ndso parameter list -b5 -w \"${working_dir}\" -s ${stage} --query-all -f yaml\n\n"
dso parameter list -b5 -w "${working_dir}" -s ${stage} --query-all -f yaml > tests/output/parameter/app-all-${provider%%/*}.yaml





