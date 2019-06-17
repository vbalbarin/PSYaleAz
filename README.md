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

```powershell
PS> $AZURE_SUBSCRIPTION_NAME = '{{ SUBSCRIPTION_NAME }}'
PS> $AZURE_AUTOMATION_ACCOUNT_NAME = '{{ AUTOMATION_ACCOUNT_NAME }}'
PS> $AZURE_RESOURCE_GROUP = '{{ RESOURCE_GROUP }}'
PS> Login-AzAccount -SubscriptionName "$AZURE_SUBSCRIPTION_NAME"

# Install PSYaleAz module locally.
PS> Import-Module PSYaleAz

# Import 'Az.Accounts' to automation account [default]

PS> New-AzAutomationModuleFromPSGallery -AutomationAccountName $AZURE_AUTOMATION_ACCOUNT_NAME `
                                    -ResourceGroupName $AZURE_RESOURCE_GROUP

PS> md ./modules
PS> Compress-Archive -Path PSYaleAz -DestinationPath ./modules/PSYaleAz.zip -Force

# Create a storage account to park artifacts used by the Automation account
# Add deployment parameters to existing hashtable specific to Storage

PS> $AZURE_STORAGE_ACCOUNT_DEPLOYMENT_PARAMETERS =  $AZURE_DEPLOYMENT_PARAMETERS + @{
    SkuName           = 'Standard_LRS'
    AccountKind       = 'StorageV2'
    AccessTierDefault = 'Hot'
    CustomDomain      = ''
    ResourceLocation =  '{{ ResourceLocation }}'
    ApplicationName = 'panostg'
    ApplicationBusinessUnit = '{{ BusinessUnit }}'
    Environment = 'dev'
}

PS> $AZURE_DEPLOYMENT = "storageaccount-$(Get-Date -Format 'yyMMddHHmmm')-deployment"

PS> $deploymentStorageAccount = New-AzResourceGroupDeployment -Name $AZURE_DEPLOYMENT `
                            -ResourceGroupName $AZURE_RESOURCE_GROUP `
                            -TemplateFile ./templates/storageaccount/azuredeploy.json `
                            -TemplateParameterObject $AZURE_STORAGE_ACCOUNT_DEPLOYMENT_PARAMETERS

PS> $AZURE_STORAGE_ACCOUNT = $deploymentStorageAccount.Outputs.storageAccountName.Value

PS> $AZURE_STORAGE_KEY = $(Get-AzStorageAccountKey -Name "$AZURE_STORAGE_ACCOUNT" -ResourceGroupName "$AZURE_RESOURCE_GROUP" | ? {$_.KeyName -eq 'key1'}).Value

PS> $AZURE_STORAGE_CONTEXT = New-AzStorageContext -StorageAccountName "$AZURE_STORAGE_ACCOUNT" `
                        -StorageAccountKey "$AZURE_STORAGE_KEY"

PS> New-AzStorageContainer -Context $AZURE_STORAGE_CONTEXT -Name 'modules' -Permission Blob 

PS> $blobs = Get-ChildItem -Recurse ./modules -Filter '*.zip' | % {Set-AzStorageBlobContent -File $_ -Context $AZURE_STORAGE_CONTEXT -Container 'modules' -Blob $($_.Name) -Properties @{"ContentType" = "application/zip"} }

PS> $AZURE_BLOB_ENDPOINT = $blobs[0].Context.BlobEndPoint
PS> New-AzAutomationModule -Name PSYaleAz -ContentLinkUri ("{0}modules/PSYaleAz.zip" -f $AZURE_BLOB_ENDPOINT) -AutomationAccountName $AZURE_AUTOMATION_ACCOUNT_NAME -ResourceGroupName $AZURE_RESOURCE_GROUP
```
## Author

Vincent Balbarin <vincent.balbarin@yale.edu>

## License

The licenses of these documents are held by [@YaleUniversity](https://github.com/YaleUniversity) under [MIT License](/LICENSE.md).