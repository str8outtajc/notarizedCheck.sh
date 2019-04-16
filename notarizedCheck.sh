#!/bin/bash
IFS=$'\n'

if ! hash "$(which stapler)" > /dev/null 2>&1
  then echo -e "\nYou need the latest XCode with stapler CLI to run this tool.\n" ; exit 0
fi

targetCSV=$(mktemp $HOME/Desktop/notarized.XXXX)
clear
echo -e "\nLooking for Applications and KEXTs"
echo -e "CSV will be opened upon completion.\n"
printf "Name,Notarized,Kind,Path" >> ${targetCSV}
for foundItem in $(mdfind -onlyin /Applications -onlyin "/Library/Application Support" -onlyin /Library/Extensions -onlyin /System/Library/Extensions -onlyin "$HOME/Applications" -onlyin "$HOME/Library/Application Support" 'kMDItemKind == "*Application*" || kMDItemKind == "*Kernel Extension*"')
  do
    if stapler validate ${foundItem} > /dev/null 2>&1
      then notarizeStatus=TRUE
    else notarizeStatus=FALSE
    fi
    itemName=$(mdls -raw -name kMDItemDisplayName ${foundItem})
    itemPath=${foundItem}
    itemKind=$(mdls -raw -name kMDItemKind ${foundItem})
    printf "\n$itemName,$notarizeStatus,$itemKind,$itemPath" >> $targetCSV
  done
unset IFS
mv ${targetCSV} ${targetCSV}.csv
echo "CSV is ${targetCSV}.csv"
open $targetCSV.csv
