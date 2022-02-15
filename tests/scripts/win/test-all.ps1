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

# Invoke-Call -ScriptBlock {.\tests\scripts\win\test-secrets.ps1 -namespace $namespace -project $project -application $application -stage $stage -working_dir "$working_dir" -provider $provider} -ErrorAction Stop > $null
# if(!$?) { exit $? }

.\tests\scripts\win\test-templates.ps1 -namespace $namespace -project $project -application $application -stage $stage -working_dir "$working_dir" -provider $provider
if(!$?) { exit $? }
