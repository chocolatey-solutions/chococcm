function Remove-CCMGroup {
    [CmdletBinding(DefaultParameterSetName='Id', SupportsShouldProcess, ConfirmImpact="High")]
    param(
        [Parameter(Mandatory, ParameterSetName='Name')]
        [string]
        $Name,

        [Parameter(Mandatory, ParameterSetName='Id', ValueFromPipelineByPropertyName)]
        [int64]
        $Id = $(if ($Name) {(Get-CCMGroup -Name $Name).Id})
    )
    process {
        if ($Id -and $PSCmdlet.ShouldProcess($(Get-Variable -Name $PSCmdlet.ParameterSetName -ValueOnly -ErrorAction SilentlyContinue), "Removing Group")) {
            try {
                Invoke-CCMApi -Method 'DELETE' -Slug "Groups/Delete?id=$($Id)" -ErrorAction Stop
                Write-Host "Removal of group '$(Get-Variable -Name $PSCmdlet.ParameterSetName -ValueOnly -ErrorAction SilentlyContinue)' succeeded." -ForegroundColor DarkGreen
            } catch {
                throw
            }
        }
    }
}