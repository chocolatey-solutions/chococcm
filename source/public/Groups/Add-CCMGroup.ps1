function Add-CCMGroup {
    <#
        .Synopsis
            Creates a new group in CCM

        .Example
            Add-CCMGroup 'TestGroup'
            # Add a new group called TestGroup

        .Example
            Add-CCMGroup -GroupName 'TestGroup' -Description 'This is a test group, for testing!'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String]
        $GroupName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [String]
        $Description,

        [Parameter()]
        [ArgumentCompleter({
                param($a1, $a2, $MatchParam, $a4, $a5)
            (Get-CCMComputer).Where{ $_.name -like "*$MatchParam*" }.ForEach{
                    [System.Management.Automation.CompletionResult]::new(
                        $_.name,
                        $_.name,
                        'ParameterValue',
                        $(if ($_.friendlyName) { $_.friendlyName } else { $_.displayName })
                    )
                }
            })]
        [String[]]
        $MemberComputer,
        
        [Parameter()]
        [String[]]
        $MemberGroup
    )

    process {
        # Check if a group already exists?
        if ($Group = Get-CCMGroup -Name $GroupName -ErrorAction SilentlyContinue) {
            return $Group
        }
        # If it does exist, do we want to update values or just exit?
        # If it doesn't exist, create it!
        $GroupArgs = @{
            name = $GroupName
        }

        if ($Description) {
            $GroupArgs.Description = $Description
        }

        if ($MemberGroup) {
            $GroupArgs.groups = @(
                foreach ($Group in Get-CCMGroup -Name $MemberGroup) {
                    @{
                        subGroupId = $Group.id
                    }
                }
            )
        }

        if ($MemberComputer) {
            $GroupArgs.computers = @(
                foreach ($Computer in Get-CCMComputer | Where-Object name -in $MemberComputer) {
                    @{
                        computerId = $Computer.id
                    }
                }
            )
        }

        try {
            $null = Invoke-CCMApi -Slug "Groups/CreateOrEdit" -Body $GroupArgs -Method "POST"
        }
        catch {
            throw
        }

        # Output the group!
        Get-CCMGroup -Name $GroupName
    }
}
