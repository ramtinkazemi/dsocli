param(
    [string]$provider = "local/v1",
    [string]$namespace = "test-ns",
    [string]$application = "test-app",
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

if (!(Test-Path .dso\output\template)) {
    New-Item -ItemType Directory -Force -Path .dso\output\template > $null
}
else {
    Get-ChildItem .dso\output\template -Recurse | Remove-Item > $null
}

##################################
### delete existing templates, in order to also test overriding configurartions, they will be set later

Write-Output "`ndso template list -v6 --config `"namespace=$namespace, application=$application, template.provider.id=$provider`" --global-scope --uninherited -f json | dso template delete -v6 --namespace $namespace --namespace $namespace --application $application --config `"template.provider.id=$provider`" --global-scope -i - -f json`n"
Invoke-Call -ScriptBlock {dso template list -v6 --config "namespace=$namespace, application=$application, template.provider.id=$provider" --global-scope --uninherited -f json | dso template delete -v6 --config "namespace=$namespace, application=$application, template.provider.id=$provider" --global-scope -i - -f json} -ErrorAction Stop

Write-Output "`ndso template list -v6 --namespace $namespace --namespace $namespace --application $application --config `"template.provider.id=$provider`" -s $stage --global-scope --uninherited -f yaml | dso template delete -v6 --namespace $namespace --namespace $namespace --application $application --config `"template.provider.id=$provider`" -s $stage --global-scope -i - -f yaml`n"
Invoke-Call -ScriptBlock {dso template list -v6 --config "namespace=$namespace, application=$application, template.provider.id=$provider" -s $stage --global-scope --uninherited -f yaml | dso template delete -v6 --config "namespace=$namespace, application=$application, template.provider.id=$provider" -s $stage --global-scope -i - -f yaml} -ErrorAction Stop

Write-Output "`ndso template list -v6 --namespace $namespace --namespace $namespace --application $application --config `"template.provider.id=$provider`" --namespace-scope --uninherited -f json | dso template delete -v6 --namespace $namespace --namespace $namespace --application $application --config `"template.provider.id=$provider`" --namespace-scope -i -`n"
Invoke-Call -ScriptBlock {dso template list -v6 --config "namespace=$namespace, application=$application, template.provider.id=$provider" --namespace-scope --uninherited -f json | dso template delete -v6 --config "namespace=$namespace, application=$application, template.provider.id=$provider" --namespace-scope -i -} -ErrorAction Stop

Write-Output "`ndso template list -v6 --namespace $namespace --namespace $namespace --application $application --config `"template.provider.id=$provider`" -s $stage --namespace-scope --uninherited -f json | dso template delete -v6 --namespace $namespace --namespace $namespace --application $application --config `"template.provider.id=$provider`" -s $stage --namespace-scope -i -`n"
Invoke-Call -ScriptBlock {dso template list -v6 --config "namespace=$namespace, application=$application, template.provider.id=$provider" -s $stage --namespace-scope --uninherited -f json | dso template delete -v6 --config "namespace=$namespace, application=$application, template.provider.id=$provider" -s $stage --namespace-scope -i -} -ErrorAction Stop

Write-Output "`ndso template list -v6 --namespace $namespace --namespace $namespace --application $application --config `"template.provider.id=$provider`" --uninherited -f json | dso template delete -v6 --namespace $namespace --namespace $namespace --application $application --config `"template.provider.id=$provider`" -i -`n"
Invoke-Call -ScriptBlock {dso template list -v6 --config "namespace=$namespace, application=$application, template.provider.id=$provider" --uninherited -f json | dso template delete -v6 --config "namespace=$namespace, application=$application, template.provider.id=$provider" -i -} -ErrorAction Stop

Write-Output "`ndso template list -v6 --namespace $namespace --namespace $namespace --application $application --config `"template.provider.id=$provider`" -s $stage --uninherited -f json | dso template delete -v6 --namespace $namespace --namespace $namespace --application $application --config `"template.provider.id=$provider`" -s $stage -i -`n"
Invoke-Call -ScriptBlock {dso template list -v6 --config "namespace=$namespace, application=$application, template.provider.id=$provider" -s $stage --uninherited -f json | dso template delete -v6 --config "namespace=$namespace, application=$application, template.provider.id=$provider" -s $stage -i -} -ErrorAction Stop

Write-Output "`ndso template list -v6 --namespace $namespace --namespace $namespace --application $application --config `"template.provider.id=$provider`" -s `"$stage/2`" --uninherited -f json | dso template delete -v6 --namespace $namespace --namespace $namespace --application $application --config `"template.provider.id=$provider`" -s `"$stage/2`" -i -`n"
Invoke-Call -ScriptBlock {dso template list -v6 --config "namespace=$namespace, application=$application, template.provider.id=$provider" -s "$stage/2" --uninherited -f json | dso template delete -v6 --config "namespace=$namespace, application=$application, template.provider.id=$provider" -s "$stage/2" -i -} -ErrorAction Stop


##################################
### set configurations

Write-Output "`ndso config set -v6 namespace $namespace`n"
Invoke-Call -ScriptBlock {dso config set -v6 namespace $namespace} -ErrorAction Stop

Write-Output "`ndso config set -v6 application $application`n"
Invoke-Call -ScriptBlock {dso config set -v6 application $application} -ErrorAction Stop

Write-Output "`ndso config set -v6 template.provider.id $provider`n"
Invoke-Call -ScriptBlock {dso config set -v6 template.provider.id "$provider"} -ErrorAction Stop


##################################
### add context-specific templates

Write-Output "`ndso template add sample-templates\global-template --global-scope -v6`n"
Invoke-Call -ScriptBlock {dso template add sample-templates\global-template --global-scope -v6} -ErrorAction Stop

Write-Output "`ndso template add sample-templates\global-stage-template global_stage_template -s $stage --global-scope -v6`n"
Invoke-Call -ScriptBlock {dso template add sample-templates\global-stage-template global_stage_template -s $stage --global-scope -v6} -ErrorAction Stop

Write-Output "`ndso template add sample-templates\namespace-template namespace_template -r '.dso\output\template\*' --namespace-scope -v6`n"
Invoke-Call -ScriptBlock {dso template add sample-templates\namespace-template namespace_template -r '.dso\output\template\*' --namespace-scope -v6} -ErrorAction Stop

Write-Output "`ndso template add sample-templates\namespace-stage-template namespace_stage_template -r '.dso\output\template\*' -s $stage --namespace-scope -v6`n"
Invoke-Call -ScriptBlock {dso template add sample-templates\namespace-stage-template namespace_stage_template -r '.dso\output\template\*' -s $stage --namespace-scope -v6} -ErrorAction Stop

Write-Output "`ndso template add sample-templates\app-template app_template -r '.dso\output\template\*' -v6`n"
Invoke-Call -ScriptBlock {dso template add sample-templates\app-template app_template -r '.dso\output\template\*' -v6} -ErrorAction Stop

Write-Output "`ndso template add sample-templates\app-stage-template app_stage_template -r '.dso\output\template\*' -s $stage -v6`n"
Invoke-Call -ScriptBlock {dso template add sample-templates\app-stage-template  app_stage_template -r '.dso\output\template\*' -s $stage -v6} -ErrorAction Stop

Write-Output "`ndso template add sample-templates\app-stage2-template app_stage2_template -r '.dso\output\template\*' -s `"$stage/2`" -v6`n"
Invoke-Call -ScriptBlock {dso template add sample-templates\app-stage2-template app_stage2_template -r '.dso\output\template\*' -s "$stage/2" -v6} -ErrorAction Stop

# ##################################
# ### add overriden templates

Write-Output "`ndso template add sample-templates\global-template-overriden overriden_template -r '.dso\output\template\*' --global-scope -v6`n"
Invoke-Call -ScriptBlock {dso template add sample-templates\global-template-overriden overriden_template -r '.dso\output\template\*' --global-scope -v6} -ErrorAction Stop

Write-Output "`ndso template add sample-templates\global-stage-template-overriden overriden_template -r '.dso\output\template\*' -s $stage --global-scope -v6`n"
Invoke-Call -ScriptBlock {dso template add sample-templates\global-stage-template-overriden overriden_template -r '.dso\output\template\*' -s $stage --global-scope -v6} -ErrorAction Stop

Write-Output "`ndso template add sample-templates\namespace-template-overriden overriden_template -r '.dso\output\template\*' --namespace-scope -v6`n"
Invoke-Call -ScriptBlock {dso template add sample-templates\namespace-template-overriden overriden_template -r '.dso\output\template\*' --namespace-scope -v6} -ErrorAction Stop

Write-Output "`ndso template add sample-templates\namespace-stage-template-overriden overriden_template -r '.dso\output\template\*' -s $stage --namespace-scope -v6`n"
Invoke-Call -ScriptBlock {dso template add sample-templates\namespace-stage-template-overriden overriden_template -r '.dso\output\template\*' -s $stage --namespace-scope -v6} -ErrorAction Stop

Write-Output "`ndso template add sample-templates\app-template-overriden overriden_template -r '.dso\output\template\*' -v6`n"
Invoke-Call -ScriptBlock {dso template add sample-templates\app-template-overriden overriden_template -r '.dso\output\template\*' -v6} -ErrorAction Stop

Write-Output "`ndso template add sample-templates\app-stage-template-overriden overriden_template -r '.dso\output\template\*' -s $stage -v6`n"
Invoke-Call -ScriptBlock {dso template add sample-templates\app-stage-template-overriden overriden_template -r '.dso\output\template\*' -s $stage -v6} -ErrorAction Stop

Write-Output "`ndso template add sample-templates\app-stage2-template-overriden overriden_template -r '.dso\output\template\*' -s `"$stage/2`" -v6`n"
Invoke-Call -ScriptBlock {dso template add sample-templates\app-stage2-template-overriden overriden_template -r '.dso\output\template\*' -s "$stage/2" -v6} -ErrorAction Stop


##################################
### get some templates

Write-Output "`ndso template get -v6 overriden_template --global-scope -f text`n"
Invoke-Call -ScriptBlock {dso template get -v6 overriden_template --global-scope -f text} -ErrorAction Stop

Write-Output "`ndso template get -v6 overriden_template --namespace-scope -f text`n"
Invoke-Call -ScriptBlock {dso template get -v6 overriden_template --namespace-scope -f text} -ErrorAction Stop

Write-Output "`ndso template get -v6 overriden_template -s $stage -f text`n"
Invoke-Call -ScriptBlock {dso template get -v6 overriden_template -s $stage -f text} -ErrorAction Stop

Write-Output "`ndso template get -v6 app_template -f text`n"
Invoke-Call -ScriptBlock {dso template get -v6 app_template -f text} -ErrorAction Stop

Write-Output "`ndso template get -v6 app_stage_template -s $stage -f text`n"
Invoke-Call -ScriptBlock {dso template get -v6 app_stage_template -s $stage -f text} -ErrorAction Stop

Write-Output "`ndso template get -v6 app_stage2_template -s `"$stage/2`" -f text`n"
Invoke-Call -ScriptBlock {dso template get -v6 app_stage2_template -s "$stage/2" -f text} -ErrorAction Stop

##################################
### edit some tempaltes

if (${Env:TEST_INTRACTIVELY} -eq "yes")
{

    Write-Output "`ndso template edit -v6 overriden_template --global-scope`n"
    Invoke-Call -ScriptBlock {dso template edit -v6 overriden_template --global-scope} -ErrorAction Stop

    Write-Output "`ndso template edit -v6 overriden_template -s $stage --namespace-scope`n"
    Invoke-Call -ScriptBlock {dso template edit -v6 overriden_template -s $stage --namespace-scope} -ErrorAction Stop

    Write-Output "`ndso template edit -v6 app_template`n"
    Invoke-Call -ScriptBlock {dso template edit -v6 app_template} -ErrorAction Stop

    Write-Output "`ndso template edit -v6 app_stage_template -s $stage`n"
    Invoke-Call -ScriptBlock {dso template edit -v6 app_stage_template -s $stage} -ErrorAction Stop

    Write-Output "`ndso template edit -v6 app_stage2_template -s `"$stage/2`"`n"
    Invoke-Call -ScriptBlock {dso template edit -v6 app_stage2_template -s "$stage/2"} -ErrorAction Stop
}

##################################
### get history of some templates

Write-Output "`ndso template history -v6 overriden_template -g -f json`n"
Invoke-Call -ScriptBlock {dso template history -v6 overriden_template -g -f json} -ErrorAction Stop

Write-Output "`ndso template history -v6 overriden_template -n -f json`n"
Invoke-Call -ScriptBlock {dso template history -v6 overriden_template -n -f json} -ErrorAction Stop

Write-Output "`ndso template history -v6 overriden_template -s $stage -f yaml`n"
Invoke-Call -ScriptBlock {dso template history -v6 overriden_template -s $stage -f json} -ErrorAction Stop

Write-Output "`ndso template history -v6 app_template --query-all -f json`n"
Invoke-Call -ScriptBlock {dso template history -v6 app_template --query-all -f json} -ErrorAction Stop

Write-Output "`ndso template history -v6 app_stage_template -s $stage --query-all -f yaml`n"
Invoke-Call -ScriptBlock {dso template history -v6 app_stage_template -s $stage --query-all -f json} -ErrorAction Stop

Write-Output "`ndso template history -v6 app_stage2_template -s `"$stage/2`" --query-all -f yaml`n"
Invoke-Call -ScriptBlock {dso template history -v6 app_stage2_template -s "$stage/2" --query-all -f json} -ErrorAction Stop

##################################
### list some templates

$filename = ("$provider" -split '/')[0]

Write-Output "`ndso template list -v6 -s $stage --uninherited --query-all overriden_template`n"
Invoke-Call -ScriptBlock {dso template list -v6 -s $stage --uninherited --query-all overriden_template} -ErrorAction Stop

Write-Output "`ndso template list -v6 -s $stage --uninherited --query-all --include-contents -f json`n"
Invoke-Call -ScriptBlock {dso template list -v6 -s $stage --uninherited --query-all --include-contents -f json} -ErrorAction Stop > ".dso\output\template\app-uninherited-${filename}.json"

Write-Output "`ndso template list -v6 -s $stage --query-all -f yaml`n"
Invoke-Call -ScriptBlock {dso template list -v6 -s $stage --query-all -f yaml} -ErrorAction Stop > ".dso\output\template\app-stage-all-${filename}.yaml"

Write-Output "`ndso template list -v6 -s `"$stage/2`" --query-all -f yaml`n"
Invoke-Call -ScriptBlock {dso template list -v6 -s "$stage/2" --query-all -f yaml} -ErrorAction Stop > ".dso\output\template\app-stage2-all-${filename}.yaml"

##################################
### render templates

Write-Output "`ndso template render overriden_template -v6`n"
Invoke-Call -ScriptBlock {dso template render overriden_template -v6} -ErrorAction Stop

# Write-Output "`ndso template render -v6 -s $stage`n"
# Invoke-Call -ScriptBlock {dso template render -v6 -s $stage} -ErrorAction Stop

Write-Output "`ndso template render -v6 -s `"$stage/2`"`n"
Invoke-Call -ScriptBlock {dso template render -v6 -s "$stage/2"} -ErrorAction Stop
