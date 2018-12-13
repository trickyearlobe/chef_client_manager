#!/bin/sh

function install_chefclient(){
 rpm -ivh /opt/ChefClientUpdater/PackageCache/$1
}

function uninstall_chefclient(){
  pkill -9 chef-client
  rpm -e chef --nodeps
}

function download_chefclient(){
  wget --no-check-certificate -P /opt/ChefClientUpdater/PackageCache $1
}

function start_chefclient(){
  if [ $1 ]
  then
    chef-client -o $1T
  else
    chef-client
fi
}

JQ_EXISTS=$(rpm -qa jq)
if [ $? -ne 0 ]
  then
    yum install -y epel-release jq
fi
# Get configuration form file 
CONFIG=$(cat /opt/ChefClientUpdater/config.json)
URL=$(echo $CONFIG | jq '.desired.package.url' | awk '{split($0,a,"\""); print a[2]}')
DEFAULT_RUNLIST=$(echo $CONFIG | jq '.client.rb.default_runlist' | awk '{split($0,a,"\""); print a[2]}')
PACKAGE_NAME=$(echo $URL | awk -F '/' '{print $NF}')
DESIRED_VERSION=$(echo $CONFIG | jq '.desired.package.version' | awk '{split($0,a,"\""); print a[2]}' )
FORCE_CLEANUP=$(echo $CONFIG | jq '.updater.force_cleanup')

#Check currently installed version of chef-client
INSTALLED_VERSION=$(rpm -qa chef | awk '{split($0,a,".el"); print a[1]}' | awk '{split($0,a,"chef-"); print a[2]}')
if [ $? -ne 0 ]
  then
    INSTALLED_VERSION=''
  else
    INSTALLED_VERSION="$INSTALLED_VERSION"
fi

if ! [ $DESIRED_VERSION == $INSTALLED_VERSION ]
  then
    #Download new version of chef-client
    download_chefclient $URL
    #Uninstall old version of chef-client
    uninstall_chefclient
    #Install new version of chef-client
    install_chefclient $PACKAGE_NAME
    #Start chef-client
    start_chefclient $DEFAULT_RUNLIST
fi

if [ $FORCE_CLEANUP ]
  then
    rm -f /etc/cron.d/ChefClientUpdater
    rm -rf /opt/ChefClientUpdater
fi
