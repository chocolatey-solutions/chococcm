function New-CCMSecret {
    [Cmdletbinding()]
    Param(
        [parameter(Mandatory)]
        [string]
        [ValidateLength(1,256)]
        [ValidateScript({
            if (Get-CCMSecret -Name $_){
                throw "'$_' is already a secret name in use. Please provide a different -Name, or look to use Set-CCMSecret."
            }
            $true
        })]
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