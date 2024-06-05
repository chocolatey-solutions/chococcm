class ComputerSoftware {
    [int64]$computerId
    $computer  # Need to ensure the Computer Class successfully casts this
    [int64]$softwareId
    [Software]$software
    [string]$installedDateTimeUtc
    [string]$isCurrentlyInstalled
    [int64]$id
}