#!/bin/bash
# Created By M Fauzan Romandhoni 
# Sshinjector.net
# For Bussines E-Mail: m.fauzan58@yahoo.com
# TELP/WA : +6283875176829

if [[ $USER != 'root' ]]; then
	echo "Maaf, Anda harus menjalankan ini sebagai root"
	exit
fi
clear

# get the VPS IP
#ip=`ifconfig venet0:0 | grep 'inet addr' | awk {'print $2'} | sed s/.*://`
MYIP=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0' | head -n1`;
#MYIP=$(ifconfig | grep 'inet addr:' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d: -f2 | awk '{ print $1}' | head -1)
if [ "$MYIP" = "" ]; then
	MYIP=$(wget -qO- ipv4.icanhazip.com)
fi
#MYIP=$(wget -qO- ipv4.icanhazip.com)
clear
echo ""
if [ -f "/var/log/openvpn/status.log" ]; then
        line=`cat /var/log/openvpn/status.log | wc -l`
        a=$((3+((line-8)/2)))
        b=$(((line-8)/2))
        echo " "
echo "---------=[ Checking OpenVPN Login ]=----------" 
echo "==============================================="
echo "| Username  |  IP Address  |  Connected Since |"
echo "-----------------------------------------------"
cat /var/log/openvpn/status.log | head -n $a | tail -n $b | cut -d "," -f 1,2,5 | sed -e 's/,/   /g' > /tmp/vpn-login-db.txt
cat /tmp/vpn-login-db.txt
fi
echo ""
echo "-----------------------------------------------"
