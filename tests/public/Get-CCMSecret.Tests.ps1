param(
    [string]$ModulePath,
    [switch]$Integration
)

BeforeDiscovery {
    Import-Module $ModulePath -Force
}

Describe "Get-CCMSecret" {
    BeforeAll {
        $MockSecrets = @(
            [PSCustomObject]@{ id = 1; name = 'OfficeLicenseKey'; value = $null }
            [PSCustomObject]@{ id = 2; name = 'AdobeKey';         value = $null }
            [PSCustomObject]@{ id = 3; name = 'OfficeProPlusKey'; value = $null }
        )

        Mock Invoke-CCMApi -ModuleName ChocoCCM -MockWith {
            $MockSecrets
        } -ParameterFilter { $Slug -eq 'SensitiveVariables/GetAll' }
    }

    Context "No Name filter (all secrets)" -Skip:$Integration {
        BeforeAll {
            $Result = Get-CCMSecret
        }

        It "Calls SensitiveVariables/GetAll" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Slug -eq 'SensitiveVariables/GetAll'
            }
        }

        It "Returns all secrets" {
            $Result | Should -HaveCount 3
        }
    }

    Context "Filtering by Name (exact match)" -Skip:$Integration {
        BeforeAll {
            $Result = Get-CCMSecret -Name 'AdobeKey'
        }

        It "Returns only the matching secret" {
            $Result | Should -HaveCount 1
            $Result.name | Should -Be 'AdobeKey'
        }
    }

    Context "Filtering by Name (regex prefix match)" -Skip:$Integration {
        BeforeAll {
            $Result = Get-CCMSecret -Name 'Office'
        }

        It "Returns all secrets whose name starts with the pattern" {
            $Result | Should -HaveCount 2
        }
    }

    Context "Filtering by Name with no match" -Skip:$Integration {
        BeforeAll {
            $Result = Get-CCMSecret -Name 'DoesNotExist'
        }

        It "Returns nothing" {
            $Result | Should -BeNullOrEmpty
        }
    }

    Context "Calling real server" -Skip:$(-not $Integration) {}
}
