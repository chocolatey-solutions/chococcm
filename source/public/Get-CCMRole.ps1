function Get-CCMRole {
    [CmdletBinding()]
    param(
        [string[]]$Permissions = @()
    )
    end {
        Invoke-CCMApi -Slug "Role/GetRoles" -Method "POST" -Body @{
            permissions = $Permissions
        }
    }
}