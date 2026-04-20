param(
    [string]$ModulePath,
    [switch]$Integration
)

BeforeDiscovery {
    Import-Module $ModulePath -Force
}

Describe "Rename-CCMGroup" {
    BeforeAll {
        $MockGroup = [PSCustomObject]@{ id = 7; name = 'OldName'; description = 'A group' }
        $MockRenamedGroup = [PSCustomObject]@{ id = 7; name = 'NewName'; description = 'A group' }

        $script:GetCCMGroupCallCount = 0
        Mock Get-CCMGroup -ModuleName ChocoCCM -MockWith {
            $script:GetCCMGroupCallCount++
            if ($script:GetCCMGroupCallCount -eq 1) { $MockGroup }
            else { $MockRenamedGroup }
        }

        Mock Invoke-CCMApi -ModuleName ChocoCCM -MockWith { $null } -ParameterFilter {
            $Slug -eq 'Groups/CreateOrEdit'
        }
    }

    Context "Renaming an existing group" -Skip:$Integration {
        BeforeAll {
            $script:GetCCMGroupCallCount = 0
            $Result = Rename-CCMGroup -Name 'OldName' -NewName 'NewName'
        }

        It "Fetches the existing group first" {
            Assert-MockCalled Get-CCMGroup -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Name -eq 'OldName'
            }
        }

        It "Calls Groups/CreateOrEdit via POST with the new name" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Slug -eq 'Groups/CreateOrEdit' -and $Method -eq 'POST' -and $Body.name -eq 'NewName'
            }
        }

        It "Fetches the updated group to return it" {
            Assert-MockCalled Get-CCMGroup -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Name -eq 'NewName'
            }
        }

        It "Returns the renamed group" {
            $Result.name | Should -Be 'NewName'
        }
    }

    Context "Group does not exist" -Skip:$Integration {
        BeforeAll {
            Mock Get-CCMGroup -ModuleName ChocoCCM -MockWith {
                throw 'Group not found'
            }
        }

        It "Throws an error" {
            { Rename-CCMGroup -Name 'NonExistent' -NewName 'Whatever' } | Should -Throw
        }
    }

    Context "Calling real server" -Skip:$(-not $Integration) {}
}
