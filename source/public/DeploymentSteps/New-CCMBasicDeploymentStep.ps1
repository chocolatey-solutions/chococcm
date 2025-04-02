function New-CCMBasicDeploymentStep {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]
        $StepTitle,

        [Parameter(Mandatory)]
        [ValidateSet('install', 'upgrade', 'uninstall')]
        [string]
        $Command,

        [Parameter(Mandatory)]
        [Alias ('PackageId')]
        [string]
        $PackageName,

        [Parameter(Mandatory)]
        [string[]]
        $TargetGroup,

        [Parameter()]
        [Alias ('Version')]
        [string]
        $PackageVersion,

        [Parameter()]
        [switch]
        $Prerelease
    )

    process {
        [PSCustomObject]@{
            Name      = $StepTitle
            Command        = $Command
            PackageID      = $PackageName
            TargetGroup    = $TargetGroup
            PackageVersion = $PackageVersion
            Prerelease     = $Prerelease
            Type           = 'Basic'
        }
    }

}