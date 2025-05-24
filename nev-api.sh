#!/bin/bash
export PATH="$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"

ver="0.22"
fhome=/usr/share/nev-api/

logger()
{
local date1=$(date '+ %Y-%m-%d %H:%M:%S'| sed 's/^[ \t]*//;s/[ \t]*$//')
echo $date1" nev-api:start "$1
}

check_api_port()
{
netstat -tupln| grep 9444 > ${fhome}port_api.txt
coll_str=$(grep -c '' $fhome"port_api.txt"| tr -d '\r')
if [ $coll_str -eq "0" ]; then
	logger "check_api_port port=9444 DOWN"
	cpid=$(sed -n 1"p" $fhome"pid_api.txt" | tr -d '\r')
	kill -9 $cpid
	rm -f $fhome"temp"
	logger "start api"
	${fhome}api.sh &
else
	logger "check_api_port port=9444 OK"
fi
trip=$((trip+1))
}


#-----START--------------
logger "Start nev-api ver="$ver

logger "start api"
${fhome}api.sh &

while true; do
	sleep 2
	check_api_port
done

rm -f $fPID

