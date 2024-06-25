function Import-CCMDeploymentPlan {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({
            Test-Path $_
        })]
        [string]
        $PlanName
    )

    process {
        $Body = (Get-Content $PlanName -Raw) | ConvertFrom-Json -Depth 10
        $null = Invoke-CCMApi -Slug '/DeploymentPlans/Import' -Method 'POST' -Body $Body
    }
}