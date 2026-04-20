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
        $ContentType = 'application/json',

        [Parameter()]
        [System.Collections.IDictionary]
        $QueryParameters
    )
    begin {
        if (-not $Script:CcmServerInfo) {
            Write-Warning 'You appear to be unconnected from your Chocolatey Central Management instance. Run Connect-CCMServer first.'
        }
    }
    end {
        $uri = "$($Script:CcmServerInfo.Protocol)://$($Script:CcmServerInfo.Hostname)/api/services/app/$($Slug.TrimStart('/api/services/app/'))"

        if ($QueryParameters -and $QueryParameters.Count -gt 0) {
            $pairs = foreach ($key in $QueryParameters.Keys) {
                $encodedKey = [System.Uri]::EscapeDataString($key)
                if ($QueryParameters[$key].GetType().ImplementedInterfaces.Contains([System.Collections.ICollection])) {
                    $encodedValue = [System.Uri]::EscapeDataString($QueryParameters[$key] -join ',')
                } else {
                    $encodedValue = [System.Uri]::EscapeDataString([string]$QueryParameters[$key])
                }
                "$encodedKey=$encodedValue"
            }
            $uri = "$uri?$($pairs -join '&')"
        }

        $params = @{
            Uri        = $uri
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
