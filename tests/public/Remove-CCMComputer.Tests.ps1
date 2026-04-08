param(
    [string]$ModulePath,
    [switch]$Integration
)

BeforeDiscovery {
    Import-Module $ModulePath -Force
}

Describe "Remove-CCMComputer" {
    BeforeAll {
        $MockComputerDetailed = [PSCustomObject]@{
            id           = 42
            name         = 'TEST-PC-01'
            computerGuid = 'a1b2c3d4-0000-0000-0000-000000000001'
        }

        Mock Get-CCMComputer -ModuleName ChocoCCM -MockWith {
            $MockComputerDetailed
        }

        Mock Invoke-CCMApi -ModuleName ChocoCCM -MockWith { $null }
    }

    Context "Removing a computer (confirm suppressed)" -Skip:$Integration {
        BeforeAll {
            Remove-CCMComputer -Name 'TEST-PC-01' -Confirm:$false
        }

        It "Resolves the computer ID via Get-CCMComputer" {
            Assert-MockCalled Get-CCMComputer -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $ComputerName -eq 'TEST-PC-01' -and $Detailed -eq $true
            }
        }

        It "Calls DELETE on Computers/Delete with the correct ID" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Method -eq 'DELETE' -and $Slug -like '*Computers/Delete*42*'
            }
        }
    }

    Context "Removing multiple computers" -Skip:$Integration {
        BeforeAll {
            Remove-CCMComputer -Name 'TEST-PC-01', 'TEST-PC-01' -Confirm:$false
        }

        It "Calls Get-CCMComputer once per computer name" {
            Assert-MockCalled Get-CCMComputer -ModuleName ChocoCCM -Scope Context -Times 2
        }

        It "Calls DELETE once per computer" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -Times 2 -ParameterFilter {
                $Method -eq 'DELETE'
            }
        }
    }

    Context "Calling real server" -Skip:$(-not $Integration) {}
}
