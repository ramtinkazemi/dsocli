#!/bin/bash

path=$(dirname $0)

dso config add config.provider.id local/v1 > /dev/null
dso config add parameter.provider.id local/v1 > /dev/null
dso config add secret.provider.id local/v1 > /dev/null
dso config add template.provider.id local/v1 > /dev/null
bash "${path}/quick-test.sh"

dso config add config.provider.id aws/ssm/v1 > /dev/null
dso config add parameter.provider.id aws/ssm/v1 > /dev/null
dso config add secret.provider.id aws/ssm/v1 > /dev/null
dso config add template.provider.id aws/ssm/v1 > /dev/null
bash "${path}/quick-test.sh"


export ap_value=ap_value
export asp_value=asp_value
export gp_value=gp_value
export gsp_value=gsp_value
export np_value=np_value
export nsp_value=nsp_value
export asop_value=asop_value

export as_value=as_value
export ass_value=ass_value
export gs_value=gs_value
export gss_value=gss_value
export ns_value=ns_value
export nss_value=nss_value
export asos_value=asos_value

dso config add config.provider.id local/v1 > /dev/null
dso config add parameter.provider.id shell/v1 > /dev/null
dso config add secret.provider.id shell/v1 > /dev/null
dso config add template.provider.id local/v1 > /dev/null
bash "${path}/quick-test.sh"
