param(
    [string]$ModulePath,
    [switch]$Integration
)

BeforeDiscovery {
    Import-Module $ModulePath -Force
}

Describe "Get-CCMGroupMembership" {
    BeforeAll {
        $MockComputer = [PSCustomObject]@{ id = 42; name = 'TEST-PC-01' }
        $MockGroup    = [PSCustomObject]@{ id = 7;  name = 'Lab Computers' }

        $MockMembershipByComputer = @(
            [PSCustomObject]@{ groupName = 'Lab Computers'; groupId = 7 }
        )

        $MockMembershipByGroup = @(
            [PSCustomObject]@{
                computerName = 'TEST-PC-01'
                computerId   = 42
                friendlyName = 'Test PC 1'
                ipAddress    = '10.0.0.1'
            }
        )

        Mock Get-CCMComputer -ModuleName ChocoCCM -MockWith { $MockComputer } -ParameterFilter {
            $ComputerName -eq 'TEST-PC-01'
        }

        Mock Get-CCMGroup -ModuleName ChocoCCM -MockWith { $MockGroup } -ParameterFilter {
            $Name -eq 'Lab Computers'
        }

        Mock Invoke-CCMApi -ModuleName ChocoCCM -MockWith {
            $MockMembershipByComputer
        } -ParameterFilter { $Slug -like '*ComputerGroup/GetAllByComputerId*' }

        Mock Invoke-CCMApi -ModuleName ChocoCCM -MockWith {
            $MockMembershipByGroup
        } -ParameterFilter { $Slug -like '*ComputerGroup/GetAllByGroupId*' }
    }

    Context "By ComputerName" -Skip:$Integration {
        BeforeAll {
            $Result = Get-CCMGroupMembership -ComputerName 'TEST-PC-01'
        }

        It "Resolves the computer ID via Get-CCMComputer" {
            Assert-MockCalled Get-CCMComputer -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $ComputerName -eq 'TEST-PC-01'
            }
        }

        It "Calls ComputerGroup/GetAllByComputerId with the resolved ID" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Slug -like '*ComputerGroup/GetAllByComputerId?computerId=42'
            }
        }

        It "Returns groupName and groupId properties" {
            $Result[0].groupName | Should -Be 'Lab Computers'
            $Result[0].groupId   | Should -Be 7
        }
    }

    Context "By GroupName" -Skip:$Integration {
        BeforeAll {
            $Result = Get-CCMGroupMembership -GroupName 'Lab Computers'
        }

        It "Resolves the group ID via Get-CCMGroup" {
            Assert-MockCalled Get-CCMGroup -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Name -eq 'Lab Computers'
            }
        }

        It "Calls ComputerGroup/GetAllByGroupId with the resolved ID" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Slug -like '*ComputerGroup/GetAllByGroupId?groupId=7'
            }
        }

        It "Returns computerName and computerId properties" {
            $Result[0].computerName | Should -Be 'TEST-PC-01'
            $Result[0].computerId   | Should -Be 42
        }
    }

    Context "Calling real server" -Skip:$(-not $Integration) {}
}
