function GetVenueCategoryByVenue($venue) {
	
	$fetchHash = @{
		Name="cint_venue_category"
		Conditions=@{a="cint_venue_categoryid"; o="eq"; v=$venue.cint_venue_category_id.id }
	}

	GetContent $fetchHash

	# $f = [xml](Render-Template "$PSScriptRoot\templates\fetchXML\fetchVenueCategoryByVenue.xml" -Values @{ venue=$venue })
	# Get-CrmContent -FetchXml $f
}