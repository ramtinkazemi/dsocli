#!/bin/bash
set -e -o pipefail

## printf "\n\nUSAGE: $0 <namespace [test-ns]> <application [test-app]> <stage [test-stage]>\n\n"

bin_path=$(realpath $(dirname $0))
root_path=$(realpath $bin_path/../../..)

namespace=${1:-"test-ns"}
application=${2:-"test-app"}
stage=${3:-"test-stage"}

dso config set namespace $namespace -v6 > /dev/null
dso config set application $application -v6 > /dev/null

dso config set config.provider.id local/v1 -v6 > /dev/null
dso config set parameter.provider.id local/v1 -v6 > /dev/null
dso config set secret.provider.id local/v1 -v6 > /dev/null
dso config set template.provider.id local/v1 -v6 > /dev/null
$bin_path/test-functionality.sh $stage

dso config set config.provider.id aws/ssm/v1 -v6 > /dev/null
dso config set parameter.provider.id aws/ssm/v1 -v6 > /dev/null
dso config set secret.provider.id aws/ssm/v1 -v6 > /dev/null
dso config set template.provider.id aws/ssm/v1 -v6 > /dev/null
$bin_path/test-functionality.sh $stage


export ap_value=ap_value
export asp_value=asp_value
export as2p_value=as2p_value
export gp_value=gp_value
export gsp_value=gsp_value
export np_value=np_value
export nsp_value=nsp_value
export asop_value=asop_value
export as2op_value=as2op_value

export as_value=as_value
export ass_value=ass_value
export as2s_value=as2s_value
export gs_value=gs_value
export gss_value=gss_value
export ns_value=ns_value
export nss_value=nss_value
export asos_value=asos_value
export as2os_value=as2os_value

dso config set config.provider.id local/v1 -v6 > /dev/null
dso config set parameter.provider.id shell/v1 -v6 > /dev/null
dso config set secret.provider.id shell/v1 -v6 > /dev/null
dso config set template.provider.id local/v1 -v6 > /dev/null
$bin_path/test-functionality.sh $stage
