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
        if ($PSBoundParameters) {
            $QueryString = New-CCMQueryString -QueryParameter $PSBoundParameters
            $Output = Invoke-CCMApi "/DeploymentPlans/GetAllPaged?$QueryString"
        }
        else {
            $Output = Invoke-CCMApi "/DeploymentPlans/GetAllPaged"
        }
        return $Output.items
    }
}