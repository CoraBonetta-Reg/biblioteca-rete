using BibliotecaService as service from '../../srv/biblioteca-service';

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
    UI.Facets : [
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'GeneralInformationFacet',
            Label : 'Informazioni Generali',
            Target : '@UI.FieldGroup#GeneralInformation',
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

annotate service.TitoliAutori with @(
    UI.LineItem #Autori : [
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