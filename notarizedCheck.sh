#!/bin/bash
# Version 1.1

IFS=$'\n'

if ! hash "$(which codesign)" > /dev/null 2>&1
  then echo -e "\nYou need the latest XCode with codesign CLI to run this tool.\n" ; exit 0
fi

targetCSV=$(mktemp $HOME/Desktop/notarized.XXXX)
echo -e "\nLooking for Applications, System Extensions, and KEXTs"
echo -e "CSV will be opened upon completion.\n"
printf "Name,Notarized,Notarized Fail Reason,Codesigned,Codesign Fail Reason,Kind,Architecture,Path" >> ${targetCSV}
itemNumber=0
totalToAnalyze=$(mdfind -count -onlyin /Applications -onlyin "/Library" -onlyin "$HOME/Applications" -onlyin "$HOME/Library/Application Support" 'kMDItemKind == "*Application*" || kMDItemKind == "*System Extension*" || kMDItemKind == "*Kernel Extension*"')
for foundItem in $(mdfind -onlyin /Applications -onlyin "/Library" -onlyin "$HOME/Applications" -onlyin "$HOME/Library/Application Support" 'kMDItemKind == "*Application*" || kMDItemKind == "*System Extension*" || kMDItemKind == "*Kernel Extension*"')
  do
    itemName=$(mdls -raw -name kMDItemDisplayName ${foundItem})
    itemPath=${foundItem}
    itemKind=$(mdls -raw -name kMDItemKind ${foundItem})
    itemArchRaw=$(mdls -raw -name kMDItemExecutableArchitectures ${foundItem})
    if echo "$itemArchRaw" | grep "arm64" > /dev/null 2>&1
      then itemArch="Universal"
    elif echo "$itemArchRaw" | grep "x86" > /dev/null 2>&1
      then itemArch="Intel"
    else itemArch="Other"
    fi
    let "itemNumber = $itemNumber + 1"
    echo -e "\nAnalyzing $itemName ($itemNumber of $totalToAnalyze)"
    if codesign -v ${foundItem} > /dev/null 2>&1
      then
        codesignStatus="TRUE"
        codesignFailReason="NA"
    else
      codesignStatus="FALSE"
      codesignFailReason="$(codesign -v ${foundItem} 2>&1 | head -1 | awk -F ":" '{print $2}' | tr -d ',')"
    fi
    if spctl --assess ${foundItem} > /dev/null 2>&1
      then
        notarizeStatus="TRUE"
        notarizeFailReason="NA"
    else
      notarizeStatus="FALSE"
      notarizeFailReason=$(spctl --assess ${foundItem} 2>&1 > /dev/null | awk -F ':' '{print $NF}')
    fi
    echo "Notarized = $notarizeStatus"
    echo "Codesigned = $codesignStatus"
    echo "Architecture = $itemArch"
    printf "\n$itemName,$notarizeStatus,$notarizeFailReason,$codesignStatus,$codesignFailReason,$itemKind,$itemArch,$itemPath" >> $targetCSV
  done
mv ${targetCSV} ${targetCSV}.csv
echo "CSV is ${targetCSV}.csv"
open $targetCSV.csv
unset IFS

#-onlyin /Applications
