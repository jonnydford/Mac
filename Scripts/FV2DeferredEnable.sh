#!/bin/bash
#

# FV2 Enable
# Runs basic checks, if FV2 is not active or deferred and current user is not admin, enables FV2

log() {
if [ "$1" ]; then
    echo $1>>$logPath
fi
}

DATESTAMP=`date`
logPath="/var/log/Deployments/FileVault2.log"
if [ ! -d "/var/log/Deployments" ]; then
    mkdir "/var/log/Deployments"
fi

log "Running FV2 Enable - $DATESTAMP"
log "Computer name: `hostname`"

currentUser=`ls -l /dev/console | awk '{print $3}'`
isUserLoggedIn=`who | grep console | grep $currentUser`

# Quit out if administrator is logged in
if [ $currentUser = "admin" ]; then
    log "administrator logged on, exiting"
    echo "administrator logged on, exiting"
    exit 0
fi

FVStatus=`fdesetup status`

# If FV is already on, exit
isOn=`echo $FVStatus | grep "FileVault is On"`
if [ "$isOn" ]; then
    log "FileVault is On. Exiting."
    echo "FileVault is On. Exiting."
    exit 0
fi

# If FV is in a deferred state already, exit
isDef=`fdesetup status | grep Deferred`
if [ "$isDef" ]; then
    log "$isDef"
    defUserResult=`echo $isDef | awk '{print $9}'`
    strLen=`echo ${#defUserResult}`
    defUsername=`echo "${defUserResult:1:$strLen-3}"`
    log "$defUsername is already set as the deferred FV user. Exiting."
    echo "$defUsername is already set as the deferred FV user. Exiting."
    exit 0
fi

# if FV is encrypting, exit
isEnc=`echo $FVStatus | grep "Encryption in progress"`
if [ "$isEnc" ]; then
    log "$FVStatus"
    echo "$FVStatus"
    exit 0
fi

# if FV is decrypting, exit
isDec=`echo $FVStatus | grep "Decryption in progress"`
if [ "$isDec" ]; then
    log "$FVStatus"
    echo "$FVStatus"
    exit 0
fi

# Make sure user is logged on
if [ ! "$isUserLoggedIn" ]; then
    log "Current console user is not logged on"
    echo "Current console user is not logged on"
    exit 0
fi

log "$currentUser currently logged in"

# All checks passed, enable FV2 for currently logged in user
log "Executing FV2 enable policy"
jamf policy -trigger enableFV2
sleep 5
FVStatus=`fdesetup status`
log "$FVStatus"
echo "$FVStatus"