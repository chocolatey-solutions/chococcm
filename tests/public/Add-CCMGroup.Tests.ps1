param(
    [string]$ModulePath,
    [switch]$Integration
)

BeforeDiscovery {
    Import-Module $ModulePath -Force
}

Describe "Add-CCMGroup" {
    BeforeAll {
        $MockAllGroups = @(
            [PSCustomObject]@{ id = 5; name = 'ExistingSubGroup'; description = '' }
        )
        $MockAllComputers = @(
            [PSCustomObject]@{ id = 42; name = 'TEST-PC-01' }
        )
        $MockNewGroup = [PSCustomObject]@{ id = 99; name = 'NewGroup'; description = '' }

        # Get-CCMGroup is called both to check existence and at the end to output the result.
        # First call (check existence) returns $null (group doesn't exist yet).
        # Subsequent call (output) returns the new group.
        $script:GetCCMGroupCallCount = 0
        Mock Get-CCMGroup -ModuleName ChocoCCM -MockWith {
            $script:GetCCMGroupCallCount++
            if ($script:GetCCMGroupCallCount -eq 1) { $null }
            else { $MockNewGroup }
        }

        Mock Get-CCMComputer -ModuleName ChocoCCM -MockWith { $MockAllComputers }

        Mock Invoke-CCMApi -ModuleName ChocoCCM -MockWith { $null } -ParameterFilter {
            $Slug -eq 'Groups/CreateOrEdit'
        }
    }

    Context "Creating a new group with just a name" -Skip:$Integration {
        BeforeAll {
            $script:GetCCMGroupCallCount = 0
            Add-CCMGroup -GroupName 'NewGroup'
        }

        It "Calls Groups/CreateOrEdit via POST" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Slug -eq 'Groups/CreateOrEdit' -and $Method -eq 'POST'
            }
        }

        It "Passes the group name in the body" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Body.name -eq 'NewGroup'
            }
        }
    }

    Context "Creating a new group with a Description" -Skip:$Integration {
        BeforeAll {
            $script:GetCCMGroupCallCount = 0
            Add-CCMGroup -GroupName 'NewGroup' -Description 'A test group'
        }

        It "Includes the description in the body" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Body.Description -eq 'A test group'
            }
        }
    }

    Context "Creating a group with member computers" -Skip:$Integration {
        BeforeAll {
            $script:GetCCMGroupCallCount = 0
            Add-CCMGroup -GroupName 'NewGroup' -MemberComputer 'TEST-PC-01'
        }

        It "Includes the computer ID in the computers collection" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Body.computers[0].computerId -eq 42
            }
        }
    }

    Context "Group already exists" -Skip:$Integration {
        BeforeAll {
            # Override mock so the group always exists
            Mock Get-CCMGroup -ModuleName ChocoCCM -MockWith { $MockNewGroup }
            $Result = Add-CCMGroup -GroupName 'NewGroup'
        }

        It "Returns the existing group without calling CreateOrEdit" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -Times 0 -ParameterFilter {
                $Slug -eq 'Groups/CreateOrEdit'
            }
        }

        It "Returns the existing group object" {
            $Result.name | Should -Be 'NewGroup'
        }
    }

    Context "Calling real server" -Skip:$(-not $Integration) {}
}
