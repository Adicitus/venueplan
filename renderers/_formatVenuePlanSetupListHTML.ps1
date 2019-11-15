#requires -Modules ACGCore

{
	param($VenuePlan)
	
	Render-Template "$PSScriptRoot\templates\HTML\SetupList.template.html" @{ VenuePlan = $VenuePlan }
	
}