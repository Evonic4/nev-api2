#!/bin/bash
export PATH="$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"

API_FOLDER="/usr/share/nev-api/"
fhome="/usr/share/nev-api/"
HOOK_FILE="${API_FOLDER}/hook.sh"
fPID=$fhome"pid_api.txt"
PORT="9444"

logger()
{
local date1=$(date '+ %Y-%m-%d %H:%M:%S'| sed 's/^[ \t]*//;s/[ \t]*$//')
echo $date1" nev-api:api "$1
}


commands(){
    logger "Request : ${REQUEST}"
	REQUEST=$(echo $REQUEST | sed 's/://g')
    source "${HOOK_FILE}"
}

reply(){
	echo "$1" > "${API_FOLDER}/temp"
}

continue(){
    REQUEST=$(echo ${REQUEST} | sed 's/^\///;   s/[^/]*\(\/.*\)/\1/')
}

error(){
	#reply "HTTP/1.1 404 OK\nContent-Type: text/html\n| API Not Found"
	reply "HTTP/1.1 404 | API Not Found"
}

listening(){
    printf "Listening on port ${PORT}"
    while true;do
        cat "${API_FOLDER}/temp" | nc -ln -p ${PORT} -q 1 > >(
       	while read line;do
            line=$(echo "${line}" | tr -d '[\r\n]')
            if echo "${line}" | grep -qE '^GET /' ;then
                REQUEST=$(echo "${line}" | cut -d ' ' -f2)
            elif [ "x${line}" = x ];then
                commands
            fi
            done
        )
    done
    rm -f "${API_FOLDER}/temp"
}

#-----START------
PID=$$
echo $PID > $fPID

logger "Start api"
mkfifo "${API_FOLDER}/temp"
listening

rm -f $fPID
