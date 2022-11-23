param(
    [string]$provider = "local/v1",
    [string]$namespace = "test-ns",
    [string]$application = "test-app",
    [string]$stage = "test-stage"
)


$Env:global_secret='global_secret'
$Env:global_stage_secret='global_stage_secret'
$Env:namespace_secret='namespace_secret'
$Env:namespace_stage_secret='namespace_stage_secret'
$Env:app_secret='app_secret'
$Env:app_stage_secret='app_stage_secret'
$Env:global_overriden_secret='global_overriden_secret'
$Env:global_stage_overriden_secret='global_stage_overriden_secret'
$Env:namespace_overriden_secret='namespace_overriden_secret'
$Env:namespace_stage_overriden_secret='namespace_stage_overriden_secret'
$Env:app_overriden_secret='app_overriden_secret'
$Env:app_stage_overriden_secret='app_stage_overriden_secret'
$Env:app_stage2_overriden_secret='app_stage2_overriden_secret'

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

if (!(Test-Path .dso\output\secret)) {
    New-Item -ItemType Directory -Force -Path .dso\output\secret > $null
}
else {
    Get-ChildItem .dso\output\secret -Recurse | Remove-Item > $null
}

##################################
### delete existing secret, in order to also test overriding configurartions, they will be set later

Write-Output "`ndso secret list -v6 --config `"namespace=${namespace}, application=${application}, secret.provider.id=${provider}`" --global-scope --uninherited -f json | dso secret delete -v6 --config `"namespace=${namespace}, application=${application}, secret.provider.id=${provider}`" --global-scope -i - -f json`n"
Invoke-Call -ScriptBlock {dso secret list -v6 --config "namespace=${namespace}, application=${application}, secret.provider.id=${provider}" --global-scope --uninherited -f json | dso secret delete -v6 --config "namespace=${namespace}, application=${application}, secret.provider.id=${provider}" --global-scope -i - -f json} -ErrorAction Stop

Write-Output "`ndso secret list -v6 --config `"namespace=${namespace}, application=${application}, secret.provider.id=${provider}`" -s ${stage} --global-scope --uninherited -f yaml | dso secret delete -v6 --config `"namespace=${namespace}, application=${application}, secret.provider.id=${provider}`" -s ${stage} --global-scope -i - -f yaml`n"
Invoke-Call -ScriptBlock {dso secret list -v6 --config "namespace=${namespace}, application=${application}, secret.provider.id=${provider}" -s ${stage} --global-scope --uninherited -f yaml | dso secret delete -v6 --config "namespace=${namespace}, application=${application}, secret.provider.id=${provider}" -s ${stage} --global-scope -i - -f yaml} -ErrorAction Stop

Write-Output "`ndso secret list -v6 --config `"namespace=${namespace}, application=${application}, secret.provider.id=${provider}`" --namespace-scope --uninherited -f json | dso secret delete -v6 --config `"namespace=${namespace}, application=${application}, secret.provider.id=${provider}`" --namespace-scope -i -`n"
Invoke-Call -ScriptBlock {dso secret list -v6 --config "namespace=${namespace}, application=${application}, secret.provider.id=${provider}" --namespace-scope --uninherited -f json | dso secret delete -v6 --config "namespace=${namespace}, application=${application}, secret.provider.id=${provider}" --namespace-scope -i -} -ErrorAction Stop

Write-Output "`ndso secret list -v6 --config `"namespace=${namespace}, application=${application}, secret.provider.id=${provider}`" -s ${stage} --namespace-scope --uninherited -f compact | dso secret delete -v6 --config `"namespace=${namespace}, application=${application}, secret.provider.id=${provider}`" -s ${stage} --namespace-scope -i - -f compact`n"
Invoke-Call -ScriptBlock {dso secret list -v6 --config "namespace=${namespace}, application=${application}, secret.provider.id=${provider}" -s ${stage} --namespace-scope --uninherited -f compact | dso secret delete -v6 --config "namespace=${namespace}, application=${application}, secret.provider.id=${provider}" -s ${stage} --namespace-scope -i - -f compact} -ErrorAction Stop

Write-Output "`ndso secret list -v6 --config `"namespace=${namespace}, application=${application}, secret.provider.id=${provider}`" --uninherited -f json | dso secret delete -v6 --config `"namespace=${namespace}, application=${application}, secret.provider.id=${provider}`" -i -`n"
Invoke-Call -ScriptBlock {dso secret list -v6 --config "namespace=${namespace}, application=${application}, secret.provider.id=${provider}" --uninherited -f json | dso secret delete -v6 --config "namespace=${namespace}, application=${application}, secret.provider.id=${provider}" -i -} -ErrorAction Stop

Write-Output "`ndso secret list -v6 --config `"namespace=${namespace}, application=${application}, secret.provider.id=${provider}`" -s ${stage} --uninherited -f json | dso secret delete -v6 --config `"namespace=${namespace}, application=${application}, secret.provider.id=${provider}`" -s ${stage} -i -`n"
Invoke-Call -ScriptBlock {dso secret list -v6 --config "namespace=${namespace}, application=${application}, secret.provider.id=${provider}" -s ${stage} --uninherited -f json | dso secret delete -v6 --config "namespace=${namespace}, application=${application}, secret.provider.id=${provider}" -s ${stage} -i -} -ErrorAction Stop

Write-Output "`ndso secret list -v6 --config `"namespace=${namespace}, application=${application}, secret.provider.id=${provider}`" -s `"${stage}/2`" --uninherited -f json | dso secret delete -v6 --config `"namespace=${namespace}, application=${application}, secret.provider.id=${provider}`" -s `"${stage}/2`" -i -`n"
Invoke-Call -ScriptBlock {dso secret list -v6 --config "namespace=${namespace}, application=${application}, secret.provider.id=${provider}" -s "${stage}/2" --uninherited -f json | dso secret delete -v6 --config "namespace=${namespace}, application=${application}, secret.provider.id=${provider}" -s "${stage}/2" -i -} -ErrorAction Stop

##################################
### add context-specific secrets

Write-Output "`nWrite-Output `"global_secret=global_secret`" | dso secret add -v6 --global-scope -f compact -i -`n"
Invoke-Call -ScriptBlock {Write-Output "global_secret=global_secret" | dso secret add -v6 --global-scope -f compact -i -} -ErrorAction Stop

Write-Output "`nWrite-Output `"global_stage_secret=global_stage_secret`" | dso secret add -v6 -s ${stage} --global-scope -f compact -i -`n"
Invoke-Call -ScriptBlock {Write-Output "global_stage_secret=global_stage_secret" | dso secret add -v6 -s ${stage} --global-scope -f compact -i -} -ErrorAction Stop

Write-Output "`nWrite-Output `"namespace_secret=namespace_secret`" | dso secret add -v6 --namespace-scope -f compact -i -`n"
Invoke-Call -ScriptBlock {Write-Output "namespace_secret=namespace_secret" | dso secret add -v6 --namespace-scope -f compact -i -} -ErrorAction Stop

Write-Output "`nWrite-Output `"namespace_stage_secret=namespace_stage_secret`" | dso secret add -v6 -s ${stage} --namespace-scope -f compact -i -`n"
Invoke-Call -ScriptBlock {Write-Output "namespace_stage_secret=namespace_stage_secret" | dso secret add -v6 -s ${stage} --namespace-scope -f compact -i -} -ErrorAction Stop

Write-Output "`nWrite-Output `"app_secret=app_secret`" | dso secret add -v6 -f compact -i -`n"
Invoke-Call -ScriptBlock {Write-Output "app_secret=app_secret" | dso secret add -v6 -f compact -i -} -ErrorAction Stop

Write-Output "`nWrite-Output `"app_stage_secret=app_stage_secret`" | dso secret add -v6 -s ${stage} -f compact -i -`n"
Invoke-Call -ScriptBlock {Write-Output "app_stage_secret=app_stage_secret" | dso secret add -v6 -s ${stage} -f compact -i -} -ErrorAction Stop

Write-Output "`ndso secret add app_stage2_secret app_stage2_secret -v6 -s `"${stage}/2`"`n"
Invoke-Call -ScriptBlock {dso secret add app_stage2_secret app_stage2_secret -v6 -s "${stage}/2"} -ErrorAction Stop

##################################
### Setting configurations

Write-Output "`ndso config add -v6 namespace ${namespace}`n"
Invoke-Call -ScriptBlock {dso config add -v6 namespace ${namespace}} -ErrorAction Stop

Write-Output "`ndso config add -v6 application ${application}`n"
Invoke-Call -ScriptBlock {dso config add -v6 application ${application}} -ErrorAction Stop

Write-Output "`ndso config add -v6 secret.provider.id ${provider}`n"
Invoke-Call -ScriptBlock {dso config add -v6 secret.provider.id "${provider}"} -ErrorAction Stop


##################################
### add overriden secrets

Write-Output "`nWrite-Output `"overriden_secret=global_overriden_secret`" | dso secret add -v6 --global-scope -f compact -i -`n"
Invoke-Call -ScriptBlock {Write-Output "overriden_secret=global_overriden_secret" | dso secret add -v6 --global-scope -f compact -i -} -ErrorAction Stop

Write-Output "`nWrite-Output `"overriden_secret=global_stage_overriden_secret`" | dso secret add -v6 -s ${stage} --global-scope -f compact -i -`n"
Invoke-Call -ScriptBlock {Write-Output "overriden_secret=global_stage_overriden_secret" | dso secret add -v6 -s ${stage} --global-scope -f compact -i -} -ErrorAction Stop

Write-Output "`nWrite-Output `"overriden_secret=namespace_overriden_secret`" | dso secret add -v6 --namespace-scope -f compact -i -`n"
Invoke-Call -ScriptBlock {Write-Output "overriden_secret=namespace_overriden_secret" | dso secret add -v6 --namespace-scope -f compact -i -} -ErrorAction Stop

Write-Output "`nWrite-Output `"overriden_secret=namespace_stage_overriden_secret`" | dso secret add -v6 -s ${stage} --namespace-scope -f compact -i -`n"
Invoke-Call -ScriptBlock {Write-Output "overriden_secret=namespace_stage_overriden_secret" | dso secret add -v6 -s ${stage} --namespace-scope -f compact -i -} -ErrorAction Stop

Write-Output "`nWrite-Output `"overriden_secret=app_overriden_secret`" | dso secret add -v6 -f compact -i -`n"
Invoke-Call -ScriptBlock {Write-Output "overriden_secret=app_overriden_secret" | dso secret add -v6 -f compact -i -} -ErrorAction Stop

Write-Output "`nWrite-Output `"overriden_secret=app_stage_overriden_secret`" | dso secret add -v6 -s ${stage} -f compact -i -`n"
Invoke-Call -ScriptBlock {Write-Output "overriden_secret=app_stage_overriden_secret" | dso secret add -v6 -s ${stage} -f compact -i -} -ErrorAction Stop

Write-Output "`ndso secret add overriden_secret=app_stage2_overriden_secret -v6 -s `"${stage}/2`"`n"
Invoke-Call -ScriptBlock {dso secret add overriden_secret app_stage2_overriden_secret -v6 -s "${stage}/2"} -ErrorAction Stop

##################################
### get some secrets

Write-Output "`ndso secret get -v6 overriden_secret --global-scope -f text`n"
Invoke-Call -ScriptBlock {dso secret get -v6 overriden_secret --global-scope -f text} -ErrorAction Stop

Write-Output "`ndso secret get -v6 overriden_secret --namespace-scope -f text`n"
Invoke-Call -ScriptBlock {dso secret get -v6 overriden_secret --namespace-scope -f text} -ErrorAction Stop

Write-Output "`ndso secret get -v6 overriden_secret -s ${stage} -f text`n"
Invoke-Call -ScriptBlock {dso secret get -v6 overriden_secret -s ${stage} -f text} -ErrorAction Stop

Write-Output "`ndso secret get -v6 overriden_secret -s `"${stage}/2`" -f text`n"
Invoke-Call -ScriptBlock {dso secret get -v6 overriden_secret -s "${stage}/2" -f text} -ErrorAction Stop

Write-Output "`ndso secret get -v6 app_secret -f text`n"
Invoke-Call -ScriptBlock {dso secret get -v6 app_secret -f text} -ErrorAction Stop

Write-Output "`ndso secret get -v6 app_stage_secret -s ${stage} -f text`n"
Invoke-Call -ScriptBlock {dso secret get -v6 app_stage_secret -s ${stage} -f text} -ErrorAction Stop

Write-Output "`ndso secret get -v6 app_stage2_secret -s `"${stage}/2`" -f text`n"
Invoke-Call -ScriptBlock {dso secret get -v6 app_stage2_secret -s "${stage}/2" -f text} -ErrorAction Stop

##################################
### edit some secrets

# Write-Output "`ndso secret edit -v6 overriden_secret --global-scope`n"
# Invoke-Call -ScriptBlock {dso secret edit -v6 overriden_secret --global-scope} -ErrorAction Stop

# Write-Output "`ndso secret edit -v6 overriden_secret -s ${stage} --namespace-scope`n"
# Invoke-Call -ScriptBlock {dso secret edit -v6 overriden_secret -s ${stage} --namespace-scope} -ErrorAction Stop

# Write-Output "`ndso secret edit -v6 app_secret`n"
# Invoke-Call -ScriptBlock {dso secret edit -v6 app_secret} -ErrorAction Stop

# Write-Output "`ndso secret edit -v6 app_stage_secret -s ${stage}`n"
# Invoke-Call -ScriptBlock {dso secret edit -v6 app_stage_secret -s ${stage}} -ErrorAction Stop

# Write-Output "`ndso secret edit -v6 app_stage2_secret -s `"${stage}/2`"`n"
# Invoke-Call -ScriptBlock {dso secret edit -v6 app_stage2_secret -s "${stage}/2"} -ErrorAction Stop


##################################
### getting history of some secrets

Write-Output "`ndso secret history -v6 overriden_secret -f json`n"
Invoke-Call -ScriptBlock {dso secret history -v6 overriden_secret -f json} -ErrorAction Stop

Write-Output "`ndso secret history -v6 overriden_secret -s ${stage} -f json`n"
Invoke-Call -ScriptBlock {dso secret history -v6 overriden_secret -s ${stage} -f json} -ErrorAction Stop

Write-Output "`ndso secret history -v6 app_secret --query-all -f json`n"
Invoke-Call -ScriptBlock {dso secret history -v6 app_secret --query-all -f json} -ErrorAction Stop

Write-Output "`ndso secret history -v6 app_stage_secret -s ${stage} --query-all -f json`n"
Invoke-Call -ScriptBlock {dso secret history -v6 app_stage_secret -s ${stage} --query-all -f json} -ErrorAction Stop

Write-Output "`ndso secret history -v6 app_stage2_secret -s `"${stage}/2`" --query-all -f json`n"
Invoke-Call -ScriptBlock {dso secret history -v6 app_stage2_secret -s "${stage}/2" --query-all -f json} -ErrorAction Stop


##################################
### listing some secrets

$filename = ("${provider}" -split '/')[0]

Write-Output "`ndso secret list -v6 -s ${stage} --uninherited --query-all overriden_secret`n"
Invoke-Call -ScriptBlock {dso secret list -v6 -s ${stage} --uninherited --query-all overriden_secret} -ErrorAction Stop

Write-Output "`ndso secret list -v6 -s ${stage} --uninherited --query-all -f json`n"
Invoke-Call -ScriptBlock {dso secret list -v6 -s ${stage} --uninherited --query-all -f json} -ErrorAction Stop > ".dso\output\secret\app_stage_uninherited-${filename}.json"

Write-Output "`ndso secret list -v6 -s ${stage} --config `"namespace=${namespace}, application=${application}, secret.provider.id=${provider}`" --query-all -f yaml`n"
Invoke-Call -ScriptBlock {dso secret list -v6 -s ${stage} --config "namespace=${namespace}, application=${application}, secret.provider.id=${provider}" --query-all -f yaml} -ErrorAction Stop > ".dso\output\secret\app_stage_all-${filename}.yaml"

Write-Output "`ndso secret list -v6 -s `"${stage}/2`" --config `"namespace=${namespace}, application=${application}, secret.provider.id=${provider}`" --query-all -f yaml`n"
Invoke-Call -ScriptBlock {dso secret list -v6 -s "${stage}/2" --config "namespace=${namespace}, application=${application}, secret.provider.id=${provider}" --query-all -f yaml} -ErrorAction Stop > ".dso\output\secret\app_stage2_all-${filename}.yaml"
