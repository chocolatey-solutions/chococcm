function New-AdvancedDeploymentStep {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $StepTitle,

        [Parameter(Mandatory)]
        [scriptblock]
        $Script,

        [Parameter(Mandatory)]
        [string[]]
        $TargetGroup

    )

    begin {
        if (-not $Script:CcmServerInfo) {
            Write-Warning 'You appear to be unconnected from your Chocolatey Central Management instance. Please run Connect-CCMServer first.'
        }
    }

    process {
        [PSCustomObject]@{
            StepTitle   = $StepTitle
            Script      = $Script
            Targetgroup = $TargetGroup
            Type = 'Advanced'
            
        }
    }


}

