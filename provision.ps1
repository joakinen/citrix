# Powershell to automatically provision VM's last/selected Snapshot to a XenDesktop Catalog
# CC-BY-SA Joaquin Herrero 2017 (@joakinen)
# https://creativecommons.org/licenses/by-sa/4.0/
#
# Check https://support.citrix.com/article/CTX129205 for more information
#

# Syntax
#    provision -scheme <scheme-name> [-snapshot <snapshot_name> ]
#
# Explanation
#    This power shell script provisions a XenDesktop Catalog (Scheme) with the last snapshot
#    from the machine acting as Master Image or (optionally) with the selected snapshot

param(
[Parameter(Mandatory=$true)]
[string]$scheme = "", 
[string]$snapshot = ""
)

if ( $snapshot -and !($snapshot -match "(?<cleanSnapshot>.*).snapshot") ) {
		$snapshot = $snapshot + ".snapshot"
	}

Add-PSSnapIn citrix*

if ( $scheme -eq "" ) {
	Write-Host "Error: missing mandatory parameter"
	return
	}

Write-Host "Getting Provisioning Schemes..."
$Schemes = Get-ProvScheme

$found = $false;
foreach ( $thiscat in $Schemes ) {
	$thisScheme = $($thiscat.ProvisioningSchemeName)
	if ( $thisScheme -eq $scheme ) {
		$found = $true;
		$vmPath = "$($thiscat.MasterImageVM)"
	}
}

if ( $found -eq $false ) {
	Write-Host "Error: Scheme $scheme not found."
	return
	} else {
	Write-Host "Scheme found!"
	}

if ( $vmPath -match "(?<cleanVMpath>.*).vm" )
      {
         $vmName = $matches['cleanVMpath'] + ".vm"
      } else {
 	 Write-Host "Error: no .vm found in MasterImageVM field"
	 return
      }
Write-Host "MasterImageVM found!"

Write-Host "Getting Snapshots..."
$snapshots = Get-ChildItem -Recurse -Path "$vmName" 

$selected_snapshot = "none"
foreach ( $this_snapshot in $snapshots ) {
	if ($snapshot) {
		if ($snapshot -eq $this_snapshot) {
			$selected_snapshot = $($this_snapshot.FullPath)
		}
	} else {	
		$selected_snapshot = $($this_snapshot.FullPath)
	}
} 

if ( $snapshot -and $selected_snapshot -eq "none" ) {
	Write-Host "Error: Snapshot $snapshot not found."
	return
	}

#Write-Host $last_snapshot

$templatePSPath = $selected_snapshot

Write-Host "Provisioning Scheme $scheme with Master Image $templatePSPath..."
Publish-ProvMasterVmImage -ProvisioningSchemeName "$scheme" -MasterImageVM "$templatePSPath"
