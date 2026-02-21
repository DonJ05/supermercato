#!/bin/bash
BUFFER="vendite_buffer.csv"
LOG_FILE="cassa.log"     
CASSA_ID="CASSA_01"      

echo "--- ANALISI BUFFER VENDITE (SVUOTAMENTO SICURO) ---"

# 1. Controllo se il file esiste
if [ ! -f "$BUFFER" ]; then
    echo "ERRORE: Il file $BUFFER non esiste!"
    exit 1
fi

# 2. Conto le vendite (esclusa intestazione)
LINEE=$(wc -l < "$BUFFER")
NUM=$((LINEE - 1))
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

if [ "$NUM" -gt 0 ]; then
    echo "Trovate $NUM vendite nel buffer. Inizio sincronizzazione..."
    
    # --- SIMULAZIONE RISPOSTA SERVER ---
    RISPOSTA="FAIL"

    if [ "$RISPOSTA" == "OK" ]; then
        # Mantiene l'intestazione e cancella il resto
        sed -i '1!d' "$BUFFER"
        
        # SCRIVIAMO NEL LOG IL SUCCESSO
        echo "$TIMESTAMP;INFO;$CASSA_ID;SYNC_DATA;online;$BUFFER;$NUM;SUCCESS;Sincronizzazione completata e buffer svuotato;0;0" >> "$LOG_FILE"
        echo "ESITO: [SUCCESSO] Svuotamento completato."
    else
        # SCRIVIAMO NEL LOG IL FALLIMENTO
        echo "$TIMESTAMP;ERROR;$CASSA_ID;SYNC_DATA;online;$BUFFER;0;FAIL;Errore server: dati mantenuti nel buffer;0;1" >> "$LOG_FILE"
        
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo "ALERT: Errore Server! Dati protetti nel buffer."
        echo "AVVISO: Chiamare assistenza tecnica IT."
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    fi
else
    echo "Il buffer è vuoto. Nessuna operazione necessaria."
fi
