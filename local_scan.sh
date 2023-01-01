#!/bin/bash

declare -a ip_array

OCTETS=$(ifconfig | grep Bcast | cut -d " " -f 12 | cut -d ":" -f 2 | cut -d "." -f 1,2,3 | uniq)
NETMASK=$(ifconfig | grep Bcast | cut -d " " -f 16 | cut -d ":" -f 2 | cut -d "." -f 1,2,3,4 | uniq)

O1=$(echo $NETMASK | cut -d "." -f 1)
O2=$(echo $NETMASK | cut -d "." -f 2)
O3=$(echo $NETMASK | cut -d "." -f 3)
O4=$(echo $NETMASK | cut -d "." -f 4)

let TOTAL_BITS=255-$O4-1
echo "+#######################+"
echo "|----PINGING HOSTS------|"
echo "+#######################+"
echo "\n"
echo "   Netmask: $NETMASK"
echo "\n"

for ip in {1..254}
do
    PING=""
    PING=$(ping -w1 $OCTETS.$ip | grep "64 bytes" | cut -d " " -f4 | tr -d ":")
    if [ "$PING" != "" ]
        then
            ip_array=("${ip_array[@]}" $PING)
        else
            echo "$OCTETS.$ip => $(tput setaf 1)unreachable$(tput setaf 7)"
    fi
done

if [ ${#ip_array[@]} > 0 ]
    then
        echo "+#########################+"        
        echo "|--SCANNING ACTIVE HOSTS--|"
        echo "+#########################+"
        for i in ${ip_array[@]}
        do
            nmap -sS $i
            echo "---------------------"
        done
        echo "\n"
        echo "$(tput setaf 2)Scan finished! $(tput setaf 7)"
    else
        echo "$(tput setaf 1)Nothing to scan $(tput setaf 7)"
fi
exit