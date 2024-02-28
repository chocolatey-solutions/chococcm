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
    process {
        $ComputerList = Invoke-CCMApi "Computers/GetAll"

        switch ($PSCmdlet.ParameterSetName) {
            "Name" {
                # Just get the ID of the computer specified
                $ComputerId = $ComputerList | Where-Object { $_.name -eq $ComputerName } | Select-Object -ExpandProperty id

                # Get generic computer metadata
                $ComputerMetaData = Invoke-CCMApi "Computers/GetComputerForView?id=$ComputerId"

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
                return $ComputerList
            }
        }
    }
}