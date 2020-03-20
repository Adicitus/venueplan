function xrmEntityToHash {
    param($obj)

    $hash = @{}
    $obj.Attributes.GetEnumerator() | ? {
        $_.value -is [Microsoft.Xrm.Sdk.AliasedValue]
    } | % {
        $hash[$_.Key] = $_.Value.Value
    }

    return $hash
}