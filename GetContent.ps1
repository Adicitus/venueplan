#requires -Modules AMSoftware.CRM
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
			
			$lazyContent = Get-CRMContent -fetchXML $fetchXML
			
			$endFetch = [datetime]::now
			
			"Fetch query took {0}ms" -f ($endFetch - $startFetch).TotalMilliSeconds | Write-Debug
			
			$startLazyLoading = [datetime]::now
			$fullContent = @()
			
			# Going through and getting values for all properties into a hashtable.
			#
			# Calling lazy properties (like attributes from Link-Entity) on the
			# native objects causes data to be loading from the server.
			#
			# These calls can be very expensive, and if the property is accessed a
			# lot it will generated a massive amount of overhead and slowing rendering
			# Down massively for large data sets.
			#
			# So therefore we make all calls here once, and cache the results in a
			# hashtable.
			foreach ($c in $lazyContent) {
				$h = @{}
				
				$c | Get-Member -MemberType Property | % {
					$n = $_.Name
					$h.$n = $c.$n
				}
				
				$fullContent += $h
			}
			
			"Loading of lazy properties took {0}ms" -f ([datetime]::now - $startLazyLoading).TotalMilliSeconds | Write-Debug
			
			return $fullContent
		}
		
		"Id" {
			Get-CRMContent -Id $Id -Entity $EntityName
		}
		
	}
}