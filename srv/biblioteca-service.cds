using {biblioteca.rete as db} from '../db/schema';

/**
 * Servizio per la gestione della rete bibliotecaria
 * 
 * Questo servizio espone le entità principali per:
 * - Consultare il catalogo dei titoli disponibili
 * - Gestire le biblioteche della rete
 * - Monitorare i prestiti interbiblioteca
 */
@i18n: '../_i18n/i18n'
service BibliotecaService {

  /** Catalogo dei titoli con informazioni complete */
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

// Field labels
annotate BibliotecaService.Titoli with {
  titolo @title: '{i18n>titolo}';
  sottotitolo @title: '{i18n>sottotitolo}';
  isbn @title: '{i18n>isbn}';
  annoPubblicazione @title: '{i18n>annoPubblicazione}';
  lingua @title: '{i18n>lingua}';
  numeroPagine @title: '{i18n>numeroPagine}';
  descrizione @title: '{i18n>descrizione}';
  casaEditrice @title: '{i18n>casaEditrice}' @Common.Text: casaEditrice.nome @Common.TextArrangement: #TextOnly;
  categoria @title: '{i18n>categoria}' @Common.Text: categoria.nome @Common.TextArrangement: #TextOnly;
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

// Value Help annotations
annotate BibliotecaService.Titoli with {
  casaEditrice @Common.ValueList : {
    Label: 'Case Editrici',
    CollectionPath: 'CaseEditrici',
    Parameters: [
      { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: casaEditrice_ID, ValueListProperty: 'ID' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'nome' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'paese_code' }
    ]
  }
  @Common.ValueListWithFixedValues;
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
  @Core.Immutable;
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
  @Core.Immutable;
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
