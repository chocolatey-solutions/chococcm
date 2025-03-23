function Move-CCMDeploymentPlan {
    [CmdletBinding()]
    Param(
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

    end {
        $Deployment = Get-CCMDeploymentPlan -Filter $DeploymentName | Where-Object { $_.isArchived -eq $false }
    
        if ($Deployment.count -gt 1) {
            Write-Host @"
Mutliple Deployment Plans found!
Please select a deployment plan below:

"@ -ForegroundColor Green
            $x = 1
            $Deployment | ForEach-Object {
                "$($x): $($_.Name)"
                $x++
            }
            $choice = Read-Host "Selection"
            $Id = $Deployment[$($choice - 1)].id
        }
        else {
            $Id = $Deployment.id
        }
    
        # Mark Deployment Plan Ready
        $null = Invoke-CCMApi -Method "POST" -Slug "DeploymentPlans/MoveToReady" -Body @{
            id = $Id
        }
    }

}