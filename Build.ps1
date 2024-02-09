#requires -Modules ModuleBuilder
[CmdletBinding()]
param(
    $Version = $(
        if (Get-Command gitversion -ErrorAction SilentlyContinue) {
            gitversion /showvariable SemVer
        } else {
            '0.1.0'
        }
    )
)

Build-Module -SemVer $Version