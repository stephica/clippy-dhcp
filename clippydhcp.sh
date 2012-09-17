#!/bin/bash

conf="./conf/routeset.conf"
currentNetwork=`/usr/sbin/networksetup -getairportnetwork AirPort | awk '{print $4}'`
currentDNS=`/usr/sbin/networksetup -getdnsservers AirPort`

# Test if the config file is readable, and bail if not
if [ ! -e "$conf" ]; then
	echo "Configure file doesn't exist. Exiting"
	exit
fi

if [ ! -r "$conf" ]; then
	echo "Configuration file is unreadable. Exiting."
	exit
fi

source $conf

currentExtGateway=`/sbin/route -n get $extNet | grep gateway | awk '{print $2}'`

if [ -z "$home" ]; then
	echo "Home Network not set. Exiting"
	exit
fi

if [ -z "$extNetGw" ]; then
	echo "External Network Gateway not set. Exiting"
	exit
fi

if [ -z "$customDNS" ]; then
	echo "External Network Gateway not set. Exiting"
	exit
fi

if [ -z "$extNet" ]; then
	echo "External Network not set. Exiting"
	exit
fi

setDNS() {
	/usr/sbin/networksetup -setdnsservers AirPort "$customDNS"
}

addRoute() {
	/sbin/route -n add "$extNet" "$extNetGw"
}

delRoute() {
	/sbin/route -n delete "$extNet"
}

if [ "$currentNetwork" = "$home" ]; then
	if [ "$currentDNS" != "$customDNS" ]; then
		eval "$setDNS"
	fi
	if [ "$currentExtGateway" != "$extNetGw" ]; then
		eval "$addRoute"
	fi
else
	`/usr/sbin/networksetup -setdnsservers AirPort Empty`
	if [ "$currentExtGateway" = "$extNetGw" ]; then
		eval "$delRoute"
        fi
fi
