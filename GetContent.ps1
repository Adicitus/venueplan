
function GetContent {
	param(
		$fetchHash
	)
	
	$fetchString = Render-Template "$PSScriptRoot\templates\fetchXML\components\fetch.e.tmplt.xml" $fetchHash
	$fetchXML = [xml]$fetchString
	
	Get-CRMContent -fetchXML $fetchXML
}