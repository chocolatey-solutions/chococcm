if ($Configuration = Get-CCMConfiguration) {
    Connect-CCMServer @Configuration
}