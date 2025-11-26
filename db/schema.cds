using { Currency, managed, cuid, Country } from '@sap/cds/common';

namespace biblioteca.rete;

/**
 * Entità principale per i titoli disponibili nella rete bibliotecaria
 */
entity Titoli : managed, cuid {
  titolo          : localized String(500)  @mandatory;
  sottotitolo     : localized String(500);
  isbn            : String(17);  // ISBN-13 con trattini
  annoPubblicazione : Integer;
  lingua          : String(2);   // ISO 639-1
  numeroPagine    : Integer;
  descrizione     : localized String(5000);
  
  // Relazioni
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
 */
entity TitoliAutori : managed {
  key titolo      : Association to Titoli  @mandatory;
  key autore      : Association to Autori  @mandatory;
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
 */
entity Categorie : managed, cuid {
  codice          : String(20)  @mandatory;
  nome            : localized String(200)  @mandatory;
  descrizione     : localized String(1000);
  parent          : Association to Categorie;
  children        : Composition of many Categorie on children.parent = $self;
  
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
 */
entity Copie : managed, cuid {
  numeroInventario : String(50)  @mandatory;
  stato           : String(20)  @mandatory default 'disponibile';  // disponibile, prestato, manutenzione, danneggiato
  ubicazione      : String(100);  // scaffale, sala, etc.
  dataAcquisizione : Date;
  note            : String(1000);
  
  titolo          : Association to Titoli  @mandatory;
  biblioteca      : Association to Biblioteche  @mandatory;
  prestiti        : Association to many PrestitiInterbiblioteca on prestiti.copia = $self;
}

/**
 * Prestiti interbiblioteca
 */
entity PrestitiInterbiblioteca : managed, cuid {
  numeroPrestito  : String(50)  @mandatory;
  dataRichiesta   : Date  @mandatory;
  dataInvio       : Date;
  dataRicezione   : Date;
  dataRestituzionePrevista : Date;
  dataRestituzioneEffettiva : Date;
  stato           : String(20)  @mandatory default 'richiesto';  // richiesto, approvato, in_transito, ricevuto, restituito, annullato
  note            : String(1000);
  
  copia           : Association to Copie  @mandatory;
  bibliotecaOrigine : Association to Biblioteche  @mandatory;
  bibliotecaDestinazione : Association to Biblioteche  @mandatory;
  richiedente     : String(200);  // Nome del richiedente nella biblioteca di destinazione
}
