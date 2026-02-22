cassa=$(cat /etc/hostname)
LOG_FILE="./log/log_cassa.log"

if [ $# -ne 0 ]; then
    echo "ERRORE: questo script non accetta argomenti"
    exit 1
fi
if ! ip link show lo | grep -q "UP"; then #controlla se l'interfaccia loopback è attiva
    echo "ERRORE CRITICO: interfaccia loopback DOWN sulla cassa $cassa"
	echo "ALERT ->> Sistemista OBENG"
    exit 1
fi

if [ -f "$LOG_FILE" ]; then
    mkdir -p "./log/archive"
    size_mb=$(du -m "$LOG_FILE" | cut -f1) #calcola la dimensione del file di log in MB
     
    if [ "$size_mb" -ge 50 ]; then #se il file di log supera i 50MB, comprimi e archivia
        ts=$(date +"%Y%m%d_%H%M%S")
        zip_file="./log/archive/log_cassa_${ts}.zip"

        zip -j "$zip_file" "$LOG_FILE" >/dev/null 

        if [ $? -eq 0 ]; then
            echo "Log $LOG_FILE archiviato in $zip_file"
            > "$LOG_FILE"   # svuota il file senza cambiarne i permessi
        else
            echo "ERRORE: compressione log fallita"
            exit 1
        fi
    
    fi
    
fi