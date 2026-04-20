param(
    [string[]]$Path = @("$PSScriptRoot\tests"),
    [switch]$Integration
)

Import-Module Pester -RequiredVersion 5.7.1 -ErrorAction Stop

# Resolve the latest built module (e.g. 1.3.0\ChocoCCM.psm1)
$builtModule = Get-ChildItem "$PSScriptRoot\*\ChocoCCM.psm1" |
    Where-Object { $_.Directory.Name -match '^\d+\.\d+\.\d+' } |
    Sort-Object { [version]$_.Directory.Name } -Descending |
    Select-Object -First 1

if (-not $builtModule) {
    throw "No built module found. Run .\Build.ps1 first."
}

Write-Host "Testing module: $($builtModule.FullName)" -ForegroundColor Cyan

# Wire up all test files as containers so $ModulePath and $Integration are passed in
$testFiles = Get-ChildItem $Path -Recurse -Filter '*.Tests.ps1'
$containers = $testFiles | ForEach-Object {
    New-PesterContainer -Path $_.FullName -Data @{
        ModulePath  = $builtModule.FullName
        Integration = $Integration.IsPresent
    }
}

$configuration = New-PesterConfiguration

$configuration.Run.Container = $containers
$configuration.Output.Verbosity = 'Detailed'

$configuration.TestResult.Enabled = $true
$configuration.TestResult.OutputPath = "$PSScriptRoot\TestResults.xml"
$configuration.TestResult.OutputFormat = 'NUnitXml'

Invoke-Pester -Configuration $configuration