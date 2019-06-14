function AzDataSensitivity {
    param(
        [Parameter(Mandatory=$True)]
        [AllowNull()]
        [HashTable] $Tags
    )

    if (($Tags) -and !($Tags -eq {})) {
        $ds = $Tags.DataSensitivity
        if ($ds) {[String] $ds} else {[String] 'None'}
    } else {
        [String] 'None'
    }
}
