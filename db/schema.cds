using { Currency, managed, cuid, Country } from '@sap/cds/common';

namespace biblioteca.rete;

/**
 * Entità principale per i titoli disponibili nella rete bibliotecaria
 * 
 * ASPECT NOTES:
 * - `managed`: Aggiunge automaticamente createdAt, createdBy, modifiedAt, modifiedBy
 * - `cuid`: Genera UUID automatico come chiave primaria (field ID)
 * - `localized`: I campi titolo/descrizione supportano traduzioni multiple (crea tabella _texts)
 */
entity Titoli : managed, cuid {
  // CAMPO LOCALIZZATO: Supporta multiple lingue, stored in Titoli_texts
  titolo          : localized String(500)  @mandatory;
  sottotitolo     : localized String(500);
  
  // ISBN-13 format: 978-XX-XXXX-XXXX-X (17 chars con trattini)
  isbn            : String(17);
  annoPubblicazione : Integer;
  
  // ISO 639-1 language code (2 chars): it, en, es, fr, etc.
  lingua          : String(2);
  numeroPagine    : Integer;
  
  // CAMPO LOCALIZZATO: Descrizione tradotta per ogni lingua
  descrizione     : localized String(5000);
  
  // RELAZIONI:
  // - autori: Many-to-Many via TitoliAutori (un titolo può avere più autori)
  // - casaEditrice: Many-to-One (ogni titolo ha una casa editrice)
  // - categoria: Many-to-One (ogni titolo appartiene a una categoria)
  // - copie: One-to-Many (un titolo può avere più copie fisiche)
  autori          : Association to many TitoliAutori on autori.titolo = $self;
  casaEditrice    : Association to CaseEditrici;
  categoria       : Association to Categorie;
  copie           : Association to many Copie on copie.titolo = $self;
}

/**
 * Entità per gli autori
 */
entity Autori : managed, cuid {
  nome            : String(100)  @mandatory;
  cognome         : String(100)  @mandatory;
  dataNascita     : Date;
  nazionalita     : Country;
  biografia       : localized String(5000);
  
  titoli          : Association to many TitoliAutori on titoli.autore = $self;
}

/**
 * Tabella di congiunzione many-to-many tra Titoli e Autori
 * 
 * JUNCTION TABLE PATTERN:
 * - Chiave composita: (titolo_ID, autore_ID)
 * - Attributo aggiuntivo: `ruolo` per qualificare la relazione
 * - CRITICAL: Entrambe le chiavi sono @Core.Immutable nel servizio per integrità dati
 * 
 * USAGE: Permette di collegare più autori a un titolo con ruoli diversi
 * (autore principale, coautore, curatore, traduttore, etc.)
 */
entity TitoliAutori : managed {
  // COMPOSITE KEY: Entrambi i campi formano la chiave primaria
  key titolo      : Association to Titoli  @mandatory;
  key autore      : Association to Autori  @mandatory;
  
  // Attributo che qualifica la relazione (opzionale ma raccomandato)
  ruolo           : String(50);  // es. "autore principale", "coautore", "curatore"
}

/**
 * Case editrici
 */
entity CaseEditrici : managed, cuid {
  nome            : String(200)  @mandatory;
  sede            : String(200);
  paese           : Country;
  sitoWeb         : String(500);
  
  titoli          : Association to many Titoli on titoli.casaEditrice = $self;
}

/**
 * Categorie per classificazione dei titoli
 * 
 * HIERARCHICAL PATTERN:
 * - Self-referencing con `parent` per creare alberi di categorie
 * - `Composition` per `children` (eliminazione a cascata)
 * - Supporta profondità arbitraria (es. Narrativa > Romanzo > Storico)
 * 
 * CRITICAL: parent è Association (nullable), children è Composition
 * Association: relazione loose, no cascading delete
 * Composition: relazione tight, cascading delete di children quando parent eliminato
 */
entity Categorie : managed, cuid {
  codice          : String(20)  @mandatory;
  
  // CAMPI LOCALIZZATI: Nome e descrizione traducibili
  nome            : localized String(200)  @mandatory;
  descrizione     : localized String(1000);
  
  // SELF-REFERENCE: Per costruire gerarchia
  parent          : Association to Categorie;  // NULL per categorie root
  
  // COMPOSITION: Children eliminati automaticamente quando parent eliminato
  children        : Composition of many Categorie on children.parent = $self;
  
  // Relazione verso titoli appartenenti a questa categoria
  titoli          : Association to many Titoli on titoli.categoria = $self;
}

/**
 * Biblioteche nella rete
 */
entity Biblioteche : managed, cuid {
  codice          : String(20)  @mandatory;
  nome            : String(200)  @mandatory;
  indirizzo       : String(500);
  citta           : String(100);
  cap             : String(10);
  provincia       : String(2);
  paese           : Country;
  telefono        : String(20);
  email           : String(100);
  sitoWeb         : String(500);
  orariApertura   : String(500);
  
  copie           : Association to many Copie on copie.biblioteca = $self;
  prestitiInviati : Association to many PrestitiInterbiblioteca on prestitiInviati.bibliotecaOrigine = $self;
  prestitiRicevuti : Association to many PrestitiInterbiblioteca on prestitiRicevuti.bibliotecaDestinazione = $self;
}

/**
 * Copie fisiche dei titoli disponibili nelle biblioteche
 * 
 * INVENTORY TRACKING:
 * - Ogni copia rappresenta un esemplare fisico di un titolo in una biblioteca
 * - numeroInventario: identificativo univoco per biblioteca
 * - stato: traccia disponibilità per prestiti
 * - ubicazione: posizione fisica (scaffale, sala)
 * 
 * IMMUTABILITY CRITICAL:
 * - titolo e biblioteca sono @Core.Immutable nel servizio
 * - Non modificabili dopo creazione per integrità storica
 * - Evita che una copia "cambi titolo" o "cambi biblioteca"
 * 
 * STATI VALIDI:
 * - disponibile: Pronto per prestito
 * - prestato: Attualmente in prestito interbiblioteca
 * - manutenzione: In riparazione/restauro
 * - danneggiato: Non prestabile
 */
entity Copie : managed, cuid {
  numeroInventario : String(50)  @mandatory;
  
  // DEFAULT VALUE: Nuove copie sono automaticamente 'disponibile'
  stato           : String(20)  @mandatory default 'disponibile';
  
  // Ubicazione fisica nella biblioteca
  ubicazione      : String(100);  // es. "Scaffale A12, Ripiano 3"
  dataAcquisizione : Date;
  note            : String(1000);
  
  // IMMUTABLE ASSOCIATIONS: Non modificabili dopo creazione (vedi srv/biblioteca-service.cds)
  titolo          : Association to Titoli  @mandatory;
  biblioteca      : Association to Biblioteche  @mandatory;
  
  // Storico prestiti di questa copia
  prestiti        : Association to many PrestitiInterbiblioteca on prestiti.copia = $self;
}

/**
 * Prestiti interbiblioteca
 * 
 * WORKFLOW TRACKING:
 * Traccia il flusso completo di un prestito tra biblioteche con date e stati:
 * 1. richiesto: Biblioteca destinazione richiede copia
 * 2. approvato: Biblioteca origine approva la richiesta
 * 3. in_transito: Copia spedita ma non ancora ricevuta
 * 4. ricevuto: Copia arrivata a destinazione
 * 5. restituito: Copia restituita a origine
 * 6. annullato: Richiesta cancellata
 * 
 * DATE TRACKING:
 * - dataRichiesta: Quando biblioteca destinazione richiede
 * - dataInvio: Quando biblioteca origine spedisce
 * - dataRicezione: Quando biblioteca destinazione riceve
 * - dataRestituzionePrevista: Deadline per restituzione
 * - dataRestituzioneEffettiva: Quando effettivamente restituito
 * 
 * IMMUTABILITY CRITICAL:
 * - Tutte e 3 le associazioni sono @Core.Immutable nel servizio
 * - Evita modifiche accidentali che romperebbero lo storico
 */
entity PrestitiInterbiblioteca : managed, cuid {
  // Business key per tracking
  numeroPrestito  : String(50)  @mandatory;
  
  // DATE WORKFLOW: Tracciamento completo del flusso
  dataRichiesta   : Date  @mandatory;
  dataInvio       : Date;
  dataRicezione   : Date;
  dataRestituzionePrevista : Date;
  dataRestituzioneEffettiva : Date;
  
  // STATO WORKFLOW: Default 'richiesto'
  stato           : String(20)  @mandatory default 'richiesto';
  note            : String(1000);
  
  // IMMUTABLE ASSOCIATIONS: Non modificabili dopo creazione
  copia           : Association to Copie  @mandatory;
  bibliotecaOrigine : Association to Biblioteche  @mandatory;
  bibliotecaDestinazione : Association to Biblioteche  @mandatory;
  
  // Nome persona richiedente nella biblioteca destinazione
  richiedente     : String(200);
}
