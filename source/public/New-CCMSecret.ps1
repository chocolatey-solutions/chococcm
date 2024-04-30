function New-CCMSecret {
    [Cmdletbinding()]
    Param(
        
        [parameter(Mandatory)]
        [string]
        [ValidateLength(1,256)]
        $Name,

        [parameter(Mandatory)]
        [string]
        [ValidateLength(1,1000)]
        $Value
    )

    process{
        Invoke-CCMApi "SensitiveVariables/Create" -Method "POST" -Body $PSBoundParameters
    }
}