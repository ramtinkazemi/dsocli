set -e

default_provider=local/v1
default_namespace=test-ns
default_project=test-project
default_application=test-app
default_stage=test-stage
default_working_dir=.

printf "\n\nUSAGE: $0 <namespace [${default_namespace}]> <project [${default_project}]> <application [${default_application}]> <stage [${default_stage}]> <working_dir [${default_working_dir}]>\n\n"

if [ $1 ]; then
  namespace="$1"
else
  namespace="${default_namespace}"
fi

if [ $2 ]; then
  project="$2"
else
  project="${default_project}"
fi

if [ $3 ]; then
  application="$3"
else
  application="${default_application}"
fi

if [ $4 ]; then
  stage="$4"
else
  stage="${default_stage}"
fi

if [ $5 ]; then
  working_dir="$5"
else
  working_dir="${default_working_dir}"
fi

if [ ! -d tests/output ]; then
    mkdir tests/output
fi

printf "\n\ndso config get -b5 -w \"${working_dir}\" --global\n\n"
dso config get -b5 -w "${working_dir}" --global > /dev/null

printf "\n\ndso config set -b5 -w \"${working_dir}\" test.global-config some-value --global\n\n"
dso config set -b5 -w "${working_dir}" test.global-config some-value -b5 --global

printf "\n\ndso config get -b5 -w \"${working_dir}\" test.global-config --global\n\n"
dso config get -b5 -w "${working_dir}" test.global-config --global > /dev/null

printf "\n\ndso config init -b5 -w \"${working_dir}\"\n\n"
dso config init -b5 -w "${working_dir}" 
printf "\n\ndso config get -b5 -w \"${working_dir}\" --local\n\n"
dso config get -b5 -w "${working_dir}" --local > /dev/null

printf "\n\ndso config set -b5 -w \"${working_dir}\" test.local-config some-value\n\n"
dso config set -b5 -w "${working_dir}" test.local-config some-value

printf "\n\ndso config get -b5 -w \"${working_dir}\" test.local-config\n\n"
dso config get -b5 -w "${working_dir}" test.local-config > /dev/null

printf "\n\ndso config unset -b5 -w \"${working_dir}\" test.global-config --global\n\n"
dso config unset -b5 -w "${working_dir}" test.global-config --global

printf "\n\ndso config unset -b5 -w \"${working_dir}\" test.local-config\n\n"
dso config unset -b5 -w "${working_dir}" test.local-config

printf "\n\ndso config set -b5 -w \"${working_dir}\" namespace ${namespace}\n\n"
dso config set -b5 -w "${working_dir}" namespace ${namespace}

printf "\n\ndso config set -b5 -w \"${working_dir}\" project ${project}\n\n"
dso config set -b5 -w "${working_dir}" project ${project}

printf "\n\ndso config set -b5 -w \"${working_dir}\" application ${application}\n\n"
dso config set -b5 -w "${working_dir}" application ${application}

