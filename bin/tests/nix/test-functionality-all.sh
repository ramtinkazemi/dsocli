#!/bin/bash
set -e -o pipefail

bin_path=$(realpath $(dirname $0))
root_path=$(realpath ${bin_path}/../../..)

namespace=test-ns
application=test-app
stage=test-stage

dso config add namespace $namespace > /dev/null
dso config add application $application > /dev/null

dso config add config.provider.id local/v1 > /dev/null
dso config add parameter.provider.id local/v1 > /dev/null
dso config add secret.provider.id local/v1 > /dev/null
dso config add template.provider.id local/v1 > /dev/null
${bin_path}/test-functionality.sh $stage

dso config add config.provider.id aws/ssm/v1 > /dev/null
dso config add parameter.provider.id aws/ssm/v1 > /dev/null
dso config add secret.provider.id aws/ssm/v1 > /dev/null
dso config add template.provider.id aws/ssm/v1 > /dev/null
${bin_path}/test-functionality.sh $stage


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

dso config add config.provider.id local/v1 > /dev/null
dso config add parameter.provider.id shell/v1 > /dev/null
dso config add secret.provider.id shell/v1 > /dev/null
dso config add template.provider.id local/v1 > /dev/null
${bin_path}/test-functionality.sh $stage
