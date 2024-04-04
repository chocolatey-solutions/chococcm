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

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [String]
        $NewName
    )

    process {
        # Check if a group already exists?
        try {
            $Group = Get-CCMGroup -Name $Name -ErrorAction Stop
            $Group.name = $NewName

            $null = Invoke-CCMApi -Slug "Groups/CreateOrEdit" -Body $Group -Method "POST" -ErrorAction Stop

            # Output the group!
            Get-CCMGroup -Name $NewName
        }
        catch {
            throw "Could not rename Group $Name"
        }
    }
} 