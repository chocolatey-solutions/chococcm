function Remove-CCMComputer {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact="High")]
    param (
        [Parameter (Mandatory)]
        [String[]]
        $Name
    )
    process {
        foreach ($N in $Name) {
            try {
                $Id = Get-CCMComputer -ComputerName $N -Detailed -ErrorAction Stop | Select-Object -ExpandProperty Id
                if ($PSCmdlet.ShouldProcess($N, "Deleting")) {
                    Invoke-CCMApi -Method 'DELETE' -Slug "/Computers/Delete?Id=$Id"
                }
            }
            catch {
                throw "Computer $N not found in Chocolatey Central Management."
            }
        }
    }
}