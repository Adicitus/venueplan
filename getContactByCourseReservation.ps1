function getContactByCourseReservation($course_reservation) {
	$fetchHash = @{
		Name="contact"
		Conditions = @{ a="contactid"; o="eq"; v=$course_reservation.cint_contact_id.Id }
	}
	
	GetContent $fetchHash
	
	#$f = [xml](Render-Template -templatePath "$PSScriptRoot\templates\fetchXML\fetchContactByCourseReservation.xml" -values @{ course_reservation=$course_reservation });
	#Get-CrmContent -FetchXml $f
}