#!/bin/bash
# Version 1.1

IFS=$'\n'

if ! hash "$(which stapler)" > /dev/null 2>&1
  then echo -e "\nYou need the latest XCode with stapler CLI to run this tool.\n" ; exit 0
fi
if ! hash "$(which codesign)" > /dev/null 2>&1
  then echo -e "\nYou need the latest XCode with codesign CLI to run this tool.\n" ; exit 0
fi

targetCSV=$(mktemp $HOME/Desktop/notarized.XXXX)
clear
echo -e "\nLooking for Applications and KEXTs"
echo -e "CSV will be opened upon completion.\n"
printf "Name,Notarized,Codesigned,Codesign Fail Reason,Kind,Path" >> ${targetCSV}
itemNumber=0
totalToAnalyze=$(mdfind -count -onlyin /Applications -onlyin "/Library/Application Support" -onlyin /Library/Extensions -onlyin /System/Library/Extensions -onlyin "$HOME/Applications" -onlyin "$HOME/Library/Application Support" 'kMDItemKind == "*Application*" || kMDItemKind == "*Kernel Extension*"')
for foundItem in $(mdfind -onlyin /Applications -onlyin "/Library/Application Support" -onlyin /Library/Extensions -onlyin /System/Library/Extensions -onlyin "$HOME/Applications" -onlyin "$HOME/Library/Application Support" 'kMDItemKind == "*Application*" || kMDItemKind == "*Kernel Extension*"')
  do
    itemName=$(mdls -raw -name kMDItemDisplayName ${foundItem})
    itemPath=${foundItem}
    itemKind=$(mdls -raw -name kMDItemKind ${foundItem})
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
    if stapler validate ${foundItem} > /dev/null 2>&1
      then notarizeStatus="TRUE"
    else notarizeStatus="FALSE"
    fi
    echo "Notarized = $notarizeStatus"
    echo "Codesigned = $codesignStatus"
    printf "\n$itemName,$notarizeStatus,$codesignStatus,$codesignFailReason,$itemKind,$itemPath" >> $targetCSV
  done
mv ${targetCSV} ${targetCSV}.csv
echo "CSV is ${targetCSV}.csv"
open $targetCSV.csv
unset IFS

#-onlyin /Applications
