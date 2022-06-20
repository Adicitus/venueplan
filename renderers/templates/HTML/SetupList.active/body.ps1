$siteNames = GetContent @{
    name="site"
    attributes = "name"
} | % name

$siteNames += GetContent @{
    name="cint_site"
    attributes = "cint_name"
} | % Name

$selectedSites = @()
$siteNames | ? {
    $_ -notin $selectedSites
} | ? {
    $cn = $_
    $SiteFilter | ? {
        $cn -like $_
    }
} | % {
    $selectedSites += $_
}

$dataLoadStartTime = [datetime]::Now

$classesLoadStartTime = [datetime]::Now

$classes = GetContent @{
    name="cint_course_date"

    Attributes=@(
        @{name="cint_course_dateid"; alias="id"}
        @{name="cint_course_datenumber"; alias="classnumber"}
        @{name="cint_name"; alias="classtitle"}
        @{name="cint_startdate"; alias="startdate"}
        @{name="cint_enddate"; alias="enddate"}
        @{name="cint_teachers"; alias="teachers"}
    )
    
    Conditions=@(
        @{a="cint_course_status"; o="in"; v=3, 2, 6}
        @{a="cint_course_type_id"; o="not-in"; v=@(
            "{D3CD634C-74D3-E211-BFD1-68B599C06842}"
            "{87FF28B3-A214-E311-BB81-68B599C06842}"
        )}
        @{a="cint_startdate"; o="on-or-after"; v=("{0}" -f $StartDate)}
        @{a="cint_startdate"; o="on-or-before"; v=("{0}" -f $EndDate)}
        @{a="statecode"; o="eq"; v=0}
    )
    
    LinkEntities = @(
        @{
            'link-type'='outer'
            name="site"
            to="cint_site_id"
        
            alias="site"
        
            Attributes = @{ name="name"; alias="sitename" }
        }
        @{
            name="cint_course"
            to="cint_course_id"
            
            alias="course"
            
            Attributes = @{ name="cint_name"; alias="coursetitle"}, @{name="cint_courseid"; alias="courseid"}
        }
    )
}

"<!-- Classes loaded: {0:N2} seconds -->" -f ([datetime]::Now - $classesLoadStartTime).TotalSeconds

$classIds = $classes | % id | % guid
$courseIds = $classes | % courseid
$classesByCourseID = @{}
$classes | % {
    if (-not $classesByCourseID.ContainsKey($_.courseid)) {
        $classesByCourseID[$_.courseid] = @()
    }

    $classesByCourseID[$_.courseid] += $_
}

$bookings = @{}
$bookingsBySite = @{}
$students = @{}
$annotations = @{}

if (!$classIds) {
    return "<div>Inga kurser under den angivna perioden.</div>"
}

# VENUES
$venuesLoadStartTime = [datetime]::Now
GetContent @{
    name="cint_venue_booking"
    
    Attributes = @(
        @{ name="cint_course_date_id"; alias="_classId" }
        # @{ name="cs_mastervenue"; alias="is_master" }
    )
    
    Conditions = @(
        @{a="cint_course_date_id"; o="in"; v=$classIds}
        @{a="statecode"; o="eq"; v=0}
    )
    
    LinkEntities = @{
        name="cint_venue"
        to="cint_venue_id"
        
        Attributes = @{ name="cint_name"; alias="venuename" }
        
        
        LinkEntities = @{
            name="cint_site"
            to="cint_site_id"
            
            Attributes=@{ name="cint_name"; alias="sitename" }

            Conditions=@{ a="cint_name"; o="in"; v=@($selectedSites) }
        }
    }
}| % {
    $cid = $_._classId.Id
    
    if (-not $bookings.ContainsKey($cid)) {
        $bookings[$cid] = @()
    }

    $bookings[$cid] += $_
}

"<!-- Venues loaded: {0:N2} seconds -->" -f ([datetime]::Now - $venuesLoadStartTime).TotalSeconds

$bookings.keys | % { $bookings[$_] } | % {
    if (-not $bookingsBySite.ContainsKey($_.sitename)) {
        $bookingsBySite[$_.sitename] = @()
    }

    $bookingsBySite[$_.sitename] += $_
}

# STUDENTS
$studentsLoadStartTime = [datetime]::Now
GetContent @{
    name="cint_course_reservation"
    
    Attributes = @(
        @{ name="cint_course_date_id"; alias="_classId"}
        @{ name="cs_participation_type"; alias="type" }
    )
    
    Conditions=@(
        @{a="cint_course_date_id"; o="in"; v=$classIds}
        @{a="cint_contact_id"; o="not-null"}
        @{a="cint_reservationstatus"; o="eq"; v=20}
    )
} | % {
    $cid = $_._classId.Id
    if (-not $students.ContainsKey($cid)) {
        $students[$cid] = @()
    }

    $students[$cid] += $_
}

"<!-- Students loaded: {0:N2} seconds -->" -f ([datetime]::Now - $studentsLoadStartTime).TotalSeconds

GetContent @{
    name="annotation"
    
    Attributes="notetext","subject",@{ name="objectid"; alias="_courseId" }
    
    Conditions=@(
        @{ a="objectid"; o="in"; v=$courseIds }
        @{ a="subject"; o="in"; v="deploy.note", "deploy.setup" }
    )
} | % {
    $annotation = $_
    $crid = $annotation._courseId.Id
    if ($cs = $classesByCourseID[$crid]) {
        foreach($c in $cs) {
            $cid = $c.id
            if (-not $Annotations.ContainsKey($cid)) {
                $Annotations[$cid] = @{
                    Course = @()
                    Class  = @()
                    Meta   = @()
                }
            }

            switch ($annotation.subject) {
                "deploy.note" {
                    $Annotations[$cid].Course += $annotation
                }

                "deploy.setup" {
                    $Annotations[$cid].Setup = $annotation
                }
            }
        }
    } 
}


# ANNOTATIONS
$notesLoadStartTime = [datetime]::Now
GetContent @{
    name="annotation"

    Attributes="notetext","subject",@{ name="objectid"; alias="_classId" }

    Conditions=@(
        @{ a="objectid"; o="in"; v=$classIds }
        @{ a="subject"; o="in"; v="deploy.note", "deploy.meta", "deploy.setup" }
    )
} | % {
	$annotation = $_
    $cid = $annotation._classId.Id
    if (-not $Annotations.ContainsKey($cid)) {
        $Annotations[$cid] = @{
            Course = @()
            Class  = @()
            Meta   = @()
        }
    }

    switch ($annotation.Name) {
        "deploy.note" {
            $Annotations[$cid].Class += $annotation
        }

        "deploy.meta" {
            $m = ConvertFrom-Json $annotation.notetext
            $Annotations[$cid].Meta += $m
        }

        "deploy.setup" {
            $Annotations[$cid].Setup = $annotation
        }
    }
}
"<!-- Notes loaded: {0:N2} seconds -->" -f ([datetime]::Now - $notesLoadStartTime).TotalSeconds

$dataLoadEndTime = [datetime]::Now

"<!-- Data load time: {0:N2} seconds -->" -f ($dataLoadEndTime - $dataLoadStartTime).TotalSeconds

$ordering = @{
    "Stockholm" = 1
    "Göteborg" = 2
    "Malmö" = 3
    _other = 100
}

$sitenames = $bookingsBySite.Keys |  Sort -Unique {
    if (!($v = $ordering[$_]))  {
        $v = $ordering._other
        $ordering._other += 1
    }

    return $v
}

foreach($sitename in $sitenames) {
    if ($siteName -eq "LiveClass") {
        continue
    }

    $currentClasses = $classes | ? {
        $bs = $bookings[$_.id]
        $bs | ? { $_.sitename -eq $siteName }
    }

    if ($null -eq $currentClasses) {
        continue
    }

    Render-Template "$TemplateDir\SetupList.active\Site.template.html" @{
        SiteName	= $siteName
        Classes 	= $currentClasses
        Bookings 	= $bookings
        BookingsBySite 	= $bookingsBySite
        Students 	= $students
        Annotations = $annotations
    }

}