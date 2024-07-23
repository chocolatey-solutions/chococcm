function Stop-CCMDeploymentPlan {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [ArgumentCompleter({
                param(
                    $Command,
                    $Parameter,
                    $WordToComplete,
                    $CommandAst,
                    $FakeBoundParams )
        
                $CompletionResults = (Get-CCMDeploymentPlan).Name

                if ($WordToComplete) {
                    $CompletionResults.Where{ $_ -match "^$WordToComplete" }
                }
                else {
                    $CompletionResults
                }
            })]
        [String]
        $DeploymentName
        
    )

    process {

        $Deployment = Get-CCMDeploymentPlan -Filter $DeploymentName
    
        #Stop Deployment Plan
        $null = Invoke-CCMApi -Method "POST" -Slug "DeploymentPlans/Cancel" -Body @{
            id = $Deployment.id
        }
    }
}