function Add-CCMGroupMember {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String]
        $GroupName,

        [Parameter()]
        [String[]]
        $MemberComputer,
        
        [Parameter()]
        [String[]]
        $MemberGroup
    )
    begin {
        $computercollection = [System.Collections.Generic.List[hashtable]]::new()
        $groupcollection = [System.Collections.Generic.List[hashtable]]::new()
    }
    process {
        <# THIS IS NOT CORRECT, DO NOT TRUST IT #>
        # We should reimplement this as an actual "add" method using the Groups/GetGroupForEdit?Id=$Id call.

        $AllComputers = Get-CCMComputer
        $AllGroups = Get-CCMGroup
        

        try {
            #Get the ID of $GroupName we are passing to edit
            $Id = Get-CCMGroup -Name $GroupName -ErrorAction Stop | Select-Object -ExpandProperty Id
            $existingdata = Invoke-CCMApi Groups/GetGroupForEdit?Id=$Id
        }
        catch {
            throw "Group $GroupName does not exist! Please use Add-CCMGroup instead."
        }

        #Put existing computers into computer collection
        foreach ($c in $existingdata.Computers) {
            $X = @{
                computerId = $c.computerId
            }

            $computercollection.add($X)
        }

        #Get current computers in CCM
        foreach ($m in $MemberComputer) {
            if ($m -in $AllComputers.Name) {
                $X = @{
                    computerId = $AllComputers | Where-Object Name -eq $m | Select-Object -ExpandProperty Id
                }

            if ($computercollection.computerId -notcontains $X.computerId){$computercollection.add($X)}
            }
            else {
                Write-Warning "Computer $m has not checked in to Chocolatey Central Management."
            }
        }

        #Put exisitng groups into groups collection
        foreach ($g in $existingdata.Groups) {
            $X = @{
                subGroupId = $g.subGroupId
            }

            $groupcollection.add($X)
        }

        #Get current groups in CCM
        foreach ($g in $MemberGroup) {
            if ($g -in $AllGroups.Name) {
                $X = @{
                    subGroupId = $AllGroups | Where-Object Name -eq $g | Select-Object -ExpandProperty Id
                }

                $groupcollection.add($X)
            if ($groupcollection.subGroupId -notcontains $X.subGroupId){$groupcollection.add($X)}
            }
            else {
                Write-Warning "Group $g does not exist within Chocolatey Central Management."
            }
        }

        #Generate Body to send to API
        $body = [PSCustomObject]@{
            name = $GroupName
            id = $Id
            groups = $groupcollection
            computers = $computercollection
        }

        $null = Invoke-CCMApi -Method "POST" -Slug "Groups/CreateOrEdit" -Body $body
    }#process
}