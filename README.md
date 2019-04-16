# notarizedCheck.sh

### Overview
Finds apps and KEXTs on local Mac and creates a CSV with notarization status for each found item.  

### Warnings
This tool is in no way shape or form designed to be run en masse accross your Mac fleet.  This is only designed to be run locally on a periodic basis to find out which apps and KEXTs are notarized.

### Credit
Credit to numerous fellow mac admins who posted on slack/twitter/etc info on `stapler` command 

### Usage
- Be sure to have latest XCode with command line tools installed  
- Save script locally  
- `chmod 755 /path/to/script`
- CSV will open when complete.

### Editing Script  
- If you want the script to search your entire Mac - simply remove the `-onlyin` arguments in the `mdfind` command inside the `for foundItem in` loop  
- Or narrow down or broaden your search with less or more `-onlyin` arguments
