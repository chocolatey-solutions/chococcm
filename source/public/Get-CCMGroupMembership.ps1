function Get-CCMGroupMembership {
    [CmdletBInding(DefaultParameterSetName="Default")]
    Param(
    [Parameter(ParameterSetName="Computer", Mandatory)]
    [string]
    $ComputerName,

    [Parameter(ParameterSetName="Group", Mandatory)]
    [string]
    $GroupName
    )

    process {
        switch ($PSCmdlet.ParameterSetName) {
            "Computer" {
               $Id = (Get-CCMComputer -ComputerName $ComputerName).Id

                Invoke-CCMApi -Slug /app/ComputerGroup/GetAllByComputerId?computerId=$Id | Select-Object groupName, groupId
            }
            "Group" {
                $Id = (Get-CCMGroup -Name $GroupName).Id

                Invoke-CCMApi -Slug /app/ComputerGroup/GetAllByGroupId?groupId=$Id | Select-Object computerName, computerId, friendlyName, ipAddress

            }
        }
    }
}