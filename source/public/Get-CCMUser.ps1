#TODO Move to a private function until documented
function Get-CCMUser {
    [CmdletBinding(DefaultParameterSetName="All")]
    param(
        [parameter(ParameterSetName = "Filter", Mandatory)]
        [string]
        $Filter,

        [Parameter(ParameterSetName = 'Role', Mandatory)]
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
                    $Roles = Invoke-CCMApi -Slug "Role/GetRoles" -Method "POST" -Body @{permissions = @()}
                    $Roles.Where({$_.name -eq $Role}, 1).id
                }
            }
        }

        $Result = Invoke-CCMApi @ApiArgs

        switch ($PSCmdlet.ParameterSetName) {
            "All" {
                $Result.items
            }
            "Filter" {
                $Result.items
            }
            "Role"{
                $Result.items
            }
        }
        

    }#end process
}#end function
