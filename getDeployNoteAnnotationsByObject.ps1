function getDeployNoteAnnotationsByObject($object) {
	
	$fetchHash = @{
		Name="annotation"
		Attributes="subject", "notetext"
		Conditions=@(
			@{a="objectid"; o="eq"; v=$object.id}
			@{a="subject"; o="eq"; v="deploy.note"}
		)
	}
	
	GetContent $fetchHash
	
}
