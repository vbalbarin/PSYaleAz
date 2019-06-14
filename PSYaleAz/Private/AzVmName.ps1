function AzVmName {
    param(
        [Parameter(Mandatory=$True)]
        [AllowNull()]
        [Object] $Vm
    )
    
    if ($Vm) {
        # TODO: Perhaps throw execption if `$<Parameter>` does not have `<member>`. 
        $vmId = $Vm.Id
        if (($vmId) -and !($vmId -eq [String]::Empty)) {   
            [String] $($vmId.Split('/')[-1])
        } else {
            [String] 'None'
        }
    } else {
        [String] 'None'
    }
}