# Cat-SetImage.ps1
# Powershell to automatically update Master Image from XenDesktop Catalog
# CC-BY-SA Joaquin Herrero 2017 (@joakinen)
# https://creativecommons.org/licenses/by-sa/4.0/
#
# Check https://support.citrix.com/article/CTX129205 for more information
#

# Syntax
#    Cat-SetImage [ -scheme <scheme-name> [-list | -snapshot <snapshot_name> ] ]
#
# Explanation
#    This power shell script updates a XenDesktop Catalog (Scheme) with the last snapshot available
#    from the machine acting as Master Image or with the selected snapshot.
#    Optionally it cal only list all the snapshots available

param(
[switch] $help,
[switch] $list,
[string] $scheme = "", 
[string] $snapshot = ""
)

if ( $help ) {
Write-Host "Syntax"
Write-Host "   Cat-SetImage [ -scheme <scheme-name> [-list | -snapshot <snapshot_name> ] ]" -ForegroundColor green
Write-Host "Examples"
Write-Host "   Cat-SetImage                                   Lists schemes available" -ForegroundColor DarkGray
Write-Host "   Cat-SetImage -scheme SC1 -list                 Lists snapshots from scheme SC1" -ForegroundColor DarkGray
Write-Host "   Cat-SetImage -scheme SC1                       Update scheme SC1 with last snapshot available" -ForegroundColor DarkGray
Write-Host "   Cat-SetImage -scheme SC1 -snapshot SNAP-1567   Update scheme SC1 with snapshot named SNAP-1567" -ForegroundColor DarkGray
Write-Host "   Cat-SetImage -help                             This help" -ForegroundColor DarkGray
return
}

if ( $snapshot -and !($snapshot -match "(?<cleanSnapshot>.*).snapshot") ) {
		$snapshot = $snapshot + ".snapshot"
	}

Add-PSSnapIn citrix*

Write-Host "Getting Provisioning Schemes..."

if ($scheme) {

    $Schemes = Get-ProvScheme
    $found = $false;
    foreach ( $thiscat in $Schemes ) {
	    $thisScheme = $($thiscat.ProvisioningSchemeName)
        if ( $thisScheme -eq $scheme ) {
            $found = $true;
		    $vmPath = "$($thiscat.MasterImageVM)"
        }
    }
} else {
    $Schemes = Get-BrokerCatalog
    foreach ( $thiscat in $Schemes ) {
        Write-Host "$($thiscat.Name)" -foregroundcolor green
        Write-Host "    $($thiscat.Description)"
        Write-Host "    Type $($thiscat.AllocationType)"
        Write-Host "    User changes $($thiscat.PersistUserChanges)"
    }
    return
}


if ( $found -eq $false ) {
	Write-Host "Error: Scheme $scheme not found." -foregroundcolor red
	return
	} else {
	Write-Host "Scheme found!"
	}

if ( $vmPath -match "(?<cleanVMpath>.*).vm" )
      {
         $vmName = $matches['cleanVMpath'] + ".vm"
      } else {
 	 Write-Host "Error: no .vm found in MasterImageVM field" -foregroundcolor red
	 return
      }
Write-Host "MasterImageVM $vmName found!" -foregroundcolor yellow

Write-Host "Getting Snapshots..."
$snapshots = Get-ChildItem -Recurse -Path "$vmName" 

$selected_snapshot_fullpath = "none"
$selected_snapshot_name = "none"
foreach ( $this_snapshot in $snapshots ) {
	if ($snapshot) {
		if ($snapshot -eq $this_snapshot) {
			$selected_snapshot_fullpath = $($this_snapshot.FullPath)
            $selected_snapshot_name = $($this_snapshot.Name)
		}
	} else {	
        if ( $list ) {
            Write-Host ($($this_snapshot)) -foregroundcolor green
        } else {
		    $selected_snapshot_fullpath = $($this_snapshot.FullPath)
            $selected_snapshot_name = $($this_snapshot.Name)
        }
	}
} 

if ($list) { return }

if ( $snapshot -and $selected_snapshot_fullpath -eq "none" ) {
	Write-Host "Error: Snapshot $snapshot not found." -foregroundcolor red
	return
	}


$templatePSPath = $selected_snapshot_fullpath

$date_start = Get-Date
$ds_hour = $date_start.Hour 
$ds_min  = $date_start.Minute
$ds_hms  = -join($ds_hour, ":", $ds_min)
Write-Host ("[$ds_hms] Provisioning Scheme $scheme with Master Image '$selected_snapshot_name'...") -foregroundcolor green
Publish-ProvMasterVmImage -ProvisioningSchemeName "$scheme" -MasterImageVM "$templatePSPath"
