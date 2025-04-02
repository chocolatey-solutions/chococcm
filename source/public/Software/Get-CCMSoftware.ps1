function Get-CCMSoftware {
    <#
    .SYNOPSIS
    Return software reported by Central Management
    
    .DESCRIPTION
    Returns the data found on the Software tab of the Central Management web interface
    
    .PARAMETER Filter
    Filer software using this parameter
    
    .EXAMPLE
    Get-CcmSoftware

    .EXAMPLE
    Get-CCMSoftware -Filter fire

    Returns all Software with fire in the name,id, or title fields
    
    .NOTES
    The filter for this function is case insensitive
    #>
    [CmdletBinding()]
    Param(
        [Parameter()]
        [String]
        $Filter
    )

    process {
        
        $encodedFilter = if ($Filter) {
            [System.Net.WebUtility]::UrlEncode($Filter) -replace '\+', '%20'
        }
        else {
            $null
        }

        if($encodedFilter){
            (Invoke-CCMApi -Slug "/Software/GetAll?Filter=$($encodedFilter -replace '\+','%20')").items

        }
        else {
            (Invoke-CCMApi -Slug "/Software/GetAllWithoutFilter")

        }
    }
}
