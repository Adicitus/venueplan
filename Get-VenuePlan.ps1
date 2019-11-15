#requires -Modules AMSoftware.CRM, ACGCore

Connect-CRMDeployment -DiscoveryUrl "http://crm.addskills.se"
Connect-CRMOrganization -Name "cornerstone"

. "$PSScriptRoot\GetContent.ps1"
. "$PSScriptRoot\GetCourseDates.ps1"
. "$PSScriptRoot\getSiteByCourseDate.ps1"
. "$PSScriptRoot\getCourseByCourseDate.ps1"
. "$PSScriptRoot\getVenueBookingsByCourseDate.ps1"
. "$PSScriptRoot\getCourseReservationsByCourseDate.ps1"
. "$PSScriptRoot\getContactByCourseReservation.ps1"
. "$PSScriptRoot\getVenueByVenueBooking.ps1"
. "$PSScriptRoot\getVenueCategoryByVenue.ps1"
. "$PSScriptRoot\getVenuePropertiesByVenue.ps1"
. "$PSScriptRoot\getVenueAttributeByVenueProperty.ps1"
. "$PSScriptRoot\getDeployMetaAnnotationsByObject.ps1"
. "$PSScriptRoot\getDeployNoteAnnotationsByObject.ps1"


function  Get-VenuePlan  {
	[CmdletBinding(DefaultParameterSetName="CalendarWeeks")] 
	param(
		[parameter(ParameterSetName="Period")][datetime]$StartDate,
		[parameter(ParameterSetName="Period")][datetime]$EndDate,
		[parameter(ParameterSetName="CalendarWeeks")][Int]$Weeks = 1,
		[parameter(ParameterSetName="CalendarWeeks")][Int]$StartFrom = 0
	)
	
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
	
	$venuePlan = @{}
	
	$VenuePlan.StartDate = $startDate
	$VenuePlan.EndDate = $endDate
	$VenuePlan.All = @()
	$VenuePlan.BySiteName = @{}
	$VenuePlan.ByVenueName = @{}
	$VenuePlan.ByCourseDateNumber = @{}
	$VenuePlan.VenueNamesBySite = @{}
	
	GetCourseDates $StartDate $EndDate | % {
		$cd = $_
		$siteName = $cd.cint_site_id.Name
		
		$class = @{
			Course_date = $cd
			Course  = getCourseByCourseDate $cd
			CourseDateMetaAnnotations = getDeployMetaAnnotationsByObject $cd
			CourseDateNoteAnnotations = getDeployNoteAnnotationsByObject $cd
			Venues = @()
			Reservations = getCourseReservationsByCourseDate $cd
			Site = getSiteByCourseDate $cd
			Contacts = @{}
		}
		$class.CourseMetaAnnotations = getDeployMetaAnnotationsByObject $class.Course
		$class.CourseNoteAnnotations = getDeployNoteAnnotationsByObject $class.Course
		
		$class.Reservations | % {
			if ($_.cint_contact_id) {
				$c = getContactByCourseReservation $_
				
				$class.Contacts[$c.contactid]  = $c
			}
		}
		
		
		if ($VenuePlan.BySiteName.Keys -notcontains $siteName) {
			$VenuePlan.BySiteName[$siteName] = @($class)
		} else {
			$VenuePlan.BySiteName[$SiteName] += $class
		}
		
		$venuePlan.All += $class
		$VenuePlan.ByCourseDateNumber[$class.course_date.cint_course_datenumber] = $class
		
		$vBookings = getVenueBookingsByCourseDate $cd;
		$vBookings | ? {
			$b = @{ booking = $_ }
			$v = GetVenueByVenueBooking $_;
			$vc = GetVenueCategoryByVenue $v;
			$b.Venue = $v
			$b.Category = $vc
			$b.Properties = @()
			getVenuePropertiesByVenue $v | % { $b.Properties += @{ Property=$_; Attribute=(getVenueAttributeByVenueProperty $_) } }
			$class.venues += $b
			
			if ($VenuePlan.VenueNamesBySite.Keys -contains $vc.Name ) {
				if ($VenuePlan.VenueNamesBySite[$vc.Name] -notcontains $v.Name) {
					$VenuePlan.VenueNamesBySite[$vc.Name] += $v.Name
				}
 			} else {
				$VenuePlan.VenueNamesBySite[$vc.Name] = @($v.Name)
			}
			
			
			if ($VenuePlan.ByVenueName.Keys -contains $v.Name) {
				$VenuePlan.ByVenueName[$v.Name] += $class
			} else {
				$VenuePlan.ByVenueName[$v.Name] = @($class)
			}
		}
		
		# Process meta annotations.
		$metaconfig = @{}
		$class.CourseMetaAnnotations | ? { $_ } | % {
			$metaconfig = Parse-ConfigFile -Content $_.notetext -Config $metaconfig
		}
		
		$class.CourseDateMetaAnnotations | ? { $_ } | % {
			$metaconfig = Parse-ConfigFile -Content $_.notetext -Config $metaconfig
		}
		
		$class.Meta = $metaconfig
	}
	
	$venuePlan.All | % {
		$class = $_
		if ($parentNumber = $class.Meta.Relations.ChildOf) {
			$parentClass = $venuePlan.ByCourseDateNumber[$parentNumber]
			if ($parentClass.Children) {
				$parentClass.Children += $class
			} else {
				$parentClass.Children = @($class)
			}
		}
	}
	
	return $venuePlan
}