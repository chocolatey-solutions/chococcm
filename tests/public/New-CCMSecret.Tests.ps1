param(
    [string]$ModulePath,
    [switch]$Integration
)

BeforeDiscovery {
    Import-Module $ModulePath -Force
}

Describe "New-CCMSecret" {
    BeforeAll {
        # The ValidateScript in New-CCMSecret calls Get-CCMSecret to check for name conflicts.
        # Mock it to return $null (no conflict) by default.
        Mock Get-CCMSecret -ModuleName ChocoCCM -MockWith { $null }

        Mock Invoke-CCMApi -ModuleName ChocoCCM -MockWith { $null } -ParameterFilter {
            $Slug -eq 'SensitiveVariables/Create'
        }
    }

    Context "Creating a new secret" -Skip:$Integration {
        BeforeAll {
            New-CCMSecret -Name 'MyApiKey' -Value 'super-secret-value'
        }

        It "Calls SensitiveVariables/Create via POST" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Slug -eq 'SensitiveVariables/Create' -and $Method -eq 'POST'
            }
        }

        It "Passes the Name in the body" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Body.Name -eq 'MyApiKey'
            }
        }

        It "Passes the Value in the body" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Body.Value -eq 'super-secret-value'
            }
        }
    }

    Context "Creating a secret whose name already exists" -Skip:$Integration {
        BeforeAll {
            Mock Get-CCMSecret -ModuleName ChocoCCM -MockWith {
                [PSCustomObject]@{ id = 1; name = 'ExistingSecret' }
            }
        }

        It "Throws a validation error" {
            { New-CCMSecret -Name 'ExistingSecret' -Value 'value' } | Should -Throw
        }
    }

    Context "Calling real server" -Skip:$(-not $Integration) {}
}
