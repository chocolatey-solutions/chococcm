function Get-CCMConfiguration {
    [cmdletbinding()]
    param()
    end {
        Import-Configuration -CompanyName "Chocolatey Software" -Name ChocoCCM
    }
}