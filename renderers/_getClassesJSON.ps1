function _getClassesJSON {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ParameterSetName="ClassId", Position=1)]
        [guid]$Id,
        [Parameter(Mandatory=$true, ParameterSetName="Period", Position=1)]
        [datetime]$StartDate,
        [Parameter(Mandatory=$true, ParameterSetName="Period", Position=2)]
        [datetime]$EndDate
    )
    
    $FetchHash = @{
        name="cint_course_date"

        Attributes=@(
            @{name="cint_course_dateid"; alias="classid"}
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
                )
            }
        )
    }
    
    switch ($PSCmdlet.ParameterSetName) {
        "Period" {
            $FetchHash.Conditions += @(
                @{a="cint_startdate"; o="on-or-after"; v=("{0}" -f $StartDate)}
                @{a="cint_startdate"; o="on-or-before"; v=("{0}" -f $EndDate)}
            )
        }
        "ClassId" {
            $FetchHash.Conditions += @{a="cint_course_dateid"; o="eq"; v=$Id}
        }
    }

    $classes = GetContent $FetchHash

    $classesHash = $classes | ForEach-Object {

        $hash = @{}
        $c = $_

        $_.Attributes.Keys | ForEach-Object {
            $hash[$_] = $c.$_
        }

        $hash
    }

    ConvertTo-Json $classesHash


}