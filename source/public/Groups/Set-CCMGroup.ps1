# Do groups and computers of the group specified. As well as edit description.

function Rename-CCMGroup {
    <#
    .SYNOPSIS
    Rename specific CCM group.
    
    .DESCRIPTION
    Rename a CCM group that you input.
    
    .PARAMETER Name
    Name of the CCM group you want to edit.
    
    .PARAMETER NewName
    New name for the CCM group you are editing.
    
    .EXAMPLE
    Rename-CCMGroup -Name ComputerLab -NewName "Upstairs Computer Lab"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String]
        $Name,

        [Parameter(ValueFromPipelineByPropertyName)]
        [String]
        $Description,

        [Parameter]
        [String[]]
        $Computer,

        [Parameter]
        [String[]]
        $Group      
    )

    process {
        # Check if a group already exists?
        try {
            $Group = Get-CCMGroup -Name $Name -ErrorAction Stop
            if($Description){
                $Group.description = $Description
            }
            if($Computer){
               #Make empty collection
               #foreach loop over group.computers
               #if thing in loop is in object already, add it to the collection
            }
            if($Group){
                #Make empty collection
               #foreach loop over group.groups
               #if thing in loop is in object already, add it to the collection
            }
            $null = Invoke-CCMApi -Slug "Groups/CreateOrEdit" -Body $Group -Method "POST" -ErrorAction Stop

            # Output the group!
            Get-CCMGroup -Name $Name
        }
        catch {
            throw "Could not rename Group $Name"
        }
    }


}