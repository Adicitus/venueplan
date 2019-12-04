$siteNames = GetContent @{
    name="site"
    attributes = "name"
} | % name

$siteNames += GetContent @{
    name="cint_venue_category"
    attributes = "cint_name"
} | % Name


$siteNames | % {
    shoutOut $_ Magenta
}

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



$classes = GetContent @{
    name="cint_course_date"

    Attributes=@(
        @{name="cint_course_dateid"; alias="id"}
        @{name="cint_course_datenumber"; alias="classnumber"}
        @{name="cint_name"; alias="classtitle"}
        @{name="cint_startdate"; alias="startdate"}
        @{name="cint_enddate"; alias="enddate"}
        @{name="cint_teachers"; alias="teachers"}
        @{name="cint_city"; alias="locality"}
        @{name="cs_version"; alias="version"}
        @{name="cint_requirevenuebooking"; alias="requires_venue"}
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
            name="site"
            to="cint_site_id"
        
            alias="site"
        
            Attributes = @{ name="name"; alias="sitename" }
        }
        @{
            name="cint_course"
            to="cint_course_id"
            
            alias="course"
            
            Attributes = @(
                @{ name="cint_name"; alias="coursetitle"}
                @{name="cint_courseid"; alias="courseid"}
                @{name="cint_course_code"; alias="coursecode"}
            )
        }
    )
}


$bookings = @{}
$bookingsBySite = @{}

foreach ($class in $classes) {

    $bookings[$class.id] = GetContent @{
        name="cint_venue_booking"
        
        Attributes = @{ name="cs_mastervenue"; alias="is_master" }
        
        Conditions = @(
            @{a="cint_course_date_id"; o="eq"; v=$class.id}
            @{a="statecode"; o="eq"; v=0}
        )
        
        LinkEntities = @{
            name="cint_venue"
            to="cint_venue_id"
            
            Attributes = @{ name="cint_name"; alias="venuename" }
            
            
            LinkEntities = @{
                name="cint_venue_category"
                to="cint_venue_category_id"
                
                Attributes=@{ name="cint_name"; alias="sitename" }

                Conditions=@{ a="cint_name"; o="in"; v=@($selectedSites) }
            }
        }
    }
    
    $bookings[$class.id] | % {
        if ($bookingsBySite.ContainsKey($_.sitename)) {
            $bookingsBySite[$_.sitename] += $_
        } else {
            $bookingsBySite[$_.sitename] = @($_)
        }
    }
    
}

$sitenames = $classes | % sitename |  Sort -Unique -Descending

foreach($sitename in $sitenames) {
    
    if ($siteName -eq "LiveClass") {
        continue
    }

    $currentClasses = $classes | ? Sitename -eq $sitename
    
    Render-Template "$TemplateDir\ClassOverviewHTML.active\Site.template.html" @{
        SiteName	= $siteName
        Classes 	= $currentClasses
        Bookings 	= $bookings
    }
}