function Remove-CCMDeploymentPlan {
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

        $Deployment = Get-CCMDeploymentPlan -Filter $DeploymentName | Where-Object {([String]::IsNullOrEmpty($_.finishDateTimeUtc)) -and ([String]::IsNullOrEmpty($_.cancelledDateTimeUtc))}
    
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
        else{
            $Id = $Deployment.id
        }

        #Archive Deployment Plan
        $Body = @{
            id = $Id
        }
        Write-Verbose ($Body | ConvertTo-Json)

        $QueryString = New-CCMQueryString -QueryParameter $Body

        $null = Invoke-CCMApi -Method "DELETE" -Slug "DeploymentPlans/Delete?$QueryString" 
    }
}