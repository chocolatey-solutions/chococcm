param(
    [string]$ModulePath,
    [switch]$Integration
)

BeforeDiscovery {
    Import-Module $ModulePath -Force
}

Describe "Get-CCMComputerSoftware" {
    BeforeAll {
        $MockComputer = [PSCustomObject]@{ id = 42; name = 'TEST-PC-01' }

        $MockSoftwareList = @(
            [PSCustomObject]@{
                id        = 10
                name      = 'Firefox'
                packageId = 'firefox'
                packageVersion = '120.0'
                isOutdated = $false
            }
            [PSCustomObject]@{
                id        = 11
                name      = 'VLC media player'
                packageId = 'vlc'
                packageVersion = '3.0.18'
                isOutdated = $false
            }
        )

        $MockComputerSoftware = @(
            [PSCustomObject]@{ computerId = 42; softwareId = 10; id = 1 }
        )

        Mock Get-CCMComputer -ModuleName ChocoCCM -MockWith { $MockComputer }
        Mock Get-CCMSoftware -ModuleName ChocoCCM -MockWith { $MockSoftwareList }

        Mock Invoke-CCMApi -ModuleName ChocoCCM -MockWith {
            $MockComputerSoftware
        } -ParameterFilter { $Slug -like '*ComputerSoftware/GetAllByComputerId*' }

        Mock Invoke-CCMApi -ModuleName ChocoCCM -MockWith {
            $MockComputerSoftware
        } -ParameterFilter { $Slug -like '*ComputerSoftware/GetAllBySoftwareId*' }
    }

    Context "By ComputerName" -Skip:$Integration {
        BeforeAll {
            Get-CCMComputerSoftware -ComputerName 'TEST-PC-01'
        }

        It "Resolves the computer via Get-CCMComputer" {
            Assert-MockCalled Get-CCMComputer -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $ComputerName -eq 'TEST-PC-01'
            }
        }

        It "Calls ComputerSoftware/GetAllByComputerId with the resolved ID" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Slug -like '*ComputerSoftware/GetAllByComputerId?computerId=42'
            }
        }
    }

    Context "By SoftwareName" -Skip:$Integration {
        BeforeAll {
            Get-CCMComputerSoftware -SoftwareName 'Firefox'
        }

        It "Retrieves the full software list" {
            Assert-MockCalled Get-CCMSoftware -ModuleName ChocoCCM -Scope Context
        }

        It "Calls ComputerSoftware/GetAllBySoftwareId for the matched software" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Slug -like '*ComputerSoftware/GetAllBySoftwareId?softwareId=10'
            }
        }
    }

    Context "By PackageId" -Skip:$Integration {
        BeforeAll {
            Get-CCMComputerSoftware -PackageId 'vlc'
        }

        It "Retrieves the full software list" {
            Assert-MockCalled Get-CCMSoftware -ModuleName ChocoCCM -Scope Context
        }

        It "Calls ComputerSoftware/GetAllBySoftwareId for the matched package" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Slug -like '*ComputerSoftware/GetAllBySoftwareId?softwareId=11'
            }
        }
    }

    Context "Calling real server" -Skip:$(-not $Integration) {}
}
