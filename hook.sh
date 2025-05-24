
trepa="F"

to-config(){
str_col=$(grep -c "" $API_FOLDER"api.txt")
rm -f $API_FOLDER"api1.txt" && touch $API_FOLDER"api1.txt"

for (( i=1;i<=$str_col;i++)); do
test=$(sed -n $i"p" $API_FOLDER"api.txt")
if [ "$i" -eq "$mi_num" ]; then
	echo $ch":"$req >> $API_FOLDER"api1.txt"
else
	echo $test >> $API_FOLDER"api1.txt"
fi
done

cp -f $API_FOLDER"api1.txt" $API_FOLDER"api.txt"
}


if [[ "${REQUEST}" == /in* ]];then	#/in_chat_req -> OK
	trepa="K"
	ch=$(echo $REQUEST | awk -F"_" '{print $2}')
	req=$(echo $REQUEST | awk -F"_" '{print $3}')
	if ! [ -z "$ch" ] && ! [ -z "$req" ]; then
		#if [[ $req =~ ^[0-9]+$ ]]; then
			mi_num=$(cat $API_FOLDER"api.txt" | grep -n $ch":" | awk -F":" '{print $1}' | tr -d '\r')
			old_req=$(cat $fhome"api.txt" | grep $ch":" | awk -F":" '{print $2}' | tr -d '\r')
			if ! [ -z "$mi_num" ]; then
				to-config;
				logger "| CHANGE "$ch":"$req
				#reply "HTTP/1.1 200 OK\nContent-Type: text/html\n| CHANGE "$ch":"$req
				reply "HTTP/1.1 200 OK| CHANGE "$ch":"$req
			else
				echo $ch":"$req >> $API_FOLDER"api.txt"
				logger "| ADD "$ch":"$req
				#reply "HTTP/1.1 200 OK\nContent-Type: text/html\n| ADD "$ch":"$req
				reply "HTTP/1.1 200 OK| ADD "$ch":"$req
			fi
			#reply "HTTP/1.1 200 OK\nContent-Type: text/html\n"
		#else
		#	error
		#fi
	else
		error
	fi
fi
if [[ "${REQUEST}" == /out* ]];then	#/out_chat  -> req
	trepa="K"
	ch=$(echo $REQUEST | awk -F"_" '{print $2}')
	if ! [ -z "$ch" ]; then
		mi_num=$(cat $API_FOLDER"api.txt" | grep -n $ch":" | awk -F":" '{print $1}' | tr -d '\r')
		if ! [ -z "$mi_num" ]; then
			req=$(sed -n $mi_num"p" $API_FOLDER"api.txt"| awk -F":" '{print $2}' | tr -d '\r')
			logger "| OUT "$ch":"$req
			#reply "HTTP/1.1 200 OK\nContent-Type: text/html\n| OUT "$ch":"$req
			reply "HTTP/1.1 200 OK| OUT "$ch":"$req
		else
			error
		fi
	else
		error
	fi
fi
if [[ "${REQUEST}" == "/ping" ]];then
	trepa="K"
	logger "| PONG"
	#reply "HTTP/1.1 200 OK\nContent-Type: text/html\n| PONG"
	reply "HTTP/1.1 200 OK| PONG"
fi
if [[ "${REQUEST}" == "/cls" ]];then
	trepa="K"
	cp -f $API_FOLDER"api.txt" $API_FOLDER"bkp_api_"$(date '+%Y%m%d%H%M%S')".txt"
	rm -f $API_FOLDER"api.txt"
	touch $API_FOLDER"api.txt"
	logger "| CLS "
	#reply "HTTP/1.1 200 OK\nContent-Type: text/html\n| CLS "
	reply "HTTP/1.1 200 OK| CLS "
fi

[ "$trepa" = "F" ] && error;
