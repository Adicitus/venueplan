function _listClassesJSON{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ParameterSetName="Date")]
        [dateTime]$Date,
        [Parameter(Mandatory=$true, ParameterSetName="Range")]
        [datetime]$StartDate,
        [parameter(Mandatory=$true, ParameterSetName="Range")]
        [datetime]$EndDate
    )

    "Query started on {0}" -f [datetime]::Now
    $query = @{
        name="cint_course_date"

        Attributes=@{name="cint_course_dateid"; alias="classId"}, @{ name="modifiedon"; alias="modifiedOn" }
        
        Conditions=@(
            @{a="cint_course_status"; o="in"; v=3, 2, 6}
            @{a="cint_course_type_id"; o="not-in"; v=@(
                "{D3CD634C-74D3-E211-BFD1-68B599C06842}"
                "{87FF28B3-A214-E311-BB81-68B599C06842}"
            )}
            @{a="statecode"; o="eq"; v=0}
        )
    }

    switch ($PSCmdlet.ParameterSetName) {
        Range {
            $query.Conditions += @{a="cint_startdate"; o="on-or-after"; v=("{0}" -f $StartDate)}
            $query.Conditions += @{a="cint_startdate"; o="on-or-before"; v=("{0}" -f $EndDate)}
        } else {
            $s = $Date.Date
            $e = $s.AddHours(24)
            $query.Conditions += @{a="cint_startdate"; o="on-or-after"; v=("{0}" -f $s)}
            $query.Conditions += @{a="cint_startdate"; o="on-or-before"; v=("{0}" -f $e)}
        }
    }

    $classes = GetContent $query
    "Query stopped on {0}" -f [datetime]::Now
    
    "Render started on {0}" -f [datetime]::Now

    $classArray = [System.Collections.ArrayList]::new()
    foreach ($class in $classes) {
        $classArray.add(@{ Id=$class.Id;Modified = $class.modifiedOn}) | Out-Null
    }

    ConvertTo-Json $classArray
    "Render stopped on {0}" -f [datetime]::Now

}