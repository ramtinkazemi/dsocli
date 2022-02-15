param(
    [string]$namespace = "test-ns",
    [string]$project = "test-project",
    [string]$application = "test-application",
    [string]$working_dir = ".",
    [string]$stage = "test-stage"

)

$ErrorActionPreference = "Stop"


##################################

# choco install nano > $null
# choco install less > $null

##################################

if (!(Test-Path tests\output)) {
    New-Item -ItemType Directory -Force -Path tests\output > $null
}

##################################


.\tests\scripts\win\test-config.ps1 -namespace $namespace -project $project -application $application
if(!$?) { exit $? }


$provider = "aws/ssm/v1"
.\tests\scripts\win\test-parameters.ps1 -namespace $namespace -project $project -application $application -stage $stage -working_dir "$working_dir" -provider $provider
if(!$?) { exit $? }

.\tests\scripts\win\test-secrets.ps1 -namespace $namespace -project $project -application $application -stage $stage -working_dir "$working_dir" -provider $provider
if(!$?) { exit $? }

.\tests\scripts\win\test-templates.ps1 -namespace $namespace -project $project -application $application -stage $stage -working_dir "$working_dir" -provider $provider
if(!$?) { exit $? }



$provider = "local/v1"
.\tests\scripts\win\test-parameters.ps1 -namespace $namespace -project $project -application $application -stage $stage -working_dir "$working_dir" -provider $provider
if(!$?) { exit $? }


$Env:global_secret='global.secret'
$Env:global_stage_secret='global.stage_secret'
$Env:project_secret='project.secret'
$Env:project_stage_secret='project.stage_secret'
$Env:app_secret='app.secret'
$Env:app_stage_secret='app.stage_secret'
$Env:overriden_secret='overriden_secret'

$provider = "shell/v1"
Invoke-Call -ScriptBlock {.\tests\scripts\win\test-secrets.ps1 -namespace $namespace -project $project -application $application -stage $stage -working_dir "$working_dir" -provider $provider} -ErrorAction Stop > $null
if(!$?) { exit $? }

$provider = "local/v1"
.\tests\scripts\win\test-templates.ps1 -namespace $namespace -project $project -application $application -stage $stage -working_dir "$working_dir" -provider $provider
if(!$?) { exit $? }
