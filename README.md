# citrix
Scripts for Citrix API

## Cat-SetImage.ps1

This power shell script updates a XenDesktop Catalog (Scheme) with the last snapshot available
from the machine acting as Master Image or with the selected snapshot.
Optionally it cal only list all the snapshots available

Check https://support.citrix.com/article/CTX129205 for more information


### Syntax

$ Cat-SetImage -scheme <scheme-name> [-snapshot <snapshot_name> ] [-list]

### Explanation

This power shell script provisions a XenDesktop Catalog (Scheme) with the last snapshot
from the machine acting as Master Image or (optionally) with the selected snapshot.

If you enter -list parameter it will only list all snapshots available.
