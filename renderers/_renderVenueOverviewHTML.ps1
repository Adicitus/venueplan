{
	param($StartDate, $EndDate, $SiteFilter="*")
	
	Render-Template "$PSScriptRoot\templates\HTML\VenueOverview.active.template.html" @{
        StartDate=$StartDate
        EndDate=$EndDate
        SiteFilter=$SiteFilter
    }
	
}