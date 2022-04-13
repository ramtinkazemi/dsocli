param(
    [string]$namespace = "test-ns",
    [string]$project = "test-project",
    [string]$application = "test-app",
    [string]$working_dir = "."
)


# $ScripName = [string]($script:MyInvocation.MyCommand.Name)
# Write-Output "USAGE: ${ScripName} <namespace [${default_namespace}]> <project [${default_project}]> <application [${default_application}]> <working_dir [${default_working_dir}]>"

##################################
function Invoke-Call([scriptblock]$ScriptBlock, [string]$ErrorAction=$ErrorActionPreference) {
    & @ScriptBlock
    if (($lastexitcode -ne 0) -and $ErrorAction -eq "Stop") {
        exit $lastexitcode
    }
}

##################################

if(!(Test-Path tests\output\))
{
    New-Item -ItemType Directory -Force -Path tests\output\ > $null
}

##################################

Write-Output "`ndso config init -b5 --global`n"
Invoke-Call -ScriptBlock {dso config init -b5 --global} -ErrorAction Stop > $null

Write-Output "`ndso config get -b5 --global`n"
Invoke-Call -ScriptBlock {dso config get -b5 --global} -ErrorAction Stop > $null

Write-Output "`ndso config set -b5  test.global-config some-value --global`n"
Invoke-Call -ScriptBlock {dso config set -b5 test.global-config some-value --global} -ErrorAction Stop > $null

Write-Output "`ndso config get -b5  test.global-config some-value --global`n"
Invoke-Call -ScriptBlock {dso config get -b5  test.global-config --global} -ErrorAction Stop > $null

Write-Output "`ndso config init -b5 -w `"${working_dir}`"`n"
Invoke-Call -ScriptBlock {dso config init -b5 -w "${working_dir}"} -ErrorAction Stop > $null

Write-Output "`ndso config get -b5 -w `"${working_dir}`"`n"
Invoke-Call -ScriptBlock {dso config get -b5 -w "${working_dir}"} -ErrorAction Stop > $null

Write-Output "`ndso config set -b5 -w `"${working_dir}`" test.local-config some-value`n"
Invoke-Call -ScriptBlock {dso config set -b5 -w "${working_dir}" test.local-config some-value} -ErrorAction Stop > $null

Write-Output "`ndso config get -b5 -w `"${working_dir}`" test.local-config`n"
Invoke-Call -ScriptBlock {dso config get -b5 -w "${working_dir}" test.local-config} -ErrorAction Stop > $null

Write-Output "`ndso config unset -b5  test.global-config some-value --global`n"
Invoke-Call -ScriptBlock {dso config unset -b5  test.global-config --global} -ErrorAction Stop > $null

Write-Output "`ndso config unset -b5 -w `"${working_dir}`" test.local-config`n"
Invoke-Call -ScriptBlock {dso config unset -b5 -w "${working_dir}" test.local-config} -ErrorAction Stop > $null

Write-Output "`ndso config set -b5 -w `"${working_dir}`" namespace ${namespace}`n"
Invoke-Call -ScriptBlock {dso config set -b5 -w "${working_dir}" namespace ${namespace}} -ErrorAction Stop > $null

Write-Output "`ndso config set -b5 -w `"${working_dir}`"`n"
Invoke-Call -ScriptBlock {dso config set -b5 -w "${working_dir}"} -ErrorAction Stop > $null

Write-Output "`ndso config set -b5 -w `"${working_dir}`" application ${application}`n"
Invoke-Call -ScriptBlock {dso config set -b5 -w "${working_dir}" application ${application}} -ErrorAction Stop > $null


