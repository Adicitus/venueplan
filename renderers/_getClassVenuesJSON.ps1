
function _getClassVenues {
    param([guid]$classid)
    
    $bookings = GetContent @{
        name="cint_venue_booking"
        
        Attributes = @{ name="cs_mastervenue"; alias="is_master" }
        
        Conditions = @(
            @{a="cint_course_date_id"; o="eq"; v=$classid}
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
            }
        }
    }

    
    
    $bookingsHash = $bookings | ForEach-Object {

        $hash = @{}
        $c = $_

        $_.Attributes.Keys | ForEach-Object {
            $hash[$_] = $c.$_
        }

        $hash
    }

    ConvertTo-Json $bookingsHash
}