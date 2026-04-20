param(
    [string]$ModulePath,
    [switch]$Integration
)

BeforeDiscovery {
    Import-Module $ModulePath -Force
}

Describe "Get-CCMLicenseInfo" {
    BeforeAll {
        # Each slug returns a different value to simulate the real API responses.
        Mock Invoke-CCMApi -ModuleName ChocoCCM -MockWith { 50 } -ParameterFilter {
            $Slug -eq '/Computers/GetComputerCount'
        }

        Mock Invoke-CCMApi -ModuleName ChocoCCM -MockWith { 100 } -ParameterFilter {
            $Slug -eq '/ChocolateyLicenseInformation/GetLicenseCount'
        }

        Mock Invoke-CCMApi -ModuleName ChocoCCM -MockWith { '2027-12-31T00:00:00Z' } -ParameterFilter {
            $Slug -eq '/ChocolateyLicenseInformation/GetLicenseExpiration'
        }

        Mock Invoke-CCMApi -ModuleName ChocoCCM -MockWith { $false } -ParameterFilter {
            $Slug -eq '/ChocolateyLicenseInformation/GetIsTrialLicense'
        }
    }

    Context "Retrieving license info" -Skip:$Integration {
        BeforeAll {
            $Result = Get-CCMLicenseInfo
        }

        It "Retrieves the current computer count" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Slug -eq '/Computers/GetComputerCount'
            }
        }

        It "Retrieves the maximum license count" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Slug -eq '/ChocolateyLicenseInformation/GetLicenseCount'
            }
        }

        It "Retrieves the license expiration" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Slug -eq '/ChocolateyLicenseInformation/GetLicenseExpiration'
            }
        }

        It "Retrieves whether the license is a trial" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Slug -eq '/ChocolateyLicenseInformation/GetIsTrialLicense'
            }
        }

        It "Exposes UsedCount" {
            $Result.UsedCount | Should -Be 50
        }

        It "Exposes MaxCount" {
            $Result.MaxCount | Should -Be 100
        }

        It "Calculates RemainingCount correctly" {
            $Result.RemainingCount | Should -Be 50
        }

        It "Calculates UtilizedPercentage correctly" {
            $Result.UtilizedPercentage | Should -Be 50
        }

        It "Exposes IsTrial" {
            $Result.IsTrial | Should -Be $false
        }
    }

    Context "Calling real server" -Skip:$(-not $Integration) {}
}
