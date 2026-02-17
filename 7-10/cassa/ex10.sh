#!/bin/bash
if [ $# -eq 1 ] && [[ $1 =~ ^[0-9]+$ ]];then
	s=$1
else
	echo "uso: $0 secondi torrelabili"
	exit 1
fi

cassa_time=$(date +%s) 
server_time=$(curl -s -S http://localhost:8080/time 2>error.log)
ora_google=$(date -d "$(curl -sI https://google.com | grep -i '^Date:' | cut -d' ' -f2-)" +%s)

if ! [[ "$server_time" =~ ^[0-9]+$ ]];then
	cat error.log
	rm error.log
	exit 1
fi
dif=$((ora_google - server_time))
dif=${dif#-}
if [ $dif -gt 5 ];then
	echo "anomalia con l'orario del server"
	exit 1
fi
diff=$((server_time - cassa_time)) 
diff=${diff#-}
if [ "$diff" -le $s ];then
	echo "orario sincronizzato entro la tolleranza di $s secondi"
else
	echo "orario non sincronizzato, aggiorno cassa..."
	sudo date -s "@$server_time"
	cassa_time=$(date +%s) 
	echo "orario cassa sistemato"
fi
echo "orario cassa: "
date -d "@$cassa_time"
echo "orario server: " 
date -d "@$server_time"

