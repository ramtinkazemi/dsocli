#!/bin/bash

path=$(dirname $0)

dso config set config.provider.id local/v1 
dso config set parameter.provider.id local/v1 
dso config set secret.provider.id local/v1 
dso config set template.provider.id local/v1 
bash "${path}/quick-test.sh"

dso config set config.provider.id aws/ssm/v1 
dso config set parameter.provider.id aws/ssm/v1 
dso config set secret.provider.id aws/ssm/v1 
dso config set template.provider.id aws/ssm/v1 
bash "${path}/quick-test.sh"


export ap_value=ap_value
export asp_value=asp_value
export gp_value=gp_value
export gsp_value=gsp_value
export np_value=np_value
export nsp_value=nsp_value
export asop_value=asop_value

export as_value=as_value
exsort ass_value=ass_value
exsort gs_value=gs_value
exsort gss_value=gss_value
exsort ns_value=ns_value
exsort nss_value=nss_value
exsort asos_value=asos_value

dso config set config.provider.id local/v1 
dso config set parameter.provider.id shell/v1 
dso config set secret.provider.id shell/v1 
dso config set template.provider.id local/v1 
bash "${path}/quick-test.sh"
