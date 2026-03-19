function New-CCMQueryString {
    <#
    .SYNOPSIS
    Turn a hashtable into a URI querystring
    
    .DESCRIPTION
    Turn a hashtable into a URI querystring
    
    .PARAMETER QueryParameter
    The hashtable to transform
    
    .EXAMPLE
    New-CCMQueryString -QueryParameter @{ Animal = 'Dog'; Breed = 'Labrador'; Name = 'Dilbert'}
    
    .EXAMPLE
    New-CCMQueryString -QueryParameter @{ Animal = 'Dog'; Breed = 'Labrador', 'Retriever'; Name = 'Dilbert'}
    
    .EXAMPLE
    New-CCMQueryString -QueryParameter ([ordered]@{ Animal = 'Dog'; Breed = 'Labrador', 'Retriever'; Name = 'Dilbert'})
    
    .NOTES
    Shamelessly taken from https://powershellmagazine.com/2019/06/14/pstip-a-better-way-to-generate-http-query-strings-in-powershell/
    #>
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]
        $QueryParameter
    )
    $pairs = foreach ($key in $QueryParameter.Keys) {
        $encodedKey = [System.Uri]::EscapeDataString($key)
        if ($QueryParameter[$key].GetType().ImplementedInterfaces.Contains([System.Collections.ICollection])) {
            $encodedValue = [System.Uri]::EscapeDataString($QueryParameter[$key] -join ',')
        }
        else {
            $encodedValue = [System.Uri]::EscapeDataString([string]$QueryParameter[$key])
        }
        "$encodedKey=$encodedValue"
    }

    return $pairs -join '&'
}