function GetCourseDates{
	param(
		$startdate=[datetime]::now,
		$enddate=[datetime]::now
	)

	$fetchHash =  @{
		Name = "cint_course_date"
		
		Conditions = @(
			@{a="cint_course_status"; o="in"; v=3, 2, 6}
			@{a="cint_course_type_id"; o="not-in"; v=@(
				"{D3CD634C-74D3-E211-BFD1-68B599C06842}"
				"{87FF28B3-A214-E311-BB81-68B599C06842}"
			)}
			@{a="cint_startdate"; o="on-or-after"; v=('{0:yyyy-MM-dd}' -f $startdate)}
			@{a="cint_startdate"; o="on-or-before"; v=('{0:yyyy-MM-dd}' -f $enddate)}
		)
	}
	
	GetContent $fetchHash
}
