function getCourseByCourseDate($course_date) {
	
	$fetchHash = @{
		Name = "cint_course"
	
		Conditions = @(
			@{ a="cint_courseid"; o="eq"; v=$course_date.cint_course_id.Id }
		)
		
	}

	GetContent $fetchHash

}
