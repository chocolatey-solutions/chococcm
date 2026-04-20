param(
    [string]$ModulePath,
    [switch]$Integration
)

BeforeDiscovery {
    Import-Module $ModulePath -Force
}

Describe "Get-CCMDeploymentPlan" {
    BeforeAll {
        $MockDeployments = @(
            [PSCustomObject]@{
                id                  = 1
                name                = 'Upgrade Firefox'
                isArchived          = $false
                result              = 'Success'
                finishDateTimeUtc   = '2026-01-01T12:00:00Z'
                cancelledDateTimeUtc = $null
            }
            [PSCustomObject]@{
                id                  = 2
                name                = 'Install VLC'
                isArchived          = $false
                result              = 'Active'
                finishDateTimeUtc   = $null
                cancelledDateTimeUtc = $null
            }
            [PSCustomObject]@{
                id                  = 3
                name                = 'Old Deployment'
                isArchived          = $true
                result              = 'Success'
                finishDateTimeUtc   = '2025-06-01T12:00:00Z'
                cancelledDateTimeUtc = $null
            }
        )

        Mock Invoke-CCMApi -ModuleName ChocoCCM -MockWith {
            [PSCustomObject]@{ items = $MockDeployments }
        } -ParameterFilter { $Slug -like '*DeploymentPlans/GetAllPaged*' }
    }

    Context "No parameters" -Skip:$Integration {
        BeforeAll {
            $Result = Get-CCMDeploymentPlan
        }

        It "Calls DeploymentPlans/GetAllPaged" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Slug -like '*DeploymentPlans/GetAllPaged*'
            }
        }

        It "Returns the items array from the paged result" {
            $Result | Should -HaveCount 3
        }
    }

    Context "With a Filter" -Skip:$Integration {
        BeforeAll {
            $Result = Get-CCMDeploymentPlan -Filter 'Firefox'
        }

        It "Includes the Filter in the query string" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $QueryParameters -and $QueryParameters['Filter'] -eq 'Firefox'
            }
        }
    }

    Context "With IsArchived switch" -Skip:$Integration {
        BeforeAll {
            $Result = Get-CCMDeploymentPlan -IsArchived
        }

        It "Includes IsArchived in the query string" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $QueryParameters -and $QueryParameters.ContainsKey('IsArchived')
            }
        }
    }

    Context "Calling real server" -Skip:$(-not $Integration) {}
}
