param(
    [string]$ModulePath,
    [switch]$Integration
)

BeforeDiscovery {
    Import-Module $ModulePath -Force
}

Describe "Remove-CCMGroup" {
    BeforeAll {
        $MockGroup = [PSCustomObject]@{ id = 7; name = 'OldGroup'; description = 'To be removed' }

        Mock Invoke-CCMApi -ModuleName ChocoCCM -MockWith {
            @($MockGroup)
        } -ParameterFilter { $Slug -eq 'Groups/GetAll' }

        Mock Invoke-CCMApi -ModuleName ChocoCCM -MockWith { $null } -ParameterFilter {
            $Slug -like 'Groups/Delete*'
        }
    }

    Context "Removing by Id (confirm suppressed)" -Skip:$Integration {
        BeforeAll {
            Remove-CCMGroup -Id 7 -Confirm:$false
        }

        It "Calls DELETE on Groups/Delete with the correct ID" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Method -eq 'DELETE' -and $Slug -like 'Groups/Delete?id=7'
            }
        }
    }

    Context "Removing by Name (confirm suppressed)" -Skip:$Integration {
        BeforeAll {
            Remove-CCMGroup -Name 'OldGroup' -Confirm:$false
        }

        It "Resolves the group ID via Groups/GetAll" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Slug -eq 'Groups/GetAll'
            }
        }

        It "Calls DELETE on Groups/Delete with the resolved ID" {
            Assert-MockCalled Invoke-CCMApi -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Method -eq 'DELETE' -and $Slug -like 'Groups/Delete?id=7'
            }
        }
    }

    Context "Calling real server" -Skip:$(-not $Integration) {}
}
