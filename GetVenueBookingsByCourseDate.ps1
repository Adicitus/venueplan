function getVenueBookingsByCourseDate($course_date) {
	
	$fetchHash = @{
		Name="cint_venue_booking"
		Conditions=@{ a="cint_course_date_id"; o="eq"; v=$course_date.cint_course_dateid }
	}
	
	GetContent $fetchHash
	
	# $f = [xml](Render-Template -templatePath "$PSScriptRoot\templates\fetchXML\fetchVenueBookingsByCourseDate.xml" -values @{ course_date=$course_date });
	# Get-CrmContent -FetchXml $f
}
