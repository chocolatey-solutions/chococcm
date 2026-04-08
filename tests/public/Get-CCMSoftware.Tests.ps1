param(
    [string]$ModulePath,
    [switch]$Integration
)

BeforeDiscovery {
    Import-Module $ModulePath -Force
}

Describe "Get-CCMSoftware" {
    BeforeAll {
        $MockSoftwareList = @(
            [PSCustomObject]@{ id = 1; name = 'Firefox'; packageId = 'firefox'; packageVersion = '120.0' }
            [PSCustomObject]@{ id = 2; name = 'VLC';     packageId = 'vlc';     packageVersion = '3.0.18' }
        )

        $MockFilteredResult = [PSCustomObject]@{
            items = @($MockSoftwareList[0])
        }

        Mock Invoke-CCMApi -ModuleName ChocoCCM -MockWith {
            $MockSoftwareList
        } -ParameterFilter { $Slug -eq '/Software/GetAllWithoutFilter' }

        Mock Invoke-CCMApi -ModuleName ChocoCCM -MockWith {
            $MockFilteredResult
        } -ParameterFilter { $Slug -like '/Software/GetAll?Filter=*' }
    }

    Context "No filter" -Skip:$Integration {
        BeforeAll {
            $Result = Get-CCMSoftware
        }

        It "Calls Software/GetAllWithoutFilter" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Slug -eq '/Software/GetAllWithoutFilter'
            }
        }

        It "Does not call the filtered endpoint" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -Times 0 -ParameterFilter {
                $Slug -like '/Software/GetAll?Filter=*'
            }
        }

        It "Returns all software" {
            $Result | Should -HaveCount 2
        }
    }

    Context "With a Filter" -Skip:$Integration {
        BeforeAll {
            $Result = Get-CCMSoftware -Filter 'Firefox'
        }

        It "Calls the filtered endpoint with the URL-encoded filter" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Slug -like '/Software/GetAll?Filter=Firefox'
            }
        }

        It "Does not call GetAllWithoutFilter" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -Times 0 -ParameterFilter {
                $Slug -eq '/Software/GetAllWithoutFilter'
            }
        }

        It "Returns the items from the paged result" {
            $Result | Should -HaveCount 1
            $Result[0].name | Should -Be 'Firefox'
        }
    }

    Context "Calling real server" -Skip:$(-not $Integration) {}
}
