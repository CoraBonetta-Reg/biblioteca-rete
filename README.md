# Sistema di Gestione Rete Bibliotecaria

Applicazione web per la gestione di una rete di biblioteche che condividono un catalogo centralizzato e gestiscono prestiti interbiblioteca.

## 🎯 Funzionalità Principali

### Catalogo Condiviso
- **Gestione Titoli**: Catalogo centralizzato con informazioni complete su libri (titolo, ISBN, autori, casa editrice, categoria)
- **Autori**: Anagrafica completa degli autori con biografia e collegamenti ai titoli
- **Case Editrici**: Gestione delle case editrici con informazioni geografiche e contatti
- **Categorie**: Classificazione gerarchica dei titoli (es. Narrativa > Romanzo Storico)

### Rete di Biblioteche
- **Biblioteche**: Anagrafica delle biblioteche della rete con contatti e orari
- **Inventario Copie**: Tracciamento delle copie fisiche per ogni biblioteca (numero inventario, stato, ubicazione)
- **Prestiti Interbiblioteca**: Sistema per richiedere e gestire prestiti tra biblioteche con tracking completo del flusso

### Interfacce Utente
6 applicazioni Fiori Elements per:
1. **Titoli** - Consultare e gestire il catalogo
2. **Autori** - Gestire gli autori e visualizzare i loro titoli
3. **Biblioteche** - Gestire le biblioteche della rete
4. **Copie** - Tracciare l'inventario fisico
5. **Case Editrici** - Gestire le case editrici
6. **Categorie** - Organizzare la classificazione

## 🚀 Avvio Rapido

### Prerequisiti
- Node.js (v18 o superiore)
- npm (v9 o superiore)

### Installazione
```bash
npm install
```

### Avvio Applicazione
```bash
npm start
# oppure
cds watch
```

L'applicazione sarà disponibile su: **http://localhost:4004**

### Avvio Singola App
```bash
npm run watch-titoli        # App Titoli
npm run watch-autori        # App Autori
npm run watch-biblioteche   # App Biblioteche
npm run watch-copie         # App Copie
npm run watch-case-editrici # App Case Editrici
npm run watch-categorie     # App Categorie
```

## 📱 Utilizzo delle Applicazioni

### App Titoli
**Funzionalità principali**:
- Visualizzare l'elenco completo dei titoli con filtri per ISBN, anno, casa editrice, categoria
- Creare nuovi titoli nel catalogo
- Modificare informazioni esistenti
- Collegare autori ai titoli
- Visualizzare tutte le copie disponibili nelle biblioteche

**Workflow tipico**:
1. Cercare un titolo esistente tramite filtri
2. Se non esiste, crearne uno nuovo con i dati completi
3. Associare uno o più autori con il loro ruolo (autore, coautore, curatore)
4. Le copie vengono gestite dalla app Copie

### App Biblioteche
**Funzionalità principali**:
- Gestire anagrafica biblioteche (indirizzo, contatti, orari)
- Visualizzare inventario copie di ogni biblioteca
- Monitorare prestiti ricevuti e inviati

**Workflow tipico**:
1. Selezionare una biblioteca
2. Visualizzare l'inventario delle copie disponibili
3. Controllare i prestiti interbiblioteca in corso

### App Copie
**Funzionalità principali**:
- Registrare nuove copie fisiche nell'inventario
- Assegnare numero di inventario e ubicazione
- Tracciare lo stato (disponibile, prestato, manutenzione, danneggiato)
- Visualizzare storico prestiti interbiblioteca

**Workflow tipico**:
1. Acquisire un nuovo libro → Creare una copia selezionando titolo e biblioteca
2. Assegnare numero inventario e ubicazione (es. "Scaffale A12")
3. Quando viene prestato, lo stato viene aggiornato automaticamente

### Prestiti Interbiblioteca
**Workflow completo**:
1. **Richiesta**: Biblioteca B cerca un libro disponibile in Biblioteca A
2. **Creazione Prestito**: Creare nuovo prestito selezionando copia, biblioteca origine e destinazione
3. **Stato**: Il sistema traccia lo stato (richiesto → approvato → in transito → ricevuto → restituito)
4. **Date**: Registrare data richiesta, invio, ricezione, restituzione prevista/effettiva

## 🌍 Supporto Multilingua

L'applicazione supporta:
- 🇮🇹 **Italiano** (predefinito)
- 🇬🇧 **Inglese**

Le etichette si adattano automaticamente alla lingua del browser.

## 📊 Dati di Esempio

Il sistema include dati di esempio per:
- 10 titoli di narrativa italiana e internazionale
- 8 autori
- 4 case editrici
- Categorie gerarchiche (Narrativa, Saggistica, etc.)
- 4 biblioteche della rete
- 20 copie distribuite
- Esempi di prestiti interbiblioteca

## 🔒 Modalità Draft

Tutte le applicazioni utilizzano la **modalità draft** per l'editing:
- Le modifiche vengono salvate in bozze
- Possibilità di salvare e continuare più tardi
- I dati diventano visibili solo dopo il salvataggio finale
- Supporto per editing collaborativo

## 💡 Suggerimenti per l'Uso

### Creare un Nuovo Titolo nel Catalogo
1. Aprire l'app **Titoli**
2. Click su **Create**
3. Compilare i campi obbligatori (titolo, ISBN)
4. Selezionare casa editrice e categoria dai dropdown
5. Click su **Save**
6. Nella sezione **Autori**, aggiungere gli autori con i loro ruoli
7. Click su **Save** per confermare

### Registrare una Nuova Copia
1. Aprire l'app **Copie**
2. Click su **Create**
3. Selezionare il titolo dal dropdown
4. Selezionare la biblioteca proprietaria
5. Inserire numero inventario (es. "INV-2025-0001")
6. Specificare ubicazione (es. "Scaffale A, Ripiano 3")
7. Stato predefinito: "disponibile"
8. Click su **Save**

### Richiedere un Prestito Interbiblioteca
1. Aprire l'app **Biblioteche**
2. Trovare la biblioteca che possiede la copia desiderata
3. Nella sezione **Copie**, verificare disponibilità
4. Creare nuovo prestito dall'app **Copie** (sezione Prestiti) o direttamente
5. Selezionare copia, biblioteca origine e destinazione
6. Inserire richiedente e date
7. Il sistema aggiorna automaticamente lo stato

## 🔍 Ricerca e Filtri

Tutte le app offrono funzionalità di ricerca avanzata:
- **Titoli**: Filtrare per ISBN, anno pubblicazione, casa editrice, categoria
- **Autori**: Cercare per nome, cognome, nazionalità
- **Biblioteche**: Filtrare per città, provincia
- **Copie**: Cercare per stato, biblioteca, titolo
- **Prestiti**: Filtrare per stato, date, biblioteche

## 📖 Documentazione Tecnica

Per dettagli tecnici sull'architettura e l'implementazione:
- **[DOCUMENTATION.md](DOCUMENTATION.md)** - Documentazione tecnica completa
- **[DEVELOPMENT_REPORT.md](DEVELOPMENT_REPORT.md)** - Report di sviluppo con metriche
- **[.github/copilot-instructions.md](.github/copilot-instructions.md)** - Istruzioni per AI agents

## 🛠️ Tecnologie

- **SAP Cloud Application Programming Model (CAP)** - Framework backend
- **SAP Fiori Elements** - Framework UI responsive
- **OData V4** - Protocollo dati
- **SQLite** - Database (sviluppo)
- **Node.js** - Runtime

## 📧 Supporto

Per domande o supporto, consultare:
- Documentazione CAP: https://cap.cloud.sap/docs/
- Documentazione Fiori: https://ui5.sap.com/

## 📄 Licenza

Progetto privato - Copyright © 2025
