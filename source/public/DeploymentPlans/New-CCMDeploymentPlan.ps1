function New-CCMDeploymentPlan {
    [Cmdletbinding(DefaultParameterSetName = "Default")]
    Param(
        [parameter(Mandatory)]
        [string]
        $PlanTitle,

        [parameter(Mandatory)]
        [PSCustomObject]
        $Step,
    
        [parameter]
        [switch]
        $RunNow,

        [parameter(Mandatory, ParameterSetName = 'Schedule')]
        [datetime]
        $StartTime,

        [parameter(ParameterSetName = 'Schedule')]
        [datetime]
        $LastStartTime,

        [parameter(ParameterSetName = 'Schedule')]
        [ValidateSet("None", "Daily", "Weekly", "EveryTwoWeeks", "EveryFourWeeks", "Monthly", "EveryTwoMonths", "Quarterly", "EverySixMonths", "Yearly")]
        [string]
        $RepeatPeriod = "None"


    )

    process {
        
        $body =@{
            name = $PlanTitle
        }

        switch($PSCmdlet.ParameterSetName){
            "Schedule" {
                $Date = Get-Date $StartTime -Format "yyyy-MM-ddTHH:mm:ss.fffZ"
        
        
        
        }
        }




        
        #CreateDeplyomentPlan
        $Deployment = Invoke-CCMApi -Slug "DeploymentPlans/CreateorEdit" -Method POST -Body $body

#region Add Steps
        #Add a step to the plan for each deployment step
        $X = 1

        foreach ($s in $step) {

            $groups = [System.Collections.Generic.List[hashtable]]::new()
            
            if ($s.type -eq 'Basic') {
                #Fetch the group data for the Deployment.
                #Get the ID of the group via CCM API
                $s.TargetGroup | ForEach-Object {
                    $GroupData = Get-CCMGroup -Name $_

                    $Groups.Add(@{groupId = $GroupData.Id; groupName = $GroupData.Name })
                }

                $null = Invoke-CCMApi -Method "Post" -Slug "DeploymentSteps/CreateorEdit" -Body @{
                    planOrder                      = $X
                    deploymentPlanId               = $Deployment.ID
                    name                           = $s.StepTitle
                    validExitCodes                 = "0, 1605, 1614, 1641, 3010"
                    executionTimeoutInSeconds      = 14400
                    machineContactTimeoutInMinutes = "0"
                    failOnError                    = $true
                    requireSuccessOnAllComputers   = $false
                    deploymentStepGroups           = @($groups)
                    # Syntax for basic Deployment Steps is "<ChocoCommand>|<PackageId>|<PackageVersion>|<PreRelease>"
                    Script                         = '{0}|{1}|{2}|{3}' -f $s.Command, $s.PackageId, $s.PackageVersion, $s.PreRelease
                }
            }
            else {
                $s.TargetGroup | ForEach-Object {
                    $GroupData = Get-CCMGroup -Name $_

                    $Groups.Add(@{groupId = $GroupData.Id; groupName = $GroupData.Name })
                }

                $null = Invoke-CCMApi -Method "POST" -Slug "DeploymentSteps/CreateorEditPrivileged" -Body @{
                    planOrder                      = $X
                    deploymentPlanId               = $Deployment.ID
                    name                           = $s.StepTitle
                    validExitCodes                 = "0, 1605, 1614, 1641, 3010"
                    executionTimeoutInSeconds      = 14400
                    machineContactTimeoutInMinutes = "0"
                    failOnError                    = $true
                    requireSuccessOnAllComputers   = $false
                    deploymentStepGroups           = @($groups)
                    Script                         = $($s.Script.ToString())
                }
            }
            #Increment Plan Order
            $X++
        }
#endregion

        #RunNow or not?
        if ($RunNow) {
            #Move Deployment Plan to Ready
            $null = Invoke-CCMApi -Method "POST" -Slug "DeploymentPlans/MoveToReady" -Body @{
                id = $Deployment.Id
            }

            #Start Deployment Plan
            $null = Invoke-CCMApi -Method "POST" -Slug "DeploymentPlans/Start" -Body @{
                id = $Deployment.Id
            }
        }
    }
}