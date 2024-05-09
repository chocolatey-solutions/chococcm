function Get-CCMSecret {
    <#
.SYNOPSIS
Gets desired CCM Sensitive Variable(s)

.PARAMETER Name
The Name parameter operates as a filter and accepts regex

.EXAMPLE
Get-CCMSecret -Name OfficeLicenseKey

.EXAMPLE
Get-CCMSecret -Name Office.

#>
    [Cmdletbinding()]
    Param(
        [parameter()]
        [string]
        $Name
    )

    process {
        $result = (Invoke-CCMApi -Slug "SensitiveVariables/GetAll" -ContentType "text/plain")
        if ($Name) {
            $result | Where-Object { $_.name -match "^$Name" }
        }
        else {
            $result
        }
    }
}