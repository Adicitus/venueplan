. "$PSScriptRoot\FetchHashToFetchXML.ps1"

function GetContent {
	[CmdletBinding()]
	param(
		[parameter(Mandatory=$true, ParameterSetName="FetchHash", Position=1)]
		[hashtable]$FetchHash,
		[parameter(Mandatory=$true, ParameterSetName="id", Position=1)]
		[System.guid]$Id,
		[parameter(Mandatory=$true, ParameterSetName="id", Position=2)]
		[string]$EntityName
	)
	
	switch ($PSCmdlet.ParameterSetName) {
		
		"FetchHash" {
			
			$startRender = [datetime]::now
			
			$fetchXML = FetchHashToFetchXML $fetchHash
			
			$endRender = [datetime]::now
			
			"Rendering query took {0}ms" -f ($endRender - $startRender).TotalMilliSeconds | Write-Debug
			
			$startFetch = [datetime]::now
			
			$content = Get-CRMContent -fetchXML $fetchXML
			
			$endFetch = [datetime]::now
			
			
			"Fetch query took {0}ms" -f ($endFetch - $startFetch).TotalMilliSeconds | Write-Debug
			
			return $content
		}
		
		"Id" {
			Get-CRMContent -Id $Id -Entity $EntityName
		}
		
	}
}