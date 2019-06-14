function Get-AzPrivateIps {
    <#
		.SYNOPSIS
        Get-AzPrivateIps retrieves private IP addresses in Azure.
        
		.DESCRIPTION
        Get-AzPrivateIps retrieves private IP addresses in Azure. It returns a [PSCustomObject] with a Result code and a Value that contains an array of IP objects with addresses and associated properties.
        
        [PSCustomObject] @{
            Address = <xxx.xxx.xxx.xxx>
            Properties = [PSCustomObject] @{
                DataSensitivity = <Data Sensitivity>
                AttachedVm = <VM Name>
                AttachedToVnet = <VNET Name>
            }
        }

		.EXAMPLE
        PS> Get-AzPrivateIps
        [PScustomObject]

        Name                           Value
        ----                           -----
        Value                          {@{Address=10.0.21.4; Properties=}, @{Address=10.6.231.4; Properties=}…}
        Result                         Success
        
        .PARAMETER Subscription [Switch]
		If specified, commandlet will return all private IPs within the current Azure subscription context. This is the default.
		.PARAMETER ResourceGroupName [String]
        If specified, commandlet will return all private IPs for the given Azure resource group within the current subscription context.
        .PARAMETER Computer [String]
		If specified with ResourceGroupName of the Computer, the commandlet will return all private IPs for the given Azure virtual machine within the resource group within the current subscription context.
        
        .NOTES
		Name: Get-AzPrivateIps
		Author: Vincent Balbarin
		Last Edit: 2019-06-14
		Keywords: 
		.LINK
	#>
    [CmdletBinding(DefaultParameterSetName='Subscription')]

    param(
        [Parameter(ParameterSetName='Subscription', Mandatory=$False)]
        [Switch] $Subscription,

        [Parameter(ParameterSetName='ResourceGroup', Mandatory=$True)]
        [Parameter(ParameterSetName='Computer')]
        [String] $ResourceGroupName,

        [Parameter(ParameterSetName='Computer', Mandatory=$True)]
        [String] $VirtualMachineName
    )
    
    $output = @{
        Result = 'NotExecuted'
        Value = 'None'
    }

    $SUBSCRIPTION_NAME = (Get-AzContext).Subscription.Name
    
    switch($PSCmdlet.ParameterSetName) {
        'Subscription' {
            Write-Verbose -Message ("Retrieving IP addresses in subscription {0}." -f $SUBSCRIPTION_NAME)
            $nics = Get-AzNetworkInterface
        }
        'ResourceGroup' {
            Write-Verbose -Message ("Retrieving IP addresses in resource group {0} in subscription {1}." -f $ResourceGroupName, $SUBSCRIPTION_NAME)
            $nics = (Get-AzNetworkInterface -ResourceGroupName $ResourceGroupName)
        }
        'Computer' {
            Write-Verbose -Message ("Retrieving IP addresses for virtual machine {0} in resource group {1} in subscription {2}." -f $VirtualMachineName, $ResourceGroupName, $SUBSCRIPTION_NAME)
            $nics = (Get-AzNetworkInterface -ResourceGroupName $ResourceGroupName | 
                    Where-Object {$_.VirtualMachine.Id.Split('/')[-1] -ieq $VirtualMachineName})
        }
    }

    $ips = New-Object System.Collections.Generic.List[System.Object]
    $nics | ForEach-Object {
        AzPrivateIps -AzNetworkInterface $_ | ForEach-Object {$ips.Add($_)}
    }
    
    $output = @{
        Result = 'Success'
        Value = $ips.ToArray()
    }

    Write-Output [PScustomObject] $output
}