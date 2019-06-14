function Get-AzPrivateIps {
    [CmdletBinding()]

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