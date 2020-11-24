
. "$PSScriptRoot\..\GetContent.ps1"

function makeVenuePlan {
	[CmdletBinding(DefaultParameterSetName="CalendarWeeks")]
	param(
		[Parameter(ParameterSetName="Period", Position=1)][datetime] $StartDate,
		[Parameter(ParameterSetName="Period", Position=2)][datetime] $EndDate,
		[Parameter(ParameterSetName="CalendarWeeks", Position=1)][Int] $Weeks = 1,
		[Parameter(ParameterSetName="CalendarWeeks", Position=2)][Int] $StartFrom = 0,
		[Parameter(Position=3)]$Sites = "*",
		[String]$Name		= "VenuePlan",
		[ValidateSet("SetupListHTML", "VenueOverviewHTML")][String]$RenderAs = "SetupListHTML",
		[string]$Path		= "$env:USERPROFILE\AppData\local\Temp\$Name.html",
		[pscredential]$Credential = $null,
		[Switch]$NoPreview
	)

	$startTime = [datetime]::now

	switch ($PSCmdlet.ParameterSetName) {
		"Period" {
			if ($null -eq $StartDate) {
				$d = ([datetime]::now).Date;
				$v = (7 - $d.DayOfWeek.value__) % 7 + 1;
				$StartDate = $d.AddDays($v)
			}
			
			if ($null -eq $EndDate) {
				$EndDate = $startDate.AddDays(6)
			}
		}
		
		"CalendarWeeks" {
			$d = [datetime]::now.Date
			$daysToNextMonday = ( (7 - $d.dayOfWeek) % 7 ) + 1
			$nextMonday = $d.AddDays($daysToNextMonday).AddDays($StartFrom * 7)
			
			if ($weeks -gt 0) {
				$StartDate 	= $nextMonday
				$EndDate	= $nextMonday.AddDays($Weeks * 7 - 1)
			} else {
				$EndDate	= $nextMonday - 8 # Last Sunday
				$StartDate	= $EndDate.AddDays(-($weeks * 7) + 1)
			}
		}
	}

	
	$renderStartTime = [datetime]::now

	$renderer  = switch ($RenderAs) {
		
		"SetupListHTML" {
			& "$PSScriptRoot\..\renderers\_renderSetupListHTML.ps1"
		}
		
		"VenueOverviewHTML" {
			& "$PSScriptRoot\..\renderers\_renderVenueOverviewHTML.ps1"
		}

	}
	
	& $renderer $StartDate $EndDate $Sites > $path

	$renderFinishTime = [datetime]::now

	if (!$NoPreview) {
		& $path
	}


	$endTime = [datetime]::now

	"Make took {0} total seconds ({1}s rendering)." -f @(
		($endTime - $startTime).TotalSeconds
		($renderFinishTime - $renderStartTime).TotalSeconds
	) | Write-Host

	return $Path

}