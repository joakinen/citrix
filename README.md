# citrix
Scripts for Citrix API

## provision.ps1

Powershell to automatically provision VM's last Snapshot to a Delivery Group

Check https://support.citrix.com/article/CTX129205 for more information


### Syntax

$ provision -scheme <scheme-name> [-snapshot <snapshot_name> ]

### Explanation

This power shell script provisions a XenDesktop Catalog (Scheme) with the last snapshot
from the machine acting as Master Image or (optionally) with the selected snapshot
