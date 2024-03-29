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


##################################

Write-Output "`ndso config init -v5 --global-scope`n"
Invoke-Call -ScriptBlock {dso config init -v5 --global-scope} -ErrorAction Stop

Write-Output "`ndso config list -v5 --global-scope`n"
Invoke-Call -ScriptBlock {dso config list -v5 --global-scope} -ErrorAction Stop

Write-Output "`ndso config list -v5 -w `"${working_dir}`" --local`n"
Invoke-Call -ScriptBlock {dso config list -v5 -w "${working_dir}"} --local -ErrorAction Stop

Write-Output "`ndso config set -v5 test.global-config some-value --global-scope`n"
Invoke-Call -ScriptBlock {dso config set -v5 test.global-config some-value --global-scope} -ErrorAction Stop

Write-Output "`ndso config get -v5 test.global-config some-value --global-scope`n"
Invoke-Call -ScriptBlock {dso config get -v5  test.global-config --global-scope} -ErrorAction Stop

Write-Output "`ndso config init -v5 -w `"${working_dir}`"`n"
Invoke-Call -ScriptBlock {dso config init -v5 -w "${working_dir}"} -ErrorAction Stop

Write-Output "`ndso config set -v5 -w `"${working_dir}`" test.local-config some-value`n"
Invoke-Call -ScriptBlock {dso config set -v5 -w "${working_dir}" test.local-config some-value} -ErrorAction Stop

Write-Output "`ndso config get -v5 -w `"${working_dir}`" test.local-config`n"
Invoke-Call -ScriptBlock {dso config get -v5 -w "${working_dir}" test.local-config} -ErrorAction Stop

Write-Output "`ndso config unset -v5 test.global-config --global-scope`n"
Invoke-Call -ScriptBlock {dso config unset -v5 test.global-config --global-scope} -ErrorAction Stop

Write-Output "`ndso config unset -v5 -w `"${working_dir}`" test.local-config`n"
Invoke-Call -ScriptBlock {dso config unset -v5 -w "${working_dir}" test.local-config} -ErrorAction Stop

Write-Output "`ndso config set -v5 -w `"${working_dir}`" namespace ${namespace}`n"
Invoke-Call -ScriptBlock {dso config set -v5 -w "${working_dir}" namespace ${namespace}} -ErrorAction Stop

Write-Output "`ndso config set -v5 -w `"${working_dir}`" application ${application}`n"
Invoke-Call -ScriptBlock {dso config set -v5 -w "${working_dir}" application ${application}} -ErrorAction Stop


