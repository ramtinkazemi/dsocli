param(
    [string]$provider = "local/v1",
    [string]$namespace = "test-ns",
    [string]$project = "test-project",
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

if (!(Test-Path tests\output\template)) {
    New-Item -ItemType Directory -Force -Path tests\output\template > $null
}
else {
    Get-ChildItem tests\output\template -Recurse | Remove-Item > $null
}

##################################

$Env:DSO_ALLOW_STAGE_TEMPLATES = "yes"


##################################
### delete existing templates, in order to also test overriding configurartions, they will be set later

Write-Output "`ndso template list -b5 -w `"${working_dir}`" --config `"namespace=${namespace}, project=${project}, application=${application}, template.provider.id=${provider}`" --global-scope --uninherited -f json | dso template delete -b5 -w `"${working_dir}`" --namespace ${namespace} --project ${project} --application ${application} --config `"template.provider.id=${provider}`" --global-scope -i - -f json`n"
Invoke-Call -ScriptBlock {dso template list -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, template.provider.id=${provider}" --global-scope --uninherited -f json | dso template delete -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, template.provider.id=${provider}" --global-scope -i - -f json} -ErrorAction Stop > $null

Write-Output "`ndso template list -b5 -w `"${working_dir}`" --namespace ${namespace} --project ${project} --application ${application} --config `"template.provider.id=${provider}`" -s ${stage} --global-scope --uninherited -f yaml | dso template delete -b5 -w `"${working_dir}`" --namespace ${namespace} --project ${project} --application ${application} --config `"template.provider.id=${provider}`" -s ${stage} --global-scope -i - -f yaml`n"
Invoke-Call -ScriptBlock {dso template list -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, template.provider.id=${provider}" -s ${stage} --global-scope --uninherited -f yaml | dso template delete -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, template.provider.id=${provider}" -s ${stage} --global-scope -i - -f yaml} -ErrorAction Stop > $null

Write-Output "`ndso template list -b5 -w `"${working_dir}`" --namespace ${namespace} --project ${project} --application ${application} --config `"template.provider.id=${provider}`" --project-scope --uninherited | dso template delete -b5 -w `"${working_dir}`" --namespace ${namespace} --project ${project} --application ${application} --config `"template.provider.id=${provider}`" --project-scope -i -`n"
Invoke-Call -ScriptBlock {dso template list -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, template.provider.id=${provider}" --project-scope --uninherited | dso template delete -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, template.provider.id=${provider}" --project-scope -i -} -ErrorAction Stop > $null

Write-Output "`ndso template list -b5 -w `"${working_dir}`" --namespace ${namespace} --project ${project} --application ${application} --config `"template.provider.id=${provider}`" -s ${stage} --project-scope --uninherited | dso template delete -b5 -w `"${working_dir}`" --namespace ${namespace} --project ${project} --application ${application} --config `"template.provider.id=${provider}`" -s ${stage} --project-scope -i -`n"
Invoke-Call -ScriptBlock {dso template list -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, template.provider.id=${provider}" -s ${stage} --project-scope --uninherited | dso template delete -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, template.provider.id=${provider}" -s ${stage} --project-scope -i -} -ErrorAction Stop > $null

Write-Output "`ndso template list -b5 -w `"${working_dir}`" --namespace ${namespace} --project ${project} --application ${application} --config `"template.provider.id=${provider}`" --uninherited | dso template delete -b5 -w `"${working_dir}`" --namespace ${namespace} --project ${project} --application ${application} --config `"template.provider.id=${provider}`" -i -`n"
Invoke-Call -ScriptBlock {dso template list -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, template.provider.id=${provider}" --uninherited | dso template delete -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, template.provider.id=${provider}" -i -} -ErrorAction Stop > $null

Write-Output "`ndso template list -b5 -w `"${working_dir}`" --namespace ${namespace} --project ${project} --application ${application} --config `"template.provider.id=${provider}`" -s ${stage} --uninherited | dso template delete -b5 -w `"${working_dir}`" --namespace ${namespace} --project ${project} --application ${application} --config `"template.provider.id=${provider}`" -s ${stage} -i -`n"
Invoke-Call -ScriptBlock {dso template list -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, template.provider.id=${provider}" -s ${stage} --uninherited | dso template delete -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, template.provider.id=${provider}" -s ${stage} -i -} -ErrorAction Stop > $null

Write-Output "`ndso template list -b5 -w `"${working_dir}`" --namespace ${namespace} --project ${project} --application ${application} --config `"template.provider.id=${provider}`" -s ${stage}/2 --uninherited | dso template delete -b5 -w `"${working_dir}`" --namespace ${namespace} --project ${project} --application ${application} --config `"template.provider.id=${provider}`" -s ${stage}/2 -i -`n"
Invoke-Call -ScriptBlock {dso template list -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, template.provider.id=${provider}" -s ${stage}/2 --uninherited | dso template delete -b5 -w "${working_dir}" --config "namespace=${namespace}, project=${project}, application=${application}, template.provider.id=${provider}" -s ${stage}/2 -i -} -ErrorAction Stop > $null


##################################
### Setting confgiurations

Write-Output "`ndso config set -b5 -w `"${working_dir}`" namespace ${namespace}`n"
Invoke-Call -ScriptBlock {dso config set -b5 -w "${working_dir}" namespace ${namespace}} -ErrorAction Stop > $null

Write-Output "`ndso config set -b5 -w `"${working_dir}`" project ${project}"
Invoke-Call -ScriptBlock {dso config set -b5 -w "${working_dir}" project ${project}} -ErrorAction Stop > $null

Write-Output "`ndso config set -b5 -w `"${working_dir}`" application ${application}`n"
Invoke-Call -ScriptBlock {dso config set -b5 -w "${working_dir}" application ${application}} -ErrorAction Stop > $null

Write-Output "`ndso config set -b5 -w `"${working_dir}`" template.provider.id ${provider}`n"
Invoke-Call -ScriptBlock {dso config set -b5 -w "${working_dir}" template.provider.id "${provider}"} -ErrorAction Stop > $null


##################################
### add context-specific templates

Write-Output "`ndso template add -b5 -w `"${working_dir}`" global.template -r 'tests\output\template\*' -c tests\sample-templates\global-template --global-scope`n"
Invoke-Call -ScriptBlock {dso template add -b5 -w "${working_dir}" global.template -r 'tests\output\template\*' -c tests\sample-templates\global-template --global-scope} -ErrorAction Stop > $null

Write-Output "`ndso template add -b5 -w `"${working_dir}`" -s ${stage} global.stage_template -r 'tests\output\template\*' -c tests\sample-templates\global-stage-template --global-scope`n"
Invoke-Call -ScriptBlock {dso template add -b5 -w "${working_dir}" -s ${stage} global.stage_template -r 'tests\output\template\*' -c tests\sample-templates\global-stage-template --global-scope} -ErrorAction Stop > $null

Write-Output "`ndso template add -b5 -w `"${working_dir}`" project.template -r 'tests\output\template\*' -c tests\sample-templates\project-template --project-scope`n"
Invoke-Call -ScriptBlock {dso template add -b5 -w "${working_dir}" project.template -r 'tests\output\template\*' -c tests\sample-templates\project-template --project-scope} -ErrorAction Stop > $null

Write-Output "`ndso template add -b5 -w `"`n${working_dir}`" -s ${stage} project.stage_template -r 'tests\output\template\*' -c tests\sample-templates\project-stage-template --project-scope`n"
Invoke-Call -ScriptBlock {dso template add -b5 -w "${working_dir}" -s ${stage} project.stage_template -r 'tests\output\template\*' -c tests\sample-templates\project-stage-template --project-scope} -ErrorAction Stop > $null

Write-Output "`ndso template add -b5 -w `"${working_dir}`" app.template -r 'tests\output\template\*' -c tests\sample-templates\app-template`n"
Invoke-Call -ScriptBlock {dso template add -b5 -w "${working_dir}" app.template -r 'tests\output\template\*' -c tests\sample-templates\app-template} -ErrorAction Stop > $null

Write-Output "`ndso template add -b5 -w `"${working_dir}`" -s ${stage} app.stage_template -r 'tests\output\template\*' -c tests\sample-templates\app-stage-template`n"
Invoke-Call -ScriptBlock {dso template add -b5 -w "${working_dir}" -s ${stage} app.stage_template -r 'tests\output\template\*' -c tests\sample-templates\app-stage-template} -ErrorAction Stop > $null

Write-Output "`ndso template add -b5 -w `"${working_dir}`" -s ${stage}/2 app.stage2_template -r 'tests\output\template\*' -c tests\sample-templates\app-stage-template`n"
Invoke-Call -ScriptBlock {dso template add -b5 -w "${working_dir}" -s ${stage}/2 app.stage2_template -r 'tests\output\template\*' -c tests\sample-templates\app-stage-template} -ErrorAction Stop > $null

# ##################################
# ### add overriden templates

Write-Output "`ndso template add -b5 -w `"${working_dir}`" overriden_template -r 'tests\output\template\*' -c tests\sample-templates\global-template-overriden --global-scope`n"
Invoke-Call -ScriptBlock {dso template add -b5 -w "${working_dir}" overriden_template -r 'tests\output\template\*' -c tests\sample-templates\global-template-overriden --global-scope} -ErrorAction Stop > $null

Write-Output "`ndso template add -b5 -w `"${working_dir}`" -s ${stage} overriden_template -r 'tests\output\template\*' -c tests\sample-templates\global-stage-template-overriden --global-scope`n"
Invoke-Call -ScriptBlock {dso template add -b5 -w "${working_dir}" -s ${stage} overriden_template -r 'tests\output\template\*' -c tests\sample-templates\global-stage-template-overriden --global-scope} -ErrorAction Stop > $null

Write-Output "`ndso template add -b5 -w `"${working_dir}`" overriden_template -r 'tests\output\template\*' -c tests\sample-templates\project-template-overriden --project-scope`n"
Invoke-Call -ScriptBlock {dso template add -b5 -w "${working_dir}" overriden_template -r 'tests\output\template\*' -c tests\sample-templates\project-template-overriden --project-scope} -ErrorAction Stop > $null

Write-Output "`ndso template add -b5 -w `"`n${working_dir}`" -s ${stage} overriden_template -r 'tests\output\template\*' -c tests\sample-templates\project-stage-template-overriden --project-scope`n"
Invoke-Call -ScriptBlock {dso template add -b5 -w "${working_dir}" -s ${stage} overriden_template -r 'tests\output\template\*' -c tests\sample-templates\project-stage-template-overriden --project-scope} -ErrorAction Stop > $null

Write-Output "`ndso template add -b5 -w `"${working_dir}`" overriden_template -r 'tests\output\template\*' -c tests\sample-templates\app-template-overriden`n"
Invoke-Call -ScriptBlock {dso template add -b5 -w "${working_dir}" overriden_template -r 'tests\output\template\*' -c tests\sample-templates\app-template-overriden} -ErrorAction Stop > $null

Write-Output "`ndso template add -b5 -w `"${working_dir}`" -s ${stage} overriden_template -r 'tests\output\template\*' -c tests\sample-templates\app-stage-template-overriden`n"
Invoke-Call -ScriptBlock {dso template add -b5 -w "${working_dir}" -s ${stage} overriden_template -r 'tests\output\template\*' -c tests\sample-templates\app-stage-template-overriden} -ErrorAction Stop > $null

Write-Output "`ndso template add -b5 -w `"${working_dir}`" -s ${stage}/2 overriden_template -r 'tests\output\template\*' -c tests\sample-templates\app-stage2-template-overriden`n"
Invoke-Call -ScriptBlock {dso template add -b5 -w "${working_dir}" -s ${stage}/2 overriden_template -r 'tests\output\template\*' -c tests\sample-templates\app-stage2-template-overriden} -ErrorAction Stop > $null


##################################
### get some templates

Write-Output "`ndso template get -b5 -w `"${working_dir}`" overriden_template --scope Global -f raw`n"
Invoke-Call -ScriptBlock {dso template get -b5 -w "${working_dir}" overriden_template --scope Global -f raw} -ErrorAction Stop > $null

Write-Output "`ndso template get -b5 -w `"${working_dir}`" overriden_template --scope Project -f raw`n"
Invoke-Call -ScriptBlock {dso template get -b5 -w "${working_dir}" overriden_template --scope Project -f raw} -ErrorAction Stop > $null

Write-Output "`ndso template get -b5 -w `"${working_dir}`" overriden_template -s ${stage} -f raw`n"
Invoke-Call -ScriptBlock {dso template get -b5 -w "${working_dir}" overriden_template -s ${stage} -f raw} -ErrorAction Stop > $null

Write-Output "`ndso template get -b5 -w `"${working_dir}`" app.template -f raw`n"
Invoke-Call -ScriptBlock {dso template get -b5 -w "${working_dir}" app.template -f raw} -ErrorAction Stop > $null

Write-Output "`ndso template get -b5 -w `"${working_dir}`" app.stage_template -s ${stage} -f raw`n"
Invoke-Call -ScriptBlock {dso template get -b5 -w "${working_dir}" app.stage_template -s ${stage} -f raw} -ErrorAction Stop > $null

Write-Output "`ndso template get -b5 -w `"${working_dir}`" app.stage2_template -s ${stage}/2 -f raw`n"
Invoke-Call -ScriptBlock {dso template get -b5 -w "${working_dir}" app.stage2_template -s ${stage}/2 -f raw} -ErrorAction Stop > $null

##################################
### edit some tempaltes

Write-Output "`ndso template edit -b5 -w `"${working_dir}`" overriden_template --global-scope`n"
Invoke-Call -ScriptBlock {dso template edit -b5 -w "${working_dir}" overriden_template --global-scope} -ErrorAction Stop

Write-Output "`ndso template edit -b5 -w `"${working_dir}`" overriden_template -s ${stage} --project-scope`n"
Invoke-Call -ScriptBlock {dso template edit -b5 -w "${working_dir}" overriden_template -s ${stage} --project-scope} -ErrorAction Stop

Write-Output "`ndso template edit -b5 -w `"${working_dir}`" app.template`n"
Invoke-Call -ScriptBlock {dso template edit -b5 -w "${working_dir}" app.template} -ErrorAction Stop

Write-Output "`ndso template edit -b5 -w `"${working_dir}`" app.stage_template -s ${stage}`n"
Invoke-Call -ScriptBlock {dso template edit -b5 -w "${working_dir}" app.stage_template -s ${stage}} -ErrorAction Stop

Write-Output "`ndso template edit -b5 -w `"${working_dir}`" app.stage2_template -s ${stage}/2`n"
Invoke-Call -ScriptBlock {dso template edit -b5 -w "${working_dir}" app.stage2_template -s ${stage}/2} -ErrorAction Stop

##################################
### getting history of some templates

Write-Output "`ndso template history -b5 -w `"${working_dir}`" overriden_template -g -f json`n"
Invoke-Call -ScriptBlock {dso template history -b5 -w "${working_dir}" overriden_template -g -f json} -ErrorAction Stop > $null

Write-Output "`ndso template history -b5 -w `"${working_dir}`" overriden_template -p -f json`n"
Invoke-Call -ScriptBlock {dso template history -b5 -w "${working_dir}" overriden_template -p -f json} -ErrorAction Stop > $null

Write-Output "`ndso template history -b5 -w `"${working_dir}`" overriden_template -s ${stage} -f yaml`n"
Invoke-Call -ScriptBlock {dso template history -b5 -w "${working_dir}" overriden_template -s ${stage} -f json} -ErrorAction Stop > $null

Write-Output "`ndso template history -b5 -w `"${working_dir}`" app.template -s ${stage} --query-all -f json`n"
Invoke-Call -ScriptBlock {dso template history -b5 -w "${working_dir}" app.template -s ${stage} --query-all -f json} -ErrorAction Stop > $null

Write-Output "`ndso template history -b5 -w `"${working_dir}`" app.stage_template -s ${stage} --query-all -f yaml`n"
Invoke-Call -ScriptBlock {dso template history -b5 -w "${working_dir}" app.stage_template -s ${stage} --query-all -f json} -ErrorAction Stop > $null

Write-Output "`ndso template history -b5 -w `"${working_dir}`" app.stage2_template -s ${stage}/2 --query-all -f yaml`n"
Invoke-Call -ScriptBlock {dso template history -b5 -w "${working_dir}" app.stage2_template -s ${stage}/2 --query-all -f json} -ErrorAction Stop > $null

##################################
### listing some templates

$filename = ("${provider}" -split '/')[0]

Write-Output "`ndso template list -b5 -w `"${working_dir}`" -s ${stage} --uninherited --query-all --filter overriden_template`n"
Invoke-Call -ScriptBlock {dso template list -b5 -w "${working_dir}" -s ${stage} --uninherited --query-all --filter ovverriden_template} -ErrorAction Stop > $null

Write-Output "`ndso template list -b5 -w `"${working_dir}`" -s ${stage} --uninherited --query-all -f json`n"
Invoke-Call -ScriptBlock {dso template list -b5 -w "${working_dir}" -s ${stage} --uninherited --query-all -f json} -ErrorAction Stop > "tests/output/template/app-uninherited-${filename}.json"

Write-Output "`ndso template list -b5 -w `"${working_dir}`" -s ${stage} --query-all -f yaml`n"
Invoke-Call -ScriptBlock {dso template list -b5 -w "${working_dir}" -s ${stage} --query-all -f yaml} -ErrorAction Stop > "tests/output/template/app-stage-all-${filename}.yaml"

Write-Output "`ndso template list -b5 -w `"${working_dir}`" -s ${stage}/2 --query-all -f yaml`n"
Invoke-Call -ScriptBlock {dso template list -b5 -w "${working_dir}" -s ${stage}/2 --query-all -f yaml} -ErrorAction Stop > "tests/output/template/app-stage2-all-${filename}.yaml"

##################################
### rendering templates

Write-Output "`ndso template render -b5 -w `"${working_dir}`" -s ${stage} --filter overriden_template`n"
Invoke-Call -ScriptBlock {dso template render -b5 -w "${working_dir}" -s ${stage}} -ErrorAction Stop > $null

Write-Output "`ndso template render -b5 -w `"${working_dir}`" -s ${stage}`n"
Invoke-Call -ScriptBlock {dso template render -b5 -w "${working_dir}" -s ${stage}} -ErrorAction Stop > $null

Write-Output "`ndso template render -b5 -w `"${working_dir}`" -s ${stage}/2`n"
Invoke-Call -ScriptBlock {dso template render -b5 -w "${working_dir}" -s ${stage}/2} -ErrorAction Stop > $null
