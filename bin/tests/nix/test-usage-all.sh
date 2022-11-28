#!/bin/bash
set -e -o pipefail

## printf "\n\nUSAGE: $0 <namespace [test-ns]> <application [test-app]> <stage [test-stage]> <working_dir [.]>\n\n"

bin_path=$(realpath $(dirname $0))
root_path=$(realpath $bin_path/../../..)

namespace=${1:-"test-ns"}
application=${2:-"test-app"}
stage=${3:-"test-stage"}
working_dir=${4:-$root_path}

[ -d .dso/output ] || mkdir .dso/output && rm -rf .dso/output/*

###################################

export DSO_USE_PAGER=${DSO_USE_PAGER:=no}
export TEST_INTRACTIVELY=${TEST_INTRACTIVELY:=yes}

###################################

$bin_path/test-usage-config.sh $namespace $application $stage $working_dir

provider=aws/ssm/v1
$bin_path/test-usage-parameters.sh $namespace $application $stage $provider
$bin_path/test-usage-secrets.sh $namespace $application $stage $provider
$bin_path/test-usage-templates.sh $namespace $application $stage $provider

provider=local/v1
$bin_path/test-usage-parameters.sh $namespace $application $stage $provider
$bin_path/test-usage-secrets.sh $namespace $application $stage $provider
$bin_path/test-usage-templates.sh $namespace $application $stage $provider

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

provider=shell/v1
$bin_path/test-usage-parameters.sh $namespace $application $stage $provider

export global_secret='global secret'
export global_stage_secret='global stage secret'
export namespace_secret='namespace secret'
export namespace_stage_secret='namespace stage secret'
export app_secret='app secret'
export app_stage_secret='app stage secret'
export global_overriden_secret='global overriden secret'
export global_stage_overriden_secret='global stage overriden secret'
export namespace_overriden_secret='namespace overriden secret'
export namespace_stage_overriden_secret='namespace stage overriden secret'
export app_overriden_secret='app overriden secret'
export app_stage_overriden_secret='app stage overriden secret'
export app_stage2_overriden_secret='app stage2 overriden secret'

provider=shell/v1
$bin_path/test-usage-secrets.sh $namespace $application $stage $provider

provider=local/v1
$bin_path/test-usage-templates.sh $namespace $application $stage $provider
