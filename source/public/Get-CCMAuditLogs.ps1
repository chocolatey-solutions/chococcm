function Get-CCMAuditLogs {
    [CmdletBinding()]
    Param (
        [Parameter()]
        [datetime]
        $StartDate,

        [Parameter()]
        [datetime]
        $EndDate,

        [Parameter()]
        [string]
        $UserName,

        [Parameter()]
        [string]
        [Alias('Service')]
        $ServiceName,

        [Parameter()]
        [string]
        [Alias('Action')]
        $MethodName,

        [Parameter()]
        [switch]
        $HasException

    )

    process {
        
        $Body = @{

        }
        # Explore this to handle different data types, and remember to account for default values
        $PSBoundParameters.GetEnumerator() | ForEach-Object{
            $Body.Add($_.Key,$_.Value)
        }

        Invoke-CCMApi -Slug "/AuditLog/GetAuditLogs" -Body $Body
    }
}