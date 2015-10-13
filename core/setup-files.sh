#!/bin/bash

#change these values to reflect your system. Run this script and personalised versions of the service files will be saved to the directory you provide here
saveDir=/home/mma68/sdtffiletest/
rethinkAuthkey='YOUR_RETHINKDB_KEY_HERE_IF_ANY'
rethinkPublicIP='10.76.71.64'
authURL='https://stf.example.org/auth/mock/'
websocketURL='https://stf.example.org/'
appURL='https://stf.example.org/'
appTriproxyURL='appside.stf.example.org'
devTriproxyURL='devside.stf.example.org'
storageURL='https://stf.example.org/'
sessionSecret='YOUR_SESSION_SECRET_HERE'


#Define the function to replace text in-place in a file
replace() {
    local search=$1
    local replace=$2
    local file=$3
    sed -i "s/${search}/${replace}/g" ${file}
}

#Copy the original files to the given directory
#Runs through all items in current directory
#If item ends in .service and is a file, copy it
for i in * 
do
    if [[ $i == *.service ]]
    then
        if test -f "$i" 
        then
           echo "Copying $i to $saveDir"
           cp $i $saveDir
        fi
    fi
done





#Replace the variables with the given values in the new files

#Enable them with systemctl

#Start them
