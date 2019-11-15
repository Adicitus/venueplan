
function makeVenuePlan {
	[CmdletBinding(DefaultParameterSetName="CalendarWeeks")]
	param(
		[Parameter(ParameterSetName="Period", Position=1)][datetime] $StartDate,
		[Parameter(ParameterSetName="Period", Position=2)][datetime] $EndDate,
		[Parameter(ParameterSetName="CalendarWeeks", Position=1)][Int] $Weeks = 1,
		[Parameter(ParameterSetName="CalendarWeeks", Position=2)][Int] $StartFrom = 0,
		[String]$Name		= "VenuePlan",
		[ValidateSet("SetupList", "Overview", "SetupListHTML", "OverviewHTML")][String]$RenderAs = "SetupListHTML",
		$Path		= "$env:USERPROFILE\AppData\local\Temp\$Name.html"
	)

	$startTime = [datetime]::now

	$loadStartTime = [datetime]::now

	. "$PSScriptRoot\..\Get-VenuePlan.ps1"

	$loadFinishTime = [datetime]::now
	
	$collateStartTime = [datetime]::now

	$nextWeek = if ($PSCmdlet.ParameterSetName -eq "Period") {
		Get-VenuePlan -StartDate $StartDate -EndDate $EndDate
	} else {
		Get-VenuePlan -Weeks $weeks -StartFrom $StartFrom
	}
	
	$collateFinishTime = [datetime]::now

	
	$renderStartTime = [datetime]::now

	$renderer  = switch ($RenderAs) {
		"Overview" {
			. "$PSScriptRoot\..\renderers\_formatVenuePlanOverview.ps1"
		}
		
		"SetupList" {
			. "$PSScriptRoot\..\renderers\_formatVenuePlanSetupList.ps1"
		}
		
		"SetupListHTML" {
			. "$PSScriptRoot\..\renderers\_formatVenuePlanSetupListHTML.ps1"
		}
		
		"OverviewHTML" {
			. "$PSScriptRoot\..\renderers\_formatVenuePlanOverviewHTML.ps1"
		}
		
	}
	
	& $renderer $nextWeek > $path

	$renderFinishTime = [datetime]::now

	& $path


	$endTime = [datetime]::now

	"Make took {0} total seconds ({1}s loading, {2}s collating, {3}s rendering)." -f @(
		($endTime - $startTime).TotalSeconds
		($loadFinishTime - $loadStartTime).TotalSeconds
		($collateFinishTime - $collateStartTime).TotalSeconds
		($renderFinishTime - $renderStartTime).TotalSeconds
	) | Write-Host

}