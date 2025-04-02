function Get-CCMOutdatedSoftware {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory,ParameterSetName = 'Software')]
        [Alias('PackageTitle','Title')]
        [String]
        $SoftwareName,

        [Parameter(Mandatory,ParameterSetName = 'Package')]
        [String]
        $PackageId
    )

    end {


        switch($PSCmdlet.ParameterSetName){
            'Software' {
                (Get-CCMComputerSoftware -SoftwareName $SoftwareName) |
                Where-Object { $_.Software.isOutdated -eq $true} |
                Select-Object @{n='Computername' ; e={ $_.Computer.name}}
        
            }
            'Package' {
                (Get-CCMComputerSoftware -PackageId $PackageId) |
                Where-Object { $_.Software.isOutdated -eq $true} |
                Select-Object @{n='Computername' ; e={ $_.Computer.name}}

            }
        }
    }
}