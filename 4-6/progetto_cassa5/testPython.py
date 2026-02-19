# script_scrivi_file.py

# Nome del file
nome_file = "cassa.log"

# Contenuto da scrivere
contenuto = "Ciao! Questo testo è stato scritto con Python.\n"

# Apriamo il file in modalità scrittura ('w')
# Se il file non esiste, viene creato
# Se il file esiste, il contenuto precedente viene sovrascritto
with open(nome_file, "w") as f:
    f.write(contenuto)
  
print(f"Contenuto scritto in '{nome_file}' con successo!")
