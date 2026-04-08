param(
    [string]$ModulePath,
    [switch]$Integration
)

BeforeDiscovery {
    Import-Module $ModulePath -Force
}

Describe "Get-CCMComputer" {
    BeforeAll {
        $MockComputerList = @(
            [PSCustomObject]@{
                id                                      = 42
                name                                    = 'TEST-PC-01'
                computerGuid                            = 'a1b2c3d4-0000-0000-0000-000000000001'
                friendlyName                            = 'Test PC 1'
                displayName                             = 'TestPC'
                ipAddress                               = '10.0.0.1'
                fqdn                                    = 'test-pc-01.domain.local'
                lastCheckinDateTime                     = '2026-01-01T00:00:00Z'
                creationTime                            = '2025-01-01T00:00:00Z'
                ccmServiceName                          = 'chocolatey-agent'
                availableForDeploymentsBasedOnLicenseCount = $true
                optedIntoDeploymentsBasedOnConfig       = $true
            }
            [PSCustomObject]@{
                id                                      = 99
                name                                    = 'SERVER-02'
                computerGuid                            = 'a1b2c3d4-0000-0000-0000-000000000002'
                friendlyName                            = 'Server 02'
                displayName                             = 'Server02'
                ipAddress                               = '10.0.0.2'
                fqdn                                    = 'server-02.domain.local'
                lastCheckinDateTime                     = '2026-01-02T00:00:00Z'
                creationTime                            = '2025-01-02T00:00:00Z'
                ccmServiceName                          = 'chocolatey-agent'
                availableForDeploymentsBasedOnLicenseCount = $true
                optedIntoDeploymentsBasedOnConfig       = $true
            }
        )

        Mock Invoke-CCMApi -ModuleName ChocoCCM -MockWith {
            $MockComputerList
        } -ParameterFilter { $Slug -eq 'Computers/GetAll' }

        Mock Invoke-CCMApi -ModuleName ChocoCCM -MockWith {
            $MockComputerList[0]
        } -ParameterFilter { $Slug -like 'Computers/GetComputerForView*' }
    }

    Context "Default parameter set (all computers)" -Skip:$Integration {
        BeforeAll {
            $Result = Get-CCMComputer
        }

        It "Calls Computers/GetAll" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Slug -eq 'Computers/GetAll'
            }
        }

        It "Returns all computers" {
            $Result | Should -HaveCount 2
        }

        It "Does not call GetComputerForView" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -Times 0 -ParameterFilter {
                $Slug -like 'Computers/GetComputerForView*'
            }
        }
    }

    Context "Name parameter set" -Skip:$Integration {
        BeforeAll {
            $Result = Get-CCMComputer -ComputerName 'TEST-PC-01'
        }

        It "Calls Computers/GetAll to resolve the ID" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Slug -eq 'Computers/GetAll'
            }
        }

        It "Calls GetComputerForView with the resolved ID" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Slug -like 'Computers/GetComputerForView?id=42'
            }
        }

        It "Returns computer properties including Name" {
            $Result.Name | Should -Be 'TEST-PC-01'
        }
    }

    Context "Name parameter set with -Detailed" -Skip:$Integration {
        BeforeAll {
            $Result = Get-CCMComputer -ComputerName 'TEST-PC-01' -Detailed
        }

        It "Returns the raw ComputerMetaData object" {
            # Detailed skips Select-Object projection, so AvailableForDeployments is present
            $Result.availableForDeploymentsBasedOnLicenseCount | Should -Be $true
        }
    }

    Context "Calling real server" -Skip:$(-not $Integration) {}
}
