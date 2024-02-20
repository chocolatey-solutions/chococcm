function Get-CCMGroup {
    [cmdletBinding(DefaultParameterSetName = "All")]
    param (
        [Parameter(Mandatory, ParameterSetName = "Name")]
        [String[]]
        $Name,

        [Parameter(Mandatory, ParameterSetName = "Id")]
        [int[]]
        $Id
    )

    begin {
        if (-not $Script:CcmServerInfo) {
            Write-Warning 'You appear to be unconnected from your Chocolatey Central Management instance.'
            Connect-CCMServer
        }
    }

    process{
        $RestArgs = @{
            Uri = "$($Script:CcmServerInfo.Protocol)://$($Script:CcmServerInfo.Hostname)/api/services/app/Groups/GetAll"
            ContentType = "application/json"
            Method = "GET"
            WebSession = $Script:CcmServerInfo.Session
            # Remove very bad, NO!!!
            SkipCertificateCheck = $true
        }

        $GroupResult = Invoke-RestMethod @RestArgs

        $FilteredResult = switch ($PSCmdlet.ParameterSetName) {
            "All" {
                $GroupResult.result
            }
            "Id" {
                $GroupResult.result | Where-Object id -in $Id
            }
            "Name" {
                $GroupResult.result | Where-Object name -in $Name
            }
            default {
                throw "Unrecognised Parameter Set"
            }
        }

        if (-not $FilteredResult) {
            Write-Error "No results found for $($PSCmdlet.ParameterSetName) '$(Get-Variable -Name $PSCmdlet.ParameterSetName -ValueOnly)'"
        }
        $FilteredResult
    }
}