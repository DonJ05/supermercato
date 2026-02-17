#!/bin/bash

if [ $# -ne 1 ];then
	echo "passami il file vendite_buffer_12345.csv"
	exit 1
fi



file=$1
if [ ! -f $file ];then
	echo "il file non esiste"
	exit 1
fi

count=$(tail -n +2 $file | sort | uniq -d)

if [ -z  "$count" ];then
	echo "nel file non ci sono duplicati"
else
	echo "queste righe sono state duplicate più volte:"
        echo "$count"
	#awk -F',' '!rd[$0]++ {print}' $file > tmm && mv tmm $file	
	awk -F',' 'i[$0]==0 {i[$0]++; print}' $file > tmm && mv tmm $file
sleep 1
echo "duplicati eliminati con successo"
fi


LOG="log/log_cassa.log"

if ! grep -q "server_online;online;$file;.*;OK" "$LOG"; then
	curl -X POST -F "file=@$file" http://localhost:8080/upload
	cs=$?
	echo "invio del file al server in corso..."
	sleep 1
else
	echo "file già inviato"
	exit 0
fi
#controlla se il comando curl è andato a buon fine
if [ $cs -eq 0 ];then 
	echo " file inviato con successo al server"
	echo "$(date '+%F %T');INFO;CASSA_01;server_online;online;$file;-;OK;Server raggiunto, invio vendite buffer completato;-;0" >> "$LOG"
else 
	echo " errore nell'invio del file"
fi
