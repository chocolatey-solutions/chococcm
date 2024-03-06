param(
    $Tests = $(Get-ChildItem $PSScriptRoot\tests\ -Recurse)
)

# Create Pester Container
$PesterArgs = @{

}

# Run the tests
Invoke-Pester @PesterArgs