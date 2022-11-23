#!/bin/bash
set -e -o pipefail

## printf "\n\nUSAGE: $0 <namespace [test-ns]> <application [test-app]> <stage [test-stage]> <working_dir [.]>\n\n"

bin_path=$(realpath $(dirname $0))
root_path=$(realpath ${bin_path}/../../..)

namespace=${1:-"test-ns"}
application=${2:-"test-app"}
stage=${3:-"test-stage"}
working_dir=${4:-$root_path}

[ -d .dso/output ] || mkdir .dso/output

###################################

printf "\n\ndso config init -v6 -w \"${working_dir}\"\n\n"
dso config init -v6 -w "${working_dir}" 

printf "\n\ndso config get -v6 -w \"${working_dir}\"\n\n"
dso config list -v6 -w "${working_dir}" > /dev/null

printf "\n\ndso config get -v6 -w \"${working_dir}\" --local\n\n"
dso config list -v6 -w "${working_dir}" --local > /dev/null

printf "\n\ndso config add -v6 -w \"${working_dir}\" test.config some-value\n\n"
dso config add -v6 -w "${working_dir}" test.config some-value > /dev/null

printf "\n\ndso config get -v6 -w \"${working_dir}\" test.config\n\n"
dso config get -v6 -w "${working_dir}" test.config > /dev/null

printf "\n\ndso config delete -v6 -w \"${working_dir}\" test.config\n\n"
dso config delete -v6 -w "${working_dir}" test.config > /dev/null

printf "\n\ndso config add -v6 -w \"${working_dir}\" namespace $namespace\n\n"
dso config add -v6 -w "${working_dir}" namespace $namespace > /dev/null

printf "\n\ndso config add -v6 -w \"${working_dir}\" application $application\n\n"
dso config add -v6 -w "${working_dir}" application $application > /dev/null

