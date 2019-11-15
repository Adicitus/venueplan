function getSiteByCourseDate($course_date) {
	
	$fetchHash = @{
		Name="site"
		Conditions=@{ a="siteid"; o="eq"; v=$course_date.cint_site_id.Id }
	}
	
	GetContent $fetchHash
	
	#$f = [xml](Render-Template -templatePath "$PSScriptRoot\templates\fetchXML\fetchSiteByCourseDate.xml" -values @{ course_date=$course_date });
	#Get-CrmContent -FetchXml $f
}
