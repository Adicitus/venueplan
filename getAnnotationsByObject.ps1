function getAnnotationsByObject($object) {
	
	$fetchHash = @{
		Name=annotation
		Conditions=@{ a="objectid"; o="eq"; v=$object.id }
	}
	
	getContent $fetchHash
}
