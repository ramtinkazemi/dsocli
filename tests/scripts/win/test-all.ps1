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
$Env:global_secret_overriden='global.secret_overriden'
$Env:global_stage_secret_overriden='global.stage.secret_overriden'
$Env:project_secret_overriden='project.secret_overriden'
$Env:project_stage_secret_overriden='project.stage_secret_overriden'
$Env:app_secret_overriden='app.secret_overriden'
$Env:app_stage_secret_overriden='app.stage_secret_overriden'
$Env:app_stage2_secret_overriden='app.stage2_secret_overriden'

$provider = "shell/v1"
.\tests\scripts\win\test-secrets.ps1 -namespace $namespace -project $project -application $application -stage $stage -working_dir "$working_dir" -provider $provider
if(!$?) { exit $? }

$provider = "local/v1"
.\tests\scripts\win\test-templates.ps1 -namespace $namespace -project $project -application $application -stage $stage -working_dir "$working_dir" -provider $provider
if(!$?) { exit $? }
