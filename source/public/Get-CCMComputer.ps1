function Get-CCMComputer {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter (ParameterSetName = "Name")]
        [String]
        $ComputerName,

        [Parameter(ParameterSetName = "Default")]
        [Parameter(ParameterSetName = "Name")]
        [switch]
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
            Uri        = "$($Script:CcmServerInfo.Protocol)://$($Script:CcmServerInfo.Hostname)/api/services/app/Computers/GetAll"
            Method     = 'GET'
            WebSession = $Script:CcmServerInfo.Session
        }

        $ComputerList = Invoke-RestMethod @params

        switch ($PSCmdlet.ParameterSetName) {
            "Name" {
                # Just get the ID of the computer specified
                $ComputerId = $ComputerList.result | Where-Object { $_.name -eq $ComputerName } | Select-Object -ExpandProperty id

                # Get generic computer metadata 
                $RestArgs = @{
                    Uri        = "$($Script:CcmServerInfo.Protocol)://$($Script:CcmServerInfo.Hostname)/api/services/app/Computers/GetComputerForView?id=$ComputerId"
                    Method     = "GET"
                    WebSession = $Script:CcmServerInfo.Session
                }

                $ComputerMetaData = (Invoke-RestMethod @RestArgs).result

                if (-not $Detailed) {
                    $ComputerMetaData | Select-Object -Property @(
                        'Name'
                        'FriendlyName'
                        'ComputerGuid'
                        'DisplayName'
                        'IpAddress'
                        'Fqdn'
                        'LastCheckinDateTime'
                        'creationTime'
                        'ccmServiceName'
                        @{Name = 'EligibleForDeployments'; Expression = { $_.availableForDeploymentsBasedOnLicenseCount } }
                        @{Name = 'OptedIntoDeployments'; Expression = { $_.optedIntoDeploymentsBasedOnConfig } }
                    )
                }
                else {
                    return $ComputerMetaData
                }
            }
            "Default" {
                return $ComputerList.result
            }
        }
    }
}