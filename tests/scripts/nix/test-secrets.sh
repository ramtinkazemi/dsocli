set -e

default_provider=aws/ssm/v1
default_namespace=test--namespaces
default_project=test-project
default_application=test--query-allpplication
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

if [ ! -d tests/output/secret ]; then
    mkdir tests/output/secret
else
    rm -rf tests/output/secret/*
fi


###################################
### delete existing secrets, in order to also test overriding configurartions, they will be set later

printf "\n\ndso secret list -b5 -w \"${working_dir}\" --config \"namespace=${namespace}, project=${project}, application=${application}, secret.provider.id=${provider}\" --global-scope --uninherited | dso secret delete -b5 -w \"${working_dir}\" --config \"namespace=${namespace}, project=${project}, application=${application}, secret.provider.id=${provider}\" --global-scope -i -\n\n"
dso secret list -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, secret.provider.id=${provider}" --global-scope --uninherited | dso secret delete -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, secret.provider.id=${provider}" --global-scope -i - > /dev/null

printf "\n\ndso secret list -b5 -s ${stage} -w \"${working_dir}\" --config \"namespace=${namespace}, project=${project}, application=${application}, secret.provider.id=${provider}\" --global-scope --uninherited | dso secret delete -b5 -s ${stage} -w \"${working_dir}\" --config \"namespace=${namespace}, project=${project}, application=${application}, secret.provider.id=${provider}\" --global-scope -i -\n\n"
dso secret list -b5 -s ${stage} -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, secret.provider.id=${provider}" --global-scope --uninherited | dso secret delete -b5 -s ${stage} -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, secret.provider.id=${provider}" --global-scope -i - > /dev/null

printf "\n\ndso secret list -b5 -w \"${working_dir}\" --config \"namespace=${namespace}, project=${project}, application=${application}, secret.provider.id=${provider}\" --project-scope --uninherited -f shell | dso secret delete -b5 -w \"${working_dir}\" --config \"namespace=${namespace}, project=${project}, application=${application}, secret.provider.id=${provider}\" --project-scope -i - -f shell\n\n"
dso secret list -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, secret.provider.id=${provider}" --project-scope --uninherited -f shell | dso secret delete -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, secret.provider.id=${provider}" --project-scope -i - -f shell > /dev/null

printf "\n\ndso secret list -b5 -s ${stage} -w \"${working_dir}\" --config \"namespace=${namespace}, project=${project}, application=${application}, secret.provider.id=${provider}\" --project-scope --uninherited -f json | dso secret delete -b5 -s ${stage} -w \"${working_dir}\" --config \"namespace=${namespace}, project=${project}, application=${application}, secret.provider.id=${provider}\" --project-scope -i - -f json\n\n"
dso secret list -b5 -s ${stage} -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, secret.provider.id=${provider}" --project-scope --uninherited -f json | dso secret delete -b5 -s ${stage} -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, secret.provider.id=${provider}" --project-scope -i - -f json > /dev/null

printf "\n\ndso secret list -b5 -w \"${working_dir}\" --config \"namespace=${namespace}, project=${project}, application=${application}, secret.provider.id=${provider}\" --uninherited -f yaml | dso secret delete -b5 -w \"${working_dir}\" --config \"namespace=${namespace}, project=${project}, application=${application}, secret.provider.id=${provider}\" -i - -f yaml\n\n"
dso secret list -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, secret.provider.id=${provider}" --uninherited -f yaml | dso secret delete -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, secret.provider.id=${provider}" -i - -f yaml > /dev/null

printf "\n\ndso secret list -b5 -s ${stage} -w \"${working_dir}\" --config \"namespace=${namespace}, project=${project}, application=${application}, secret.provider.id=${provider}\" --uninherited -f json | dso secret delete -b5 -s ${stage} -w \"${working_dir}\" --config \"namespace=${namespace}, project=${project}, application=${application}, secret.provider.id=${provider}\" -i - -f json\n\n"
dso secret list -b5 -s ${stage} -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, secret.provider.id=${provider}" --uninherited -f json | dso secret delete -b5 -s ${stage} -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, secret.provider.id=${provider}" -i - -f json > /dev/null


###################################
### Setting confgiurations
printf "\n\ndso config set -b5 -w \"${working_dir}\" namespace ${namespace}\n\n"
dso config set -b5 namespace ${namespace} -w "${working_dir}"

printf "\n\ndso config set -b5 -w \"${working_dir}\" project ${project}\n\n"
dso config set -b5 project ${project} -w "${working_dir}"

printf "\n\ndso config set -b5 -w \"${working_dir}\" application ${application}\n\n"
dso config set -b5 application ${application} -w "${working_dir}"

printf "\n\ndso config set -b5 -w \"${working_dir}\" parameter.provider.id \"${provider}\"\n\n"
dso config set -b5 parameter.provider.id "${provider}" -w "${working_dir}"


###################################
### add context-specific secrets

printf "\n\ncat <<EOF | dso secret add -b5 -w \"${working_dir}\" --global-scope -f shell -i -
global.secret=global.secret-value
EOF\n\n"
cat <<EOF | dso secret add -b5 -w "${working_dir}" --global-scope -f shell -i - > /dev/null
global.secret=global.secret-value
EOF

printf "\n\ncat <<EOF | dso secret add -b5 -s ${stage} -w \"${working_dir}\" --global-scope -f shell -i -
global.stage_secret=global.stage_secret-value
EOF\n\n"
cat <<EOF | dso secret add -b5 -s ${stage} -w "${working_dir}" --global-scope -f shell -i - > /dev/null
global.stage_secret=global.stage_secret-value
EOF


printf "\n\ncat <<EOF | dso secret add -b5 -w \"${working_dir}\" --project-scope -f shell -i -
project.secret=project.secret-value
EOF\n\n"
cat <<EOF | dso secret add -b5 -w "${working_dir}" --project-scope -f shell -i - > /dev/null
project.secret=project.secret-value
EOF

printf "\n\ncat <<EOF | dso secret add -b5 -s ${stage} -w \"${working_dir}\" --project-scope -f shell -i -
project.stage_secret=project.stage_secret-value
EOF\n\n"
cat <<EOF | dso secret add -b5 -s ${stage} -w "${working_dir}" --project-scope -f shell -i - > /dev/null
project.stage_secret=project.stage_secret-value
EOF


printf "\n\ncat <<EOF | dso secret add -b5 -w \"${working_dir}\" -f shell -i -
app.secret=app.secret-value
EOF\n\n"
cat <<EOF | dso secret add -b5 -w "${working_dir}" -f shell -i - > /dev/null
app.secret=app.secret-value
EOF

printf "\n\ncat <<EOF | dso secret add -b5 -s ${stage} -w \"${working_dir}\" -f shell -i - 
app.stage_secret=app.stage_secret-value
EOF\n\n"
cat <<EOF | dso secret add -b5 -s ${stage} -w "${working_dir}" -f shell -i - > /dev/null
app.stage_secret=app.stage_secret-value
EOF


###################################
### add overriden secrets

printf "\n\ncat <<EOF | dso secret add -b5 -w \"${working_dir}\" --global-scope -f shell -i -
overriden_secret=global-secret-overriden-value
EOF\n\n"
cat <<EOF | dso secret add -b5 -w "${working_dir}" --global-scope -f shell -i - > /dev/null
overriden_secret=global-secret-overriden-value
EOF

printf "\n\ncat <<EOF | dso secret add -b5 -s ${stage} -w \"${working_dir}\" --global-scope -f shell -i -
overriden_secret=global-stage-secret-overriden-value
EOF\n\n"
cat <<EOF | dso secret add -b5 -s ${stage} -w "${working_dir}" --global-scope -f shell -i - > /dev/null
overriden_secret=global-stage-secret-overriden-value
EOF

printf "\n\ncat <<EOF | dso secret add -b5 -w \"${working_dir}\" --project-scope -f shell -i - 
overriden_secret=project-secret-overriden-value
EOF\n\n"
cat <<EOF | dso secret add -b5 -w "${working_dir}" --project-scope -f shell -i - > /dev/null
overriden_secret=project-secret-overriden-value
EOF

printf "\n\ncat <<EOF | dso secret add -b5 -s ${stage} -w \"${working_dir}\" --project-scope -f shell -i - 
overriden_secret=project-stage-secret-overriden-value
EOF\n\n"
cat <<EOF | dso secret add -b5 -s ${stage} -w "${working_dir}" --project-scope -f shell -i - > /dev/null
overriden_secret=project-stage-secret-overriden-value
EOF

printf "\n\ncat <<EOF | dso secret add -b5 -w \"${working_dir}\" -f shell -i -
overriden_secret=app-secret-overriden-value
EOF\n\n"
cat <<EOF | dso secret add -b5 -w "${working_dir}" -f shell -i - > /dev/null
overriden_secret=app-secret-overriden-value
EOF

printf "\n\ncat <<EOF | dso secret add -b5 -s ${stage} -w \"${working_dir}\" -f shell -i - 
overriden_secret=app-stage-secret-overriden-value
EOF\n\n"
cat <<EOF | dso secret add -b5 -s ${stage} -w "${working_dir}" -f shell -i - > /dev/null
overriden_secret=app-stage-secret-overriden-value
EOF

###################################
### getting some secrets

printf "\n\ndso secret get -b5 -w \"${working_dir}\" overriden_secret -f raw\n\n"
dso secret get -b5 -w "${working_dir}" overriden_secret -f raw > /dev/null

printf "\n\ndso secret get -b5 -w \"${working_dir}\"  overriden_secret -s ${stage} -f raw\n\n"
dso secret get -b5 -w "${working_dir}" overriden_secret -s ${stage} -f raw > /dev/null

printf "\n\ndso secret get -b5 -w \"${working_dir}\" app.secret -s ${stage} -f raw\n\n"
dso secret get -b5 -w "${working_dir}" app.secret -s ${stage} -f raw > /dev/null

printf "\n\ndso secret get -b5 -w \"${working_dir}\" app.stage_secret -s ${stage} -f raw\n\n"
dso secret get -b5 -w "${working_dir}" app.stage_secret -s ${stage} -f raw > /dev/null


###################################
### edit some secrets

printf "\n\ndso secret edit -b5 -w \"${working_dir}\" overriden_secret --global-scope\n\n"
dso secret edit -b5 -w "${working_dir}" overriden_secret --global-scope -b5

printf "\n\ndso secret edit -b5 -w \"${working_dir}\" overriden_secret -s ${stage} --project-scope\n\n"
dso secret edit -b5 -w "${working_dir}" overriden_secret -s ${stage} --project-scope

printf "\n\ndso secret edit -b5 -w \"${working_dir}\" app.secret\n\n"
dso secret edit -b5 -w "${working_dir}" app.secret

printf "\n\ndso secret edit -b5 -w \"${working_dir}\" app.stage_secret -s ${stage}\n\n"
dso secret edit -b5 -w "${working_dir}" app.stage_secret -s ${stage}


###################################
### getting history of some secrets

printf "\n\ndso secret history -b5 -w \"${working_dir}\" overriden_secret -f json\n\n"
dso secret history -b5 -w "${working_dir}" overriden_secret -f json > /dev/null

printf "\n\ndso secret history -b5 -w \"${working_dir}\" overriden_secret -s ${stage} -f json\n\n"
dso secret history -b5 -w "${working_dir}" overriden_secret -s ${stage} -f json > /dev/null

printf "\n\ndso secret history -b5 -w \"${working_dir}\" app.secret -s ${stage} --query-all -f json\n\n"
dso secret history -b5 -w "${working_dir}" app.secret -s ${stage} --query-all -f json > /dev/null

printf "\n\ndso secret history -b5 -w \"${working_dir}\" app.stage_secret -s ${stage} --query-all -f json\n\n"
dso secret history -b5 -w "${working_dir}" app.stage_secret -s ${stage} --query-all -f json > /dev/null


###################################
### listing some secrets

printf "\n\ndso secret list -b5 -w \"${working_dir}\" -s ${stage} --uninherited --query-all --filter overriden_secret\n\n"
dso secret list -b5 -w "${working_dir}" -s ${stage} --uninherited --query-all --filter overriden_secret > /dev/null

printf "\n\ndso secret list -b5 -w \"${working_dir}\" -s ${stage} --uninherited -d --query-all -f json\n\n"
dso secret list -b5 -w "${working_dir}" -s ${stage} --uninherited -d --query-all -f json > tests/output/secret/app-uninherited-${provider%%/*}.json

printf "\n\ndso secret list -b5 -w \"${working_dir}\" -s ${stage} -d --query-all -f yaml\n\n"
dso secret list -b5 -w "${working_dir}" -s ${stage} -d --query-all -f yaml > tests/output/secret/app--query-allll-${provider%%/*}.yaml
