function _getClassStudents{
    param([guid]$classid)

    $students = GetContent @{
        name="cint_course_reservation"
        
        Attributes = @(
            @{ name="cs_course_reservationid"; alias="id" }
            @{ name="cs_remote_participant"; alias="is_athome" }
            @{ name="cs_course_reservation_id"; alias="satellite_id" }
        )
        
        Conditions=@(
            @{a="cint_course_date_id"; o="eq"; v=$classid}
            @{a="cint_reservationstatus"; o="eq"; v=20}
        )

        LinkEntities=@{
            "link-type"="outer"
            name="cint_venue_booking"
            to="cs_course_reservation_id"

            LinkEntities = @{
                "link-type"="outer"
                name="cint_venue"
                to="cint_venue_id"

                Attributes = @{name="cint_visitingcity"; alias="sitename"}
            }
        }
    }

    $studentsHash = $students | ForEach-Object {

        $hash = @{}
        $c = $_

        $_.Attributes.Keys | ForEach-Object {
            $hash[$_] = $c.$_
        }

        $hash
    }

    ConvertTo-Json $studentsHash
}