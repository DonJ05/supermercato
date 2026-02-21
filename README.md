## 1) Problema individuato

**Problema:** Analisi e resilienza della connessione (`check_network.sh`).

In un sistema operativo GNU/Linux dedicato alla vendita, la rete deve essere monitorata costantemente.  
Una latenza elevata o una disconnessione possono causare blocchi dei processi applicativi e la mancata sincronizzazione delle transazioni in tempo 

---

## Motivazione della scelta
Questa problematica è stata selezionata perché la continuità operativa (Business Continuity) è il requisito principale di un punto vendita.  
Identificare preventivamente un guasto di rete permette al sistema di passare in modalità **offline** senza che l'utente finale percepisca interruzioni.

---

## Può causare
- **Blocchi alla cassa**: attese infinite per risposte dal server che non arrivano.  
- **Incertezza operativa**: l'operatore non sa se il sistema è connesso o se sta lavorando "nel vuoto".  
- **Perdita di vendite**: impossibilità di chiudere lo scontrino per timeout di rete.

---

## Rilevanza nel contesto
- Permette una gestione fluida del passaggio tra stato **Online** e **Offline**.  
- Fornisce dati storici utili per diagnosticare guasti infrastrutturali ricorrenti.

---

## Sintesi tecnica del funzionamento
Lo script utilizza il comando `ping` per testare la raggiungibilità dell'host.  
Attraverso `grep` e `awk`, isola il valore numerico della latenza (ms) dalla stringa di risposta del terminale, permettendo un confronto logico con una soglia prefissata.  
Ogni evento viene registrato in un log tramite l'operatore di ridirezione `>>`.

---

## Come usare lo script
Abilitare i permessi di esecuzione e lanciare lo script:

```bash
chmod +x check_network.sh
./check_network.sh
```

## 2) Problema individuato


**Problema:** Svuotamento sicuro del buffer vendite (`svuota_buffer.sh`).

Le vendite effettuate mentre la rete è assente vengono salvate in un file temporaneo (`vendite_buffer.csv`).  
Il rischio critico è la cancellazione accidentale di queste informazioni prima che il server centrale ne abbia confermato la corretta ricezione.

---

## Motivazione della scelta
La scelta è dettata dalla necessità di garantire l'integrità dei dati fiscali.  
In un contesto aziendale, perdere i dati di vendita significa un danno economico certo.  
Lo script implementa una logica di "handshake" per proteggere il patrimonio informativo.

---

## Può causare
- **Perdita di incassi**: dati eliminati localmente ma mai arrivati al database centrale.  
- **Errori contabili**: discrepanze tra il denaro presente fisicamente in cassa e quello registrato digitalmente.

---

## Rilevanza nel contesto
- Garantisce la sicurezza del dato fiscale in ogni condizione di connettività.  
- Automatizza il riallineamento dei dati non appena la connessione torna stabile.

---

## Sintesi tecnica del funzionamento
Lo script:
1. Calcola il volume dei dati tramite il comando `wc -l`.  
2. Se sono presenti transazioni, simula la sincronizzazione con il server.  
3. In caso di successo, utilizza il comando `sed` per svuotare il file mantenendo solo l’intestazione:

```bash
sed -i '1!d' vendite_buffer.csv
```
## Come usare lo script

Abilitare i permessi di esecuzione e lanciare lo script:

```bash
chmod +x svuota_buffer.sh
./svuota_buffer.sh
```


## 3) Problema individuato


**Problema:** Ricostruzione scontrini quando il server non è raggiungibile (`genera_scontrino.sh`).

Quando si opera offline, il sistema registra solo gli ID numerici dei prodotti.  
Tuttavia, per normativa e trasparenza verso il cliente, è necessario produrre un documento leggibile che riporti nomi descrittivi e prezzi calcolati correttamente.

---

## Motivazione della scelta
Questo problema è stato selezionato per dimostrare la capacità del sistema di operare in **Edge Computing**.  
La cassa deve essere autonoma e in grado di processare dati complessi (join tra ID e descrizioni) anche senza l’ausilio di un database remoto.

---

## Può causare
- **Mancanza di trasparenza**: il cliente non è in grado di verificare la correttezza della spesa.  
- **Difficoltà nei controlli**: il personale non può validare l’uscita della merce.

---

## Rilevanza nel contesto
- Assicura l’autonomia della cassa grazie all’integrazione con un catalogo locale (`prodotti_default.csv`).  
- Migliora la qualità del servizio al cliente riducendo i tempi di attesa per la generazione dello scontrino.

---

## Sintesi tecnica del funzionamento
Lo script:
1. Effettua una ricerca all’interno dei file dati tramite `grep`.  
2. Utilizza `awk` per sommare i valori decimali dei prezzi e calcolare il totale.  
3. Usa `printf` per formattare l’output in colonne allineate, garantendo un layout simile a quello di una stampante fiscale fisica.

---

## Come usare lo script
Abilitare i permessi di esecuzione e lanciare lo script:

```bash
chmod +x genera_scontrino.sh
./genera_scontrino.sh
``` 
**Output:** lo scontrino viene stampato a terminale e l’evento registrato in `cassa.log`.


## 4) Problema individuato

**Problema:** utilizzo di un file `prodotti_default.csv` non aggiornato nella cassa.  
Quando la connessione con il server centrale non è disponibile, la cassa entra in modalità offline e utilizza il file locale `prodotti_default.csv` come unica fonte dati per prezzi, stato attivo dei prodotti e altre informazioni di vendita.

Se questo file non è allineato con il database centrale, la cassa può operare con dati obsoleti.

### Può causare

- **Errori di prezzo:** vendita di prodotti con importi non aggiornati.  
- **Disallineamenti contabili:** differenze tra vendite registrate in cassa e dati presenti nel database centrale.    
- **Vendita di prodotti disattivati:** articoli rimossi dal catalogo potrebbero risultare ancora disponibili.

### Rilevanza nel contesto

- Nel supermercato, l’**accuratezza dei dati di vendita** è essenziale per la gestione economica e fiscale.  
- La modalità offline garantisce continuità operativa, ma richiede un meccanismo sicuro di aggiornamento del catalogo.  
- Mantenere il file `prodotti_default.csv` sincronizzato con il server centrale assicura:  
  - coerenza tra cassa e database,  
  - corretto aggiornamento del magazzino,  
  - affidabilità nei report di vendita.  

L’integrità del catalogo prodotti è quindi un elemento critico per la stabilità dell’intero sistema.

---

### Sintesi dello script

Lo script `ScriptCassa.sh` gestisce l’aggiornamento automatico del file `prodotti_default.csv`, garantendo sincronizzazione sicura e prevenendo corruzioni.

#### Funzionalità principali

- Verifica la disponibilità del server centrale tramite `nc` (netcat).  
- Scarica il catalogo aggiornato in formato CSV quando la connessione è attiva.  
- Salva i dati ricevuti in un file temporaneo (`Temp_prodotti_default.csv`).  
- Confronta il file temporaneo con quello attualmente in uso tramite `diff`.  
- Sostituisce il file locale solo in presenza di differenze, utilizzando `cp` e `rm` .  

---

#### Come usare lo script
Per avviare lo script serve:
```bash
./ScriptCassa.sh
```
Per avviare il server che manda i dati alla cassa serve:
```bash
python3 server.py
```
oppure:
```bash
python server.py
```
Per usufruire di questi script bisogna essere nella cartella `progetto_casse4Alt`



## 5) Problema individuato

**Problema:** possibile modifica dei file critici della cassa da parte di processi nocivi o non autorizzati.  
Il corretto funzionamento del sistema di cassa dipende dall’integrità di alcuni file fondamentali, tra cui:

- `prodotti_default.csv`
- `vendite_buffer.csv`
- `cassa.log`

Questi file contengono informazioni essenziali per la gestione dei prodotti, delle vendite e per la tracciabilità delle operazioni.

Se un processo nocivo (malware, script non autorizzato, utente con privilegi errati, ecc.) dovesse modificare tali file, potrebbero verificarsi gravi anomalie.

### Può causare

- **Alterazione dei prezzi dei prodotti**
- **Manipolazione dei dati di vendita**
- **Cancellazione o modifica dei log**
- **Compromissione della configurazione del sistema**
- **Malfunzionamenti della cassa**

Un’eventuale compromissione dei file critici potrebbe generare blocchi operativi e significative perdite economiche per l’azienda.

---

### Rilevanza nel contesto

- Nel supermercato, l’**integrità dei dati** è fondamentale per garantire correttezza contabile e affidabilità del sistema.
- I file locali rappresentano la base operativa della cassa, specialmente in modalità offline.
- Proteggere tali file significa:
  - prevenire manipolazioni accidentali o malevole,
  - garantire tracciabilità delle operazioni,
  - mantenere stabilità e sicurezza dell’infrastruttura.

La protezione dei file critici è quindi una misura preventiva di sicurezza indispensabile.

---

### Sintesi dello script

Lo script `ScriptPerms.sh` assicura che i file critici della cassa siano protetti da modifiche non autorizzate, verificando e impostando i permessi dei file.

#### Funzionalità principali

- Controlla l’esistenza dei file critici (`prodotti_default.csv`, `vendite_buffer.csv`, `cassa.log`).
- Crea automaticamente i file mancanti.
- Imposta permessi restrittivi (es. `chmod 600`).
- Assegna il proprietario corretto (root o utente designato).
- Verifica periodicamente che i permessi non siano stati alterati.
- Ripristina automaticamente i permessi corretti se rileva modifiche non conformi.

---

### Modalità di funzionamento

1. **Verifica dell’esistenza dei file**

   Per ogni file critico, lo script controlla la presenza nel filesystem della cassa.  
   Se un file non esiste, viene creato automaticamente per garantire continuità operativa.

2. **Impostazione dei permessi restrittivi**

   Lo script imposta:

   - Proprietario: amministratore (root o utente dedicato)
   - Permessi: lettura e scrittura solo per il proprietario (`chmod 600`)

   Questo implica che:

   - Solo l’amministratore può leggere e modificare il file.
   - Altri utenti o processi non autorizzati non possono accedere ai contenuti.

3. **Ripristino automatico dei permessi**

   Lo script può essere eseguito oltre che all'inizio del ciclo di vita di una cassa.

   Se rileva permessi diversi da quelli previsti:

   - Ripristina automaticamente i permessi corretti.
   - Riporta il proprietario previsto.

---

### Come usare lo script
Per avviare lo script serve:
```bash
./ScriptPerms.sh
```
Per usufruire di questo script bisogna essere nella cartella `progetto_cassa5`

## 6) Problema individuato

**Problema:** mancato monitoraggio dello stato operativo della cassa.  
Durante il normale funzionamento di una cassa basata su sistema Linux, possono verificarsi condizioni anomale che compromettono stabilità e continuità operativa.

Tra le principali criticità si individuano:

- Saturazione della memoria RAM  
- Spazio su disco insufficiente o prossimo all’esaurimento  
- Arresto o crash del processo dell’applicazione di cassa  
- Temperatura della CPU eccessivamente elevata  
- Crescita anomala del file `vendite_buffer.csv` in modalità offline  

Tali condizioni possono causare rallentamenti, blocchi del sistema, perdita di dati o interruzione delle operazioni di vendita.

### Può causare

- **RAM quasi piena:** impedisce l’esecuzione corretta dei processi.  
- **Disco pieno:** blocca la registrazione di vendite e log.  
- **Processo della cassa assente:** impossibilità di effettuare operazioni.  
- **CPU troppo calda:** rischio di spegnimenti improvvisi o danni hardware.  
- **File `vendite_buffer.csv` troppo grande:** rischio di saturazione della memoria (8 GB totali) e indicatore di prolungata disconnessione dal server.

---

### Rilevanza nel contesto

- Nel supermercato, la **continuità operativa** è fondamentale per evitare interruzioni delle vendite.
- Un sistema non monitorato può degenerare rapidamente in guasto critico.
- L’approccio deve essere **proattivo**, non reattivo: intercettare i problemi prima che causino fermo macchina.

Il monitoraggio continuo aumenta l’affidabilità dell’infrastruttura e riduce i tempi di inattività.

---

### Sintesi dello script

Lo script `scriptControl.sh` implementa un sistema di monitoraggio periodico delle risorse critiche della cassa.

Viene eseguito in background e controlla costantemente lo stato del sistema.

---

### Funzionalità principali

- Verifica percentuale di utilizzo della RAM.  
- Controlla spazio disponibile su disco.  
- Monitora la dimensione del file `vendite_buffer.csv`.  
- Rileva temperatura della CPU.  
- Verifica la presenza del processo dell’applicazione di cassa.  
- Invia notifiche ai sistemisti in caso di anomalie.

---

### Modalità di funzionamento

#### 1. Controllo della memoria RAM

Lo script verifica la percentuale di utilizzo della RAM.  
Se l’utilizzo supera il **90%**, viene generato un avviso.

---

#### 2. Controllo dello spazio su disco

Viene analizzata la percentuale di utilizzo del disco.  
Se l’utilizzo supera il **90%**, viene generata una segnalazione.

---

#### 3. Controllo dimensione file `vendite_buffer.csv`

Lo script verifica la dimensione del file.

Se supera **1 GB**, può indicare:

- Prolungata modalità offline  
- Rischio di saturazione della memoria  

In tal caso viene generato un avviso.

---

#### 4. Controllo temperatura CPU

Viene monitorata la temperatura della CPU.  
Se supera una soglia critica predefinita, viene inviata una notifica per prevenire:

- Spegnimenti improvvisi  
- Danni hardware  

---

#### 5. Verifica del processo dell’applicazione di cassa

Lo script controlla se il processo dell’applicazione di cassa è in esecuzione.

Se il processo risulta assente:

- Viene generato un messaggio di allerta.

---

#### 6. Invio notifiche

Se uno o più controlli risultano negativi, lo script:

- Invia un messaggio ai sistemisti 

Lo script opera in modo continuo o periodico senza interferire con le normali operazioni di vendita.

---

### Come usare lo script
Per avviare lo script serve:
```bash
sudo ./scriptControl.sh
```
oppure se si vuol fare andare lo script in background:
```bash
sudo ./scriptControl.sh &
```
Per avviare l'applicazione della cassa serve:
```bash
python3 cassa_app.py
```
oppure:
```bash
python cassa_app.py
```
Per usufruire di questo script bisogna essere nella cartella `progetto_casse6`


## 7) Problema individuato

**Problema:** duplicazione delle vendite nei file `vendite_buffer.csv`.  
Quando una cassa è offline, tutte le vendite vengono salvate localmente in `vendite_buffer.csv`.

Se lo stesso file viene inviato più volte al server oppure contiene righe duplicate interne, si rischia di creare **record doppi nel database centrale**.

### Può causare

- **Errori contabili:** i totali delle vendite sarebbero errati.  
- **Incoerenza dei dati:** il server avrebbe più righe della stessa vendita, rendendo difficile il tracciamento.  
- **Problemi di performance:** dati duplicati aumentano inutilmente il carico del database.

### Rilevanza nel contesto

- Nel supermercato, la **continuità operativa** e l’**integrità dei dati** sono fondamentali.  
- Evitare duplicazioni garantisce:  
  - accuratezza delle vendite,  
  - corretto aggiornamento del magazzino,  
  - fiducia nei dati di analisi.  
- La **sicurezza dei dati** viene indirettamente tutelata: duplicati potrebbero anche mascherare errori reali o malfunzionamenti del sistema di sincronizzazione.

### Sintesi dello script

Lo script gestisce l'invio dei file `vendite_buffer.csv` al server centrale, prevenendo duplicazioni e garantendo l’integrità dei dati.

#### Funzionalità principali
- Controlla che il file `vendite_buffer.csv` esista e sia corretto.
- Rileva eventuali **duplicati interni** al file e li elimina, evitando che lo stesso record venga inviato più volte.
- Verifica nel **log della cassa** se il file è già stato inviato al server; se sì, blocca un nuovo invio.
- Invia il file al server tramite `curl` se non è già stato inviato.
- Aggiorna il log locale con esito dell’operazione, così da tracciare tutte le azioni.

#### Come usare lo script
Avviare il codice simula server
```bash
python ./server/fserver.py
```
Avviare lo script
```bash
./cassa/ex7.sh vendite_buffer_12345.csv
```
---

## 8) Problema individuato

Durante l’avvio del sistema di cassa possono verificarsi condizioni anomale critiche che, se non rilevate subito, compromettono:  

- Il corretto funzionamento del software di cassa  
- La continuità operativa  
- La sicurezza e l’integrità dei dati  

### Problemi principali individuati

1. **Interfaccia di loopback (lo) non attiva**  
   L’interfaccia di loopback è fondamentale per:  
   - La comunicazione tra processi locali  
   - Il corretto funzionamento di servizi interni (database locali, servizi di sincronizzazione, logging)  

   Se lo è DOWN:  
   - Alcuni servizi possono fallire silenziosamente  
   - La cassa può sembrare operativa ma produrre dati inconsistenti  
   - I meccanismi di sincronizzazione con il server possono non funzionare correttamente  

2. **Crescita incontrollata del file di log**  
   Il file `log_cassa.log` cresce continuamente registrando:  
   - Vendite  
   - Errori  
   - Sincronizzazioni  
   - Eventi di rete  

   Se non gestito:  
   - Può raggiungere dimensioni elevate  
   - Saturare lo spazio disco (la cassa ha memoria limitata)  
   - Portare al blocco delle vendite o del sistema operativo  

### Motivazione della scelta

Intercettare all’avvio:  
- Il problema del loopback  
- La dimensione del file di log  

È strategico perché:  
- L’avvio è il momento migliore per prevenire errori prima che la cassa inizi a vendere  
- Evita situazioni di degrado durante l’orario di apertura  
- Riduce il rischio di perdita o corruzione dei dati  

La gestione preventiva è più sicura ed efficace rispetto a un intervento reattivo.

## Cosa fa lo script

Lo script `ex8.sh` viene eseguito all’avvio della cassa (tramite cronjob `@reboot ../cassa/ex8.sh`) e serve a prevenire condizioni critiche durante l’avvio del sistema.

### Funzionalità principali
- Controlla che la cassa parta in condizioni sicure verificando:
  - L’interfaccia **loopback (lo)** sia attiva, Genera messaggi di errore e alert verso il sistemista in caso di anomalie.
  - La dimensione del log non superi la soglia di sicurezza (50 MB).
- Se il log è troppo grande:
  - Lo comprime in un archivio ZIP con timestamp.
  - Svuota il file originale senza modificare i permessi.


#### Come usare lo script

Lo script `ex8.sh` viene eseguito all’avvio della cassa (tramite cronjob `@reboot ../cassa/ex8.sh`) e serve a prevenire condizioni critiche durante l’avvio del sistema.

Se vuoi testare lo script
```bash
./cassa/ex8.sh
```
---

## 9) Problema individuato

Nel sistema di casse analizzato, il **server centrale** può diventare temporaneamente non raggiungibile.

### Motivazione della scelta

Sapere quando e per quanto tempo il server non è stato disponibile è fondamentale per:
- Valutare SLA
- Individuare problemi di rete o infrastruttura
- Migliorare la resilienza del sistema
- Generare report affidabili sul funzionamento del sistema
- Confrontare periodi offline con i dati di vendita
- Individuare problemi di rete o anomalie di sincronizzazione

### Cosa fa lo script
Analizza `log_cassa.log` calcola:
- Data del giorno considerato
- Ora di inizio del periodo offline
- Ora di ripristino della connessione
- Durata totale in secondi del periodo di indisponibilità

Questo permette di avere un **report preciso e strutturato** dei momenti di mancata connessione, utile per analisi statistiche, estrazioni dati e controllo della continuità operativa.

Lo script gestisce anche:

- Controllo dei parametri in ingresso
- Validazione del formato della data
- Verifica dell’esistenza del file di log
- Creazione di un file di output strutturato con intestazione
- Scrive i risultati in un file (`status_offline.log`) pronto per estrazioni o report

### Come usare lo Script
```bash
./ex9.sh 2026-02-01 ./log/log_cassa.log
```
- Lo script richiede due parametri:
  1. Il giorno da analizzare, nel formato `YYYY-MM-DD`
  2. Il file di log della cassa da cui estrarre i dati

- L’output viene scritto in `./log/status_offline.log`.  
  Se il file non esiste o è vuoto, viene creato con intestazione chiara.


## 10) Problema individuato

Nel sistema di casse analizzato, **cassa e server devono avere orari coerenti**.  
Una differenza significativa di tempo può causare:

- Errori nella ricostruzione delle vendite  
- Problemi di sincronizzazione dei file CSV  
- Incoerenze nei log di sicurezza  
- Difficoltà nell’analisi forense e negli audit  

In ambienti con funzionamento **offline/online intermittente**, una cassa con orario errato può:
- Registrare vendite con timestamp non attendibili  
- Inviare dati che il server interpreta come duplicati o fuori sequenza  

### Motivazione della scelta

Il controllo dell’orario è stato introdotto perché:
- I log e le vendite si basano sul timestamp  
- La sicurezza e la tracciabilità richiedono tempi affidabili 

Differenze di orario compromettono:
- L’ordine cronologico delle vendite  
- La corretta sincronizzazione offline → online  
- L’affidabilità dei report  

Questo controllo migliora:
- L’integrità dei dati  
- La coerenza dei log  
- La sicurezza operativa complessiva del sistema

L’uso di una **soglia di tolleranza configurabile** consente:
- Flessibilità operativa  
- Adattamento a contesti reali (latenza di rete, micro-scarti temporali)  

### Cosa fa lo script
Lo script verifica che l’orario della **cassa** e quello del **server centrale** siano coerenti, condizione fondamentale per garantire l’affidabilità dei log e dei dati di vendita.

In particolare:
- Confronta l’orario della cassa con quello del server
- Valida l’orario del server confrontandolo con una fonte esterna affidabile
- Calcola la differenza temporale tra cassa e server
- Verifica che tale differenza rientri in una soglia di tolleranza configurabile
- In caso di scarto eccessivo, aggiorna automaticamente l’orario della cassa
- Fornisce un riscontro chiaro sugli orari finali di cassa e server

### Come usare lo script
Avviare il codice simula server
```bash
python ./server/fserver.py
```
Avviare lo script
```bash
./cassa/ex10.sh 5
```
- Lo script richiede **un solo parametro**: il numero di secondi di tolleranza ammessi tra cassa e server.
- Se la differenza rientra nella soglia, il sistema viene considerato sincronizzato.
- Se la differenza supera la soglia, l’orario della cassa viene corretto automaticamente.
- Lo script è pensato per essere eseguito manualmente dal sistemista o integrato in procedure di controllo periodico.





