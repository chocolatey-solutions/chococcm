function Get-CCMSoftware {
    [CmdletBinding(DefaultParameterSetName="All")]
    Param(
        [parameter(ParameterSetName = "Name")]
        [string[]]
        $ComputerName
    )

    process {
        switch ($PSCmdlet.ParameterSetName) {
            "Name" {
                ForEach ($Computer in $ComputerName) {
                    $ComputerInfo = Get-CCMComputer -ComputerName $Computer
                    Invoke-CCMApi -Slug "/ComputerSoftware/GetAllByComputerId?computerId=$($ComputerInfo.id)"
                }
            }
            "All"{
                Invoke-CCMApi -Slug "/Software/GetAll"
            }
        }
    }
}