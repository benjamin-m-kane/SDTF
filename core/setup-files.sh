#!/bin/bash

#Example values that match the examples on the github DEPLOYMENT.md page.
#saveDir=/home/mma68/sdtffiletest/
#rethinkAuthkey='YOUR_RETHINKDB_KEY_HERE_IF_ANY'
#rethinkPublicIP='rethinkdb.stf.example.org'
#authURL='https://stf.example.org/auth/mock/'
#websocketURL='https://stf.example.org/'
#appURL='https://stf.example.org/'
#appTriproxyURL='appside.stf.example.org'
#devTriproxyURL='devside.stf.example.org'
#storageURL='https://stf.example.org/'
#sessionSecret='YOUR_SESSION_SECRET_HERE'


#change these values to reflect your system. Run this script and personalised versions of the service files will be saved to the directory you provide here
saveDir=/home/core/sdtffiletest/
rethinkAuthkey='1234'
rethinkPublicIP='10.76.71.63'
authURL='https://10.76.71.8/auth/mock/'
websocketURL='https://10.76.71.8/'
appURL='https://10.76.71.8/'
appTriproxyURL='10.76.71.8'
devTriproxyURL='10.76.71.8'
storageURL='https://10.76.71.8/'
sessionSecret='BASH_TEST'

#Change these to the locations of your SSL certificate files. Use the ones on the git for a self-signed temporary version
crtLocation=/home/core/SDTF/ssl/cert.crt
keyLocation=/home/core/SDTF/ssl/cert.key
dhparamLocation=/home/core/SDTF/ssl/dhparam.pem

#if your certificates are self-signed, set this to 1 and we'll add the appropriate "ignore" lines in the relevant service files
selfsigned=1

#Define the function to replace text in-place in a file
replace() {
    local search=$1
    local replace=$2
    local file=$3
    sed -i "s,${search},${replace},g" ${file}
}

#Copy the original files to the given directory
#Runs through all items in current directory
#If item ends in .service and is a file, copy it
mkdir -p $saveDir
for i in * 
do
    if [[ "$i" == *.service ]]
    then
        if test -f "$i" 
        then
           echo "Copying $i to $saveDir"
           cp "$i" $saveDir
        fi
    fi
done

#Replace the variables with the given values in the new files
for j in $saveDir*
do
    if [[ "$j" == *.service ]]
    then
        if test -f "$j"
        then
            echo "Replacing values in $j"
            replace 'YOUR_RETHINKDB_AUTH_KEY_HERE_IF_ANY' $rethinkAuthkey $j
            replace 'RETHINKDB_PUBLIC_IP' $rethinkPublicIP $j
            replace 'AUTH_URL' $authURL $j
            replace 'WEBSOCKET_URL' $websocketURL $j
            replace 'APP_URL' $appURL $j
            replace 'APP_TRIPROXY' $appTriproxyURL $j
            replace 'DEV_TRIPROXY' $devTriproxyURL $j
            replace 'STORAGE_URL' $storageURL $j
            replace 'YOUR_SESSION_SECRET_HERE' $sessionSecret $j
            if [[ $selfsigned == 1 ]]
            then
                replace '\#-e "NODE_TLS_REJECT_UNAUTHORIZED=0"\' '-e "NODE_TLS_REJECT_UNAUTHORIZED=0"\' $j
            fi
        fi
    fi
done


#Copy SSL keys to the right place
mkdir -p /srv/nginx
mkdir -p /srv/ssl
cp $crtLocation /srv/ssl/cert.crt
cp $keyLocation /srv/ssl/cert.key
cp $dpharamLocation /srv/ssl/dhparam.pem

#Replace the relevant IPs in nginx.conf
cp nginx.conf /srv/nginx/nginx.conf
replace '192.168.255.100:3100' $
replace '192.168.255.150:3200' $
replace '192.168.255.100:3300' $
replace '192.168.255.100:3400' $
replace '192.168.255.100:3500' $
replace '192.168.255.100:3600' $
replace 'stf.example.org' $

#Enable them with systemctl
for i in $saveDir*
do
    if [[ "$i$ == *.service ]]
    then
        if test -f "$i"
        then
            #nothing yet
        fi
    fi
done

#Start them
