param(
    [string]$namespace = "test-ns",
    [string]$project = "test-project",
    [string]$application = "test-application",
    [string]$working_dir = ".",
    [string]$provider = "aws/ssm/v1",
    [string]$stage = "test-stage"

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

if (!(Test-Path tests\output/secret)) {
    New-Item -ItemType Directory -Force -Path tests\output/secret > $null
}
else {
    Get-ChildItem tests\output/secret -Recurse | Remove-Item > $null
}

##################################
### delete existing secret, in order to also test overriding configurartions, they will be set later

Write-Output "`ndso secret list -b5 -w `"${working_dir}`" --namespace ${namespace} --project ${project} --application ${application} --config `"secret.provider.id=${provider}`" --global-scope --uninherited -f json | dso secret delete -b5 -w `"${working_dir}`" --namespace ${namespace} --project ${project} --application ${application} --config `"secret.provider.id=${provider}`" --global-scope -i - -f json`n"
Invoke-Call -ScriptBlock {dso secret list -b5 -w "${working_dir}" --namespace ${namespace} --project ${project} --application ${application} --config "secret.provider.id=${provider}" --global-scope --uninherited -f json | dso secret delete -b5 -w "${working_dir}" --namespace ${namespace} --project ${project} --application ${application} --config "secret.provider.id=${provider}" --global-scope -i - -f json} -ErrorAction Stop > $null

Write-Output "`ndso secret list -b5 -w `"${working_dir}`" --namespace ${namespace} --project ${project} --application ${application} --config `"secret.provider.id=${provider}`" -s ${stage} --global-scope --uninherited -f yaml | dso secret delete -b5 -w `"${working_dir}`" --namespace ${namespace} --project ${project} --application ${application} --config `"secret.provider.id=${provider}`" -s ${stage} --global-scope -i - -f yaml`n"
Invoke-Call -ScriptBlock {dso secret list -b5 -w "${working_dir}" --namespace ${namespace} --project ${project} --application ${application} --config "secret.provider.id=${provider}" -s ${stage} --global-scope --uninherited -f yaml | dso secret delete -b5 -w "${working_dir}" --namespace ${namespace} --project ${project} --application ${application} --config "secret.provider.id=${provider}" -s ${stage} --global-scope -i - -f yaml} -ErrorAction Stop > $null

Write-Output "`ndso secret list -b5 -w `"${working_dir}`" --namespace ${namespace} --project ${project} --application ${application} --config `"secret.provider.id=${provider}`" --project-scope --uninherited | dso secret delete -b5 -w `"${working_dir}`" --namespace ${namespace} --project ${project} --application ${application} --config `"secret.provider.id=${provider}`" --project-scope -i -`n"
Invoke-Call -ScriptBlock {dso secret list -b5 -w "${working_dir}" --namespace ${namespace} --project ${project} --application ${application} --config "secret.provider.id=${provider}" --project-scope --uninherited | dso secret delete -b5 -w "${working_dir}" --namespace ${namespace} --project ${project} --application ${application} --config "secret.provider.id=${provider}" --project-scope -i -} -ErrorAction Stop > $null

Write-Output "`ndso secret list -b5 -w `"${working_dir}`" --namespace ${namespace} --project ${project} --application ${application} --config `"secret.provider.id=${provider}`" -s ${stage} --project-scope --uninherited -f shell | dso secret delete -b5 -w `"${working_dir}`" --namespace ${namespace} --project ${project} --application ${application} --config `"secret.provider.id=${provider}`" -s ${stage} --project-scope -i - -f shell`n"
Invoke-Call -ScriptBlock {dso secret list -b5 -w "${working_dir}" --namespace ${namespace} --project ${project} --application ${application} --config "secret.provider.id=${provider}" -s ${stage} --project-scope --uninherited -f shell | dso secret delete -b5 -w "${working_dir}" --namespace ${namespace} --project ${project} --application ${application} --config "secret.provider.id=${provider}" -s ${stage} --project-scope -i - -f shell} -ErrorAction Stop > $null

Write-Output "`ndso secret list -b5 -w `"${working_dir}`" --namespace ${namespace} --project ${project} --application ${application} --config `"secret.provider.id=${provider}`" --uninherited | dso secret delete -b5 -w `"${working_dir}`" --namespace ${namespace} --project ${project} --application ${application} --config `"secret.provider.id=${provider}`" -i -`n"
Invoke-Call -ScriptBlock {dso secret list -b5 -w "${working_dir}" --namespace ${namespace} --project ${project} --application ${application} --config "secret.provider.id=${provider}" --uninherited | dso secret delete -b5 -w "${working_dir}" --namespace ${namespace} --project ${project} --application ${application} --config "secret.provider.id=${provider}" -i -} -ErrorAction Stop > $null

Write-Output "`ndso secret list -b5 -w `"${working_dir}`" --namespace ${namespace} --project ${project} --application ${application} --config `"secret.provider.id=${provider}`" -s ${stage} --uninherited | dso secret delete -b5 -w `"${working_dir}`" --namespace ${namespace} --project ${project} --application ${application} --config `"secret.provider.id=${provider}`" -s ${stage} -i -`n"
Invoke-Call -ScriptBlock {dso secret list -b5 -w "${working_dir}" --namespace ${namespace} --project ${project} --application ${application} --config "secret.provider.id=${provider}" -s ${stage} --uninherited | dso secret delete -b5 -w "${working_dir}" --namespace ${namespace} --project ${project} --application ${application} --config "secret.provider.id=${provider}" -s ${stage} -i -} -ErrorAction Stop > $null


##################################
### add context-specific secrets

Write-Output "`nWrite-Output `"global.secret=global-secret-value`" | dso secret add -b5 -w `"${working_dir}`" --global-scope -f shell -i -`n"
Invoke-Call -ScriptBlock {Write-Output "global.secret=global-secret-value" | dso secret add -b5 -w "${working_dir}" --global-scope -f shell -i -} -ErrorAction Stop > $null

Write-Output "`nWrite-Output `"global.stage_secret=global-stage-secret-value`" | dso secret add -b5 -w `"${working_dir}`" -s ${stage} --global-scope -f shell -i -`n"
Invoke-Call -ScriptBlock {Write-Output "global.stage_secret=global-stage-secret-value" | dso secret add -b5 -w "${working_dir}" -s ${stage} --global-scope -f shell -i -} -ErrorAction Stop > $null

Write-Output "`nWrite-Output `"project.secret=project-secret-value`" | dso secret add -b5 -w `"${working_dir}`" --project-scope -f shell -i -`n"
Invoke-Call -ScriptBlock {Write-Output "project.secret=project-secret-value" | dso secret add -b5 -w "${working_dir}" --project-scope -f shell -i -} -ErrorAction Stop > $null

Write-Output "`nWrite-Output `"project.stage_secret=project-stage-secret-value`" | dso secret add -b5 -w `"${working_dir}`" -s ${stage} --project-scope -f shell -i -`n"
Invoke-Call -ScriptBlock {Write-Output "project.stage_secret=project-stage-secret-value" | dso secret add -b5 -w "${working_dir}" -s ${stage} --project-scope -f shell -i -} -ErrorAction Stop > $null

Write-Output "`nWrite-Output `"app.secret=app-secret-value`" | dso secret add -b5 -w `"${working_dir}`" `-f shell -i -`n"
Invoke-Call -ScriptBlock {Write-Output "app.secret=app-secret-value" | dso secret add -b5 -w "${working_dir}" `-f shell -i -} -ErrorAction Stop > $null

Write-Output "`nWrite-Output `"app.stage_secret=app-stage-secret-value`" | dso secret add -b5 -w `"${working_dir}`" -s ${stage} `-f shell -i -`n"
Invoke-Call -ScriptBlock {Write-Output "app.stage_secret=app-stage-secret-value" | dso secret add -b5 -w "${working_dir}" -s ${stage} -f shell -i -} -ErrorAction Stop > $null


##################################
### Setting confgiurations

Write-Output "`ndso config set -b5 -w `"${working_dir}`" namespace ${namespace}`n"
Invoke-Call -ScriptBlock {dso config set -b5 -w "${working_dir}" namespace ${namespace}} -ErrorAction Stop > $null

Write-Output "`ndso config set -b5 -w `"${working_dir}`" project ${project}`n"
Invoke-Call -ScriptBlock {dso config set -b5 -w "${working_dir}" project ${project}} -ErrorAction Stop > $null

Write-Output "`ndso config set -b5 -w `"${working_dir}`" application ${application}`n"
Invoke-Call -ScriptBlock {dso config set -b5 -w "${working_dir}" application ${application}} -ErrorAction Stop > $null

Write-Output "`ndso config set -b5 -w `"${working_dir}`" secret.provider.id ${provider}`n"
Invoke-Call -ScriptBlock {dso config set -b5 -w "${working_dir}" secret.provider.id "${provider}"} -ErrorAction Stop > $null


##################################
### add overriden secrets

Write-Output "`nWrite-Output `"overriden_secret=global-overriden-secret-value`" | dso secret add -b5 -w `"${working_dir}`" --global-scope -f shell -i -`n"
Invoke-Call -ScriptBlock {Write-Output "overriden_secret=global-overriden-secret-value" | dso secret add -b5 -w "${working_dir}" --global-scope -f shell -i -} -ErrorAction Stop > $null

Write-Output "`nWrite-Output `"overriden_secret=global-stage-overriden-secret-value`" | dso secret add -b5 -w `"${working_dir}`" -s ${stage} --global-scope -f shell -i -`n"
Invoke-Call -ScriptBlock {Write-Output "overriden_secret=global-stage-overriden-secret-value" | dso secret add -b5 -w "${working_dir}" -s ${stage} --global-scope -f shell -i -} -ErrorAction Stop > $null

Write-Output "`nWrite-Output `"overriden_secret=project-overriden-secret-value`" | dso secret add -b5 -w `"${working_dir}`" --project-scope -f shell -i -`n"
Invoke-Call -ScriptBlock {Write-Output "overriden_secret=project-overriden-secret-value" | dso secret add -b5 -w "${working_dir}" --project-scope -f shell -i -} -ErrorAction Stop > $null

Write-Output "`nWrite-Output `"overriden_secret=project-stage-overriden-secret-value`" | dso secret add -b5 -w `"${working_dir}`" -s ${stage} --project-scope -f shell -i -`n"
Invoke-Call -ScriptBlock {Write-Output "overriden_secret=project-stage-overriden-secret-value" | dso secret add -b5 -w "${working_dir}" -s ${stage} --project-scope -f shell -i -} -ErrorAction Stop > $null

Write-Output "`nWrite-Output `"overriden_secret=app-overriden-secret-value`" | dso secret add -b5 -w `"${working_dir}`" `-f shell -i -`n"
Invoke-Call -ScriptBlock {Write-Output "overriden_secret=app-overriden-secret-value" | dso secret add -b5 -w "${working_dir}" `-f shell -i -} -ErrorAction Stop > $null

Write-Output "`nWrite-Output `"overriden_secret=app-stage-overriden-secret-value`" | dso secret add -b5 -w `"${working_dir}`" -s ${stage} `-f shell -i -`n"
Invoke-Call -ScriptBlock {Write-Output "overriden_secret=app-stage-overriden-secret-value" | dso secret add -b5 -w "${working_dir}" -s ${stage} -f shell -i -} -ErrorAction Stop > $null


##################################
### getting some secrets

Write-Output "`ndso secret get -b5 -w `"${working_dir}`" overriden_secret -f raw`n"
Invoke-Call -ScriptBlock {dso secret get -b5 -w "${working_dir}" overriden_secret -f raw} -ErrorAction Stop > $null

Write-Output "`ndso secret get -b5 -w `"${working_dir}`" overriden_secret -s ${stage} -f raw`n"
Invoke-Call -ScriptBlock {dso secret get -b5 -w "${working_dir}" overriden_secret -s ${stage} -f raw} -ErrorAction Stop > $null

Write-Output "`ndso secret get -b5 -w `"${working_dir}`" app.secret -f raw`n"
Invoke-Call -ScriptBlock {dso secret get -b5 -w "${working_dir}" app.secret -f raw} -ErrorAction Stop > $null

Write-Output "`ndso secret get -b5 -w `"${working_dir}`" app.stage_secret -s ${stage} -f raw`n"
Invoke-Call -ScriptBlock {dso secret get -b5 -w "${working_dir}" app.stage_secret -s ${stage} -f raw} -ErrorAction Stop > $null


##################################
### edit some secrets

Write-Output "`ndso secret edit -b5 -w `"${working_dir}`" overriden_secret --global-scope`n"
Invoke-Call -ScriptBlock {dso secret edit -b5 -w "${working_dir}" overriden_secret --global-scope} -ErrorAction Stop

Write-Output "`ndso secret edit -b5 -w `"${working_dir}`" overriden_secret -s ${stage} --project-scope`n"
Invoke-Call -ScriptBlock {dso secret edit -b5 -w "${working_dir}" overriden_secret -s ${stage} --project-scope} -ErrorAction Stop

Write-Output "`ndso secret edit -b5 -w `"${working_dir}`" app.secret`n"
Invoke-Call -ScriptBlock {dso secret edit -b5 -w "${working_dir}" app.secret} -ErrorAction Stop

Write-Output "`ndso secret edit -b5 -w `"${working_dir}`" app.stage_secret -s ${stage}`n"
Invoke-Call -ScriptBlock {dso secret edit -b5 -w "${working_dir}" app.stage_secret -s ${stage}} -ErrorAction Stop


##################################
### getting history of some secrets

Write-Output "`ndso secret history -b5 -w `"${working_dir}`" overriden_secret -f json`n"
Invoke-Call -ScriptBlock {dso secret history -b5 -w "${working_dir}" overriden_secret -f json} -ErrorAction Stop > $null

Write-Output "`ndso secret history -b5 -w `"${working_dir}`" overriden_secret -s ${stage} -f json`n"
Invoke-Call -ScriptBlock {dso secret history -b5 -w "${working_dir}" overriden_secret -s ${stage} -f json} -ErrorAction Stop > $null

Write-Output "`ndso secret history -b5 -w `"${working_dir}`" app.secret -s ${stage} --query-all -f json`n"
Invoke-Call -ScriptBlock {dso secret history -b5 -w "${working_dir}" app.secret -s ${stage} --query-all -f json} -ErrorAction Stop > $null

Write-Output "`ndso secret history -b5 -w `"${working_dir}`" app.stage_secret -s ${stage} --query-all -f json`n"
Invoke-Call -ScriptBlock {dso secret history -b5 -w "${working_dir}" app.stage_secret -s ${stage} --query-all -f json} -ErrorAction Stop > $null


##################################
### listing some secrets

$filename = ("${provider}" -split '/')[0]

Write-Output "`ndso secret list -b5 -w `"${working_dir}`" -s ${stage} --uninherited --query-all --filter overriden_secret`n"
Invoke-Call -ScriptBlock {dso secret list -b5 -w "${working_dir}" -s ${stage} --uninherited --query-all --filter ovverriden_secret} -ErrorAction Stop > $null

Write-Output "`ndso secret list -b5 -w `"${working_dir}`" -s ${stage} --uninherited --query-all -f json`n"
Invoke-Call -ScriptBlock {dso secret list -b5 -w "${working_dir}" -s ${stage} --uninherited --query-all -f json} -ErrorAction Stop > "tests/output/secret/app-stage-uninherited-${filename}.json"

Write-Output "`ndso secret list -b5 -w `"${working_dir}`" -s ${stage} --namespace ${namespace} --project ${project} --application ${application} --config `"secret.provider.id=${provider}`" --query-all -f yaml`n"
Invoke-Call -ScriptBlock {dso secret list -b5 -w "${working_dir}" -s ${stage} --namespace ${namespace} --project ${project} --application ${application} --config "secret.provider.id=${provider}" --query-all -f yaml} -ErrorAction Stop > "tests/output/secret/app-stage-all-${filename}.yaml"
