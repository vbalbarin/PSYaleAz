# Yale University Azure Utility Module

## Introduction

This module comprises a set of commandlets for use in Azure. This module may be used in Azure runbooks.

Currently, it contains the following commandlets:

* Get-AzPrivateIPAddresses

## Installation from Local Folder

Launch Powershell:

```bash
$ pwsh
```

Clone repository:

```powershell
PS> md './modules'
PS> git clone https://github.com/vbalbarin/PSYaleAz.git
PS> cd PSYaleAz

Install `PSYaleAz` module:

```powershell
PS> $userModulesPath = ($($env:PSModulePath) -split ':|;')[0]
PS> Copy-Item -Recurse 'PSYaleAz' "$userModulesPath/PSYaleAz"
PS> Import-Module PSYaleAz
PS> Get-Module PSYaleAz
```

## Import Module to Azure Automation Runbook.

[TODO: Document importing]

## Author

Vincent Balbarin <vincent.balbarin@yale.edu>

## License

The licenses of these documents are held by [@YaleUniversity](https://github.com/YaleUniversity) under [MIT License](/LICENSE.md).