param(
    [string]$provider = "local/v1",
    [string]$namespace = "test-ns",
    [string]$application = "test-app",
    [string]$stage = "test-stage"

)

$ErrorActionPreference = "Stop"

##################################

$Env:DSO_USE_PAGER = "no"

##################################
function Invoke-Call([scriptblock]$ScriptBlock, [string]$ErrorAction = $ErrorActionPreference) {
    & @ScriptBlock
    if (($lastexitcode -ne 0) -and $ErrorAction -eq "Stop") {
        exit $lastexitcode
}
}

##################################

if (!(Test-Path .dso\output\parameter)) {
    New-Item -ItemType Directory -Force -Path .dso\output\parameter > $null
}
else {
    Get-ChildItem .dso\output\parameter -Recurse | Remove-Item > $null
}

##################################
### delete existing parameters, in order to also test overriding configurartions, they will be set later

Write-Output "`ndso parameter list -v6 --config `"namespace=${namespace}, application=${application}, parameter.provider.id=${provider}`" --global-scope --uninherited -f json | dso parameter delete -v6 --config `"namespace=${namespace}, application=${application}, parameter.provider.id=${provider}`" --global-scope -i - -f json`n"
Invoke-Call -ScriptBlock {dso parameter list -v6 --config "namespace=${namespace}, application=${application}, parameter.provider.id=${provider}" --global-scope --uninherited -f json | dso parameter delete -v6 --config "namespace=${namespace}, application=${application}, parameter.provider.id=${provider}" --global-scope -i - -f json} -ErrorAction Stop

Write-Output "`ndso parameter list -v6 --config `"namespace=${namespace}, application=${application}, parameter.provider.id=${provider}`" -s ${stage} --global-scope --uninherited -f yaml | dso parameter delete -v6 --config `"namespace=${namespace}, application=${application}, parameter.provider.id=${provider}`" -s ${stage} --global-scope -i - -f yaml`n"
Invoke-Call -ScriptBlock {dso parameter list -v6 --config "namespace=${namespace}, application=${application}, parameter.provider.id=${provider}" -s ${stage} --global-scope --uninherited -f yaml | dso parameter delete -v6 --config "namespace=${namespace}, application=${application}, parameter.provider.id=${provider}" -s ${stage} --global-scope -i - -f yaml} -ErrorAction Stop

Write-Output "`ndso parameter list -v6 --config `"namespace=${namespace}, application=${application}, parameter.provider.id=${provider}`" --namespace-scope --uninherited -f json | dso parameter delete -v6 --config `"namespace=${namespace}, application=${application}, parameter.provider.id=${provider}`" --namespace-scope -i -`n"
Invoke-Call -ScriptBlock {dso parameter list -v6 --config "namespace=${namespace}, application=${application}, parameter.provider.id=${provider}" --namespace-scope --uninherited -f json | dso parameter delete -v6 --config "namespace=${namespace}, application=${application}, parameter.provider.id=${provider}" --namespace-scope -i -} -ErrorAction Stop

Write-Output "`ndso parameter list -v6 --config `"namespace=${namespace}, application=${application}, parameter.provider.id=${provider}`" -s ${stage} --namespace-scope --uninherited -f compact | dso parameter delete -v6 --config `"namespace=${namespace}, application=${application}, parameter.provider.id=${provider}`" -s ${stage} --namespace-scope -i - -f compact`n"
Invoke-Call -ScriptBlock {dso parameter list -v6 --config "namespace=${namespace}, application=${application}, parameter.provider.id=${provider}" -s ${stage} --namespace-scope --uninherited -f compact | dso parameter delete -v6 --config "namespace=${namespace}, application=${application}, parameter.provider.id=${provider}" -s ${stage} --namespace-scope -i - -f compact} -ErrorAction Stop

Write-Output "`ndso parameter list -v6 --config `"namespace=${namespace}, application=${application}, parameter.provider.id=${provider}`" --uninherited -f json | dso parameter delete -v6 --config `"namespace=${namespace}, application=${application}, parameter.provider.id=${provider}`" -i -`n"
Invoke-Call -ScriptBlock {dso parameter list -v6 --config "namespace=${namespace}, application=${application}, parameter.provider.id=${provider}" --uninherited -f json | dso parameter delete -v6 --config "namespace=${namespace}, application=${application}, parameter.provider.id=${provider}" -i -} -ErrorAction Stop

Write-Output "`ndso parameter list -v6 --namespace ${namespace} --namespace ${namespace} --application ${application} --config `"parameter.provider.id=${provider}` -s ${stage} --uninherited -f json | dso parameter delete -v6 --config `"namespace=${namespace}, application=${application}, parameter.provider.id=${provider}`" -s ${stage} -i -`n"
Invoke-Call -ScriptBlock {dso parameter list -v6 --config "namespace=${namespace}, application=${application}, parameter.provider.id=${provider}" -s ${stage} --uninherited -f json | dso parameter delete -v6 --config "namespace=${namespace}, application=${application}, parameter.provider.id=${provider}" -s ${stage} -i -} -ErrorAction Stop

Write-Output "`ndso parameter list -v6 --namespace ${namespace} --namespace ${namespace} --application ${application} --config `"parameter.provider.id=${provider}` -s "${stage}/2" --uninherited -f json | dso parameter delete -v6 --config `"namespace=${namespace}, application=${application}, parameter.provider.id=${provider}`" -s "${stage}/2" -i -`n"
Invoke-Call -ScriptBlock {dso parameter list -v6 --config "namespace=${namespace}, application=${application}, parameter.provider.id=${provider}" -s "${stage}/2" --uninherited -f json | dso parameter delete -v6 --config "namespace=${namespace}, application=${application}, parameter.provider.id=${provider}" -s "${stage}/2" -i -} -ErrorAction Stop

##################################
### Setting configurations

Write-Output "`ndso config set -v6 namespace ${namespace}`n"
Invoke-Call -ScriptBlock {dso config set -v6 namespace ${namespace}} -ErrorAction Stop

Write-Output "`ndso config set -v6 application ${application}`n"
Invoke-Call -ScriptBlock {dso config set -v6 application ${application}} -ErrorAction Stop

Write-Output "`ndso config set -v6 parameter.provider.id ${provider}`n"
Invoke-Call -ScriptBlock {dso config set -v6 parameter.provider.id ${provider}} -ErrorAction Stop


##################################
### add context-specific parameters

Write-Output "`ndso parameter add -v6 global_parameter global_parameter --global-scope`n"
Invoke-Call -ScriptBlock {dso parameter add -v6 global_parameter global_parameter --global-scope} -ErrorAction Stop

Write-Output "`ndso parameter add -v6 global_stage_parameter global_stage_parameter -s ${stage} --global-scope`n"
Invoke-Call -ScriptBlock {dso parameter add -v6 global_stage_parameter global_stage_parameter -s ${stage} --global-scope} -ErrorAction Stop

Write-Output "`ndso parameter add -v6 namespace_parameter namespace_parameter --namespace-scope`n"
Invoke-Call -ScriptBlock {dso parameter add -v6 namespace_parameter namespace_parameter --namespace-scope} -ErrorAction Stop

Write-Output "`ndso parameter add -v6 namespace_stage_parameter namespace_stage_parameter -s ${stage} --namespace-scope`n"
Invoke-Call -ScriptBlock {dso parameter add -v6 namespace_stage_parameter namespace_stage_parameter -s ${stage} --namespace-scope} -ErrorAction Stop


Write-Output "`ndso parameter add -v6 app_parameter app_parameter`n"
Invoke-Call -ScriptBlock {dso parameter add -v6 app_parameter app_parameter} -ErrorAction Stop

Write-Output "`ndso parameter add -v6 app_stage_parameter app_stage_parameter -s ${stage}`n"
Invoke-Call -ScriptBlock {dso parameter add -v6 app_stage_parameter app_stage_parameter -s ${stage}} -ErrorAction Stop

Write-Output "`ndso parameter add -v6 app_stage2_parameter app_stage2_parameter -s `"${stage}/2`"`n"
Invoke-Call -ScriptBlock {dso parameter add -v6 app_stage2_parameter app_stage2_parameter -s "${stage}/2"} -ErrorAction Stop

##################################
### add overriden parameters

Write-Output "`ndso parameter add -v6 overriden_parameter global_overridden_parameter --global-scope`n"
Invoke-Call -ScriptBlock {dso parameter add -v6 overriden_parameter global_overridden_parameter --global-scope} -ErrorAction Stop

Write-Output "`ndso parameter add -v6 overriden_parameter global_stage_overridden_parameter -s ${stage} --global-scope`n"
Invoke-Call -ScriptBlock {dso parameter add -v6 overriden_parameter global_stage_overridden_parameter -s ${stage} --global-scope} -ErrorAction Stop


Write-Output "`ndso parameter add -v6 overriden_parameter namespace_overridden_parameter --namespace-scope`n"
Invoke-Call -ScriptBlock {dso parameter add -v6 overriden_parameter namespace_overridden_parameter --namespace-scope} -ErrorAction Stop

Write-Output "`ndso parameter add -v6 overriden_parameter namespace_stage_overridden_parameter -s ${stage} --namespace-scope`n"
Invoke-Call -ScriptBlock {dso parameter add -v6 overriden_parameter namespace_stage_overridden_parameter -s ${stage} --namespace-scope} -ErrorAction Stop


Write-Output "`ndso parameter add -v6 overriden_parameter app_overridden_parameter`n"
Invoke-Call -ScriptBlock {dso parameter add -v6 overriden_parameter app_overridden_parameter} -ErrorAction Stop

Write-Output "`ndso parameter add -v6 overriden_parameter app_stage_overridden_parameter -s ${stage}`n"
Invoke-Call -ScriptBlock {dso parameter add -v6 overriden_parameter app_stage_overridden_parameter -s ${stage}} -ErrorAction Stop

Write-Output "`ndso parameter add -v6 overriden_parameter app_stage2_overridden_parameter -s `"${stage}/2`"`n"
Invoke-Call -ScriptBlock {dso parameter add -v6 overriden_parameter app_stage2_overridden_parameter -s "${stage}/2"} -ErrorAction Stop


##################################
### get some parameters

Write-Output "`ndso parameter get -v6 overriden_parameter --global-scope -f text`n"
Invoke-Call -ScriptBlock {dso parameter get -v6 overriden_parameter --global-scope -f text} -ErrorAction Stop

Write-Output "`ndso parameter get -v6 overriden_parameter --namespace-scope -f text`n"
Invoke-Call -ScriptBlock {dso parameter get -v6 overriden_parameter --namespace-scope -f text} -ErrorAction Stop

Write-Output "`ndso parameter get -v6 overriden_parameter -s ${stage} -f text`n"
Invoke-Call -ScriptBlock {dso parameter get -v6 overriden_parameter -s ${stage} -f text} -ErrorAction Stop

Write-Output "`ndso parameter get -v6 overriden_parameter -s `"${stage}/2`" -f text`n"
Invoke-Call -ScriptBlock {dso parameter get -v6 overriden_parameter -s "${stage}/2" -f text} -ErrorAction Stop

Write-Output "`ndso parameter get -v6 app_parameter -s ${stage} -f text`n"
Invoke-Call -ScriptBlock {dso parameter get -v6 app_parameter -s ${stage} -f text} -ErrorAction Stop

Write-Output "`ndso parameter get -v6 app_stage_parameter -s ${stage} -f text`n"
Invoke-Call -ScriptBlock {dso parameter get -v6 app_stage_parameter -s ${stage} -f text} -ErrorAction Stop

Write-Output "`ndso parameter get -v6 app_stage2_parameter -s `"${stage}/2`" -f text`n"
Invoke-Call -ScriptBlock {dso parameter get -v6 app_stage2_parameter -s "${stage}/2" -f text} -ErrorAction Stop


##################################
### edit some parameters

# Write-Output "`ndso parameter edit -v6 overriden_parameter --global-scope`n"
# Invoke-Call -ScriptBlock {dso parameter edit -v6 overriden_parameter --global-scope} -ErrorAction Stop

# Write-Output "`ndso parameter edit -v6 overriden_parameter -s ${stage} --namespace-scope`n"
# Invoke-Call -ScriptBlock {dso parameter edit -v6 overriden_parameter -s ${stage} --namespace-scope} -ErrorAction Stop

# Write-Output "`ndso parameter edit -v6 app_parameter`n"
# Invoke-Call -ScriptBlock {dso parameter edit -v6 app_parameter} -ErrorAction Stop

# Write-Output "`ndso parameter edit -v6 app_stage_parameter -s ${stage}`n"
# Invoke-Call -ScriptBlock {dso parameter edit -v6 app_stage_parameter -s ${stage}} -ErrorAction Stop

# Write-Output "`ndso parameter edit -v6 app_stage2_parameter -s `"${stage}/2`"`n"
# Invoke-Call -ScriptBlock {dso parameter edit -v6 app_stage2_parameter -s "${stage}/2"} -ErrorAction Stop


##################################
### getting history of some parameters

Write-Output "`ndso parameter history -v6 overriden_parameter -f json`n"
Invoke-Call -ScriptBlock {dso parameter history -v6 overriden_parameter -f json} -ErrorAction Stop

Write-Output "`ndso parameter history -v6 overriden_parameter -s ${stage} -f json`n"
Invoke-Call -ScriptBlock {dso parameter history -v6 overriden_parameter -s ${stage} -f json} -ErrorAction Stop

Write-Output "`ndso parameter history -v6 app_parameter --query-all -f json`n"
Invoke-Call -ScriptBlock {dso parameter history -v6 app_parameter --query-all -f json} -ErrorAction Stop

Write-Output "`ndso parameter history -v6 app_stage_parameter -s ${stage} --query-all -f json`n"
Invoke-Call -ScriptBlock {dso parameter history -v6 app_stage_parameter -s ${stage} --query-all -f json} -ErrorAction Stop

Write-Output "`ndso parameter history -v6 app_stage2_parameter -s `"${stage}/2`" --query-all -f json`n"
Invoke-Call -ScriptBlock {dso parameter history -v6 app_stage2_parameter -s "${stage}/2" --query-all -f json} -ErrorAction Stop


##################################
### listing some parameters

$filename = (${provider} -split '/')[0]

Write-Output "`ndso parameter list -v6 -s ${stage} --uninherited --query-all overriden_parameter`n"
Invoke-Call -ScriptBlock {dso parameter list -v6 -s ${stage} --uninherited --query-all overriden_parameter} -ErrorAction Stop

Write-Output "`ndso parameter list -v6 -s ${stage} --uninherited --query-all -f json`n"
Invoke-Call -ScriptBlock {dso parameter list -v6 -s ${stage} --uninherited --query-all -f json} -ErrorAction Stop > ".dso\output\parameter\app_stage_uninherited-${filename}.json"

Write-Output "`ndso parameter list -v6 -s ${stage} --query-all -f yaml`n"
Invoke-Call -ScriptBlock {dso parameter list -v6 -s ${stage} --query-all -f yaml} -ErrorAction Stop > ".dso\output\parameter\app_stage_all-${filename}.yaml"

Write-Output "`ndso parameter list -v6 -s `"${stage}/2`" --query-all -f yaml`n"
Invoke-Call -ScriptBlock {dso parameter list -v6 -s "${stage}/2" --query-all -f yaml} -ErrorAction Stop > ".dso\output\parameter\app_stage2-all-${filename}.yaml"
