#!/bin/bash

if [ $# -ne 2 ];then
	echo "ERRORE: numero parametro errato, uso: $0 YYYY-MM-DD FILE_Log"
	exit 1
elif [[ ! $1 =~ ^[0-9]{4}\-[0-9]{2}\-[0-9]{2}$ ]];then
	echo "ERRORE: formato data non valido(YYYY-MM-DD)"
	exit 1
elif [[ ! -f $2 ]];then
	echo "ERRORE: $2 -> file non esiste"
	exit 1
fi

if [ ! -s ./log/status_offline.log ];then
	echo "Data;Ora_Offline;Ora_Online;Durata_Secondi" > ./log/status_offline.log
fi

if grep -q -E "^$1" ./log/status_offline.log;then
    echo "ATTENZIONE: il giorno $1 è già presente in status_offline.log"
    exit 1
fi



date="$1"
awk -F';' -v date="$date" '
BEGIN {t1=0}  {if($4 == "server_offline" && date == substr($1,1,10)){
c1=$1
split($1, i, /[- :]/)
t1 = mktime(i[1]" "i[2]" "i[3]" "i[4]" "i[5]" "i[6])
}

if($4 == "server_online" && date == substr($1,1,10)){
 split($1, z, /[- :]/)
 t2 = mktime(z[1]" "z[2]" "z[3]" "z[4]" "z[5]" "z[6])
 if(t1 > 0){
 c2++
 tf=t2-t1
 print date";"substr(c1,12,19)";"substr($1,12,19)";"tf
 t1=0
 }
 }

}' "$2" >> ./log/status_offline.log
