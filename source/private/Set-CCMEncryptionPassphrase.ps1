function Set-CCMEncryptionPassphrase {
    [CmdletBinding()]
    param(
        # must conatin a capital, lowercase, number, and special char
        [Parameter(Mandatory)]
        [ValidateScript({
            if ($_.Length -lt 6) {
                throw "The password must be six or more characters long."
            }
            if (!($_ -imatch "([A-Z]|[a-z]|[0-9]|&_\.-)")) {
                throw "The password must contain an uppercase letter, a lowercase letter, a number, and a special character."
            }
            $true
        })]
        [SecureString]
        $NewPassphrase,

        [securestring]
        $OldPassphrase = [SecureString]::new()
    )
    end {
        #Get current encrption settings
        $Settings = Invoke-CCMApi -Slug "TenantSettings/GetAllSettings"

        #Update old settings with new values
        $NewPassphraseText = [System.Net.NetworkCredential]::new('new', $NewPassphrase).Password
        $Settings.encryption.oldPassphrase = [System.Net.NetworkCredential]::new('old', $OldPassphrase).Password
        $Settings.encryption.passphrase = $NewPassphraseText
        $Settings.encryption.confirmPassphrase = $NewPassphraseText

        #Push Updated values
        Invoke-CCMApi -Slug "TenantSettings/UpdateAllSettings" -Method "PUT" -Body $Settings
    }
}

# ('Choco24020'|ConvertTo-SecureString -AsPlainText -Force)