param(
    [string]$ModulePath,
    [switch]$Integration
)

BeforeDiscovery {
    Import-Module $ModulePath -Force
}

Describe "Get-CCMGroup" {
    BeforeAll {
        $MockGroups = @(
            [PSCustomObject]@{ id = 1; name = 'Lab Computers'; description = 'All lab machines' }
            [PSCustomObject]@{ id = 2; name = 'Servers';       description = 'Production servers' }
            [PSCustomObject]@{ id = 3; name = 'Dev Machines';  description = 'Developer workstations' }
        )

        Mock Invoke-CCMApi -ModuleName ChocoCCM -MockWith {
            $MockGroups
        } -ParameterFilter { $Slug -eq 'Groups/GetAll' }
    }

    Context "Default (all groups)" -Skip:$Integration {
        BeforeAll {
            $Result = Get-CCMGroup
        }

        It "Calls Groups/GetAll" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Slug -eq 'Groups/GetAll'
            }
        }

        It "Returns all groups" {
            $Result | Should -HaveCount 3
        }
    }

    Context "Filtering by single Name" -Skip:$Integration {
        BeforeAll {
            $Result = Get-CCMGroup -Name 'Servers'
        }

        It "Calls Groups/GetAll" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Slug -eq 'Groups/GetAll'
            }
        }

        It "Returns only the matching group" {
            $Result | Should -HaveCount 1
            $Result.name | Should -Be 'Servers'
        }
    }

    Context "Filtering by multiple Names" -Skip:$Integration {
        BeforeAll {
            $Result = Get-CCMGroup -Name 'Servers', 'Lab Computers'
        }

        It "Returns two groups" {
            $Result | Should -HaveCount 2
        }
    }

    Context "Filtering by Id" -Skip:$Integration {
        BeforeAll {
            $Result = Get-CCMGroup -Id 2
        }

        It "Returns only the group with the matching Id" {
            $Result | Should -HaveCount 1
            $Result.id | Should -Be 2
        }
    }

    Context "Filtering by a Name that does not exist" -Skip:$Integration {
        It "Writes an error when no match is found" {
            { Get-CCMGroup -Name 'DoesNotExist' -ErrorAction Stop } | Should -Throw
        }
    }

    Context "Calling real server" -Skip:$(-not $Integration) {}
}
