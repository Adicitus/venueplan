function GetVenueByVenueBooking($venue_booking) {
	
	$fetchHash = @{
		Name="cint_venue"
		Conditions=@{a="cint_venueid"; o="eq"; v=$venue_booking.cint_venue_id.id}
	}
	
	GetContent $fetchHash
	
	#$f = [xml](Render-Template "$PSScriptRoot\templates\fetchXML\fetchVenueByVenueBooking.xml" -Values @{ venue_booking=$venue_booking })
	#Get-CrmContent -FetchXml $f
}