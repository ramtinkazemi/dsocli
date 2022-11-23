#!/bin/bash
set -e -o pipefail

## printf "\n\nUSAGE: $0 <stage [test-stage]>\n\n"

bin_path=$(realpath $(dirname $0))
root_path=$(realpath $bin_path/../../..)

stage=${1:-"test-stage"}

### deleting parameters
${bin_path}/delete-parameters.sh $stage
sleep 3
response="$(dso parameter list -s $stage -f compact)"
expected="$(cat <<-END
END
)"
${bin_path}/assert.sh "${expected}" "${response}"

### adding parameters
${bin_path}/add-parameters.sh $stage
sleep 3
response="$(dso parameter list -s $stage/2 -f compact)"
expected="$(cat <<-END
ap='ap_value'
as2p='as2p_value'
asp='asp_value'
gp='gp_value'
gsp='gsp_value'
np='np_value'
nsp='nsp_value'
op='as2op_value'
END
)"
${bin_path}/assert.sh "${expected}" "${response}"

### deleting secrets
${bin_path}/delete-secrets.sh $stage
sleep 3
response="$(dso secret list -d -s $stage -f compact)"
expected="$(cat <<-END
END
)"
${bin_path}/assert.sh "${expected}" "${response}"

### adding secrets
${bin_path}/add-secrets.sh $stage
sleep 3
response="$(dso secret list -d -s $stage/2 -f compact)"
expected="$(cat <<-END
as='as_value'
as2s='as2s_value'
ass='ass_value'
gs='gs_value'
gss='gss_value'
ns='ns_value'
nss='nss_value'
os='as2os_value'
END
)"
${bin_path}/assert.sh "${expected}" "${response}"


### deleting templates
${bin_path}/delete-templates.sh $stage
sleep 3
response="$(dso template list -s $stage -f compact)"
expected="$(cat <<-END
END
)"
${bin_path}/assert.sh "${expected}" "${response}"

### adding templates
${bin_path}/add-templates.sh $stage
sleep 3
response="$(dso template list -s $stage/2 -f compact)"
expected="$(cat <<-END
as2t='./.dso/output/as2t'
ast='./.dso/output/ast'
at='./.dso/output/at'
gst='./.dso/output/gst'
gt='./.dso/output/gt'
nst='./.dso/output/nst'
nt='./.dso/output/nt'
ot='./.dso/output/ot'
END
)"
${bin_path}/assert.sh "${expected}" "${response}"

### rendering templates
response="$(dso template render -s $stage/2)"
expected="$(cat <<-END
{
  "Success": [
    {
      "Key": "as2t",
      "Scope": "Application Numbered Stage",
      "RenderPath": "./.dso/output/as2t"
    },
    {
      "Key": "ast",
      "Scope": "Application Stage",
      "RenderPath": "./.dso/output/ast"
    },
    {
      "Key": "at",
      "Scope": "Application",
      "RenderPath": "./.dso/output/at"
    },
    {
      "Key": "gst",
      "Scope": "Global Stage",
      "RenderPath": "./.dso/output/gst"
    },
    {
      "Key": "gt",
      "Scope": "Global",
      "RenderPath": "./.dso/output/gt"
    },
    {
      "Key": "nst",
      "Scope": "Namespace Stage",
      "RenderPath": "./.dso/output/nst"
    },
    {
      "Key": "nt",
      "Scope": "Namespace",
      "RenderPath": "./.dso/output/nt"
    },
    {
      "Key": "ot",
      "Scope": "Application Numbered Stage",
      "RenderPath": "./.dso/output/ot"
    }
  ],
  "Failure": []
}
END
)"
${bin_path}/assert.sh "${expected}" "${response}"

### validating some rendred template
response="$(<.dso/output/as2t)"
expected="$(cat <<-END
Application Stage 2 Template
Params:
op = as2op_value
gp = gp_value
gsp = gsp_value
np = np_value
nsp = nsp_value
ap = ap_value
asp = asp_value
as2p = as2p_value
Secrets:
os = as2os_value
gs = gs_value
gss = gss_value
ns = ns_value
nss = nss_value
as = as_value
ass = ass_value
as2s = as2s_value
END
)"
${bin_path}/assert.sh "${expected}" "${response}"

response="$(<.dso/output/ot)"
expected="$(cat <<-END
Overriden Application Stage 2 Template
Params:
op = as2op_value
gp = gp_value
gsp = gsp_value
np = np_value
nsp = nsp_value
ap = ap_value
asp = asp_value
as2p = as2p_value
Secrets:
os = as2os_value
gs = gs_value
gss = gss_value
ns = ns_value
nss = nss_value
as = as_value
ass = ass_value
as2s = as2s_value
END
)"
${bin_path}/assert.sh "${expected}" "${response}"


