function AzPrivateIps {
    param(
        [Parameter(Mandatory=$true)]
        $AzNetworkInterface
    )
    $azNic = $AzNetworkInterface
    $azPrivateIps = New-Object System.Collections.Generic.List[System.Object]

    $tags = $azNic.Tag
    $attachedVm = $azNic.VirtualMachine
 
    $azNic.IpConfigurations | ForEach-Object {
        $attachedSubnet = $_.Subnet
        $azPrivateIps.Add(
            [PSCustomObject] @{
                Address = $_.PrivateIpAddress
                Properties = [PSCustomObject] @{
                    DataSensitivity = AzDataSensitivity -Tags $tags
                    AttachedVmName = AzVmName -Vm $attachedVm
                    AttachedToVnet = AzVnetName -Subnet $attachedSubnet
                }
            }
        )
    }
    $azPrivateIps.ToArray()
}