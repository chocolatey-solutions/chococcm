function New-BasicDeploymentStep {
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
        [string]
        $Prerelease
    )


    begin {
        if (-not $Script:CcmServerInfo) {
            Write-Warning 'You appear to be unconnected from your Chocolatey Central Management instance. Please run Connect-CCMServer first.'
        }
    
    }

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