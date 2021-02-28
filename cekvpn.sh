#!/bin/bash

clear
last | grep ppp | grep still | awk '{print " ",$1," - " $3 }' > /tmp/login-db-l2tp.txt;
echo " "
echo " "
echo "===========================================";
echo " "
echo " "
echo "-------------------------------------";
echo "    L2TP/IPSEC VPN User Login";
echo "-------------------------------------";
echo "Username   ---   IP";
echo "-------------------------------------";
cat /tmp/login-db-l2tp.txt
echo " "
echo " "
echo " "
echo "===========================================";
echo " ";
echo " ";
