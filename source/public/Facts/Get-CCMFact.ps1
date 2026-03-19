function Get-CCMFact {
    <#
    .SYNOPSIS
    Return facts reported by computers in Chocolatey Central Management

    .DESCRIPTION
    Retrieves the facts (system information collected by Chocolatey Agent) for one or more
    computers registered in Chocolatey Central Management. Facts can be filtered by computer
    name, and optionally certain categories or fact groups can be excluded from the results.

    .PARAMETER Computername
    The name(s) of the computer(s) to retrieve facts for. If omitted, facts for all computers
    are returned.

    .PARAMETER ExcludeCategory
    One or more fact categories to exclude from the results.

    .PARAMETER ExcludeFactGroup
    One or more fact groups to exclude from the results.

    .EXAMPLE
    Get-CCMFact

    Returns facts for all computers registered in Central Management.

    .EXAMPLE
    Get-CCMFact -Computername 'DESKTOP-001'

    Returns all facts reported by the computer named DESKTOP-001.

    .EXAMPLE
    Get-CCMFact -Computername 'DESKTOP-001','SERVER-02' -ExcludeCategory 'Network'

    Returns facts for DESKTOP-001 and SERVER-02, excluding anything in the Network category.

    .NOTES
    Requires an active connection to a Chocolatey Central Management server.
    Run Connect-CCMServer before calling this function.
    #>
    [CmdletBinding()]
    Param(
        [Parameter()]
        [String[]]
        $Computername,

        [Parameter()]
        [String[]]
        $ExcludeCategory,

        [Parameter()]
        [String[]]
        $ExcludeFactGroup
    )

    begin {
        $factCollection = [System.Collections.Generic.List[pscustomobject]]::new()
    }

    process {
        $computers = Get-CCMComputer

        if ($Computername) {
            $computers = $computers | Where-Object { $_.Name -in $Computername }
        }

        foreach ($computer in $computers) {
            $computerId = $computer.Id

            $queryParams = @{
                ComputerId = $computerId
            }

            if ($ExcludeCategory) {
                $queryParams['ExcludeCategories'] = $ExcludeCategory
            }

            if ($ExcludeFactGroup) {
                $queryParams['ExcludeFactGroups'] = $ExcludeFactGroup
            }
            
            $QueryString = New-CCMQueryString $queryParams
            $facts = Invoke-CCMApi "/Computers/GetFactsByComputerId?$QueryString"
            $factCollection.Add($facts)
        }
    }

    end {
        return $factCollection
    }
}