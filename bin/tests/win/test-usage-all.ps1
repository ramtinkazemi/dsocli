param(
    [string]$namespace = "test-ns",
    [string]$project = "test-project",
    [string]$application = "test-app",
    [string]$stage = "test-stage",
    [string]$working_dir = "."

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


.\tests\scripts\win\test-config.ps1 -namespace $namespace -project $project -application $application  -working_dir "$working_dir"
if(!$?) { exit $? }


$provider = "aws/ssm/v1"
.\tests\scripts\win\test-parameters.ps1 -namespace $namespace -project $project -application $application -stage $stage -provider $provider
if(!$?) { exit $? }

.\tests\scripts\win\test-secrets.ps1 -namespace $namespace -project $project -application $application -stage $stage -provider $provider
if(!$?) { exit $? }

.\tests\scripts\win\test-templates.ps1 -namespace $namespace -project $project -application $application -stage $stage -provider $provider
if(!$?) { exit $? }



$provider = "local/v1"
.\tests\scripts\win\test-parameters.ps1 -namespace $namespace -project $project -application $application -stage $stage -provider $provider
if(!$?) { exit $? }

$provider = "shell/v1"

$Env:global_secret='global.secret'
$Env:global_stage_secret='global.stage_secret'
$Env:project_secret='project.secret'
$Env:project_stage_secret='project.stage_secret'
$Env:app_secret='app.secret'
$Env:app_stage_secret='app.stage_secret'
$Env:global_overriden_secret='global.overriden_secret'
$Env:global_stage_overriden_secret='global.stage.overriden_secret'
$Env:project_overriden_secret='project.overriden_secret'
$Env:project_stage_overriden_secret='project.stage_overriden_secret'
$Env:app_overriden_secret='app.overriden_secret'
$Env:app_stage_overriden_secret='app.stage_overriden_secret'
$Env:app_stage2_overriden_secret='app.stage2_overriden_secret'

.\tests\scripts\win\test-secrets.ps1 -namespace $namespace -project $project -application $application -stage $stage -provider $provider
if(!$?) { exit $? }

$provider = "local/v1"
.\tests\scripts\win\test-templates.ps1 -namespace $namespace -project $project -application $application -stage $stage -provider $provider
if(!$?) { exit $? }
