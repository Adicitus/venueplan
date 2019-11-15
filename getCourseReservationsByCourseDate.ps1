function getCourseReservationsByCourseDate($course_date) {
	
	$fetchHash = @{
		Name = "cint_course_reservation"
		Conditions = @{a="cint_course_date_id"; o="eq"; v=$course_date.cint_course_dateid}
	}
	
	GetContent $fetchHash
}
