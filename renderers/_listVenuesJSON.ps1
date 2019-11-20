function _listVenusJSON{
    param()
    
    $venueIds = GetContent @{
        name="cint_venue"

        Attributes="cint_venueid"
        
        Conditions=@(
            @{a="statecode"; o="eq"; v=0}
        )
    }

    ConvertTo-Json ($venueIds | % { $_.cint_venueid.Guid })

}