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
    process{
        $GroupResult = Invoke-CCMApi -Slug "Groups/GetAll"

        $FilteredResult = switch ($PSCmdlet.ParameterSetName) {
            "All" {
                $GroupResult
            }
            "Id" {
                $GroupResult | Where-Object id -in $Id
            }
            "Name" {
                $GroupResult | Where-Object name -in $Name
            }
            default {
                throw "Unrecognised Parameter Set"
            }
        }

        if (-not $FilteredResult) {
            Write-Error "No results found for $($PSCmdlet.ParameterSetName) '$(Get-Variable -Name $PSCmdlet.ParameterSetName -ValueOnly -ErrorAction SilentlyContinue)'"
        }
        $FilteredResult
    }
}