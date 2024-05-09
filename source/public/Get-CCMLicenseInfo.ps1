function Get-CCMLicenseInfo {
    [CmdletBinding()]
    Param(

    )

    process {
        $UsedCount = Invoke-CCMApi -Slug "/Computers/GetComputerCount"
        $MaxCount = Invoke-CCMApi -Slug "/ChocolateyLicenseInformation/GetLicenseCount"
        
        [PSCustomObject]@{
            UsedCount          = $UsedCount
            MaxCount           = $MaxCount
            Expiration         = Invoke-CCMApi -Slug "/ChocolateyLicenseInformation/GetLicenseExpiration"
            IsTrial            = Invoke-CCMApi -Slug "/ChocolateyLicenseInformation/GetIsTrialLicense"
            RemainingCount     = ($MaxCount - $UsedCount)
            UtilizedPercentage = (($UsedCount / $MaxCount) * 100)
        }
    }
}