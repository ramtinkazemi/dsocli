param(
    [string]$provider = "shell/v1",
    [string]$namespace = "test-ns",
    [string]$project = "test-project",
    [string]$application = "test-app",
    [string]$stage = "test-stage",
    [string]$working_dir = "."

)


$Env:global_secret='global.secret'
$Env:global_stage_secret='global.stage_secret'
$Env:project_secret='project.secret'
$Env:project_stage_secret='project.stage_secret'
$Env:app_secret='app.secret'
$Env:app_stage_secret='app.stage_secret'
$Env:global_overriden_secret='global.overriden_secret'
$Env:global_stage_overriden_secret='global.stage_overriden_secret'
$Env:project_overriden_secret='project.overriden_secret'
$Env:project_stage_overriden_secret='project.stage_overriden_secret'
$Env:app_overriden_secret='app.overriden_secret'
$Env:app_stage_overriden_secret='app.stage_overriden_secret'
$Env:app_stage2_overriden_secret='app.stage2_overriden_secret'

$ErrorActionPreference = "Stop"

##################################
function Invoke-Call([scriptblock]$ScriptBlock, [string]$ErrorAction = $ErrorActionPreference) {
    & @ScriptBlock
    if (($lastexitcode -ne 0) -and $ErrorAction -eq "Stop") {
        exit $lastexitcode
    }
}

##################################

if (!(Test-Path tests\output/secret)) {
    New-Item -ItemType Directory -Force -Path tests\output/secret > $null
}
else {
    Get-ChildItem tests\output/secret -Recurse | Remove-Item > $null
}

##################################
### delete existing secret, in order to also test overriding configurartions, they will be set later

Write-Output "`ndso secret list -v5 -w `"${working_dir}`" --config `"namespace=${namespace}, application=${application}, secret.provider.id=${provider}`" --global-scope --uninherited -f json | dso secret delete -v5 -w `"${working_dir}`" --config `"namespace=${namespace}, application=${application}, secret.provider.id=${provider}`" --global-scope -i - -f json`n"
Invoke-Call -ScriptBlock {dso secret list -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, secret.provider.id=${provider}" --global-scope --uninherited -f json | dso secret delete -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, secret.provider.id=${provider}" --global-scope -i - -f json} -ErrorAction Stop > $null

Write-Output "`ndso secret list -v5 -w `"${working_dir}`" --config `"namespace=${namespace}, application=${application}, secret.provider.id=${provider}`" -s ${stage} --global-scope --uninherited -f yaml | dso secret delete -v5 -w `"${working_dir}`" --config `"namespace=${namespace}, application=${application}, secret.provider.id=${provider}`" -s ${stage} --global-scope -i - -f yaml`n"
Invoke-Call -ScriptBlock {dso secret list -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, secret.provider.id=${provider}" -s ${stage} --global-scope --uninherited -f yaml | dso secret delete -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, secret.provider.id=${provider}" -s ${stage} --global-scope -i - -f yaml} -ErrorAction Stop > $null

Write-Output "`ndso secret list -v5 -w `"${working_dir}`" --config `"namespace=${namespace}, application=${application}, secret.provider.id=${provider}`" --namespace-scope --uninherited | dso secret delete -v5 -w `"${working_dir}`" --config `"namespace=${namespace}, application=${application}, secret.provider.id=${provider}`" --namespace-scope -i -`n"
Invoke-Call -ScriptBlock {dso secret list -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, secret.provider.id=${provider}" --namespace-scope --uninherited | dso secret delete -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, secret.provider.id=${provider}" --namespace-scope -i -} -ErrorAction Stop > $null

Write-Output "`ndso secret list -v5 -w `"${working_dir}`" --config `"namespace=${namespace}, application=${application}, secret.provider.id=${provider}`" -s ${stage} --namespace-scope --uninherited -f shell | dso secret delete -v5 -w `"${working_dir}`" --config `"namespace=${namespace}, application=${application}, secret.provider.id=${provider}`" -s ${stage} --namespace-scope -i - -f shell`n"
Invoke-Call -ScriptBlock {dso secret list -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, secret.provider.id=${provider}" -s ${stage} --namespace-scope --uninherited -f shell | dso secret delete -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, secret.provider.id=${provider}" -s ${stage} --namespace-scope -i - -f shell} -ErrorAction Stop > $null

Write-Output "`ndso secret list -v5 -w `"${working_dir}`" --config `"namespace=${namespace}, application=${application}, secret.provider.id=${provider}`" --uninherited | dso secret delete -v5 -w `"${working_dir}`" --config `"namespace=${namespace}, application=${application}, secret.provider.id=${provider}`" -i -`n"
Invoke-Call -ScriptBlock {dso secret list -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, secret.provider.id=${provider}" --uninherited | dso secret delete -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, secret.provider.id=${provider}" -i -} -ErrorAction Stop > $null

Write-Output "`ndso secret list -v5 -w `"${working_dir}`" --config `"namespace=${namespace}, application=${application}, secret.provider.id=${provider}`" -s ${stage} --uninherited | dso secret delete -v5 -w `"${working_dir}`" --config `"namespace=${namespace}, application=${application}, secret.provider.id=${provider}`" -s ${stage} -i -`n"
Invoke-Call -ScriptBlock {dso secret list -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, secret.provider.id=${provider}" -s ${stage} --uninherited | dso secret delete -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, secret.provider.id=${provider}" -s ${stage} -i -} -ErrorAction Stop > $null

Write-Output "`ndso secret list -v5 -w `"${working_dir}`" --config `"namespace=${namespace}, application=${application}, secret.provider.id=${provider}`" -s `"${stage}/2`" --uninherited | dso secret delete -v5 -w `"${working_dir}`" --config `"namespace=${namespace}, application=${application}, secret.provider.id=${provider}`" -s `"${stage}/2`" -i -`n"
Invoke-Call -ScriptBlock {dso secret list -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, secret.provider.id=${provider}" -s "${stage}/2" --uninherited | dso secret delete -v5 -w "${working_dir}" --config "namespace=${namespace}, application=${application}, secret.provider.id=${provider}" -s "${stage}/2" -i -} -ErrorAction Stop > $null

##################################
### add context-specific secrets

Write-Output "`nWrite-Output `"global.secret=global_secret`" | dso secret add -v5 -w `"${working_dir}`" --global-scope -f shell -i -`n"
Invoke-Call -ScriptBlock {Write-Output "global.secret=global_secret" | dso secret add -v5 -w "${working_dir}" --global-scope -f shell -i -} -ErrorAction Stop > $null

Write-Output "`nWrite-Output `"global.stage_secret=global_stage_secret`" | dso secret add -v5 -w `"${working_dir}`" -s ${stage} --global-scope -f shell -i -`n"
Invoke-Call -ScriptBlock {Write-Output "global.stage_secret=global_stage_secret" | dso secret add -v5 -w "${working_dir}" -s ${stage} --global-scope -f shell -i -} -ErrorAction Stop > $null

Write-Output "`nWrite-Output `"project.secret=project_secret`" | dso secret add -v5 -w `"${working_dir}`" --namespace-scope -f shell -i -`n"
Invoke-Call -ScriptBlock {Write-Output "project.secret=project_secret" | dso secret add -v5 -w "${working_dir}" --namespace-scope -f shell -i -} -ErrorAction Stop > $null

Write-Output "`nWrite-Output `"project.stage_secret=project_stage_secret`" | dso secret add -v5 -w `"${working_dir}`" -s ${stage} --namespace-scope -f shell -i -`n"
Invoke-Call -ScriptBlock {Write-Output "project.stage_secret=project_stage_secret" | dso secret add -v5 -w "${working_dir}" -s ${stage} --namespace-scope -f shell -i -} -ErrorAction Stop > $null

Write-Output "`nWrite-Output `"app.secret=app_secret`" | dso secret add -v5 -w `"${working_dir}`" -f shell -i -`n"
Invoke-Call -ScriptBlock {Write-Output "app.secret=app_secret" | dso secret add -v5 -w "${working_dir}" -f shell -i -} -ErrorAction Stop > $null

Write-Output "`nWrite-Output `"app.stage_secret=app_stage_secret`" | dso secret add -v5 -w `"${working_dir}`" -s ${stage} -f shell -i -`n"
Invoke-Call -ScriptBlock {Write-Output "app.stage_secret=app_stage_secret" | dso secret add -v5 -w "${working_dir}" -s ${stage} -f shell -i -} -ErrorAction Stop > $null

Write-Output "`ndso secret add app.stage2_secret app_stage2_secret -v5 -w `"${working_dir}`" -s `"${stage}/2`"`n"
Invoke-Call -ScriptBlock {dso secret add app.stage2_secret app_stage2_secret -v5 -w "${working_dir}" -s "${stage}/2"} -ErrorAction Stop > $null

##################################
### Setting configurations

Write-Output "`ndso config set -v5 -w `"${working_dir}`" namespace ${namespace}`n"
Invoke-Call -ScriptBlock {dso config set -v5 -w "${working_dir}" namespace ${namespace}} -ErrorAction Stop > $null

Write-Output "`ndso config set -v5 -w `"${working_dir}`" application ${application}`n"
Invoke-Call -ScriptBlock {dso config set -v5 -w "${working_dir}" application ${application}} -ErrorAction Stop > $null

Write-Output "`ndso config set -v5 -w `"${working_dir}`" secret.provider.id ${provider}`n"
Invoke-Call -ScriptBlock {dso config set -v5 -w "${working_dir}" secret.provider.id "${provider}"} -ErrorAction Stop > $null


##################################
### add overriden secrets

Write-Output "`nWrite-Output `"overriden_secret=global_overriden_secret`" | dso secret add -v5 -w `"${working_dir}`" --global-scope -f shell -i -`n"
Invoke-Call -ScriptBlock {Write-Output "overriden_secret=global_overriden_secret" | dso secret add -v5 -w "${working_dir}" --global-scope -f shell -i -} -ErrorAction Stop > $null

Write-Output "`nWrite-Output `"overriden_secret=global_stage_overriden_secret`" | dso secret add -v5 -w `"${working_dir}`" -s ${stage} --global-scope -f shell -i -`n"
Invoke-Call -ScriptBlock {Write-Output "overriden_secret=global_stage_overriden_secret" | dso secret add -v5 -w "${working_dir}" -s ${stage} --global-scope -f shell -i -} -ErrorAction Stop > $null

Write-Output "`nWrite-Output `"overriden_secret=project_overriden_secret`" | dso secret add -v5 -w `"${working_dir}`" --namespace-scope -f shell -i -`n"
Invoke-Call -ScriptBlock {Write-Output "overriden_secret=project_overriden_secret" | dso secret add -v5 -w "${working_dir}" --namespace-scope -f shell -i -} -ErrorAction Stop > $null

Write-Output "`nWrite-Output `"overriden_secret=project_stage_overriden_secret`" | dso secret add -v5 -w `"${working_dir}`" -s ${stage} --namespace-scope -f shell -i -`n"
Invoke-Call -ScriptBlock {Write-Output "overriden_secret=project_stage_overriden_secret" | dso secret add -v5 -w "${working_dir}" -s ${stage} --namespace-scope -f shell -i -} -ErrorAction Stop > $null

Write-Output "`nWrite-Output `"overriden_secret=app_overriden_secret`" | dso secret add -v5 -w `"${working_dir}`" -f shell -i -`n"
Invoke-Call -ScriptBlock {Write-Output "overriden_secret=app_overriden_secret" | dso secret add -v5 -w "${working_dir}" -f shell -i -} -ErrorAction Stop > $null

Write-Output "`nWrite-Output `"overriden_secret=app_stage_overriden_secret`" | dso secret add -v5 -w `"${working_dir}`" -s ${stage} -f shell -i -`n"
Invoke-Call -ScriptBlock {Write-Output "overriden_secret=app_stage_overriden_secret" | dso secret add -v5 -w "${working_dir}" -s ${stage} -f shell -i -} -ErrorAction Stop > $null

Write-Output "`ndso secret add overriden_secret app_stage2_overriden_secret -v5 -w `"${working_dir}`" -s `"${stage}/2`"`n"
Invoke-Call -ScriptBlock {dso secret add overriden_secret app_stage2_overriden_secret -v5 -w "${working_dir}" -s "${stage}/2"} -ErrorAction Stop > $null

##################################
### get some secrets

Write-Output "`ndso secret get -v5 -w `"${working_dir}`" overriden_secret --scope Global -f raw`n"
Invoke-Call -ScriptBlock {dso secret get -v5 -w "${working_dir}" overriden_secret --scope Global -f raw} -ErrorAction Stop > $null

Write-Output "`ndso secret get -v5 -w `"${working_dir}`" overriden_secret --scope Namespace -f raw`n"
Invoke-Call -ScriptBlock {dso secret get -v5 -w "${working_dir}" overriden_secret --scope Namespace -f raw} -ErrorAction Stop > $null

Write-Output "`ndso secret get -v5 -w `"${working_dir}`" overriden_secret -s ${stage} -f raw`n"
Invoke-Call -ScriptBlock {dso secret get -v5 -w "${working_dir}" overriden_secret -s ${stage} -f raw} -ErrorAction Stop > $null

Write-Output "`ndso secret get -v5 -w `"${working_dir}`" overriden_secret -s `"${stage}/2`" -f raw`n"
Invoke-Call -ScriptBlock {dso secret get -v5 -w "${working_dir}" overriden_secret -s "${stage}/2" -f raw} -ErrorAction Stop > $null

Write-Output "`ndso secret get -v5 -w `"${working_dir}`" app.secret -f raw`n"
Invoke-Call -ScriptBlock {dso secret get -v5 -w "${working_dir}" app.secret -f raw} -ErrorAction Stop > $null

Write-Output "`ndso secret get -v5 -w `"${working_dir}`" app.stage_secret -s ${stage} -f raw`n"
Invoke-Call -ScriptBlock {dso secret get -v5 -w "${working_dir}" app.stage_secret -s ${stage} -f raw} -ErrorAction Stop > $null

Write-Output "`ndso secret get -v5 -w `"${working_dir}`" app.stage2_secret -s `"${stage}/2`" -f raw`n"
Invoke-Call -ScriptBlock {dso secret get -v5 -w "${working_dir}" app.stage2_secret -s "${stage}/2" -f raw} -ErrorAction Stop > $null

##################################
### edit some secrets

Write-Output "`ndso secret edit -v5 -w `"${working_dir}`" overriden_secret --global-scope`n"
Invoke-Call -ScriptBlock {dso secret edit -v5 -w "${working_dir}" overriden_secret --global-scope} -ErrorAction Stop

Write-Output "`ndso secret edit -v5 -w `"${working_dir}`" overriden_secret -s ${stage} --namespace-scope`n"
Invoke-Call -ScriptBlock {dso secret edit -v5 -w "${working_dir}" overriden_secret -s ${stage} --namespace-scope} -ErrorAction Stop

Write-Output "`ndso secret edit -v5 -w `"${working_dir}`" app.secret`n"
Invoke-Call -ScriptBlock {dso secret edit -v5 -w "${working_dir}" app.secret} -ErrorAction Stop

Write-Output "`ndso secret edit -v5 -w `"${working_dir}`" app.stage_secret -s ${stage}`n"
Invoke-Call -ScriptBlock {dso secret edit -v5 -w "${working_dir}" app.stage_secret -s ${stage}} -ErrorAction Stop

Write-Output "`ndso secret edit -v5 -w `"${working_dir}`" app.stage2_secret -s `"${stage}/2`"`n"
Invoke-Call -ScriptBlock {dso secret edit -v5 -w "${working_dir}" app.stage2_secret -s "${stage}/2"} -ErrorAction Stop


##################################
### getting history of some secrets

Write-Output "`ndso secret history -v5 -w `"${working_dir}`" overriden_secret -f json`n"
Invoke-Call -ScriptBlock {dso secret history -v5 -w "${working_dir}" overriden_secret -f json} -ErrorAction Stop > $null

Write-Output "`ndso secret history -v5 -w `"${working_dir}`" overriden_secret -s ${stage} -f json`n"
Invoke-Call -ScriptBlock {dso secret history -v5 -w "${working_dir}" overriden_secret -s ${stage} -f json} -ErrorAction Stop > $null

Write-Output "`ndso secret history -v5 -w `"${working_dir}`" app.secret --query-all -f json`n"
Invoke-Call -ScriptBlock {dso secret history -v5 -w "${working_dir}" app.secret --query-all -f json} -ErrorAction Stop > $null

Write-Output "`ndso secret history -v5 -w `"${working_dir}`" app.stage_secret -s ${stage} --query-all -f json`n"
Invoke-Call -ScriptBlock {dso secret history -v5 -w "${working_dir}" app.stage_secret -s ${stage} --query-all -f json} -ErrorAction Stop > $null

Write-Output "`ndso secret history -v5 -w `"${working_dir}`" app.stage2_secret -s `"${stage}/2`" --query-all -f json`n"
Invoke-Call -ScriptBlock {dso secret history -v5 -w "${working_dir}" app.stage2_secret -s "${stage}/2" --query-all -f json} -ErrorAction Stop > $null


##################################
### listing some secrets

$filename = ("${provider}" -split '/')[0]

Write-Output "`ndso secret list -v5 -w `"${working_dir}`" -s ${stage} --uninherited --query-all --filter overriden_secret`n"
Invoke-Call -ScriptBlock {dso secret list -v5 -w "${working_dir}" -s ${stage} --uninherited --query-all --filter ovverriden_secret} -ErrorAction Stop > $null

Write-Output "`ndso secret list -v5 -w `"${working_dir}`" -s ${stage} --uninherited --query-all -f json`n"
Invoke-Call -ScriptBlock {dso secret list -v5 -w "${working_dir}" -s ${stage} --uninherited --query-all -f json} -ErrorAction Stop > "tests/output/secret/app.stage_uninherited-${filename}.json"

Write-Output "`ndso secret list -v5 -w `"${working_dir}`" -s ${stage} --config `"namespace=${namespace}, application=${application}, secret.provider.id=${provider}`" --query-all -f yaml`n"
Invoke-Call -ScriptBlock {dso secret list -v5 -w "${working_dir}" -s ${stage} --config "namespace=${namespace}, application=${application}, secret.provider.id=${provider}" --query-all -f yaml} -ErrorAction Stop > "tests/output/secret/app.stage_all-${filename}.yaml"

Write-Output "`ndso secret list -v5 -w `"${working_dir}`" -s `"${stage}/2`" --config `"namespace=${namespace}, application=${application}, secret.provider.id=${provider}`" --query-all -f yaml`n"
Invoke-Call -ScriptBlock {dso secret list -v5 -w "${working_dir}" -s "${stage}/2" --config "namespace=${namespace}, application=${application}, secret.provider.id=${provider}" --query-all -f yaml} -ErrorAction Stop > "tests/output/secret/app.stage2_all-${filename}.yaml"
