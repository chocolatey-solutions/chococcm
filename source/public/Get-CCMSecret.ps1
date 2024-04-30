function Get-CCMSecret {
    [Cmdletbinding()]
    Param(
        [parameter()]
        [string]
        $Name
    )

    process{
    $result = (Invoke-CCMApi -Slug "SensitiveVariables/GetAll" -ContentType "text/plain")
       if($Name){
        $result | Where-Object{$_.name -eq $Name}
       }
       else{
        $result
        }
    }
}