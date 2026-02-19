#!/bin/bash

FILE_CRITICI=( "prodotti_default.csv" "cassa.log" "vendite_buffer.csv" )

if [ $# -ne 0 ]; then
    echo "comando $0 non accetta nessuno argomento"
    exit 1
fi

for file in ${FILE_CRITICI[@]}; do
    userPerms=$(ls -l | grep $file |cut -d " " -f 3,4,9)
    filePerms=$(ls -l | grep $file| grep -e "-rw-------"| cut -d " " -f1)
    
    if [ ! -e $file ]; then
        touch $file
    fi
    if [[ "$userPerms" != "root root" && "$filePerms" != "-rw-------" ]]; then
        chown root:root $file
        chmod 600 $file
        echo "$file:permessi impostati"
    else
        echo "$file: questo file ha già i permessi impostati"
    fi

done