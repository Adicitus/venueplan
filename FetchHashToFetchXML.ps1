function FetchHashToFetchXML {
    param($FetchHash)

    function _fetch($hash) {
        $doc = New-Object System.Xml.XmlDocument

        $root = $doc.createElement("fetch")
        $null = $doc.AppendChild($root)

        _attributes_a $root $hash @("mapping") @{ mapping="logical" }

        if ($hash.ContainsKey("Entity")) {
            _entity $doc $root $hash.Entity
        } else {
            _entity $doc $root $hash
        }

        return $doc
    }

    function _entity($doc, $element, $hash) {
        $entity = $doc.createElement("entity")
        $null = $element.AppendChild($entity)

        _attributes_a $entity $hash @("name") @{}

        _entity_body $doc $entity $hash
    }

    function _linkEntity ($doc, $element, $hash) {
        $linkEntity = $doc.createElement("link-entity")
        $null = $element.AppendChild($linkEntity)

        _attributes_a $linkEntity $hash @("name", "to", "from", "alias", "link-type") @{}

        _entity_body $doc $linkEntity $hash
    }

    function _entity_body ($doc, $element, $hash) {
        $hash.Attributes | ? { $_ } | % {
            $attribute = $doc.createElement("attribute")
            $null = $element.AppendChild($attribute)

            if ($_ -is [hashtable]) {
                _attributes_a $attribute $_ @("name", "alias") @{}
            } else {
                _attributes_a $attribute @{name=$_} @("name","alias") @{}
            }
        }

        if ($hash.ContainsKey("Conditions")) {
            $filter = @{
                Conditions=$hash.Conditions
            }

            if ($hash.ContainsKey("Filters")) {
                $filter.Filters = $hash.Filters
            }

            _filter $doc $element $filter
        } else {
            $hash.Filters | ? { $_ } | % {
                _filter $doc $element $_
            }
        }

        $hash.LinkEntities | ? { $_ } | % {
            _linkEntity $doc $element $_
        }
    }

    function _filter($doc, $element, $hash) {
        $filter = $doc.createElement("filter")
        $null = $element.AppendChild($filter)

        _attributes_a $filter $hash @("type") @{type="and"}

        $hash.Conditions | ? { $_ } | % {
            _condition $doc $filter $_
        }

        $hash.Filters | ? { $_ } | % {
            _filter $doc $filter $_
        }

    }

    function _condition($doc, $element, $hash) {
        $condition = $doc.createElement("condition")
        $null = $element.AppendChild($condition)

        if ($hash.v -is [array] ) {
            $hash.v | ? { $_ } | % {
                $value = $doc.createElement("value")
                $null = $condition.AppendChild($value)
                $text = $doc.CreateTextNode($_)
                $null = $value.AppendChild($text)
            }
        } else {
            _attributes_a $condition $hash @("a", "o", "v") @{ }
        }
    }

    function _attributes_a(
        $element,
        $hash,
        $acceptedAttributes,
        $defaults
    ) {

        $acceptedAttributes | ? { $hash.ContainsKey($_) -or $defaults.ContainsKey($_) } | % {
            if ( !($v = $hash[$_]) ) {
                $v = $defaults[$_]
            }
            $element.SetAttribute($_, $v)
        } 

    }


    
    _fetch $FetchHash
}