#/bin/bash
#pass in values, assign, echo

rethinkAuthkey=$1
rethinkPublicIP=$2
authURL="https://" 
authURL+=$3 
authURL+="/auth/mock/"
websocketURL="https://"
websocketURL+=$3
websocketURL+="/"
appURL="https://" 
appURL+=$3
appURL+="/"
appTriproxyURL=$3
devTriproxyURL=$3
storageURL="https://" 
storageURL+=$3
storageURL+="/"
sessionSecret=$4
certLocation=$5
crtLocation=$5
crtLocation+="cert.crt"
keyLocation=$5
keyLocation+="cert.key"
dhparamLocation=$6
dhparamLocation+=dhparam.pem

echo "rethink auth key: $rethinkAuthkey"
echo "rethink public IP: $rethinkPublicIP"
echo "auth URL: $authURL"
echo "websocket URL: $websocketURL"
echo "app URL: $appURL"
echo "app triproxy URL: $appTriproxyURL"
echo "dev triproxy URL: $devTriproxyURL"
echo "storage URL: $storageURL"
echo "session secret: $sessionSecret"
echo "cert location: $5"
echo "certificate cert location: $crtLocation"
echo "certificate key location: $keyLocation"
echo "dhparam pem location: $dhparamLocation"
crtLocation=/home/core/SDTF/ssl/cert.crt
keyLocation=/home/core/SDTF/ssl/cert.key

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
                replace '\\#-e "NODE_TLS_REJECT_UNAUTHORIZED=0"\\' '-e "NODE_TLS_REJECT_UNAUTHORIZED=0"\\' $j
            fi
        fi
    fi
done


#Copy SSL keys to the right place
mkdir -p /srv/nginx
mkdir -p /srv/ssl
cp $crtLocation /srv/ssl/cert.crt
cp $keyLocation /srv/ssl/cert.key
cp $dhparamLocation /srv/ssl/dhparam.pem

#Replace the relevant IPs in nginx.conf
cp nginx.conf /srv/nginx/nginx.conf
replace '192.168.255.100:3100' $STF_APP':3100' /srv/nginx/nginx.conf
replace '192.168.255.150:3200' $STF_AUTH':3200' /srv/nginx/nginx.conf
replace '192.168.255.100:3300' $STF_STORAGE_APK':3300' /srv/nginx/nginx.conf
replace '192.168.255.100:3400' $STF_STORAGE_IMAGE':3400' /srv/nginx/nginx.conf
replace '192.168.255.100:3500' $STF_STORAGE':3500' /srv/nginx/nginx.conf
replace '192.168.255.100:3600' $STF_WEBSOCKET':3600' /srv/nginx/nginx.conf
replace 'stf.example.org' $SERVER_NAME /srv/nginx/nginx.conf

#Enable them with systemctl
for i in $saveDir*
do
    if [[ "$i" == *.service ]]
    then
        if test -f "$i"
        then
            systemctl enable "$i"
        fi
    fi
done

#Start them
systemctl start rethinkdb-proxy-28015.service
systemctl start stf-migrate.service
systemctl start stf-triproxy-app.service
systemctl start stf-triproxy-dev.service
systemctl start stf-storage-temp@3500.service
systemctl start stf-storage-plugin-apk@3300.service
systemctl start stf-storage-plugin-image@3400.service
systemctl start stf-reaper.service
systemctl start stf-websocket@3600.service
systemctl start stf-processor@1.service
systemctl start stf-app@3100.service
systemctl start stf-migrate
