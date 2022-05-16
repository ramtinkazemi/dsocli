#!/bin/bash

path=$(dirname $0)

bash "${path}/delete-parameters.sh"
sleep 3
response="$(dso parameter list -s dev -f shell)"
expected="$(cat <<-END
END
)"
bash "${path}/assert.sh" "${expected}" "${response}" || exit 1


bash "${path}/add-parameters.sh"
sleep 3
response="$(dso parameter list -s dev -f shell)"
expected="$(cat <<-END
gp='gp_value'
op='asop_value'
gsp='gsp_value'
np='np_value'
nsp='nsp_value'
ap='ap_value'
asp='asp_value'
END
)"
bash "${path}/assert.sh" "${expected}" "${response}" || exit 1


bash "${path}/delete-secrets.sh"
sleep 3
response="$(dso secret list -d -s dev -f shell)"
expected="$(cat <<-END
END
)"
bash "${path}/assert.sh" "${expected}" "${response}" || exit 1


bash "${path}/add-secrets.sh"
sleep 3
response="$(dso secret list -d -s dev -f shell)"
expected="$(cat <<-END
gs='gs_value'
os='asos_value'
gss='gss_value'
ns='ns_value'
nss='nss_value'
as='as_value'
ass='ass_value'
END
)"
bash "${path}/assert.sh" "${expected}" "${response}" || exit 1


bash "${path}/delete-templates.sh"
sleep 3
response="$(dso template list -s dev -f shell)"
expected="$(cat <<-END
END
)"
bash "${path}/assert.sh" "${expected}" "${response}" || exit 1


bash "${path}/add-templates.sh"
sleep 3
response="$(dso template list -s dev -f shell)"
expected="$(cat <<-END
gt='./.dso/output/gt'
ot='./.dso/output/ot'
gst='./.dso/output/gst'
nt='./.dso/output/nt'
nst='./.dso/output/nst'
at='./.dso/output/at'
ast='./.dso/output/ast'
END
)"
bash "${path}/assert.sh" "${expected}" "${response}" || exit 1


response="$(dso template render -s dev)"
expected="$(cat <<-END
{
  "Success": [
    {
      "Key": "gt",
      "Scope": "Global",
      "RenderPath": "./.dso/output/gt"
    },
    {
      "Key": "ot",
      "Scope": "Application Stage",
      "RenderPath": "./.dso/output/ot"
    },
    {
      "Key": "gst",
      "Scope": "Global Stage",
      "RenderPath": "./.dso/output/gst"
    },
    {
      "Key": "nt",
      "Scope": "Namespace",
      "RenderPath": "./.dso/output/nt"
    },
    {
      "Key": "nst",
      "Scope": "Namespace Stage",
      "RenderPath": "./.dso/output/nst"
    },
    {
      "Key": "at",
      "Scope": "Application",
      "RenderPath": "./.dso/output/at"
    },
    {
      "Key": "ast",
      "Scope": "Application Stage",
      "RenderPath": "./.dso/output/ast"
    }
  ],
  "Failure": []
}
END
)"
bash "${path}/assert.sh" "${expected}" "${response}" || exit 1
