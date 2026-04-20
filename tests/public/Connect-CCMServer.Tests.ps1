param(
    [string]$ModulePath,
    [switch]$Integration
)
BeforeDiscovery {
    Import-Module $ModulePath -Force
}
Describe "Connect-CCMServer" {
    BeforeAll {
        Mock Invoke-WebRequest -ModuleName ChocoCCM -MockWith {
            if ($SessionVariable -eq "Session") {
                $script:Session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
            }
        }
    }

    Context "Connecting to a HTTP server" -Skip:$Integration {
        BeforeAll {
            $Values = @{
                Hostname = "test.local"
                Credential = [PSCredential]::new(
                    "testuser",
                    (ConvertTo-SecureString "testpass" -Force -AsPlainText)
                )
            }
            Connect-CCMServer @Values
        }
    # Uri we're calling:
        # If the UseSSL isn't passed, it should use http rather than https
        It "Uses HTTP if UseSSL isn't present" {
            Assert-MockCalled Invoke-WebRequest -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Uri.ToString().StartsWith('http://')
            }
        }
        # the hostname being passed to the Invoke-WebRequest matches our hostname
        It "Calls the right HostName" {
            Assert-MockCalled Invoke-WebRequest -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                ([uri]$Uri).Host -eq $values.Hostname
            }
        }
        # We're calling /Account/Login with Invoke-WebRequest
        It "Calls the right Path" {
            Assert-MockCalled Invoke-WebRequest -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Uri.ToString().EndsWith('/Account/Login')
            }
        }
        # We're calling POST
        It "Calls the right Rest Method" {
            Assert-MockCalled Invoke-WebRequest -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Method -eq 'POST'
            }
        }

    # Body:
        # We should check that our credential username is being passed in to usernameOrEmailAddress
        It "Verify Username being passed in Credential" {
            Assert-MockCalled Invoke-WebRequest -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Body.usernameOrEmailAddress -eq $values.Credential.UserName
            }
        }

        # ... and that our password is being passed in
        It "Verifies Password being passed in Credential" {
            Assert-MockCalled Invoke-WebRequest -ModuleName ChocoCCM -Scope Context -ParameterFilter {
                $Body.password -eq $values.Credential.GetNetworkCredential().Password
            }
        }
    # Outcome:
        # Check if Script:CcmServerInfo is being filled out correctly
        It "Sets the Session Variable(s)" {
            $ServerInfo = InModuleScope ChocoCCM { $script:CcmServerInfo }

            # Scoping issues $ServerInfo.Session | Should -BeOfType [Microsoft.PowerShell.Commands.WebRequestSession]
            $ServerInfo.Hostname | Should -Be $values.Hostname
            $ServerInfo.Protocol | Should -Be 'http'
        }
    }

    Context "Connecting to a HTTPS server" -Skip:$Integration {}

    Context "Failing to connect to a server" -Skip:$Integration {}

    Context "Connecting to real server" -Skip:$(-not $Integration) {}

    # Test that parameters exist, are as expected, and have some validation?
    # - Hostname and Credential should be mandatory

}