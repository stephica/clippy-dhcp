#!/bin/bash
#
#Copyright (c) 2012, Ben Sykes
#All rights reserved.
#
#Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
#
#Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
#Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
#THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

conf="./conf/clippydhcp.conf"
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
