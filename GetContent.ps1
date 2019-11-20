
#requires -Modules AMSoftware.CRM, ACGCore
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

	try {
		$null = Get-CrmOrganization
		Write-Debug "Already connected to CRM."
	} catch {
		$ex = $_
		if ($_.Exception.message -eq "Not connected with a CRM Deployment. Run Connect-CrmDeployment.") {
			$runasFile = "$PSScriptRoot\runas"
			if (Test-Path $runasFile) {
				try {
					$cred = Load-Credential $runasFile
					$null = Connect-CrmDeployment -DiscoveryUrl "http://crm.addskills.se" -Credential $cred
					$conn = Connect-CrmOrganization cornerstone
					"Connected to CRM using runas-credentials (as '{0}')." -f $cred.Username | Write-Debug
					$conn | Out-string | Write-Debug
				} catch {
					throw $_
				}
			} else {
				throw $ex
			}
		} else {
			throw $ex
		}
	}
	
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