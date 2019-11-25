function GetVenueAttributeByVenueProperty($venue_property) {
	
	$fetchHash = @{
		Name="cint_venue_attribute"
		Conditions=@{ a="cint_venue_attributeid"; o="eq"; v=$venue_property.cint_venue_attribute_id.id }
	}
	
	GetContent $fetchHash
	
}