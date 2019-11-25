#requires -Modules ACGCore

{
	param($StartDate, $EndDate, $SiteFilter)
	
	Render-Template "$PSScriptRoot\templates\HTML\SetupList.active.template.html" @{
		StartDate=$StartDate
		EndDate=$EndDate
		SiteFilter=$SiteFilter
	}
	
}