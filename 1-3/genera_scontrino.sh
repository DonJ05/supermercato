#!/bin/bash
# Script 3: genera_scontrino.sh

BUFFER="vendite_buffer.csv"
PRODOTTI="prodotti_default.csv"
LOG_FILE="cassa.log"
CASSA_ID="CASSA_01"

# 1. Recupero dell'ultimo ID Scontrino dal buffer
ID_SC=$(grep -ve '^$' "$BUFFER" | tail -n 1 | cut -d',' -f1)

# Controllo se il buffer è vuoto o se abbiamo preso l'intestazione
if [ -z "$ID_SC" ] || [ "$ID_SC" == "scontrino_id" ]; then
    echo "ERRORE: Nessuna vendita valida presente nel buffer."
    exit 1
fi

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# 2. Estetica dello scontrino
echo "=========================================="
echo "      SUPERMERCATO - USCITA CLIENTE       "
echo "ID SCONTRINO: $ID_SC"
echo "Data: $TIMESTAMP"
echo "------------------------------------------"

# 3. Ciclo di lettura prodotti
# Usiamo grep per isolare solo le righe dell'ultimo scontrino
grep "$ID_SC" "$BUFFER" | while IFS=',' read -r s_id v_id c_id p_id qta prezzo totale giorno ora metodo; do
    
    # Cerchiamo il NOME nel file prodotti (colonna 3)
    NOME_PROD=$(grep "^$p_id," "$PRODOTTI" | cut -d',' -f3)
    
    # Se il prodotto non è nel database locale
    if [ -z "$NOME_PROD" ]; then NOME_PROD="Articolo $p_id"; fi
    
    # SOLUZIONE ERRORE: Aggiunto -- per stampare il trattino senza errori
    printf -- "- %-25s (x%s): €%s\n" "$NOME_PROD" "$qta" "$totale"
done

# 4. Calcolo del totale con AWK
TOTALE_SC=$(grep "$ID_SC" "$BUFFER" | awk -F',' '{sum += $7} END {printf "%.2f", sum}')

echo "------------------------------------------"
echo "TOTALE DA PAGARE: €$TOTALE_SC"
echo "=========================================="

# 5. Scrittura nel LOG (aggiungiamo la riga senza sovrascrivere con >>)
echo "$TIMESTAMP;INFO;$CASSA_ID;PRINT_RECEIPT;offline;$BUFFER;1;SUCCESS;Scontrino $ID_SC generato;512;0" >> "$LOG_FILE"