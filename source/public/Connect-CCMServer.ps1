function Connect-CCMServer {
    [CmdletBinding()]
    param(
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
        } else {
            'http'
        }

        $url = "$($Protocol)://$Hostname/Account/Login"

        $body = @{
            usernameOrEmailAddress = $Credential.UserName
            password               = $Credential.GetNetworkCredential().Password
        }
        try {
            $null = Invoke-WebRequest -Uri $url -Body $body -Method Post -SessionVariable Session -ErrorAction Stop -SkipCertificateCheck

            $Script:CcmServerInfo = @{
                Session  = $Session
                Hostname = $Hostname
                Protocol = $Protocol
            }

            Write-Host 'Successfully connected to Chocolatey Central Management!!' -ForegroundColor DarkYellow
        } catch {
            $ErrorDetails = ConvertFrom-Json $_.ErrorDetails -ErrorAction SilentlyContinue

            Write-Error -Message "$($ErrorDetails.error.message)`n$($ErrorDetails.error.details)" -Exception $_.Exception -ErrorAction Stop
        }
    }
}