function Get-CCMComputerSoftware {
    [CmdletBinding()]
    Param(
        [parameter(Mandatory)]
        [string[]]
        $ComputerName
    )
    process {
        ForEach ($Computer in $ComputerName) {
            $ComputerInfo = Get-CCMComputer -ComputerName $Computer
            [ComputerSoftware[]](Invoke-CCMApi -Slug "/ComputerSoftware/GetAllByComputerId?computerId=$($ComputerInfo.id)")
        }
    }
}