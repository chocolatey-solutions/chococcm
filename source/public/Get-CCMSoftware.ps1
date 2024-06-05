function Get-CCMSoftware {    
    process {
        
        [Software[]](Invoke-CCMApi -Slug "/Software/GetAll" | Select-Object -ExpandProperty items)
    }
}
