#!/bin/bash

# --- CONFIGURAZIONE ---
SERVER_IP="8.8.8.8"      
LOG_FILE="cassa.log"      
SOGLIA_MS=200            # IL MASSIMO: se supera 200ms, la rete è troppo lenta
CASSA_ID="CASSA_01"

# Assicuriamoci che il file log esista per evitare errori di analisi
touch "$LOG_FILE"

echo "--- DIAGNOSTICA RETE CASSA ---"

# 1. TEST DI RAGGIUNGIBILITÀ (Ping rapido: aspetta max 2 secondi)
PING_RES=$(ping -c 1 -W 2 $SERVER_IP 2>&1)
EXIT_CODE=$?
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# 2. LOGICA DI DECISIONE (IL CUORE DELLA TUA SOLUZIONE)
if [ $EXIT_CODE -ne 0 ]; then
    # --- CASO A: SERVER DOWN (Problema Rete Totale) ---
    MODALITA="offline"
    STATO="FAIL"
    MSG="Server non raggiungibile - Passaggio a locale"
    
    echo "$TIMESTAMP;ERROR;$CASSA_ID;NET_CHECK;$MODALITA;none;0;$STATO;$MSG;0;0" >> "$LOG_FILE"
    echo "ESITO: [CRITICO] $MSG"

    # --- AGGIUNTA ALERT TECNICO ---
    echo ""
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "ALERT: Server Down! Notifica inviata al tecnico IT."
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

else
    # --- CASO B: IL SERVER RISPONDE -> CONTROLLIAMO LA VELOCITÀ ---
    LATENZA=$(echo "$PING_RES" | grep 'time=' | awk -F'time=' '{print $2}' | cut -d'.' -f1)

    if [ "$LATENZA" -gt "$SOGLIA_MS" ]; then
        # --- CASO B1: RETE TROPPO LENTA (Problema Qualità) ---
        MODALITA="offline"
        STATO="FAIL"
        MSG="Connessione instabile (${LATENZA}ms > ${SOGLIA_MS}ms) - Backup attivato"
        
        echo "$TIMESTAMP;WARNING;$CASSA_ID;NET_CHECK;$MODALITA;none;0;$STATO;$MSG;0;1" >> "$LOG_FILE"
        echo "ESITO: [LENTO] $MSG"

        # --- AGGIUNTA ALERT TECNICO ---
        echo ""
        echo "--------------------------------------------------"
        echo "ATTENZIONE: Latenza critica! Segnalazione degrado rete."
        echo "--------------------------------------------------"
    else
        # --- CASO B2: RETE PERFETTA ---
        MODALITA="online"
        STATO="SUCCESS"
        MSG="Connessione ottimale (${LATENZA}ms)"
        
        echo "$TIMESTAMP;INFO;$CASSA_ID;NET_CHECK;$MODALITA;none;0;$STATO;$MSG;0;0" >> "$LOG_FILE"
        echo "ESITO: [OK] $MSG"
    fi
fi

# 3. RIEPILOGO STATISTICHE (Analisi storica del file log)
echo "------------------------------"
echo "RIEPILOGO STATISTICHE (Analisi Log):"
TOTAL_FAIL=$(grep -c "FAIL" "$LOG_FILE")
SERVER_DOWN=$(grep -c "Server non raggiungibile" "$LOG_FILE")
SLOW_CONN=$(grep -c "Connessione instabile" "$LOG_FILE")

echo "Totale errori rilevati nel log: $TOTAL_FAIL"
echo "- Di cui Server Spenti (Prob. 1): $SERVER_DOWN"
echo "- Di cui Rete Lenta (Prob. 2): $SLOW_CONN"