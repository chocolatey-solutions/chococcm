if (($Configuration = Get-CCMConfiguration).Keys) {
    Write-Verbose "Connecting to '$($Configuration.Hostname)' with previously used credentials..."
    Connect-CCMServer @Configuration
}