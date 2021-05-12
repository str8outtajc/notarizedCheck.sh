# notarizedCheck.sh

### Overview
Finds apps and KEXTs on local Mac and creates a CSV with the following information for each found item.   
- Notarization Status  
- Codesign Status  
- Universal Binary (M1 Native) Status  


### Warnings
This tool is in no way shape or form designed to be run en masse across your Mac fleet.  This is only designed to be run locally on a periodic basis to find out which apps and KEXTs are notarized.

### Troubleshooting
If when running the script you notice that all applications come back with `Notarized = False`, this may be that you don't have XCode installed for the use of `stapler` or you do but Terminal is set to use the Command Line Tools which doesn't include `stapler`.

To fix this issue, run `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer` in Terminal and then run the script, which will now properly reflect Notarization information.

### Credit
Credit to numerous fellow mac admins who posted on slack/twitter/etc info on `stapler` command

### Usage
- Be sure to have latest XCode with command line tools installed  
- Save script locally  
- `chmod 755 /path/to/script`  
- Run script - `/path/to/script`  
- CSV will open when complete.

### Editing Script  
- If you want the script to search your entire Mac - simply remove the `-onlyin` arguments in the `mdfind` command inside the `for foundItem in` loop  
- Or narrow down or broaden your search with less or more `-onlyin` arguments
