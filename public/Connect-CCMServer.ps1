function Connect-CCMServer {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [String]
        $Hostname,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [Switch]
        $UseSSL
    )
 
    process {

        $protocol = if ($UseSSL) {
            'https'
        }
        else {
            'http'
        }

        $url = "$($protocol)://$Hostname/Account/Login"

        $body = @{
            usernameOrEmailAddress = $Credential.UserName
            password               = $Credential.GetNetworkCredential().Password
        }

        $null = Invoke-WebRequest -Uri $url -Body $body -Method Post -SessionVariable Session

        $Script:CcmServerInfo = @{
            Session = $Session
            Hostname = $Hostname
            Protocol = $protocol
        }

        Write-Host 'Successfully connected to Chocolatey Central Management!!' -ForegroundColor Green
    }
}