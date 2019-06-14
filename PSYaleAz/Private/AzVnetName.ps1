function AzVnetName {
    param(
        [Parameter(Mandatory=$True)]
        [AllowNull()]
        [Object] $Subnet
    )

    if ($Subnet) {
        # TODO: Perhaps throw execption if `$<Parameter>` does not have `<member>`. 
        $subnetId = $Subnet.Id
        if (($subnetId) -and !($subnetId -eq [String]::Empty)) {   
            [String] $($SubnetId.Split('/')[8])
        } else {
            [String] 'None'
        }
    } else {
        [String] 'None'
    }
}