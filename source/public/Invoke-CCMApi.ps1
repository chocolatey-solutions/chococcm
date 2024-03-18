function Invoke-CCMApi {
    [CmdletBinding()]

    Param(
        [Parameter(Mandatory, Position=0)]
        [string]
        $Slug,

        [Parameter()]
        [Microsoft.PowerShell.Commands.WebRequestMethod]
        $Method = "GET",

        [Parameter()]
        $Body,

        [Parameter()]
        [string]
        $ContentType = 'application/json'
    )
    begin {
        if (-not $Script:CcmServerInfo) {
            Write-Warning 'You appear to be unconnected from your Chocolatey Central Management instance.'
            Connect-CCMServer
        }
    }
    end {
        $params = @{
            Uri        = "$($Script:CcmServerInfo.Protocol)://$($Script:CcmServerInfo.Hostname)/api/services/app/$($Slug.TrimStart('/api/services/app/'))"
            Method     = $Method
            WebSession = $Script:CcmServerInfo.Session
            SkipCertificateCheck = $true  # TODO: Remove this later
            Verbose = $false
        }

        if ($Body -and $ContentType -eq 'application/json') {
            $params['ContentType'] = $ContentType
            $params['Body'] = $Body | ConvertTo-Json -Depth 5
        }

        try {
            (Invoke-RestMethod @params -ErrorAction Stop).result
        } catch {
            $ErrorDetails = ConvertFrom-Json $_.ErrorDetails -ErrorAction SilentlyContinue

            Write-Error -Message "$($ErrorDetails.error.message)`n$($ErrorDetails.error.details)" -Exception $_.Exception -ErrorAction Stop
        }
    }
}
