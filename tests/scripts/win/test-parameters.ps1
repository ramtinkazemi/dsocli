param(
    [string]$namespace = "test-ns",
    [string]$project = "test-project",
    [string]$application = "test-application",
    [string]$working_dir = ".",
    [string]$provider = "local/v1",
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

if (!(Test-Path tests\output\parameter)) {
    New-Item -ItemType Directory -Force -Path tests\output\parameter > $null
}
else {
    Get-ChildItem tests\output\parameter -Recurse | Remove-Item > $null
}

##################################
### delete existing parameters, in order to also test overriding configurartions, they will be set later

Write-Output "`ndso parameter list -b5 -w `"${working_dir}`" --config `"namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}`" --global-scope --uninherited -f json | dso parameter delete -b5 -w `"${working_dir}`" --config `"namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}`" --global-scope -i - -f json`n"
Invoke-Call -ScriptBlock {dso parameter list -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}" --global-scope --uninherited -f json | dso parameter delete -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}" --global-scope -i - -f json} -ErrorAction Stop > $null

Write-Output "`ndso parameter list -b5 -w `"${working_dir}`" --config `"namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}`" -s ${stage} --global-scope --uninherited -f yaml | dso parameter delete -b5 -w `"${working_dir}`" --config `"namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}`" -s ${stage} --global-scope -i - -f yaml`n"
Invoke-Call -ScriptBlock {dso parameter list -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}" -s ${stage} --global-scope --uninherited -f yaml | dso parameter delete -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}" -s ${stage} --global-scope -i - -f yaml} -ErrorAction Stop > $null

Write-Output "`ndso parameter list -b5 -w `"${working_dir}`" --config `"namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}`" --project-scope --uninherited | dso parameter delete -b5 -w `"${working_dir}`" --config `"namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}`" --project-scope -i -`n"
Invoke-Call -ScriptBlock {dso parameter list -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}" --project-scope --uninherited | dso parameter delete -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}" --project-scope -i -} -ErrorAction Stop > $null

Write-Output "`ndso parameter list -b5 -w `"${working_dir}`" --config `"namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}`" -s ${stage} --project-scope --uninherited -f shell | dso parameter delete -b5 -w `"${working_dir}`" --config `"namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}`" -s ${stage} --project-scope -i - -f shell`n"
Invoke-Call -ScriptBlock {dso parameter list -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}" -s ${stage} --project-scope --uninherited -f shell | dso parameter delete -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}" -s ${stage} --project-scope -i - -f shell} -ErrorAction Stop > $null

Write-Output "`ndso parameter list -b5 -w `"${working_dir}`" --config `"namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}`" --uninherited | dso parameter delete -b5 -w `"${working_dir}`" --config `"namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}`" -i -`n"
Invoke-Call -ScriptBlock {dso parameter list -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}" --uninherited | dso parameter delete -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}" -i -} -ErrorAction Stop > $null

Write-Output "`ndso parameter list -b5 -w `"${working_dir}`" --namespace ${namespace} --project ${project} --application ${application} --config `"parameter.provider.id=${provider}` -s ${stage} --uninherited | dso parameter delete -b5 -w `"${working_dir}`" --config `"namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}`" -s ${stage} -i -`n"
Invoke-Call -ScriptBlock {dso parameter list -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}" -s ${stage} --uninherited | dso parameter delete -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, parameter.provider.id=${provider}" -s ${stage} -i -} -ErrorAction Stop > $null


##################################
### Setting confgiurations

Write-Output "`ndso config set -b5 -w `"${working_dir}`" namespace ${namespace}`n"
Invoke-Call -ScriptBlock {dso config set -b5 -w "${working_dir}" namespace ${namespace}} -ErrorAction Stop > $null

Write-Output "`ndso config set -b5 -w `"${working_dir}`" project ${project}`n"
Invoke-Call -ScriptBlock {dso config set -b5 -w "${working_dir}" project ${project}} -ErrorAction Stop > $null

Write-Output "`ndso config set -b5 -w `"${working_dir}`" application ${application}`n"
Invoke-Call -ScriptBlock {dso config set -b5 -w "${working_dir}" application ${application}} -ErrorAction Stop > $null

Write-Output "`ndso config set -b5 -w `"${working_dir}`" parameter.provider.id ${provider}`n"
Invoke-Call -ScriptBlock {dso config set -b5 -w "${working_dir}" parameter.provider.id ${provider}} -ErrorAction Stop > $null


##################################
### add context-specific parameters

Write-Output "`ndso parameter add -b5 -w `"${working_dir}`" global.parameter global-parameter-value --global-scope`n"
Invoke-Call -ScriptBlock {dso parameter add -b5 -w "${working_dir}" global.parameter global-parameter-value --global-scope} -ErrorAction Stop > $null

Write-Output "`ndso parameter add -b5 -w `"${working_dir}`" global.stage_parameter global-stage-parameter-value -s ${stage} --global-scope`n"
Invoke-Call -ScriptBlock {dso parameter add -b5 -w "${working_dir}" global.stage_parameter global-stage-parameter-value -s ${stage} --global-scope} -ErrorAction Stop > $null

Write-Output "`ndso parameter add -b5 -w `"${working_dir}`" project.parameter project-parameter-value --project-scope`n"
Invoke-Call -ScriptBlock {dso parameter add -b5 -w "${working_dir}" project.parameter project-parameter-value --project-scope} -ErrorAction Stop > $null

Write-Output "`ndso parameter add -b5 -w `"${working_dir}`" project.stage_parameter project-stage-parameter-value -s ${stage} --project-scope`n"
Invoke-Call -ScriptBlock {dso parameter add -b5 -w "${working_dir}" project.stage_parameter  project-stage-parameter-value -s ${stage} --project-scope} -ErrorAction Stop > $null


Write-Output "`ndso parameter add -b5 -w `"${working_dir}`" app.parameter app-parameter-value`n"
Invoke-Call -ScriptBlock {dso parameter add -b5 -w "${working_dir}" app.parameter app-parameter-value} -ErrorAction Stop > $null

Write-Output "`ndso parameter add -b5 -w `"${working_dir}`" app.stage_parameter app-stage-parameter-value -s ${stage}`n"
Invoke-Call -ScriptBlock {dso parameter add -b5 -w "${working_dir}" app.stage_parameter app-stage-parameter-value -s ${stage}} -ErrorAction Stop > $null


##################################
### add overriden parameters

Write-Output "`ndso parameter add -b5 -w `"${working_dir}`" overriden_parameter global-parameter-overridden-value --global-scope`n"
Invoke-Call -ScriptBlock {dso parameter add -b5 -w "${working_dir}" overriden_parameter global-parameter-overridden-value --global-scope} -ErrorAction Stop > $null

Write-Output "`ndso parameter add -b5 -w `"${working_dir}`" overriden_parameter global-stage-overridden-parameter-value -s ${stage} --global-scope`n"
Invoke-Call -ScriptBlock {dso parameter add -b5 -w "${working_dir}" overriden_parameter global-stage-overridden-parameter-value -s ${stage} --global-scope} -ErrorAction Stop > $null


Write-Output "`ndso parameter add -b5 -w `"${working_dir}`" overriden_parameter project-overridden-parameter-value --project-scope`n"
Invoke-Call -ScriptBlock {dso parameter add -b5 -w "${working_dir}" overriden_parameter project-overridden-parameter-value --project-scope} -ErrorAction Stop > $null

Write-Output "`ndso parameter add -b5 -w `"${working_dir}`" overriden_parameter project-stage-overridden-parameter-value -s ${stage} --project-scope`n"
Invoke-Call -ScriptBlock {dso parameter add -b5 -w "${working_dir}" overriden_parameter project-stage-overridden-parameter-value -s ${stage} --project-scope} -ErrorAction Stop > $null


Write-Output "`ndso parameter add -b5 -w `"${working_dir}`" overriden_parameter app-overridden-parameter-value`n"
Invoke-Call -ScriptBlock {dso parameter add -b5 -w "${working_dir}" overriden_parameter app-overridden-parameter-value} -ErrorAction Stop > $null

Write-Output "`ndso parameter add -b5 -w `"${working_dir}`" overriden_parameter app-stage-overridden-parameter-value -s ${stage}`n"
Invoke-Call -ScriptBlock {dso parameter add -b5 -w "${working_dir}" overriden_parameter app-stage-overridden-parameter-value -s ${stage}} -ErrorAction Stop > $null


##################################
### getting some parameters

Write-Output "`ndso parameter get -b5 -w `"${working_dir}`" overriden_parameter -f raw`n"
Invoke-Call -ScriptBlock {dso parameter get -b5 -w "${working_dir}" overriden_parameter -f raw} -ErrorAction Stop > $null

Write-Output "`ndso parameter get -b5 -w `"${working_dir}`" overriden_parameter -s ${stage} -f raw`n"
Invoke-Call -ScriptBlock {dso parameter get -b5 -w "${working_dir}" overriden_parameter -s ${stage} -f raw} -ErrorAction Stop > $null

Write-Output "`ndso parameter get -b5 -w `"${working_dir}`" app.parameter -s ${stage} -f raw`n"
Invoke-Call -ScriptBlock {dso parameter get -b5 -w "${working_dir}" app.parameter -s ${stage} -f raw} -ErrorAction Stop > $null

Write-Output "`ndso parameter get -b5 -w `"${working_dir}`" app.stage_parameter -s ${stage} -f raw`n"
Invoke-Call -ScriptBlock {dso parameter get -b5 -w "${working_dir}" app.stage_parameter -s ${stage} -f raw} -ErrorAction Stop > $null


##################################
### edit some parameters

Write-Output "`ndso parameter edit -b5 -w `"${working_dir}`" overriden_parameter --global-scope`n"
Invoke-Call -ScriptBlock {dso parameter edit -b5 -w "${working_dir}" overriden_parameter --global-scope} -ErrorAction Stop

Write-Output "`ndso parameter edit -b5 -w `"${working_dir}`" overriden_parameter -s ${stage} --project-scope`n"
Invoke-Call -ScriptBlock {dso parameter edit -b5 -w "${working_dir}" overriden_parameter -s ${stage} --project-scope} -ErrorAction Stop

Write-Output "`ndso parameter edit -b5 -w `"${working_dir}`" app.parameter`n"
Invoke-Call -ScriptBlock {dso parameter edit -b5 -w "${working_dir}" app.parameter} -ErrorAction Stop

Write-Output "`ndso parameter edit -b5 -w `"${working_dir}`" app.stage_parameter -s ${stage}`n"
Invoke-Call -ScriptBlock {dso parameter edit -b5 -w "${working_dir}" app.stage_parameter -s ${stage}} -ErrorAction Stop


##################################
### getting history of some parameters

Write-Output "`ndso parameter history -b5 -w `"${working_dir}`" overriden_parameter -f json`n"
Invoke-Call -ScriptBlock {dso parameter history -b5 -w "${working_dir}" overriden_parameter -f json} -ErrorAction Stop > $null

Write-Output "`ndso parameter history -b5 -w `"${working_dir}`" overriden_parameter -s ${stage} -f json`n"
Invoke-Call -ScriptBlock {dso parameter history -b5 -w "${working_dir}" overriden_parameter -s ${stage} -f json} -ErrorAction Stop > $null

Write-Output "`ndso parameter history -b5 -w `"${working_dir}`" app.parameter -s ${stage} --query-all -f json`n"
Invoke-Call -ScriptBlock {dso parameter history -b5 -w "${working_dir}" app.parameter -s ${stage} --query-all -f json} -ErrorAction Stop > $null

Write-Output "`ndso parameter history -b5 -w `"${working_dir}`" app.stage_parameter -s ${stage} --query-all -f json`n"
Invoke-Call -ScriptBlock {dso parameter history -b5 -w "${working_dir}" app.stage_parameter -s ${stage} --query-all -f json} -ErrorAction Stop > $null


##################################
### listing some parameters

$filename = (${provider} -split '/')[0]

Write-Output "`ndso parameter list -b5 -w `"${working_dir}`" -s ${stage} --uninherited --query-all --filter overriden_parameter`n"
Invoke-Call -ScriptBlock {dso parameter list -b5 -w "${working_dir}" -s ${stage} --uninherited --query-all --filter ovverriden_parameter} -ErrorAction Stop > $null

Write-Output "`ndso parameter list -b5 -w `"${working_dir}`" -s ${stage} --uninherited --query-all -f json`n"
Invoke-Call -ScriptBlock {dso parameter list -b5 -w "${working_dir}" -s ${stage} --uninherited --query-all -f json} -ErrorAction Stop > "tests/output/parameter/app-stage-uninherited-${filename}.json"

Write-Output "`ndso parameter list -b5 -w `"${working_dir}`" -s ${stage} --query-all -f yaml`n"
Invoke-Call -ScriptBlock {dso parameter list -b5 -w "${working_dir}" -s ${stage} --query-all -f yaml} -ErrorAction Stop > "tests/output/parameter/app-stage-all-${filename}.yaml"
