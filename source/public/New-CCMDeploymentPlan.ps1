function New-CCMDeploymentPlan {
    [Cmdletbinding()]
    Param(
        [parameter(Mandatory)]
        [string]
        $PlanTitle,

        [parameter(Mandatory)]
        [PSCustomObject]
        $Step,
    
        [parameter]
        [switch]
        $RunNow

    )

    begin {
        if (-not $Script:CcmServerInfo) {
            Write-Warning 'You appear to be unconnected from your Chocolatey Central Management instance. Please run Connect-CCMServer first.'
        }
    }

    process {
        #CreateDeplyomentPlan
        $params = @{
            Uri         = "$($Script:CcmServerInfo.Protocol)://$($Script:CcmServerInfo.Hostname)/api/services/app/DeploymentPlans/CreateorEdit"
            ContentType = "application/json"
            Method      = "POST"
            WebSession  = $Script:CcmServerInfo.Session
            Body        = @{name = $PlanTitle } | ConvertTo-Json
        }
        $Deployment = Invoke-RestMethod @params

        #Add a step to the plan for each deplyoment step
        $X = 1

        foreach ($s in $step) {

            $groups = [System.Collections.Generic.List[hashtable]]::new()
            
            if ($s.type -eq 'Basic') {
                #Fetch the group data for the Deployment.
                #Get the ID of the group via CCM API
                $s.TargetGroup | ForEach-Object {
                    $params = @{
                        Uri        = "$($CcmConnection['protocol'])://$($CcmConnection['CcmHost'])/api/services/app/Groups/GetAll"
                        Method     = "GET"
                        WebSession = $CcmConnection['Session']
                    }
                    
                    $GroupData = Invoke-RestMethod @params |
                    Select-Object -ExpandProperty result |
                    Where-Object Name -eq $_ | Select-Object Name, ID, Description

                    $Groups.Add(@{groupId = $GroupData.Id; groupName = $GroupData.Name })
                }

                $Body = @{
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
                } | ConvertTo-Json

                $params = @{
                    Uri         = "$($Script:CcmServerInfo.Protocol)://$($Script:CcmServerInfo.Hostname)/api/services/app/DeploymentSteps/CreateorEdit"
                    ContentType = "application/json"
                    Method      = "POST"
                    WebSession  = $Script:CcmServerInfo.Session
                    Body        = $Body
                }
                $null = Invoke-RestMethod @params
            }
            else {
                $s.TargetGroup | ForEach-Object {
                    $params = @{
                        Uri        = "$($CcmConnection['protocol'])://$($CcmConnection['CcmHost'])/api/services/app/Groups/GetAll"
                        Method     = "GET"
                        WebSession = $CcmConnection['Session']
                    }
                    
                    $GroupData = Invoke-RestMethod @params |
                    Select-Object -ExpandProperty result |
                    Where-Object Name -eq $_ | Select-Object Name, ID, Description

                    $Groups.Add(@{groupId = $GroupData.Id; groupName = $GroupData.Name })
                
                }

                $Body = @{
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
                } | ConvertTo-Json

                $params = @{
                    Uri         = "$($Script:CcmServerInfo.Protocol)://$($Script:CcmServerInfo.Hostname)/api/services/app/DeploymentSteps/CreateorEditPrivileged"
                    ContentType = "application/json"
                    Method      = "POST"
                    WebSession  = $Script:CcmServerInfo.Session
                    Body        = $Body
                }
                $null = Invoke-RestMethod @params
            }
        #Increment Plan Order
        $X++
        }
        #RunNow or not?
        if ($RunNow){
            #Move Deployment Plan to Ready
            $params = @{
                Uri         = "$($Script:CcmServerInfo.Protocol)://$($Script:CcmServerInfo.Hostname)/api/services/app/DeploymentPlans/MoveToReady"
                ContentType = "application/json"
                Method      = "POST"
                WebSession  = $Script:CcmServerInfo.Session
                Body        = @{id = $Deployment.Id} | ConvertTo-Json
            } 
            $null = Invoke-RestMethod @params

            #Start Deployment Plan
            $params = @{
                Uri         = "$($Script:CcmServerInfo.Protocol)://$($Script:CcmServerInfo.Hostname)/api/services/app/DeploymentPlans/Start"
                ContentType = "application/json"
                Method      = "POST"
                WebSession  = $Script:CcmServerInfo.Session
                Body        = @{id = $Deployment.Id} | ConvertTo-Json
            } 
            $null = Invoke-RestMethod @params
        }
    }
}