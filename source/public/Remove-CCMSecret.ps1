function Remove-CCMSecret {
    [CmdLetBinding(SupportsShouldProcess, ConfirmImpact = "High")]

    Param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [ArgumentCompleter({
                param(
                     $Command,
                     $Parameter,
                     $WordToComplete,
                     $CommandAst,
                     $FakeBoundParams )
            
                $CompletionResults = (Get-CCMSecret).Name

                if ($WordToComplete) {
                    $CompletionResults.Where($_ -match "^$WordToComplete")
                }
                else {
                    $CompletionResults
                }
            })]
        [string]
        $Name
    )
    process {
        $Secret = Get-CCMSecret -Name $Name

        if ($Secret) {

            if ($PSCmdlet.ShouldProcess($Name, "Deleting")) {
                Invoke-CCMApi -Method "Delete" -Slug "/SensitiveVariables/Delete?id=$($Secret.Id)" 
            }
        }
        else {
            throw "Secret $Name does not exist"
        }
    }
}