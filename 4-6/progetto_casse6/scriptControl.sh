#!/bin/bash

PROCESSO_CASSA="cassa_app.py"
BASE_DIR="../progetto_casse6"
VENDITE_FILE="$BASE_DIR/vendite_buffer.csv"
isAppActive=0
isAlmostFull=0
isRamAlmostFull=0
isFileBig=0
isCPUHot=0


if [ $# -ne 0 ]; then
    echo "comando $0 non accetta nessuno argomento"
    exit 1
fi

while :
do
    #controllo se l'app della cassa è attiva
    ps -fA | grep -q "[c]assa_app.py"
    
    if [[ $? -ne 0 ]]; then
        if [ "$isAppActive" -eq 0 ]; then
            echo "Processo cassa NON attivo!"
            echo "il sistemista è stato avvisato"
            isAppActive=1
        fi
    else
        isAppActive=0
    fi

    #controllo se la memoria del disco è quasi piena
    USO_MEM=78

    if [[ "$USO_MEM" -ge 90 ]]; then
        if [ "$isAlmostFull" -eq 0 ]; then
            echo "Memoria disco oltre il 90%: utilizzo attuale ${USO_MEM}%"
            echo "il sistemista è stato avvisato"
            isAlmostFull=1
        fi
    else
        isAlmostFull=0
    fi

    #controllo se la memoria RAM è quasi piena
    SOGLIA_MEM=90
    MEM=76
    if [ "$MEM" -gt "$SOGLIA_MEM" ]; then
        if [ "$isRamAlmostFull" -eq 0 ]; then
            echo "Memoria RAM quasi piena: $MEM%"
            echo "il sistemista è stato avvisato"
            isRamAlmostFull=1
        fi
    else
        isRamAlmostFull=0
    fi

    #controllo se il file vendite_buffer è molto grande
    if [[ -f "$VENDITE_FILE" ]]; then
        SIZE_MB=88
        if [[ "$SIZE_MB" -ge 1000 ]]; then
            if [ "$isFileBig" -eq 0 ]; then
                echo "vendite_buffer.csv superiore a 1 GB!"
                echo "il sistemista è stato avvisato"
                isFileBig=1
            fi
        else
            isFileBig=0
        fi
    fi

    #controllo se la temperatura della CPU supera il massimo raccomandato
    # Simulazione temperatura CPU (in gradi Celsius)
    TEMP_C=79
    SOGLIA_CRITICA=80

    if [[ "$TEMP_C" -gt "$SOGLIA_CRITICA" ]]; then
        if [ "$isCPUHot" -eq 0 ]; then
            echo "Temperatura CPU critica: $TEMP_C°C"
            echo "il sistemista è stato avvisato"
            isCPUHot=1
        fi
    else
        isCPUHot=0
    fi

done


