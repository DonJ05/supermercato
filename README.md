## Problema 1 – Duplicazione delle vendite

### Descrizione

- Il file `vendite_buffer.csv` può:
  - essere inviato più volte
  - contenere righe duplicate
- Questo genera **record duplicati** nel database centrale

### Impatti

- Errori contabili
- Dati incoerenti
- Problemi di audit
- Peggioramento delle performance

### Soluzione adottata

- Controllo dei parametri di input
- Verifica dell’esistenza del file
- Rimozione dei duplicati interni (esclusa l’intestazione)
- Controllo nel log per evitare reinvii
- Invio al server solo se il file non risulta già trasmesso
- Registrazione dell’esito nel log

### Risultato

- Nessuna vendita duplicata
- Database centrale coerente

---

## Problema 2 – Avvio in condizioni anomale

### Descrizione

Durante l’avvio della cassa possono verificarsi condizioni critiche:

- Interfaccia di loopback non attiva
- Crescita incontrollata del file di log

### Rischi

- Servizi locali non funzionanti
- Saturazione del disco
- Perdita di dati
- Blocco del sistema

### Soluzione adottata

- Verifica dell’interfaccia `lo`
- Blocco dell’avvio in caso di errore critico
- Controllo della dimensione di `log_cassa.log`
- Archiviazione automatica del log oltre i 50 MB
- Svuotamento sicuro del file

### Risultato

- Avvio solo in condizioni sicure
- Prevenzione della saturazione del disco

---

## Problema 3 – Analisi del tempo di offline del server

### Descrizione

- Il server centrale può essere temporaneamente non raggiungibile
- Senza analisi strutturate non è possibile valutarne l’affidabilità

### Soluzione adottata

- Analisi del file `log_cassa.log`
- Identificazione degli eventi:
  - `server_offline`
  - `server_online`
- Calcolo della durata dell’offline in secondi
- Scrittura dei risultati in `status_offline.log`
- Blocco delle analisi duplicate per la stessa giornata

### Risultato

- Tracciabilità storica delle indisponibilità
- Supporto a controlli SLA e auditing

---

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
