#requires -Modules ACGCore

{
	param($StartDate, $EndDate)
	
	Render-Template "$PSScriptRoot\templates\HTML\SetupList.active.template.html" @{ StartDate=$StartDate; EndDate=$EndDate }
	
}