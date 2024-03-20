function Add-CCMGroupMember {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]$GroupName,

        [Parameter()]
        [string[]]$MemberComputerName,

        [Parameter()]
        [string[]]$MemberGroupName
    )
    begin {
        $AllComputers = Get-CCMComputer
        $AllGroups = Get-CCMGroup
    }
    process {
        # Get the group we are modifying
        $Id = Get-CCMGroup -Name $GroupName -ErrorAction Stop | Select-Object -ExpandProperty Id
        $ExistingGroup = Invoke-CCMApi Groups/GetGroupForEdit?Id=$Id
        $ExistingGroup.computers = [System.Collections.ArrayList]$ExistingGroup.computers
        $ExistingGroup.groups = [System.Collections.ArrayList]$ExistingGroup.groups

        # Add missing computers to the group object
        foreach ($Computer in $AllComputers | Where-Object Name -in $MemberComputerName) {
            if ($ExistingGroup.computers.computerId -notcontains $Computer.Id) {
                $null = $ExistingGroup.computers.add(@{computerId = $Computer.Id})
            }
        }

        # Add missing groups to the group object
        foreach ($Group in $AllGroups | Where-Object Name -in $MemberGroupName) {
            if ($ExistingGroup.groups.subGroupId -notcontains $Group.Id) {
                $null = $ExistingGroup.groups.add(@{subGroupId = $Group.Id})
            }
        }

        # "Commit" the changes to the API
        $null = Invoke-CCMApi -Method "POST" -Slug "Groups/CreateOrEdit" -Body $ExistingGroup
    }
}