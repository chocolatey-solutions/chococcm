function Get-CCMComputerSoftware {
    [CmdletBinding()]
    Param(
        [parameter(Mandatory, ParameterSetName = "Computer")]
        [string[]]
        $ComputerName,

        [parameter(Mandatory, ParameterSetName = "Software")]
        [string[]]
        $SoftwareName,

        [Parameter(Mandatory, ParameterSetName = 'PackageId')]
        [String[]]
        $PackageId
    )
    process {
        switch ($PSCmdlet.ParameterSetName) {
            'Computer' {
                ForEach ($Computer in $ComputerName) {
                    $ComputerInfo = Get-CCMComputer -ComputerName $Computer
                    [ComputerSoftware[]](Invoke-CCMApi -Slug "/ComputerSoftware/GetAllByComputerId?computerId=$($ComputerInfo.id)")
                }
            }
            'Software'{
                $AllSoftware = Get-CCMSoftware
                ForEach ($Software in $SoftwareName) {
                    $SoftwareInfo = ($AllSoftware | Where-Object -Property name -eq $SoftwareName)
                    foreach ($Version in $SoftwareInfo) {
                        [ComputerSoftware[]](Invoke-CCMApi -Slug "/ComputerSoftware/GetAllBySoftwareId?softwareId=$($Version.id)")
                    }
                }
            }
            'PackageId'{
                $AllSoftware = Get-CCMSoftware
                ForEach ($Package in $PackageId) {
                    $SoftwareInfo = ($AllSoftware | Where-Object -Property packageId -eq $PackageId)
                    foreach ($Version in $SoftwareInfo) {
                        [ComputerSoftware[]](Invoke-CCMApi -Slug "/ComputerSoftware/GetAllBySoftwareId?softwareId=$($Version.id)")
                    }
                }

            }
        }
    }
}