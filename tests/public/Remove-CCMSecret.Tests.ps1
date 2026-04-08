param(
    [string]$ModulePath,
    [switch]$Integration
)

BeforeDiscovery {
    Import-Module $ModulePath -Force
}

Describe "Remove-CCMSecret" {
    BeforeAll {
        $MockSecret = [PSCustomObject]@{ id = 5; name = 'OldApiKey' }

        Mock Get-CCMSecret -ModuleName ChocoCCM -MockWith { $MockSecret } -ParameterFilter {
            $Name -eq 'OldApiKey'
        }

        Mock Get-CCMSecret -ModuleName ChocoCCM -MockWith { $null } -ParameterFilter {
            $Name -eq 'DoesNotExist'
        }

        Mock Invoke-CCMApi -ModuleName ChocoCCM -MockWith { $null } -ParameterFilter {
            $Slug -like '*SensitiveVariables/Delete*'
        }
    }

    Context "Removing an existing secret (confirm suppressed)" -Skip:$Integration {
        BeforeAll {
            Remove-CCMSecret -Name 'OldApiKey' -Confirm:$false
        }

        It "Looks up the secret by name first" {
            Assert-MockCalled Get-CCMSecret -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Name -eq 'OldApiKey'
            }
        }

        It "Calls DELETE on SensitiveVariables/Delete with the correct ID" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Method -eq 'Delete' -and $Slug -like '*SensitiveVariables/Delete?id=5'
            }
        }
    }

    Context "Removing a secret that does not exist" -Skip:$Integration {
        It "Throws an error" {
            { Remove-CCMSecret -Name 'DoesNotExist' -Confirm:$false } | Should -Throw "Secret DoesNotExist does not exist"
        }
    }

    Context "Calling real server" -Skip:$(-not $Integration) {}
}
