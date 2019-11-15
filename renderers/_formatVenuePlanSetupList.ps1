## This is a temporary prototyping setup. Needs more work.

{
	param(
		$VenuePlan
	)
	
	$VenuePlan.VenueNamesBySite.Keys | Sort | % {
		$currentSite = $_
		
		if ($currentSite -eq "LiveClass") {
			return
		}
		
		$indent = 0
		
		("{0}__ {1} " -f (" "*$indent), $currentSite).padRight((80), "_")
		
		
		$VenuePlan.VenueNamesBySite[$currentSite] | Sort | % {
		
			$currentVenueName = $_
				
			$indent = 1
			
			("{0}= [{1}] " -f (" "*$indent), $currentVenueName.ToUpper()).padRight((80), "=")
			
			$VenuePlan.ByVenueName[$currentVenueName] | Sort { $_.course_date.cint_startdate } | % {
				$class = $_
				$cd = $class.course_date
				$id = $cd.cint_course_datenumber
				$v = $class.Venues.Venue | ? { $_.Name -eq $currentVenueName }
				
				$indent = 3
				
				$week = @("M", "T", "O", "T", "F")
				$sd = $cd.cint_startdate
				$ed = $cd.cint_enddate
				$si = $sd.DayOfWeek.value__
				$ei = $ed.DayOfWeek.value__
				
				for ($i = 1; $i -le 5; $i++) {
					if ( ($i -lt $si) -or ($i -gt $ei) ) {
						$week[$i-1] = "_"
					}
				}
				
				$week = $week -join ""
				
				$circleChar = [System.Text.UTF8Encoding]::UTF8.GetChars(@(0xE2,0x97,0x8B))
				$checklist = ($circleChar * 5) -join " "
				
				("{0}== {2} == {3:yyyy-MM-dd HH:mm} -> {4:yyyy-MM-dd HH:mm} == {1} " -f @(
						(" "*$indent),
						$checklist,
						$week,
						$cd.cint_startdate,
						$cd.cint_enddate
					)
				).padRight((80), "=")
			
				$indent = 8
			
				$title = $cd.cint_name
				
				$titleTrunkated = if ($title.Length -gt (60 - $indent)) {
					$title.substring(0, (58 - $indent)) + ".."
				} else {
					$title
				}
				"{0}{1, -$(60 - $indent)} | {2, -20} " -f @(
					(" "*$indent),
					$titleTrunkated,
					$id	
				)
				
				
				$definitiveStudents = $_.Reservations | ? { $_.cint_reservationstatus -eq 20 }
				$studentCount = $definitiveStudents | measure | % Count
				$masterStudents = $definitiveStudents | ? { !($_.cs_remote_participant -or $_.cs_course_reservation_id) }
				$studentCountAtHome = $definitiveStudents | ? { $_.cs_remote_participant } | Measure | % Count
				$remoteStudents = @{}
				
				$definitiveStudents | % {
					$s = $_
					if ($s.cs_course_reservation_id) {
						$class.Venues | ? {
							$_.Booking.cint_venue_bookingid -eq $s.cs_course_reservation_id
						} | % {
							$city = $_.Venue.cint_visitingcity
							if (!$remoteStudents[$city]) {
								$remoteStudents[$city] = @()
							}
							
							$remoteStudents[$city] += $s
						}
					}
				}
				
				$isSatellite = $remoteStudents.Keys -contains $currentSite
				$isMaster = !$isSatellite -and ($remoteStudents.Keys -gt 0)
				$localStudentCount = if ($isSatellite) {
					$remoteStudents[$currentSite] | measure | % Count
				} else {
					$masterStudents | measure | % Count
				}
				$atHomeValue = if ($studentCountAtHome) { ("{0}x@Home" -f $studentCountAtHome) } else { "" }
				$satelliteValue = ($remoteStudents.Keys | % { "{1}x{0}" -f $_, $remoteStudents[$_].Count }) -join " "
				$localStudentValue = if ($isSatellite) { "{0} [LC]" -f $localStudentCount } else { "{0}" -f $localStudentCount }
				if ($isSatellite -or !$isMaster) {
					"{0}{1,-8} {2}" -f @(
						(" "*$indent),
						"Delt.:",
						$localStudentValue
					)
				} else {
					"{0}{1,-8} {2} + {3} {4}" -f @(
						(" "*$indent),
						"Delt.:",
						$localStudentValue,
						$atHomeValue,
						$satelliteValue
					)
				}
				
				"{0}{1,-8} {2}" -f @(
					(" "*$indent),
					"Instr.:",
					$cd.cint_teachers
				)
				
				if ($cd.cint_city) {
					"{0}{1,-8} {2}" -f @(
						(" "*$indent),
						"Ort:",
						$cd.cint_city
					)
				}
				
				if ($cd.cs_version) {
					"{0}{1,-8} {2}" -f @(
						(" "*$indent),
						"Version:",
						$cd.cs_version
					)
				}
				
				if ($cd.cint_course_code) {
					"{0}{1, -8} {2}" -f @(
						(" "*$indent),
						"Kurskod:",
						$cd.cint_course_code
					)
				}
				
			}
			
			"`n"*1
		
		}
		
		"`n"*3
		
	}
	
}