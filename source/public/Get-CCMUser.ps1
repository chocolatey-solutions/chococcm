#TODO Move to a private function until documented
function Get-CCMUser {
    [CmdletBinding(DefaultParameterSetName="All")]
    param(
        [parameter(ParameterSetName = "Filter", Mandatory)]
        [string]
        $Filter,

        [Parameter(ParameterSetName = 'Role', Mandatory)]
        [ArgumentCompleter({
            (Get-CCMRole).ForEach{
                $_.id
            }
        })]
        [string]
        $Role
    )
    
    process{
        $APIArgs = @{
            Slug   = "/api/services/app/User/GetUsers"
            Method = "POST"
            Body   = @{
                Filter = ""
            }
        }

        if ($Filter) {
            $ApiArgs.Body.Filter = $Filter
        }

        if ($Role) {
            $ApiArgs.Body = @{
                Role = if ($Role -as [int]) {
                    $Role
                } else {
                    (Get-CCMRole).Where({$_.name -eq $Role}, 1).id
                }
            }
        }

        (Invoke-CCMApi @ApiArgs).items
    }#end process
}#end function
