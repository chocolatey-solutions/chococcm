function Remove-CCMUser {
    <#
        .Synopsis
            Removes a user from Chocolatey Central Management

        .Example
            Remove-CCMUser -Id 5

        .Example
            Remove-CCMUser -UserName jruskin

        .Example
            Get-CCMUser -Filter 'bob' | Remove-CCMUser
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
    param(
        [Parameter(ParameterSetName='Name', ValueFromPipeline, Mandatory)]
        [string[]]
        $UserName
    )
    process {
        foreach ($UserFilter in $UserName) {
            $User = Get-CCMUser -Filter $UserFilter | Where-Object userName -eq $UserFilter

            if ($PSCmdlet.ShouldProcess($User.userName, "Deleting")){
                Invoke-CCMApi "User/DeleteUser?id=$($User.id)" -Method "DELETE"
            }
        }
    }
}