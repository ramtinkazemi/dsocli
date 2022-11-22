#!/bin/bash
set -e -o pipefail

bin_path=$(realpath $(dirname $0))
root_path=$(realpath ${bin_path}/../../..)

default_provider=local/v1
default_namespace=test-ns
default_project=test-project
default_application=test-app
default_stage=test-stage
default_working_dir=${root_path}

printf "\n\nUSAGE: $0 <namespace [${default_namespace}]> <application [${default_application}]> <stage [${default_stage}]> <working_dir [${default_working_dir}]>\n\n"

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


if [ ! -d tests/output ]; then
    mkdir tests/output
fi


###################################

printf "\n\ndso config init -v5 -w \"${working_dir}\"\n\n"
dso config init -v5 -w "${working_dir}" 

printf "\n\ndso config get -v5 -w \"${working_dir}\"\n\n"
dso config list -v5 -w "${working_dir}" > /dev/null

printf "\n\ndso config add -v5 -w \"${working_dir}\" test.config some-value\n\n"
dso config add -v5 -w "${working_dir}" test.config some-value > /dev/null

printf "\n\ndso config get -v5 -w \"${working_dir}\" test.config\n\n"
dso config get -v5 -w "${working_dir}" test.config > /dev/null

printf "\n\ndso config delete -v5 -w \"${working_dir}\" test.config\n\n"
dso config delete -v5 -w "${working_dir}" test.config > /dev/null

printf "\n\ndso config add -v5 -w \"${working_dir}\" namespace ${namespace}\n\n"
dso config add -v5 -w "${working_dir}" namespace ${namespace} > /dev/null

printf "\n\ndso config add -v5 -w \"${working_dir}\" application ${application}\n\n"
dso config add -v5 -w "${working_dir}" application ${application} > /dev/null

