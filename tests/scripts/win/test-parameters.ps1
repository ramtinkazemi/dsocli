param(
    [string]$provider = "local/v1",
    [string]$namespace = "test-ns",
    [string]$application = "test-app",
    [string]$stage = "test-stage",
    [string]$working_dir = "."

)

$ErrorActionPreference = "Stop"

##################################
function Invoke-Call([scriptblock]$ScriptBlock, [string]$ErrorAction = $ErrorActionPreference) {
    & @ScriptBlock
    if (($lastexitcode -ne 0) -and $ErrorAction -eq "Stop") {
        exit $lastexitcode
}
}

##################################

if (!(Test-Path tests\output\parameter)) {
    New-Item -ItemType Directory -Force -Path tests\output\parameter > $null
}
else {
    Get-ChildItem tests\output\parameter -Recurse | Remove-Item > $null
}

##################################
### delete existing parameters, in order to also test overriding configurartions, they will be set later

Write-Output "`ndso parameter list -v5 -w `"${working_dir}`" --config `"namespace=${namespace}, application=${application}, parameter.provider.id=${provider}`" --global-scope --uninherited -f json | dso parameter delete -v5 -w `"${working_dir}`" --config `"namespace=${namespace}, application=${application}, parameter.provider.id=${provider}`" --global-scope -i - -f json`n"
Invoke-Call -ScriptBlock {dso parameter list -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, parameter.provider.id=${provider}" --global-scope --uninherited -f json | dso parameter delete -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, parameter.provider.id=${provider}" --global-scope -i - -f json} -ErrorAction Stop > $null

Write-Output "`ndso parameter list -v5 -w `"${working_dir}`" --config `"namespace=${namespace}, application=${application}, parameter.provider.id=${provider}`" -s ${stage} --global-scope --uninherited -f yaml | dso parameter delete -v5 -w `"${working_dir}`" --config `"namespace=${namespace}, application=${application}, parameter.provider.id=${provider}`" -s ${stage} --global-scope -i - -f yaml`n"
Invoke-Call -ScriptBlock {dso parameter list -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, parameter.provider.id=${provider}" -s ${stage} --global-scope --uninherited -f yaml | dso parameter delete -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, parameter.provider.id=${provider}" -s ${stage} --global-scope -i - -f yaml} -ErrorAction Stop > $null

Write-Output "`ndso parameter list -v5 -w `"${working_dir}`" --config `"namespace=${namespace}, application=${application}, parameter.provider.id=${provider}`" --namespace-scope --uninherited | dso parameter delete -v5 -w `"${working_dir}`" --config `"namespace=${namespace}, application=${application}, parameter.provider.id=${provider}`" --namespace-scope -i -`n"
Invoke-Call -ScriptBlock {dso parameter list -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, parameter.provider.id=${provider}" --namespace-scope --uninherited | dso parameter delete -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, parameter.provider.id=${provider}" --namespace-scope -i -} -ErrorAction Stop > $null

Write-Output "`ndso parameter list -v5 -w `"${working_dir}`" --config `"namespace=${namespace}, application=${application}, parameter.provider.id=${provider}`" -s ${stage} --namespace-scope --uninherited -f shell | dso parameter delete -v5 -w `"${working_dir}`" --config `"namespace=${namespace}, application=${application}, parameter.provider.id=${provider}`" -s ${stage} --namespace-scope -i - -f shell`n"
Invoke-Call -ScriptBlock {dso parameter list -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, parameter.provider.id=${provider}" -s ${stage} --namespace-scope --uninherited -f shell | dso parameter delete -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, parameter.provider.id=${provider}" -s ${stage} --namespace-scope -i - -f shell} -ErrorAction Stop > $null

Write-Output "`ndso parameter list -v5 -w `"${working_dir}`" --config `"namespace=${namespace}, application=${application}, parameter.provider.id=${provider}`" --uninherited | dso parameter delete -v5 -w `"${working_dir}`" --config `"namespace=${namespace}, application=${application}, parameter.provider.id=${provider}`" -i -`n"
Invoke-Call -ScriptBlock {dso parameter list -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, parameter.provider.id=${provider}" --uninherited | dso parameter delete -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, parameter.provider.id=${provider}" -i -} -ErrorAction Stop > $null

Write-Output "`ndso parameter list -v5 -w `"${working_dir}`" --namespace ${namespace} --namespace ${namespace} --application ${application} --config `"parameter.provider.id=${provider}` -s ${stage} --uninherited | dso parameter delete -v5 -w `"${working_dir}`" --config `"namespace=${namespace}, application=${application}, parameter.provider.id=${provider}`" -s ${stage} -i -`n"
Invoke-Call -ScriptBlock {dso parameter list -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, parameter.provider.id=${provider}" -s ${stage} --uninherited | dso parameter delete -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, parameter.provider.id=${provider}" -s ${stage} -i -} -ErrorAction Stop > $null

Write-Output "`ndso parameter list -v5 -w `"${working_dir}`" --namespace ${namespace} --namespace ${namespace} --application ${application} --config `"parameter.provider.id=${provider}` -s "${stage}/2" --uninherited | dso parameter delete -v5 -w `"${working_dir}`" --config `"namespace=${namespace}, application=${application}, parameter.provider.id=${provider}`" -s "${stage}/2" -i -`n"
Invoke-Call -ScriptBlock {dso parameter list -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, parameter.provider.id=${provider}" -s "${stage}/2" --uninherited | dso parameter delete -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, parameter.provider.id=${provider}" -s "${stage}/2" -i -} -ErrorAction Stop > $null

##################################
### Setting configurations

Write-Output "`ndso config set -v5 -w `"${working_dir}`" namespace ${namespace}`n"
Invoke-Call -ScriptBlock {dso config set -v5 -w "${working_dir}" namespace ${namespace}} -ErrorAction Stop > $null

Write-Output "`ndso config set -v5 -w `"${working_dir}`" application ${application}`n"
Invoke-Call -ScriptBlock {dso config set -v5 -w "${working_dir}" application ${application}} -ErrorAction Stop > $null

Write-Output "`ndso config set -v5 -w `"${working_dir}`" parameter.provider.id ${provider}`n"
Invoke-Call -ScriptBlock {dso config set -v5 -w "${working_dir}" parameter.provider.id ${provider}} -ErrorAction Stop > $null


##################################
### add context-specific parameters

Write-Output "`ndso parameter add -v5 -w `"${working_dir}`" global.parameter global_parameter --global-scope`n"
Invoke-Call -ScriptBlock {dso parameter add -v5 -w "${working_dir}" global.parameter global_parameter --global-scope} -ErrorAction Stop > $null

Write-Output "`ndso parameter add -v5 -w `"${working_dir}`" global.stage_parameter global_stage_parameter -s ${stage} --global-scope`n"
Invoke-Call -ScriptBlock {dso parameter add -v5 -w "${working_dir}" global.stage_parameter global_stage_parameter -s ${stage} --global-scope} -ErrorAction Stop > $null

Write-Output "`ndso parameter add -v5 -w `"${working_dir}`" namespace.parameter namespace_parameter --namespace-scope`n"
Invoke-Call -ScriptBlock {dso parameter add -v5 -w "${working_dir}" namespace.parameter namespace_parameter --namespace-scope} -ErrorAction Stop > $null

Write-Output "`ndso parameter add -v5 -w `"${working_dir}`" namespace.stage_parameter namespace_stage_parameter -s ${stage} --namespace-scope`n"
Invoke-Call -ScriptBlock {dso parameter add -v5 -w "${working_dir}" namespace.stage_parameter namespace_stage_parameter -s ${stage} --namespace-scope} -ErrorAction Stop > $null


Write-Output "`ndso parameter add -v5 -w `"${working_dir}`" app.parameter app_parameter`n"
Invoke-Call -ScriptBlock {dso parameter add -v5 -w "${working_dir}" app.parameter app_parameter} -ErrorAction Stop > $null

Write-Output "`ndso parameter add -v5 -w `"${working_dir}`" app.stage_parameter app_stage_parameter -s ${stage}`n"
Invoke-Call -ScriptBlock {dso parameter add -v5 -w "${working_dir}" app.stage_parameter app_stage_parameter -s ${stage}} -ErrorAction Stop > $null

Write-Output "`ndso parameter add -v5 -w `"${working_dir}`" app.stage2_parameter app_stage2_parameter -s `"${stage}/2`"`n"
Invoke-Call -ScriptBlock {dso parameter add -v5 -w "${working_dir}" app.stage2_parameter app_stage2_parameter -s "${stage}/2"} -ErrorAction Stop > $null

##################################
### add overriden parameters

Write-Output "`ndso parameter add -v5 -w `"${working_dir}`" overriden_parameter global_overridden_parameter --global-scope`n"
Invoke-Call -ScriptBlock {dso parameter add -v5 -w "${working_dir}" overriden_parameter global_overridden_parameter --global-scope} -ErrorAction Stop > $null

Write-Output "`ndso parameter add -v5 -w `"${working_dir}`" overriden_parameter global_stage_overridden_parameter -s ${stage} --global-scope`n"
Invoke-Call -ScriptBlock {dso parameter add -v5 -w "${working_dir}" overriden_parameter global_stage_overridden_parameter -s ${stage} --global-scope} -ErrorAction Stop > $null


Write-Output "`ndso parameter add -v5 -w `"${working_dir}`" overriden_parameter namespace_overridden_parameter --namespace-scope`n"
Invoke-Call -ScriptBlock {dso parameter add -v5 -w "${working_dir}" overriden_parameter namespace_overridden_parameter --namespace-scope} -ErrorAction Stop > $null

Write-Output "`ndso parameter add -v5 -w `"${working_dir}`" overriden_parameter namespace_stage_overridden_parameter -s ${stage} --namespace-scope`n"
Invoke-Call -ScriptBlock {dso parameter add -v5 -w "${working_dir}" overriden_parameter namespace_stage_overridden_parameter -s ${stage} --namespace-scope} -ErrorAction Stop > $null


Write-Output "`ndso parameter add -v5 -w `"${working_dir}`" overriden_parameter app_overridden_parameter`n"
Invoke-Call -ScriptBlock {dso parameter add -v5 -w "${working_dir}" overriden_parameter app_overridden_parameter} -ErrorAction Stop > $null

Write-Output "`ndso parameter add -v5 -w `"${working_dir}`" overriden_parameter app_stage_overridden_parameter -s ${stage}`n"
Invoke-Call -ScriptBlock {dso parameter add -v5 -w "${working_dir}" overriden_parameter app_stage_overridden_parameter -s ${stage}} -ErrorAction Stop > $null

Write-Output "`ndso parameter add -v5 -w `"${working_dir}`" overriden_parameter app_stage2_overridden_parameter -s `"${stage}/2`"`n"
Invoke-Call -ScriptBlock {dso parameter add -v5 -w "${working_dir}" overriden_parameter app_stage2_overridden_parameter -s "${stage}/2"} -ErrorAction Stop > $null


##################################
### get some parameters

Write-Output "`ndso parameter get -v5 -w `"${working_dir}`" overriden_parameter --scope Global -f raw`n"
Invoke-Call -ScriptBlock {dso parameter get -v5 -w "${working_dir}" overriden_parameter --scope Global -f raw} -ErrorAction Stop > $null

Write-Output "`ndso parameter get -v5 -w `"${working_dir}`" overriden_parameter --scope namespace -f raw`n"
Invoke-Call -ScriptBlock {dso parameter get -v5 -w "${working_dir}" overriden_parameter  --scope namespace -f raw} -ErrorAction Stop > $null

Write-Output "`ndso parameter get -v5 -w `"${working_dir}`" overriden_parameter -s ${stage} -f raw`n"
Invoke-Call -ScriptBlock {dso parameter get -v5 -w "${working_dir}" overriden_parameter -s ${stage} -f raw} -ErrorAction Stop > $null

Write-Output "`ndso parameter get -v5 -w `"${working_dir}`" overriden_parameter -s `"${stage}/2`" -f raw`n"
Invoke-Call -ScriptBlock {dso parameter get -v5 -w "${working_dir}" overriden_parameter -s "${stage}/2" -f raw} -ErrorAction Stop > $null

Write-Output "`ndso parameter get -v5 -w `"${working_dir}`" app.parameter -s ${stage} -f raw`n"
Invoke-Call -ScriptBlock {dso parameter get -v5 -w "${working_dir}" app.parameter -s ${stage} -f raw} -ErrorAction Stop > $null

Write-Output "`ndso parameter get -v5 -w `"${working_dir}`" app.stage_parameter -s ${stage} -f raw`n"
Invoke-Call -ScriptBlock {dso parameter get -v5 -w "${working_dir}" app.stage_parameter -s ${stage} -f raw} -ErrorAction Stop > $null

Write-Output "`ndso parameter get -v5 -w `"${working_dir}`" app.stage2_parameter -s `"${stage}/2`" -f raw`n"
Invoke-Call -ScriptBlock {dso parameter get -v5 -w "${working_dir}" app.stage2_parameter -s "${stage}/2" -f raw} -ErrorAction Stop > $null


##################################
### edit some parameters

Write-Output "`ndso parameter edit -v5 -w `"${working_dir}`" overriden_parameter --global-scope`n"
Invoke-Call -ScriptBlock {dso parameter edit -v5 -w "${working_dir}" overriden_parameter --global-scope} -ErrorAction Stop

Write-Output "`ndso parameter edit -v5 -w `"${working_dir}`" overriden_parameter -s ${stage} --namespace-scope`n"
Invoke-Call -ScriptBlock {dso parameter edit -v5 -w "${working_dir}" overriden_parameter -s ${stage} --namespace-scope} -ErrorAction Stop

Write-Output "`ndso parameter edit -v5 -w `"${working_dir}`" app.parameter`n"
Invoke-Call -ScriptBlock {dso parameter edit -v5 -w "${working_dir}" app.parameter} -ErrorAction Stop

Write-Output "`ndso parameter edit -v5 -w `"${working_dir}`" app.stage_parameter -s ${stage}`n"
Invoke-Call -ScriptBlock {dso parameter edit -v5 -w "${working_dir}" app.stage_parameter -s ${stage}} -ErrorAction Stop

Write-Output "`ndso parameter edit -v5 -w `"${working_dir}`" app.stage2_parameter -s `"${stage}/2`"`n"
Invoke-Call -ScriptBlock {dso parameter edit -v5 -w "${working_dir}" app.stage2_parameter -s "${stage}/2"} -ErrorAction Stop


##################################
### getting history of some parameters

Write-Output "`ndso parameter history -v5 -w `"${working_dir}`" overriden_parameter -f json`n"
Invoke-Call -ScriptBlock {dso parameter history -v5 -w "${working_dir}" overriden_parameter -f json} -ErrorAction Stop > $null

Write-Output "`ndso parameter history -v5 -w `"${working_dir}`" overriden_parameter -s ${stage} -f json`n"
Invoke-Call -ScriptBlock {dso parameter history -v5 -w "${working_dir}" overriden_parameter -s ${stage} -f json} -ErrorAction Stop > $null

Write-Output "`ndso parameter history -v5 -w `"${working_dir}`" app.parameter -s ${stage} --query-all -f json`n"
Invoke-Call -ScriptBlock {dso parameter history -v5 -w "${working_dir}" app.parameter -s ${stage} --query-all -f json} -ErrorAction Stop > $null

Write-Output "`ndso parameter history -v5 -w `"${working_dir}`" app.stage_parameter -s ${stage} --query-all -f json`n"
Invoke-Call -ScriptBlock {dso parameter history -v5 -w "${working_dir}" app.stage_parameter -s ${stage} --query-all -f json} -ErrorAction Stop > $null

Write-Output "`ndso parameter history -v5 -w `"${working_dir}`" app.stage_parameter -s `"${stage}/2`" --query-all -f json`n"
Invoke-Call -ScriptBlock {dso parameter history -v5 -w "${working_dir}" app.stage_parameter -s "${stage}/2" --query-all -f json} -ErrorAction Stop > $null


##################################
### listing some parameters

$filename = (${provider} -split '/')[0]

Write-Output "`ndso parameter list -v5 -w `"${working_dir}`" -s ${stage} --uninherited --query-all --filter overriden_parameter`n"
Invoke-Call -ScriptBlock {dso parameter list -v5 -w "${working_dir}" -s ${stage} --uninherited --query-all --filter ovverriden_parameter} -ErrorAction Stop > $null

Write-Output "`ndso parameter list -v5 -w `"${working_dir}`" -s ${stage} --uninherited --query-all -f json`n"
Invoke-Call -ScriptBlock {dso parameter list -v5 -w "${working_dir}" -s ${stage} --uninherited --query-all -f json} -ErrorAction Stop > "tests/output/parameter/app.stage_uninherited-${filename}.json"

Write-Output "`ndso parameter list -v5 -w `"${working_dir}`" -s ${stage} --query-all -f yaml`n"
Invoke-Call -ScriptBlock {dso parameter list -v5 -w "${working_dir}" -s ${stage} --query-all -f yaml} -ErrorAction Stop > "tests/output/parameter/app.stage_all-${filename}.yaml"

Write-Output "`ndso parameter list -v5 -w `"${working_dir}`" -s `"${stage}/2`" --query-all -f yaml`n"
Invoke-Call -ScriptBlock {dso parameter list -v5 -w "${working_dir}" -s "${stage}/2" --query-all -f yaml} -ErrorAction Stop > "tests/output/parameter/app.stage2-all-${filename}.yaml"
