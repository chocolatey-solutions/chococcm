param(
    [string]$ModulePath,
    [switch]$Integration
)

BeforeDiscovery {
    Import-Module $ModulePath -Force
}

Describe "Get-CCMFact" {
    BeforeAll {
        $MockComputerList = @(
            [PSCustomObject]@{ id = 1; name = 'TEST-PC-01' }
            [PSCustomObject]@{ id = 2; name = 'SERVER-02' }
        )

        # ComputerFacts is a class defined in the module.
        # The mock returns a hashtable that can be cast to [ComputerFacts].
        $MockFactsResult = @{
            computerId        = 1
            computerName      = ''
            reportDateTimeUtc = [datetime]'2026-01-01'
            categories        = @()
            id                = 'facts-abc'
        }

        Mock Get-CCMComputer -ModuleName ChocoCCM -MockWith {
            $MockComputerList
        }

        Mock Invoke-CCMApi -ModuleName ChocoCCM -MockWith {
            [PSCustomObject]$MockFactsResult
        } -ParameterFilter { $Slug -like '*GetFactsByComputerId*' }
    }

    Context "No computer filter (all computers)" -Skip:$Integration {
        BeforeAll {
            $Result = Get-CCMFact
        }

        It "Retrieves the full computer list" {
            Assert-MockCalled Get-CCMComputer -ModuleName ChocoCCM -Scope Context
        }

        It "Calls GetFactsByComputerId for each computer" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -Times 2 -ParameterFilter {
                $Slug -like '*GetFactsByComputerId*'
            }
        }

        It "Returns one result per computer" {
            $Result | Should -HaveCount 2
        }
    }

    Context "Filtering by single computer name" -Skip:$Integration {
        BeforeAll {
            $Result = Get-CCMFact -Computername 'TEST-PC-01'
        }

        It "Only calls GetFactsByComputerId once" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -Times 1 -ParameterFilter {
                $Slug -like '*GetFactsByComputerId*'
            }
        }

        It "Calls the endpoint with the correct computer ID" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Slug -like '*ComputerId=1*'
            }
        }
    }

    Context "Filtering by multiple computer names" -Skip:$Integration {
        BeforeAll {
            $Result = Get-CCMFact -Computername 'TEST-PC-01', 'SERVER-02'
        }

        It "Calls the endpoint once per matched computer" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -Times 2 -ParameterFilter {
                $Slug -like '*GetFactsByComputerId*'
            }
        }
    }

    Context "Passing ExcludeCategory" -Skip:$Integration {
        BeforeAll {
            Get-CCMFact -Computername 'TEST-PC-01' -ExcludeCategory 'Network'
        }

        It "Includes ExcludeCategories in the query string" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Slug -like '*ExcludeCategories*'
            }
        }
    }

    Context "Passing ExcludeFactGroup" -Skip:$Integration {
        BeforeAll {
            Get-CCMFact -Computername 'TEST-PC-01' -ExcludeFactGroup 'Chocolatey'
        }

        It "Includes ExcludeFactGroups in the query string" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Slug -like '*ExcludeFactGroups*'
            }
        }
    }

    Context "Calling real server" -Skip:$(-not $Integration) {}
}
