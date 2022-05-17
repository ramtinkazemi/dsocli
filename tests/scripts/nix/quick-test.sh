#!/bin/bash

path=$(dirname $0)

bash "${path}/delete-parameters.sh"
sleep 3
response="$(dso parameter list -s dev -f compact)"
expected="$(cat <<-END
END
)"
bash "${path}/assert.sh" "${expected}" "${response}" || exit 1


bash "${path}/add-parameters.sh"
sleep 3
response="$(dso parameter list -s dev -f compact)"
expected="$(cat <<-END
ap='ap_value'
asp='asp_value'
gp='gp_value'
gsp='gsp_value'
np='np_value'
nsp='nsp_value'
op='asop_value'
END
)"
bash "${path}/assert.sh" "${expected}" "${response}" || exit 1


bash "${path}/delete-secrets.sh"
sleep 3
response="$(dso secret list -d -s dev -f compact)"
expected="$(cat <<-END
END
)"
bash "${path}/assert.sh" "${expected}" "${response}" || exit 1


bash "${path}/add-secrets.sh"
sleep 3
response="$(dso secret list -d -s dev -f compact)"
expected="$(cat <<-END
as='as_value'
ass='ass_value'
gs='gs_value'
gss='gss_value'
ns='ns_value'
nss='nss_value'
os='asos_value'
END
)"
bash "${path}/assert.sh" "${expected}" "${response}" || exit 1


bash "${path}/delete-templates.sh"
sleep 3
response="$(dso template list -s dev -f compact)"
expected="$(cat <<-END
END
)"
bash "${path}/assert.sh" "${expected}" "${response}" || exit 1


bash "${path}/add-templates.sh"
sleep 3
response="$(dso template list -s dev -f compact)"
expected="$(cat <<-END
ast='./.dso/output/ast'
at='./.dso/output/at'
gst='./.dso/output/gst'
gt='./.dso/output/gt'
nst='./.dso/output/nst'
nt='./.dso/output/nt'
ot='./.dso/output/ot'
END
)"
bash "${path}/assert.sh" "${expected}" "${response}" || exit 1


response="$(dso template render -s dev)"
expected="$(cat <<-END
{
  "Success": [
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
      "Scope": "Application Stage",
      "RenderPath": "./.dso/output/ot"
    }
  ],
  "Failure": []
}
END
)"
bash "${path}/assert.sh" "${expected}" "${response}" || exit 1

response="$(<./.dso/output/ot)"
expected="$(cat <<-END
Overriden Application Stage Template
Params:
op = asop_value
gp = gp_value
gsp = gsp_value
np = np_value
nsp = nsp_value
ap = ap_value
asp = asp_value
Secrets:
os = asos_value
gs = gs_value
gss = gss_value
ns = ns_value
nss = nss_value
as = as_value
ass = ass_value
END
)"
bash "${path}/assert.sh" "${expected}" "${response}" || exit 1


response="$(<./.dso/output/ast)"
expected="$(cat <<-END
Application Stage Template
Params:
op = asop_value
gp = gp_value
gsp = gsp_value
np = np_value
nsp = nsp_value
ap = ap_value
asp = asp_value
Secrets:
os = asos_value
gs = gs_value
gss = gss_value
ns = ns_value
nss = nss_value
as = as_value
ass = ass_value
END
)"
bash "${path}/assert.sh" "${expected}" "${response}" || exit 1

