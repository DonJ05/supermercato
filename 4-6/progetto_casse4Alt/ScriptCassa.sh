#!/bin/bash

SERVER="localhost"
PORT=8000
CSV_FILE="../progetto_casse4Alt/prodotti_default.csv"
TEMP_FILE="../progetto_casse4Alt/Temp_prodotti_default.csv"

if [ $# -ne 0 ]; then
    echo "comando $0 non accetta nessuno argomento"
    exit 1
fi

nc -zw 1 $SERVER $PORT

if [ $? -eq 0 ]; then
    echo "close"|nc -w 1 $SERVER $PORT > $TEMP_FILE
else
    echo "la connessione tra cassa e server non è andata a buon fine, riprovare."
    exit 1
fi

if [ ! -s "$TEMP_FILE" ]; then
    echo "il file non è stato trasmesso correttamente, Riprova"
    rm $TEMP_FILE
    exit 1
fi
Dati_cassa=$(cat $CSV_FILE|tail -n +2)
Dati_server=$(cat $TEMP_FILE|tail -n +2)

diff -bq $CSV_FILE $TEMP_FILE

if [ "$?" -ne 0  ]; then
    cp $TEMP_FILE $CSV_FILE
    rm $TEMP_FILE
    echo "caricamento completato"

else
    echo "Il file del server e della cassa coincidono, niente verrà sovrascritto"
    rm $TEMP_FILE

fi 

