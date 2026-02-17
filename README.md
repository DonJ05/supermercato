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
```bash
./ex7.sh vendite_buffer_12345.csv
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

## Cosa fa lo script (descrizione dettagliata)

Lo script `ex8.sh` viene eseguito all’avvio della cassa (tramite cronjob `@reboot ../cassa/ex8.sh`) e serve a prevenire condizioni critiche durante l’avvio del sistema.

### Funzionalità principali
- Controlla che la cassa parta in condizioni sicure verificando:
  - L’interfaccia **loopback (lo)** sia attiva.
  - La dimensione del log non superi la soglia di sicurezza (50 MB).
- Se il log è troppo grande:
  - Lo comprime in un archivio ZIP con timestamp.
  - Svuota il file originale senza modificare i permessi.
- Genera messaggi di errore e alert verso il sistemista in caso di anomalie.

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
- Evita di generare dati duplicati per lo stesso giorno
- Scrive i risultati in un file CSV-like (`status_offline.log`) pronto per estrazioni o report

### Come usare lo Script
```bash
./ex9.sh YYYY-MM-DD LOG_CASSA
```
- Lo script richiede due parametri:
  1. Il giorno da analizzare, nel formato `YYYY-MM-DD`
  2. Il file di log della cassa da cui estrarre i dati

- L’output viene scritto in `./log/status_offline.log`.  
  Se il file non esiste o è vuoto, viene creato con intestazione chiara.











## Problema 4 – Disallineamento orario cassa–server

### Descrizione

- Differenze di orario causano:
  - errori nei log
  - problemi di sincronizzazione
  - incoerenze nei report

### Soluzione adottata

- Inserimento di una soglia di tolleranza configurabile
- Confronto tra:
  - orario cassa
  - orario server
  - riferimento esterno
- Verifica di coerenza del server
- Aggiornamento automatico dell’orario della cassa se necessario

### Risultato

- Timestamp coerenti
- Migliore affidabilità dei dati

---
