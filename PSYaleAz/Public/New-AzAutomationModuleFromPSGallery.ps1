function New-AzAutomationModuleFromPSGallery {
        <#
		.SYNOPSIS
        New-AzAutomationModuleFromPSGallery installs a list of Powershell Gallery modules into an Azure automation account.
        
		.DESCRIPTION
        New-AzAutomationModuleFromPSGallery installs a list of Powershell Gallery modules into an Azure automation account.
        'Az-Accounts' must always be imported into the automation account prior to any other module. This commandlet enforces this requirement.
        
        * If no list is specified, 'Az.Accounts' is set to default.
        * If 'Az.Accounts' is unspecified, it is prepended to the list.
        * If 'Az.Accounts' is not first item in the list, it is placed at the beginning of thelist.

		.EXAMPLE
        PS> New-AzAutomationModuleFromPSGallery -AutomationAccountName $AZURE_AUTOMATION_ACCOUNT_NAME -ResourceGroupName $AZURE_RESOURCE_GROUP -Verbose
    
        ResourceGroupName     : {{ $AZURE_RESOURCE_GROUP }}
        AutomationAccountName : {{ $AZURE_AUTOMATION_ACCOUNT_NAME }}
        Name                  : Az.Accounts
        IsGlobal              : False
        Version               : 1.5.2
        SizeInBytes           : 3671679
        ActivityCount         : 30
        CreationTime          : 6/17/19 1:33:53 PM -04:00
        LastModifiedTime      : 6/17/19 4:22:59 PM -04:00
        ProvisioningState     : Creating

        VERBOSE: Az.Accounts provisioning state: Creating
        [truncated]
        VERBOSE: Az.Accounts provisioning state: Creating
        VERBOSE: Az.Accounts provisioning state: RunningImportModuleRunbook
        VERBOSE: Az.Accounts provisioning state: ContentValidated
        VERBOSE: Az.Accounts provisioning state: ConnectionTypeImported
        VERBOSE: Az.Accounts provisioning state: Succeeded
        Az.Accounts provisioning state: Succeeded

        .EXAMPLE
        PS> New-AzAutomationModuleFromPSGallery  -Modules @('Az.Storage', 'Az.Accounts') -AutomationAccountName $AZURE_AUTOMATION_ACCOUNT_NAME -ResourceGroupName $AZURE_RESOURCE_GROUP

        ResourceGroupName     : {{ $AZURE_RESOURCE_GROUP }}
        AutomationAccountName : {{ $AZURE_AUTOMATION_ACCOUNT_NAME }}
        Name                  : Az.Accounts
        IsGlobal              : False
        Version               : 1.5.2
        SizeInBytes           : 3671679
        ActivityCount         : 30
        CreationTime          : 6/17/19 1:33:53 PM -04:00
        LastModifiedTime      : 6/17/19 4:56:37 PM -04:00
        ProvisioningState     : Creating

        Az.Accounts provisioning state: Succeeded

        ResourceGroupName     : {{ $AZURE_RESOURCE_GROUP }}
        AutomationAccountName : {{ $AZURE_AUTOMATION_ACCOUNT_NAME }}
        Name                  : Az.Storage
        IsGlobal              : False
        Version               : 1.3.0
        SizeInBytes           : 2470616
        ActivityCount         : 101
        CreationTime          : 6/17/19 4:42:48 PM -04:00
        LastModifiedTime      : 6/17/19 4:57:52 PM -04:00
        ProvisioningState     : Creating

        Az.Storage provisioning state: Succeeded

        .PARAMETER Modules [String[]]
		Array of Powershell Gallery Module names.
		.PARAMETER ResourceGroupName [String]
        Name of Azure resource group containing automation account.
        .PARAMETER AutomationAccountName [String]
		Name of Azure automation account.
        
        .NOTES
		Name: New-AzAutomationModuleFromPSGallery
		Author: Vincent Balbarin
		Last Edit: 2019-06-17
		Keywords: 
		.LINK
	#>
    [CmdletBinding()]

    param(
        [Parameter()]
        [System.Collections.ArrayList]
        $Modules =  @('Az.Accounts'),

        [Parameter(Mandatory=$true)]
        [String]
        $AutomationAccountName,

        [Parameter(Mandatory=$true)]
        [String]
        $ResourceGroupName

    )

    $module_names = New-Object -TypeName System.Collections.ArrayList
    $Modules | ForEach-Object {
        [Void] $module_names.Add($_.ToLower())
    }
    
    if ($module_names.ToArray().Length -ne 1) {
        $module_names.Sort()
        $module_names = [System.Collections.ArrayList] ($module_names | Select-Object -Unique)
        if ($azAccountIndex -ne 0) {
            $module_names.Remove('az.accounts')
            $module_names.Insert(0, 'az.accounts')
        }
    }

    $psGalleryModules = $module_names | ForEach-Object {Find-Module -Name $_ -Repository PSGallery}

    $psGalleryModules | ForEach-Object {
        New-AzAutomationModule -AutomationAccountName $AutomationAccountName `
                           -ResourceGroupName $ResourceGroupName `
                           -ContentLink $('{0}/package/{1}/{2}' -f $_.RepositorySourceLocation, $_.Name, $_.Version) `
                           -Name $_.Name

        $i = 1; do {
            if ($i -ge 100 ) {
                $state = 'Failed'
            } else {
                $state = (Get-AzAutomationModule -Name $_.Name `
                                     -ResourceGroupName $ResourceGroupName `
                                     -AutomationAccountName $AutomationAccountName).ProvisioningState
            }
            $message = $("{0} provisioning state: {1}" -f $_.Name, $state)
            Write-Verbose -Message $message
            $i += 1
        } until (($state -eq 'Succeeded') -or ($state -eq 'Failed'))
        Write-Host "$message`r`n"
    }
    
}