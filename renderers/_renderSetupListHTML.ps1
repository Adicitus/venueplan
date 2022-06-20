{
	param([datetime]$StartDate, [datetime]$EndDate, $SiteFilter="*")
	
	Render-Template -TemplatePath "$PSScriptRoot\templates\HTML\SetupList.active.template.html" -Values @{
		StartDate=$StartDate
		EndDate=$EndDate
		SiteFilter=$SiteFilter
	}
	
}