param(
    [string]$ModulePath,
    [switch]$Integration
)

BeforeDiscovery {
    Import-Module $ModulePath -Force
}

Describe "Get-CCMAuditLogs" {
    BeforeAll {
        $MockAuditLogs = @(
            [PSCustomObject]@{
                id              = 1
                userName        = 'admin'
                serviceName     = 'ComputerAppService'
                methodName      = 'GetAll'
                executionDuration = 120
                browserInfo     = 'Chrome'
                hasException    = $false
                creationTime    = '2026-01-01T00:00:00Z'
            }
        )

        Mock Invoke-CCMApi -ModuleName ChocoCCM -MockWith {
            $MockAuditLogs
        }
    }

    Context "Calling with no parameters" -Skip:$Integration {
        BeforeAll {
            Get-CCMAuditLogs
        }

        It "Calls the AuditLog endpoint" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Slug -eq '/AuditLog/GetAuditLogs'
            }
        }

        It "Sends an empty body" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Body.Count -eq 0
            }
        }
    }

    Context "Filtering by UserName" -Skip:$Integration {
        BeforeAll {
            Get-CCMAuditLogs -UserName 'admin'
        }

        It "Calls the AuditLog endpoint" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Slug -eq '/AuditLog/GetAuditLogs'
            }
        }

        It "Includes UserName in the body" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Body.UserName -eq 'admin'
            }
        }
    }

    Context "Filtering by ServiceName alias" -Skip:$Integration {
        BeforeAll {
            Get-CCMAuditLogs -Service 'ComputerAppService'
        }

        It "Includes ServiceName in the body" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Body.ServiceName -eq 'ComputerAppService'
            }
        }
    }

    Context "Filtering by HasException" -Skip:$Integration {
        BeforeAll {
            Get-CCMAuditLogs -HasException
        }

        It "Includes HasException in the body" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Body.HasException -eq $true
            }
        }
    }

    Context "Calling real server" -Skip:$(-not $Integration) {}
}
