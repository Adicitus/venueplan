## This is a temporary prototyping setup. Needs more work.

{
	param(
		$VenuePlan
	)
	
	$VenuePlan.BySiteName.Keys | Sort | % {
	
		$currentSiteName = $_
		
		("__ {0} " -f $currentSiteName).padRight(80, "_")
		
		$VenuePlan.BySiteName[$currentSiteName] | Sort { $_.course_date.cint_startdate }  | % {
			$class = $_
			$cd = $_.course_date
			$vs = $_.Venues
			
			$siteName = $class.course_date.cint_site_id.Name
			
			"="*80
			
			$indent = 1
			
			
			$id = $cd.cint_course_datenumber
			
			$title = $cd.cint_name
			
			$titleTrunkated = if ($title.Length -gt 60) {
				$title.substring(0, 58) + ".."
			} else {
				$title
			}
			"{0}{1, -60} | {2, -20} " -f @(
				(" "*$indent),
				$titleTrunkated,
				$id
				
			)
			
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
			
			"{0}{1, -10}{2:yyyy-MM-dd HH:mm} -> {3:yyyy-MM-dd HH:mm} ({4})" -f @(
				(" "*$indent),
				$siteName,
				$cd.cint_startdate,
				$cd.cint_enddate,
				($week -join "")
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
			
			"{0}" -f @(
				(" "*$indent)
			)
			
			"{0}{1,-8} {2}" -f @(
				(" "*$indent),
				"Instr.:",
				$cd.cint_teachers
			)
			
			$studentsDefinitive = $_.Reservations | ? { $_.cint_reservationstatus -eq 20 }
			$studentCount = $studentsDefinitive | measure | % Count
			$studentCountAtHome = $studentsDefinitive | ? { $_.cs_remote_participant } | Measure | % Count
			$remoteStudents = @{}
			
			$studentsDefinitive | % {
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
			
			
			$atHomeValue = if ($studentCountAtHome) { ("({0} @Home)" -f $studentCountAtHome) } else { "" }
			$satelliteValue = ($remoteStudents.Keys | % { "{1}x{0}" -f $_, $remoteStudents[$_].Count }) -join " "
			"{0}{1,-8} {2} {3} {4}" -f @(
				(" "*$indent),
				"Delt.:",
				$studentCount,
				$atHomeValue,
				$satelliteValue
			)
			
			
			$venues = $_.Venues | ? { $_.Category.cint_name -ne "LiveClass" }
			
			$circleChar = [System.Text.UTF8Encoding]::UTF8.GetChars(@(0xE2,0x97,0x8B))
			$checklist = ($circleChar * 5) -join " "
			
			$onelineVenue = ($venues | measure ).Count -eq 1
			$venueLabel = if ($onelineVenue) { "Lokal:" } else { "Lokaler:" }
			$venueValue = if ($onelineVenue) {
				$vn = $_.Venues[0].Venue.Name
				"{0} {1}" -f $vn.padRight(45, "."), $checklist
			} else {
				@($venues).Count
			}
			"{0}{1, -8} {2}" -f @(
				(" "*$indent)
				$venueLabel,
				$venueValue
			)
			
			"{0}" -f @(
				(" "*$indent)
			)
			
			$indent = 5
			
			if (!$onelineVenue) {
				$venues | Sort { $_.Venue.Name } | % {
					$v = $_.Venue
					$b = $_.Booking

					$mastertag = if ($b.cs_mastervenue) {
						"[MASTER]"
					} else {
						""
					}
					
					"{0}{2,-8} {1, -45} {3}" -f @(
							(" "*$indent),
							($v.Name.padRight(45, ".")),
							$mastertag,
							$checklist
						)
				}
			}
			
			" "
		}
		
		"_"*80
		"`n"*5
	}
}