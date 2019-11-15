function GetVenuePropertiesByVenue($venue) {
	
	$fetchHash = @{
		Name="cint_venue_property"
		Attributes="cint_value", "cint_venue_attribute_id"
		Conditions=@{a="cint_venue_id"; o="eq"; v=$venue.cint_venueid}
	}

	GetContent $fetchHash

}