function New-CCMAdvancedDeploymentStep {
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

    process {
        [PSCustomObject]@{
            StepTitle   = $StepTitle
            Script      = $Script
            Targetgroup = $TargetGroup
            Type        = 'Advanced'
            
        }
    }

}
