function _listClassesJSON{
    param(
        [datetime]$StartDate,
        [datetime]$EndDate
    )
    
    $classes = GetContent @{
        name="cint_course_date"

        Attributes="cint_course_dateid"
        
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
    }

    ConvertTo-Json ($classes | % { $_.cint_course_dateid.Guid })

}