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
        $AllComputers = Get-CCMComputer
        
        $Group = Get-CCMGroup -Name $GroupName
        $Id = $Group.id

        #Get current computers in CCM
        foreach ($m in $MemberComputer) {
            if ($m -in $AllComputers.Name) {
                $X = @{
                    computerId = $AllComputers | Where-Object Name -eq $m | Select-Object -ExpandProperty Id
                }

                $computercollection.add($X)
            }
            else {
                Write-Warning "Computer $m has not checked in to Chocolatey Central Management."
            }
        }

        #Get current groups in CCM
    }#process
}