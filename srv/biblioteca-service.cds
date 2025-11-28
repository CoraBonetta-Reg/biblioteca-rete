using {biblioteca.rete as db} from '../db/schema';

/**
 * Servizio per la gestione della rete bibliotecaria
 * 
 * ARCHITECTURE NOTES:
 * - Espone 8 entità del dominio come OData V4 entities
 * - Tutte le entità sono @odata.draft.enabled per editing collaborativo
 * - i18n configurato per supporto multilingua (IT/EN)
 * - Annotazioni @Common.Text per display human-readable (no UUID visibili)
 * - Annotazioni @Common.ValueList per dropdown F4 help
 * - Annotazioni @Core.Immutable su chiavi critiche per integrità dati
 * 
 * ENDPOINT BASE: http://localhost:4004/biblioteca/
 * METADATA: http://localhost:4004/biblioteca/$metadata
 */
@i18n: '../_i18n/i18n'
service BibliotecaService {

  /**
   * Catalogo dei titoli con informazioni complete
   * 
   * DRAFT MODE: Abilitato per permettere:
   * - Salvataggio incrementale senza pubblicare
   * - Editing collaborativo con conflict resolution
   * - Rollback modifiche senza impatto su dati attivi
   * 
   * CRITICAL: Le entità correlate (autori, copie) NON possono essere
   * create/modificate inline da draft - gestirle nelle loro app dedicate
   */
  @odata.draft.enabled
  entity Titoli as projection on db.Titoli;

  /** Autori dei titoli */
  @odata.draft.enabled
  entity Autori as projection on db.Autori;

  /** Case editrici */
  @odata.draft.enabled
  entity CaseEditrici as projection on db.CaseEditrici;

  /** Categorie per la classificazione */
  @odata.draft.enabled
  entity Categorie as projection on db.Categorie;

  /** Biblioteche della rete */
  @odata.draft.enabled
  entity Biblioteche as projection on db.Biblioteche;

  /** Copie fisiche disponibili nelle biblioteche */
  @odata.draft.enabled
  entity Copie as projection on db.Copie;

  /** Gestione dei prestiti interbiblioteca */
  @odata.draft.enabled
  entity PrestitiInterbiblioteca as projection on db.PrestitiInterbiblioteca;

  /** Relazione titoli-autori */
  @odata.draft.enabled
  entity TitoliAutori as projection on db.TitoliAutori;
}

// =============================================================================
// NAVIGATION RESTRICTIONS FOR READ-ONLY ASSOCIATIONS
// =============================================================================
// Disable inline create, update, delete for navigation properties in Titoli
// Users must use dedicated Autori and Copie apps for modifications
// =============================================================================

annotate BibliotecaService.Titoli with {
  autori @Capabilities : {
    InsertRestrictions : {Insertable : false},
    UpdateRestrictions : {Updatable : false},
    DeleteRestrictions : {Deletable : false}
  };
  copie @Capabilities : {
    InsertRestrictions : {Insertable : false},
    UpdateRestrictions : {Updatable : false},
    DeleteRestrictions : {Deletable : false}
  };
};

// =============================================================================
// FIELD LABELS WITH i18n
// =============================================================================
// Pattern: @title: '{i18n>key}' per tutte le label
// Files: _i18n/i18n.properties (EN), _i18n/i18n_it.properties (IT)
// Runtime: Label si adatta automaticamente alla lingua del browser
// =============================================================================

annotate BibliotecaService.Titoli with {
  titolo @title: '{i18n>titolo}';
  sottotitolo @title: '{i18n>sottotitolo}';
  isbn @title: '{i18n>isbn}';
  annoPubblicazione @title: '{i18n>annoPubblicazione}';
  lingua @title: '{i18n>lingua}';
  numeroPagine @title: '{i18n>numeroPagine}';
  descrizione @title: '{i18n>descrizione}';
  
  // HUMAN-READABLE DISPLAY PATTERN:
  // @Common.Text: Specifica quale campo mostrare invece dell'ID
  // @Common.TextArrangement: #TextOnly nasconde completamente l'ID
  // Result: User vede "Einaudi" invece di "550e8400-e29b-41d4-a716-446655440001"
  casaEditrice @title: '{i18n>casaEditrice}' 
               @Common.Text: casaEditrice.nome 
               @Common.TextArrangement: #TextOnly;
  categoria @title: '{i18n>categoria}' 
            @Common.Text: categoria.nome 
            @Common.TextArrangement: #TextOnly;
};

annotate BibliotecaService.Autori with {
  nome @title: '{i18n>nome}';
  cognome @title: '{i18n>cognome}';
  dataNascita @title: '{i18n>dataNascita}';
  nazionalita @title: '{i18n>nazionalita}';
  biografia @title: '{i18n>biografia}';
};

annotate BibliotecaService.CaseEditrici with {
  nome @title: '{i18n>nome}';
  paese @title: '{i18n>paese}';
  sitoWeb @title: '{i18n>sitoWeb}';
};

annotate BibliotecaService.Categorie with {
  codice @title: '{i18n>codice}';
  nome @title: '{i18n>nome}';
  descrizione @title: '{i18n>descrizione}';
  parent @title: '{i18n>parent}' @Common.Text: parent.nome @Common.TextArrangement: #TextOnly;
};

annotate BibliotecaService.Biblioteche with {
  codice @title: '{i18n>codice}';
  nome @title: '{i18n>nome}';
  indirizzo @title: '{i18n>indirizzo}';
  citta @title: '{i18n>citta}';
  cap @title: '{i18n>cap}';
  provincia @title: '{i18n>provincia}';
  paese @title: '{i18n>paese}';
  telefono @title: '{i18n>telefono}';
  email @title: '{i18n>email}';
  sitoWeb @title: '{i18n>sitoWeb}';
  orariApertura @title: '{i18n>orariApertura}';
};

annotate BibliotecaService.Copie with {
  numeroInventario @title: '{i18n>numeroInventario}';
  stato @title: '{i18n>stato}';
  ubicazione @title: '{i18n>ubicazione}';
  dataAcquisizione @title: '{i18n>dataAcquisizione}';
  note @title: '{i18n>note}';
  titolo @title: '{i18n>titolo}' @Common.Text: titolo.titolo @Common.TextArrangement: #TextOnly;
  biblioteca @title: '{i18n>biblioteca}' @Common.Text: biblioteca.nome @Common.TextArrangement: #TextOnly;
};

annotate BibliotecaService.PrestitiInterbiblioteca with {
  numeroPrestito @title: '{i18n>numeroPrestito}';
  dataRichiesta @title: '{i18n>dataRichiesta}';
  dataInvio @title: '{i18n>dataInvio}';
  dataRicezione @title: '{i18n>dataRicezione}';
  dataRestituzionePrevista @title: '{i18n>dataRestituzionePrevista}';
  dataRestituzioneEffettiva @title: '{i18n>dataRestituzioneEffettiva}';
  stato @title: '{i18n>stato}';
  note @title: '{i18n>note}';
  copia @title: '{i18n>copia}' @Common.Text: copia.numeroInventario @Common.TextArrangement: #TextOnly;
  bibliotecaOrigine @title: '{i18n>bibliotecaOrigine}' @Common.Text: bibliotecaOrigine.nome @Common.TextArrangement: #TextOnly;
  bibliotecaDestinazione @title: '{i18n>bibliotecaDestinazione}' @Common.Text: bibliotecaDestinazione.nome @Common.TextArrangement: #TextOnly;
  richiedente @title: '{i18n>richiedente}';
};

annotate BibliotecaService.TitoliAutori with {
  titolo @title: '{i18n>titolo}' @Common.Text: titolo.titolo @Common.TextArrangement: #TextOnly;
  autore @title: '{i18n>autore}' @Common.Text: { $value: autore.cognome, ![@UI.TextArrangement]: #TextFirst } @Common.TextArrangement: #TextOnly;
  ruolo @title: '{i18n>ruolo}';
};

// =============================================================================
// VALUE HELP (F4) CONFIGURATION
// =============================================================================
// Pattern: @Common.ValueList definisce dropdown con campi visibili
// @Common.ValueListWithFixedValues: CRITICAL - disabilita input manuale UUID
// Without this, users can type random UUIDs causing data integrity issues
// =============================================================================

annotate BibliotecaService.Titoli with {
  // VALUE HELP PATTERN:
  // 1. Label: Titolo del dropdown popup
  // 2. CollectionPath: Entity set da cui caricare i valori
  // 3. Parameters:
  //    - ValueListParameterInOut: Campo chiave (ID) - binding bidirezionale
  //    - ValueListParameterDisplayOnly: Campi descrittivi visibili (nome, paese)
  // 4. @Common.ValueListWithFixedValues: FORZA selezione da dropdown (no input manuale)
  
  casaEditrice @Common.ValueList : {
    Label: 'Case Editrici',
    CollectionPath: 'CaseEditrici',
    Parameters: [
      { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: casaEditrice_ID, ValueListProperty: 'ID' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'nome' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'paese_code' }
    ]
  }
  @Common.ValueListWithFixedValues;  // CRITICAL: Previene input UUID manuale
  categoria @Common.ValueList : {
    Label: 'Categorie',
    CollectionPath: 'Categorie',
    Parameters: [
      { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: categoria_ID, ValueListProperty: 'ID' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'nome' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'descrizione' }
    ]
  }
  @Common.ValueListWithFixedValues;
};

// =============================================================================
// IMMUTABILITY CONSTRAINTS
// =============================================================================
// @Core.Immutable: Campo non modificabile dopo creazione
// CRITICAL for junction tables e foreign keys critiche
// Prevents accidental changes that would break data integrity/history
// Applied to:
// - TitoliAutori: titolo, autore (junction table keys)
// - Copie: titolo, biblioteca (physical inventory tracking)
// - PrestitiInterbiblioteca: all associations (historical tracking)
// =============================================================================

annotate BibliotecaService.TitoliAutori with {
  titolo @Common.ValueList : {
    Label: 'Titoli',
    CollectionPath: 'Titoli',
    Parameters: [
      { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: titolo_ID, ValueListProperty: 'ID' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'titolo' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'isbn' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'annoPubblicazione' }
    ]
  }
  @Common.ValueListWithFixedValues
  @Core.Immutable;  // CRITICAL: Non modificabile dopo creazione (junction table key)
  autore @Common.ValueList : {
    Label: 'Autori',
    CollectionPath: 'Autori',
    Parameters: [
      { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: autore_ID, ValueListProperty: 'ID' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'cognome' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'nome' }
    ]
  }
  @Common.ValueListWithFixedValues
  @Core.Immutable;  // CRITICAL: Non modificabile dopo creazione (junction table key)
};

annotate BibliotecaService.Categorie with {
  parent @Common.ValueList : {
    Label: 'Categoria Padre',
    CollectionPath: 'Categorie',
    Parameters: [
      { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: parent_ID, ValueListProperty: 'ID' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'nome' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'descrizione' }
    ]
  }
  @Common.ValueListWithFixedValues;
};

annotate BibliotecaService.Copie with {
  titolo @Common.ValueList : {
    Label: 'Titoli',
    CollectionPath: 'Titoli',
    Parameters: [
      { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: titolo_ID, ValueListProperty: 'ID' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'titolo' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'isbn' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'annoPubblicazione' }
    ]
  }
  @Common.ValueListWithFixedValues
  @Core.Immutable;
  biblioteca @Common.ValueList : {
    Label: 'Biblioteche',
    CollectionPath: 'Biblioteche',
    Parameters: [
      { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: biblioteca_ID, ValueListProperty: 'ID' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'nome' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'citta' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'indirizzo' }
    ]
  }
  @Common.ValueListWithFixedValues
  @Core.Immutable;
};

annotate BibliotecaService.PrestitiInterbiblioteca with {
  copia @Common.ValueList : {
    Label: 'Copie',
    CollectionPath: 'Copie',
    Parameters: [
      { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: copia_ID, ValueListProperty: 'ID' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'numeroInventario' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'stato' }
    ]
  }
  @Common.ValueListWithFixedValues
  @Core.Immutable;
  bibliotecaOrigine @Common.ValueList : {
    Label: 'Biblioteca Origine',
    CollectionPath: 'Biblioteche',
    Parameters: [
      { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: bibliotecaOrigine_ID, ValueListProperty: 'ID' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'nome' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'citta' }
    ]
  }
  @Common.ValueListWithFixedValues
  @Core.Immutable;
  bibliotecaDestinazione @Common.ValueList : {
    Label: 'Biblioteca Destinazione',
    CollectionPath: 'Biblioteche',
    Parameters: [
      { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: bibliotecaDestinazione_ID, ValueListProperty: 'ID' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'nome' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'citta' }
    ]
  }
  @Common.ValueListWithFixedValues
  @Core.Immutable;
};
