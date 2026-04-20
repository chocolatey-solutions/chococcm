param(
    [string]$ModulePath,
    [switch]$Integration
)

BeforeDiscovery {
    Import-Module $ModulePath -Force
}

Describe "Get-CCMRole" {
    BeforeAll {
        $MockRoles = @(
            [PSCustomObject]@{ id = 1; name = 'CCM Admin' }
            [PSCustomObject]@{ id = 2; name = 'CCM User' }
        )

        Mock Invoke-CCMApi -ModuleName ChocoCCM -MockWith {
            $MockRoles
        } -ParameterFilter { $Slug -eq 'Role/GetRoles' }
    }

    Context "No permissions filter" -Skip:$Integration {
        BeforeAll {
            $Result = Get-CCMRole
        }

        It "Calls Role/GetRoles via POST" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Slug -eq 'Role/GetRoles' -and $Method -eq 'POST'
            }
        }

        It "Passes an empty permissions array by default" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Body.permissions.Count -eq 0
            }
        }

        It "Returns the roles" {
            $Result | Should -HaveCount 2
        }
    }

    Context "With a Permissions filter" -Skip:$Integration {
        BeforeAll {
            Get-CCMRole -Permissions 'Pages.Computers'
        }

        It "Includes the permission in the body" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Body.permissions -contains 'Pages.Computers'
            }
        }
    }

    Context "Calling real server" -Skip:$(-not $Integration) {}
}
