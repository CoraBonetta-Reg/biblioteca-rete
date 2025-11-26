# Sistema di Gestione Rete Bibliotecaria

## Panoramica

Applicazione CAP (Cloud Application Programming Model) per la gestione di una rete bibliotecaria. Il sistema supporta la catalogazione di titoli, la gestione delle biblioteche della rete e il tracciamento dei prestiti interbiblioteca.

## Modello dei Dati

### Entità Principali

#### **Titoli**
Rappresenta i titoli disponibili nella rete bibliotecaria.

**Campi principali:**
- `titolo` - Titolo dell'opera (localizzato)
- `sottotitolo` - Sottotitolo dell'opera (opzionale)
- `isbn` - Codice ISBN-13
- `annoPubblicazione` - Anno di pubblicazione
- `lingua` - Codice lingua ISO 639-1
- `numeroPagine` - Numero di pagine
- `descrizione` - Descrizione dell'opera
- `casaEditrice` - Associazione alla casa editrice
- `categoria` - Categoria di classificazione

**Relazioni:**
- Many-to-Many con `Autori` attraverso `TitoliAutori`
- One-to-Many con `Copie`

#### **Autori**
Informazioni sugli autori delle opere.

**Campi principali:**
- `nome` - Nome dell'autore
- `cognome` - Cognome dell'autore
- `dataNascita` - Data di nascita
- `nazionalita` - Codice paese ISO
- `biografia` - Biografia dell'autore (localizzata)

#### **Biblioteche**
Biblioteche appartenenti alla rete.

**Campi principali:**
- `codice` - Codice identificativo univoco
- `nome` - Nome della biblioteca
- `indirizzo`, `citta`, `cap`, `provincia`, `paese` - Dati indirizzo
- `telefono`, `email`, `sitoWeb` - Contatti
- `orariApertura` - Orari di apertura

**Relazioni:**
- One-to-Many con `Copie`
- One-to-Many con `PrestitiInterbiblioteca` (come origine e destinazione)

#### **Copie**
Copie fisiche dei titoli disponibili nelle biblioteche.

**Campi principali:**
- `numeroInventario` - Numero inventario univoco
- `stato` - Stato della copia (disponibile, prestato, manutenzione, danneggiato)
- `ubicazione` - Posizione fisica nella biblioteca
- `dataAcquisizione` - Data di acquisizione
- `titolo` - Riferimento al titolo
- `biblioteca` - Biblioteca che possiede la copia

#### **PrestitiInterbiblioteca**
Gestione dei prestiti tra biblioteche della rete.

**Campi principali:**
- `numeroPrestito` - Numero univoco del prestito
- `dataRichiesta` - Data della richiesta
- `dataInvio` - Data di invio
- `dataRicezione` - Data di ricezione
- `dataRestituzionePrevista` - Data prevista per la restituzione
- `dataRestituzioneEffettiva` - Data effettiva di restituzione
- `stato` - Stato del prestito (richiesto, approvato, in_transito, ricevuto, restituito, annullato)
- `copia` - Copia prestata
- `bibliotecaOrigine` - Biblioteca che invia
- `bibliotecaDestinazione` - Biblioteca che riceve
- `richiedente` - Nome del richiedente

### Entità di Supporto

#### **CaseEditrici**
Case editrici dei titoli.

#### **Categorie**
Sistema gerarchico di categorizzazione dei titoli (supporta parent-child).

#### **TitoliAutori**
Tabella di congiunzione many-to-many tra Titoli e Autori, con campo `ruolo` per specificare il tipo di contributo (es. "autore principale", "coautore", "curatore").

## Best Practices Implementate

1. **Uso di Aspect Riusabili**
   - `cuid` - Chiavi UUID per tutte le entità principali
   - `managed` - Campi di audit automatici (createdAt, modifiedAt, createdBy, modifiedBy)
   - `Country` - Tipo riusabile da @sap/cds/common

2. **Modellazione delle Relazioni**
   - Associazioni managed per relazioni one-to-many
   - Tabella di congiunzione esplicita per many-to-many con attributi aggiuntivi
   - Composition per relazioni parent-child nelle categorie

3. **Localizzazione**
   - Campi localizzati per titolo, sottotitolo, descrizione, biografia
   - Supporto multilingua tramite `localized String`

4. **Vincoli di Integrità**
   - Campi `@mandatory` dove appropriato
   - Valori di default per campi di stato
   - Chiavi UUID per garantire unicità globale

## Struttura del Progetto

```
biblioteca-rete/
├── db/
│   ├── schema.cds          # Modello dati principale
│   └── data/               # Dati CSV di esempio
│       ├── biblioteca.rete-Autori.csv
│       ├── biblioteca.rete-Biblioteche.csv
│       ├── biblioteca.rete-CaseEditrici.csv
│       ├── biblioteca.rete-Categorie.csv
│       ├── biblioteca.rete-Copie.csv
│       ├── biblioteca.rete-PrestitiInterbiblioteca.csv
│       ├── biblioteca.rete-Titoli.csv
│       └── biblioteca.rete-TitoliAutori.csv
└── srv/
    └── cat-service.cds     # Definizione servizio

```

## Comandi Utili

```bash
# Installare le dipendenze
npm install

# Avviare il servizio in modalità sviluppo
cds watch

# Deployare il database
cds deploy --to sqlite

# Compilare il modello
cds compile db/schema.cds
```

## Servizio BibliotecaService

Il servizio espone le seguenti entità:

- **Titoli** (readonly) - Catalogo completo dei titoli
- **Autori** (readonly) - Elenco autori
- **CaseEditrici** (readonly) - Case editrici
- **Categorie** (readonly) - Sistema di categorizzazione
- **Biblioteche** (readonly) - Rete di biblioteche
- **Copie** - Gestione copie fisiche
- **PrestitiInterbiblioteca** - Gestione prestiti tra biblioteche
- **TitoliAutori** (readonly) - Relazione titoli-autori

## Dati di Esempio

Il progetto include dati di esempio con:
- 5 titoli di autori italiani e internazionali
- 5 autori celebri
- 5 biblioteche italiane
- 7 copie distribuite nelle biblioteche
- 3 prestiti interbiblioteca in vari stati
- 5 case editrici
- 6 categorie organizzate gerarchicamente

## Prossimi Sviluppi Possibili

- Aggiungere gestione utenti e prestiti agli utenti finali
- Implementare sistema di prenotazioni
- Aggiungere ricerca full-text sui titoli
- Implementare notifiche per scadenze prestiti
- Aggiungere statistiche e report
- Integrare con sistemi di catalogazione esterni (es. OPAC)
