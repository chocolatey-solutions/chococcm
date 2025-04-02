function Wait-DeploymentPlan {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [Alias('Id')]
        [Int64]
        $DeploymentId
    )
    
    end {
        $DeploymentResult = @{
            0 = 'Unknown'
            1 = 'Draft'
            2 = 'Pending'
            3 = 'Ready'
            4 = 'Deleted'
            5 = 'Active'
            6 = 'Cancelled'
            7 = 'Inconclusive'
            8 = 'Failed'
            9 = 'Success'
            10 = 'Unreachable'
        }

        $codes = @(6, 7, 8, 9, 10)

        while ((Get-CCMDeploymentPlan -Filter 'Upgrade Firefox').result -eq 5) {
            Write-Host '.' -NoNewline
            Start-sleep -Seconds 30
    
        }
    
    }
}