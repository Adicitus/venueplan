{
	param($StartDate, $EndDate, $SiteFilter="*")
	
	Render-Template "$PSScriptRoot\templates\HTML\ClassOverviewHTML.active.template.html" @{
		StartDate=$StartDate
		EndDate=$EndDate
		SiteFilter=$SiteFilter
	}
	
}