function New-CCMUser {
    <#
        .Synopsis
            Creates a new Chocolatey Central Management user.

        .Example
            New-CCMUser -UserName ryanr -Name Ryan -Surname Richter
    #>
    [CmdletBinding()]
    param(
        # The username for logging in.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]
        $UserName,

        # The password for logging in.
        [Parameter(ValueFromPipelineByPropertyName)]
        [securestring]
        $Password,

        # The first name of the user.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('FirstName')]
        [string]
        $Name,

        # The last name of the user.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        [Alias('LastName')]
        $Surname,

        # The email address of the user.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]
        $Email,

        # The phone number of the user.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $PhoneNumber,

        # An array of role names to add the user to.
        [Parameter()]
        [ValidateScript({(Get-CCMRole).id})]
        [ArgumentCompleter({(Get-CCMRole).id})]
        [string[]]
        $Roles = @("CCM User"),
        
        # If passed, disables the created user.
        [Parameter()]
        [switch]
        $Disabled
    )
    process {
        $UserCreationFields = @{
            user = @{
                name         = $Name
                surname      = $Surname
                userName     = $UserName
                emailAddress = $Email
                isActive     = -not $Disabled
                isLockoutEnabled = $true  # For now
            }
            assignedRoleNames = $Roles
        }

        if ($Password) {
            $Credential = [System.Net.NetworkCredential]::new($UserName, $Password)
            $UserCreationFields.user += @{
                Password       = $Credential.Password
                PasswordRepeat = $Credential.Password
                ShouldChangePasswordOnNextLogin = $false
            }
        } else {
            $UserCreationFields.SetRandomPassword = $true
            $UserCreationFields.User.ShouldChangePasswordOnNextLogin = $true
        }

        if ($PhoneNumber) {
            $UserCreationFields.user.PhoneNumber = $PhoneNumber
        }

        # Send Activation Email is currently MIA

        Invoke-CCMApi "User/CreateOrUpdateUser" -Method "POST" -Body $UserCreationFields
    }
} #end function