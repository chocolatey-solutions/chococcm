# ChocoCCM

A PowerShell module for interacting with the [Chocolatey Central Management (CCM)](https://docs.chocolatey.org/en-us/central-management/) REST API.

> **Community project** — ChocoCCM is developed and maintained by the **Solutions Engineering team at Chocolatey Software**. It is **not** covered by any commercial support agreement you may hold with Chocolatey. Community assistance is available by joining our Discord at <https://ch0.co/community>.

---

## Table of Contents

- [Overview](#overview)
- [Requirements](#requirements)
- [Installation](#installation)
- [Getting Started](#getting-started)
- [Command Reference](#command-reference)
  - [Connection](#connection)
  - [Computers](#computers)
  - [Computer Software](#computer-software)
  - [Groups](#groups)
  - [Deployment Plans](#deployment-plans)
  - [Deployment Steps](#deployment-steps)
  - [Software](#software)
  - [Facts](#facts)
  - [Audit Logs](#audit-logs)
  - [Roles](#roles)
  - [Sensitive Variables (Secrets)](#sensitive-variables-secrets)
  - [License Information](#license-information)
  - [Configuration](#configuration)
  - [Raw API Access](#raw-api-access)
- [Contributing](#contributing)
- [Support](#support)

---

## Overview

ChocoCCM wraps the Chocolatey Central Management HTTP API in idiomatic PowerShell cmdlets, letting you automate common CCM administration tasks such as:

- Querying computer inventory and the software installed on each machine
- Managing computer groups and their membership
- Creating, starting, stopping, and monitoring deployment plans
- Inspecting facts (system information) collected by Chocolatey Agent
- Managing sensitive variables (secrets) used in deployments
- Reviewing audit logs and license information

---

## Requirements

| Requirement | Minimum version |
|---|---|
| PowerShell | 5.1 (Desktop) or 7+ (Core) |
| Chocolatey Central Management | 0.4.0 or later |
| PowerShell module: `Configuration` | (installed automatically as a dependency) |

---

## Installation

```powershell
Install-Module -Name ChocoCCM -Repository PSGallery
```

Or, if you are managing modules with a `RequiredModules.psd1` (e.g. via PSDepend), add:

```powershell
@{
    ChocoCCM = 'latest'
}
```

---

## Getting Started

All commands require an active session. Establish one first with `Connect-CCMServer`:

```powershell
$cred = Get-Credential
Connect-CCMServer -Hostname 'ccm.example.com' -Credential $cred -UseSSL
```

Once connected, the session is stored in the module scope and used automatically by all subsequent commands.

```powershell
# List all computers registered in CCM
Get-CCMComputer

# Get all facts for a specific computer
Get-CCMFact -Computername 'DESKTOP-001'

# Start a deployment plan
Start-CCMDeploymentPlan -Id 42
```

---

## Command Reference

### Connection

| Command | Description |
|---|---|
| `Connect-CCMServer` | Authenticate to a CCM server and store the session for subsequent calls |

### Computers

| Command | Description |
|---|---|
| `Get-CCMComputer` | Return computers registered in CCM |
| `Remove-CCMComputer` | Remove a computer record from CCM |

### Computer Software

| Command | Description |
|---|---|
| `Get-CCMComputerSoftware` | Return software installed on a specific computer |

### Groups

| Command | Description |
|---|---|
| `Get-CCMGroup` | Return computer groups |
| `Add-CCMGroup` | Create a new computer group |
| `Remove-CCMGroup` | Delete a computer group |
| `Rename-CCMGroup` | Rename an existing group |
| `Set-CCMGroup` | Update group properties |
| `Add-CCMGroupMember` | Add a computer to a group |
| `Remove-CCMGroupMember` | Remove a computer from a group |
| `Set-CCMGroupMember` | Replace the full membership of a group |
| `Get-CCMGroupMembership` | Return the groups a computer belongs to |

### Deployment Plans

| Command | Description |
|---|---|
| `Get-CCMDeploymentPlan` | Return deployment plans |
| `New-CCMDeploymentPlan` | Create a new deployment plan |
| `Import-CCMDeploymentPlan` | Import a deployment plan from a definition |
| `Move-CCMDeploymentPlan` | Move a deployment plan to a different folder |
| `Save-CCMDeploymentPlan` | Save (persist) changes to a deployment plan |
| `Start-CCMDeploymentPlan` | Start a deployment plan |
| `Stop-CCMDeploymentPlan` | Stop a running deployment plan |
| `Remove-CCMDeploymentPlan` | Delete a deployment plan |
| `Wait-DeploymentPlan` | Block until a deployment plan reaches a terminal state |

### Deployment Steps

| Command | Description |
|---|---|
| `New-CCMBasicDeploymentStep` | Add a basic deployment step to a plan |
| `New-CCMAdvancedDeploymentStep` | Add an advanced deployment step to a plan |

### Software

| Command | Description |
|---|---|
| `Get-CCMSoftware` | Return software known to CCM |
| `Get-CCMOutdatedSoftware` | Return software that has an available upgrade |

### Facts

| Command | Description |
|---|---|
| `Get-CCMFact` | Return facts (system information) reported by computers |

### Audit Logs

| Command | Description |
|---|---|
| `Get-CCMAuditLogs` | Return CCM audit log entries |

### Roles

| Command | Description |
|---|---|
| `Get-CCMRole` | Return CCM roles |

### Sensitive Variables (Secrets)

| Command | Description |
|---|---|
| `Get-CCMSecret` | List sensitive variables stored in CCM |
| `New-CCMSecret` | Create a new sensitive variable |
| `Remove-CCMSecret` | Delete a sensitive variable |

### License Information

| Command | Description |
|---|---|
| `Get-CCMLicenseInfo` | Return Chocolatey license information from CCM |

### Configuration

| Command | Description |
|---|---|
| `Get-CCMConfiguration` | Return the saved CCM connection configuration |
| `Set-CCMConfiguration` | Persist CCM connection settings for future sessions |

### Raw API Access

| Command | Description |
|---|---|
| `Invoke-CCMApi` | Make a raw authenticated call to the CCM API |

---

## Contributing

Pull requests and issues are welcome. Please open an issue first for larger changes so we can discuss the approach.

To build the module locally:

```powershell
.\Build.ps1 -SemVer 1.0.0
```

Tests are run with:

```powershell
.\Test.ps1
```

---

## Support

ChocoCCM is a **community project** from the Solutions Engineering team at Chocolatey Software and is **not covered by any commercial support agreement**.

Need help? Join the Chocolatey community on Discord: <https://ch0.co/community>
