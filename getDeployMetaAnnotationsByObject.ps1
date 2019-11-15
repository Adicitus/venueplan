function getDeployMetaAnnotationsByObject($object) {
	
	$fetchHash = @{
		Name="annotation"
		Attributes="subject", "notetext"
		Conditions=@(
			@{a="objectid"; o="eq"; v=$object.id}
			@{a="subject"; o="eq"; v="deplot.meta"}
		)
	}
	
	GetContent $fetchHash
	
	#$f = [xml](Render-Template -templatePath "$PSScriptRoot\templates\fetchXML\fetchDeployMetaAnnotationsByObject.xml" -values @{ object = $object });
	#Get-CrmContent -FetchXml $f
}
