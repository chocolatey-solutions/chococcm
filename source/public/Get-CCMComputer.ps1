function Get-CCMComputer {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter (ParameterSetName = "Name")]
        [String]
        $ComputerName,

        [Parameter(ParameterSetName = "Default")]
        [Parameter(ParameterSetName = "Name")]
        [string]
        $Detailed
        
    )
    begin {
        if (-not $Script:CcmServerInfo) {
            Write-Warning 'You appear to be unconnected from your Chocolatey Central Management instance.'
            Connect-CCMServer
        }
    }
    process {
        $params = @{
            Uri = "$($Script:CcmServerInfo.Protocol)://$($Script:CcmServerInfo.Hostname)/api/services/app/Computers/GetAll"
                    Method     = 'GET'
                    WebSession = $Script:CcmServerInfo.Session
                }

        $ComputerList = Invoke-RestMethod @params
                $ComputerList
        switch ($PSCmdlet.ParameterSetName) {
            "Name" {
                #Just get the ID of the computer specified
                $ComputerId = $ComputerList.result | Where-Object { $_.name -eq $ComputerName } | Select-Object -ExpandProperty id

                #Get generic computer metadata 
                $RestArgs = @{
                    Uri        = "$($Script:CcmServerInfo.Protocol)://$($Script:CcmServerInfo.Hostname)/api/services/app/Computers/GetComputerForView?id=$ComputerId"
                    Method     = "GET"
                    WebSession = $Script:CcmServerInfo.Session
                }

                $ComputerMetaData = (Invoke-RestMethod @RestArgs).result

                if(-not $Detailed){
                    $properties = @('Name'
                    'FriendlyName',
                    'ComputerGuid',
                    'DisplayName',
                    'IpAddress',
                    'Fqdn',
                    'LastCheckinDateTime',
                    'creationTime',
                    'ccmServiceName',
                    @{N='EligibleForDeployments';E={$_.availableForDeploymentsBasedOnLicenseCount}},
                    @{N='OptedIntoDeployments';E={$_.optedIntoDeploymentsBasedOnConfig}})
                    $ComputerMetaData | Select-Object $properties
                } else {
                    return $ComputerMetaData
                }
            } 
            "Default" {

            }
        }
    }

}