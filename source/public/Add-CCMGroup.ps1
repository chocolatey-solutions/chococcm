function Add-CCMGroup {
    <#
        .Synopsis
            Creates a new group in CCM

        .Example
            Add-CCMGroup 'TestGroup'
            # Add a new group called TestGroup

        .Example
            Add-CCMGroup -GroupName 'TestGroup' -Description 'This is a test group, for testing!'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String]
        $GroupName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [String]
        $Description  #,

        # [Parameter()]
        # [String[]]
        # $MemberComputer,
        
        # [Parameter()]
        # [String[]]
        # $MemberGroup,
    )
    begin {
        if (-not $Script:CcmServerInfo) {
            Write-Warning 'You appear to be unconnected from your Chocolatey Central Management instance.'
            Connect-CCMServer
        }
    }
    process {
        # IGNORE: Check if a group already exists?
        # If it does exist, do we want to update values or just exit?
        # If it doesn't exist, create it!
        $GroupArgs = @{
            name = $GroupName
        }

        if ($Description) {
            $GroupArgs.Description = $Description
        }

        <# $script:CCMServerInfo
            Session 
            Hostname
            Protocol
        #>

        $RestArgs = @{
            Uri                  = "$($Script:CcmServerInfo.Protocol)://$($Script:CcmServerInfo.Hostname)/api/services/app/Groups/CreateOrEdit"
            Body                 = $GroupArgs | ConvertTo-Json
            ContentType          = "application/json"
            Method               = "POST"
            WebSession           = $Script:CcmServerInfo.Session
            # Remove very bad, NO!!!
            SkipCertificateCheck = $true
        }

        try {
            $GroupResult = Invoke-RestMethod @RestArgs
            if ($GroupResult.success) {
                Write-Host "The group $($GroupName) was created successfully!" -ForegroundColor Green
            } else {
                Write-Error "The group $($GroupName) failed to be created." -ErrorAction Stop
            }
        } catch {
            throw
        }

        # Output the group! Call Get-Group as part of this
    }
}
