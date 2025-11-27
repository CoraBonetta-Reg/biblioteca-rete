using BibliotecaService as service from '../../srv/biblioteca-service';

/**
 * UI ANNOTATIONS FOR TITOLI APP
 * 
 * STRUCTURE:
 * 1. UI.HeaderInfo: Object Page header (titolo invece di UUID)
 * 2. UI.LineItem: Colonne tabella List Report
 * 3. UI.FieldGroup: Campi form Object Page
 * 4. UI.Facets: Layout Object Page (sezioni e tabelle correlate)
 * 5. Qualified LineItems (#Autori, #Copie): Tabelle correlate nei facets
 * 
 * CRITICAL PATTERN:
 * - Usare navigation properties (casaEditrice.nome) NON _ID fields
 * - @Common.Text nel servizio garantisce display human-readable
 * - Entity-level annotations (Capabilities) causano errori se duplicate
 */

// =============================================================================
// HEADERINFO: Object Page Title
// =============================================================================
// Pattern: Mostra campo descrittivo (titolo) invece di ID nel breadcrumb
// Title: Campo principale visibile
// Description: Campo secondario (sotto il titolo)
// =============================================================================

annotate service.Titoli with @(
    UI.HeaderInfo : {
        TypeName : 'Titolo',
        TypeNamePlural : 'Titoli',
        Title : {
            $Type : 'UI.DataField',
            Value : titolo,
        },
        Description : {
            $Type : 'UI.DataField',
            Value : isbn,
        }
    },
    
    // =========================================================================
    // LINEITEM: Colonne Tabella List Report
    // =========================================================================
    // Pattern: Ogni DataField = una colonna
    // CRITICAL: Usare navigation properties (casaEditrice.nome) NON _ID
    // =========================================================================
    
    UI.LineItem : [
        {
            $Type : 'UI.DataField',
            Label : 'Titolo',
            Value : titolo,
        },
        {
            $Type : 'UI.DataField',
            Label : 'ISBN',
            Value : isbn,
        },
        {
            $Type : 'UI.DataField',
            Label : 'Anno Pubblicazione',
            Value : annoPubblicazione,
        },
        {
            $Type : 'UI.DataField',
            Label : 'Casa Editrice',
            Value : casaEditrice.nome,
        },
        {
            $Type : 'UI.DataField',
            Label : 'Categoria',
            Value : categoria.nome,
        },
    ]
);

// =============================================================================
// FIELDGROUP: Campi Form Object Page
// =============================================================================
// Pattern: Raggruppamento logico di campi per form editing
// #GeneralInformation: Nome qualificatore (usato nei Facets)
// CRITICAL: Usare navigation properties per human-readable display
// =============================================================================

annotate service.Titoli with @(
    UI.FieldGroup #GeneralInformation : {
        $Type : 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Label : 'Titolo',
                Value : titolo,
            },
            {
                $Type : 'UI.DataField',
                Label : 'Sottotitolo',
                Value : sottotitolo,
            },
            {
                $Type : 'UI.DataField',
                Label : 'ISBN',
                Value : isbn,
            },
            {
                $Type : 'UI.DataField',
                Label : 'Anno Pubblicazione',
                Value : annoPubblicazione,
            },
            {
                $Type : 'UI.DataField',
                Label : 'Lingua',
                Value : lingua,
            },
            {
                $Type : 'UI.DataField',
                Label : 'Anno Pubblicazione',
                Value : annoPubblicazione,
            },
            {
                $Type : 'UI.DataField',
                Label : 'Casa Editrice',
                Value : casaEditrice.nome,
            },
            {
                $Type : 'UI.DataField',
                Label : 'Categoria',
                Value : categoria.nome,
            },
            {
                $Type : 'UI.DataField',
                Label : 'Numero Pagine',
                Value : descrizione,
            },
        ],
    },
    
    // =========================================================================
    // FACETS: Layout Object Page
    // =========================================================================
    // Pattern: Definisce sezioni (tabs) nell'Object Page
    // - ReferenceFacet: Riferimento a FieldGroup o navigation con LineItem
    // - Target '@UI.FieldGroup#...': Riferimento a FieldGroup definito sopra
    // - Target 'navigation/@UI.LineItem#...': Tabella correlata (qualified)
    // 
    // CRITICAL: LineItem qualificati (#Autori, #Copie) evitano conflitti
    // quando stessa entity appare in più app con configurazioni diverse
    // =========================================================================
    
    UI.Facets : [
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'GeneralInformationFacet',
            Label : 'Informazioni Generali',
            Target : '@UI.FieldGroup#GeneralInformation',  // Link a FieldGroup sopra
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Autori',
            ID : 'Autori',
            Target : 'autori/@UI.LineItem#Autori',
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Copie',
            ID : 'Copie',
            Target : 'copie/@UI.LineItem#Copie',
        },
    ]
);

// =============================================================================
// QUALIFIED LINEITEM: Tabelle Correlate nei Facets
// =============================================================================
// Pattern: LineItem #Qualificatore per configurazioni specifiche per contesto
// #Autori: Configurazione specifica per tabella autori dentro Titoli app
// #Copie: Configurazione specifica per tabella copie dentro Titoli app
// 
// PERCHÉ QUALIFIED:
// - TitoliAutori appare sia in Titoli app che in Autori app
// - Ogni app può avere colonne diverse → serve qualificatore
// - Senza qualificatore: conflitti se configurazioni diverse
// =============================================================================

annotate service.TitoliAutori with @(
    UI.LineItem #Autori : [  // #Autori = qualificatore per questa vista
        {
            $Type : 'UI.DataField',
            Label : 'Nome',
            Value : autore.nome,
        },
        {
            $Type : 'UI.DataField',
            Label : 'Cognome',
            Value : autore.cognome,
        },
        {
            $Type : 'UI.DataField',
            Label : 'Ruolo',
            Value : ruolo,
        },
    ]
) {
    autore @Common.ValueList : {
        Label: 'Autori',
        CollectionPath: 'Autori',
        Parameters: [
            { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: autore_ID, ValueListProperty: 'ID' },
            { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'cognome' },
            { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'nome' }
        ]
    }
    @Common.ValueListWithFixedValues;
};

annotate service.Copie with @(
    UI.LineItem #Copie : [
        {
            $Type : 'UI.DataField',
            Label : 'Numero Inventario',
            Value : numeroInventario,
        },
        {
            $Type : 'UI.DataField',
            Label : 'Biblioteca',
            Value : biblioteca.nome,
        },
        {
            $Type : 'UI.DataField',
            Label : 'Stato',
            Value : stato,
        },
        {
            $Type : 'UI.DataField',
            Label : 'Ubicazione',
            Value : ubicazione,
        },
    ]
) {
    biblioteca @Common.ValueList : {
        Label: 'Biblioteche',
        CollectionPath: 'Biblioteche',
        Parameters: [
            { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: biblioteca_ID, ValueListProperty: 'ID' },
            { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'nome' },
            { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'citta' }
        ]
    }
    @Common.ValueListWithFixedValues;
};