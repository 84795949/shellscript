#!/bin/bash
echo "My IP is 192.168.1.88" > ip.txt
IP=`ifconfig -a | grep inet | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | tr -d "addrs"`

OLD_IP=`sed "s/.* \([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\).*/\1/;s/[^0-9 ]*\([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\).*/\1/" ip.txt`
a=$IP
b=$OLD_IP
cat ip.txt
echo $b -----$a

sed -i "s/$b/$a/g" ip.txt
cat ip.txt
