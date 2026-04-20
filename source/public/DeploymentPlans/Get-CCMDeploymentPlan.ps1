Function Get-CCMDeploymentPlan {
    [CmdletBinding()]
    Param(
        [Parameter()]
        [string]
        $Filter,

        [Parameter()]
        [switch]
        $IsArchived
    )

    process { 
        if ($PSBoundParameters.Count -gt 0) {
            $Output = Invoke-CCMApi "/DeploymentPlans/GetAllPaged" -QueryParameters $PSBoundParameters
        }
        else {
            $Output = Invoke-CCMApi "/DeploymentPlans/GetAllPaged"
        }
        return $Output.items
    }
}