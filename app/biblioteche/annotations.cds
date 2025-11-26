using BibliotecaService as service from '../../srv/biblioteca-service';

annotate service.Biblioteche with @(
    UI.HeaderInfo : {
        TypeName : 'Biblioteca',
        TypeNamePlural : 'Biblioteche',
        Title : {
            $Type : 'UI.DataField',
            Value : nome,
        },
        Description : {
            $Type : 'UI.DataField',
            Value : citta,
        }
    },
    UI.LineItem : [
        {
            $Type : 'UI.DataField',
            Label : 'Nome',
            Value : nome,
        },
        {
            $Type : 'UI.DataField',
            Label : 'Città',
            Value : citta,
        },
        {
            $Type : 'UI.DataField',
            Label : 'Indirizzo',
            Value : indirizzo,
        },
        {
            $Type : 'UI.DataField',
            Label : 'Telefono',
            Value : telefono,
        },
        {
            $Type : 'UI.DataField',
            Label : 'Email',
            Value : email,
        },
    ]
);

annotate service.Biblioteche with @(
    UI.FieldGroup #GeneralInformation : {
        $Type : 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Label : 'Nome',
                Value : nome,
            },
            {
                $Type : 'UI.DataField',
                Label : 'Indirizzo',
                Value : indirizzo,
            },
            {
                $Type : 'UI.DataField',
                Label : 'Città',
                Value : citta,
            },
            {
                $Type : 'UI.DataField',
                Label : 'CAP',
                Value : cap,
            },
            {
                $Type : 'UI.DataField',
                Label : 'Provincia',
                Value : provincia,
            },
            {
                $Type : 'UI.DataField',
                Label : 'Paese',
                Value : paese_code,
            },
            {
                $Type : 'UI.DataField',
                Label : 'Telefono',
                Value : telefono,
            },
            {
                $Type : 'UI.DataField',
                Label : 'Email',
                Value : email,
            },
            {
                $Type : 'UI.DataField',
                Label : 'Sito Web',
                Value : sitoWeb,
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
            Label : 'Copie',
            ID : 'Copie',
            Target : 'copie/@UI.LineItem#CopieBiblioteca',
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Prestiti Ricevuti',
            ID : 'PrestitiRicevuti',
            Target : 'prestitiRicevuti/@UI.LineItem#PrestitiRicevuti',
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Prestiti Inviati',
            ID : 'PrestitiInviati',
            Target : 'prestitiInviati/@UI.LineItem#PrestitiInviati',
        },
    ]
);

annotate service.Copie with @(
    UI.LineItem #CopieBiblioteca : [
        {
            $Type : 'UI.DataField',
            Label : 'Numero Inventario',
            Value : numeroInventario,
        },
        {
            $Type : 'UI.DataField',
            Label : 'Titolo',
            Value : titolo.titolo,
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
    titolo @Common.ValueList : {
        Label: 'Titoli',
        CollectionPath: 'Titoli',
        Parameters: [
            { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: titolo_ID, ValueListProperty: 'ID' },
            { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'titolo' },
            { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'isbn' }
        ]
    }
    @Common.ValueListWithFixedValues;
};

annotate service.PrestitiInterbiblioteca with @(
    UI.LineItem : [
        {
            $Type : 'UI.DataField',
            Label : 'Numero Prestito',
            Value : numeroPrestito,
        },
        {
            $Type : 'UI.DataField',
            Label : 'Titolo',
            Value : copia.titolo.titolo,
        },
        {
            $Type : 'UI.DataField',
            Label : 'Biblioteca Origine',
            Value : bibliotecaOrigine.nome,
        },
        {
            $Type : 'UI.DataField',
            Label : 'Biblioteca Destinazione',
            Value : bibliotecaDestinazione.nome,
        },
        {
            $Type : 'UI.DataField',
            Label : 'Data Richiesta',
            Value : dataRichiesta,
        },
        {
            $Type : 'UI.DataField',
            Label : 'Stato',
            Value : stato,
        },
    ]
);

annotate service.PrestitiInterbiblioteca with @(
    UI.LineItem #PrestitiRicevuti : [
        {
            $Type : 'UI.DataField',
            Label : 'Titolo',
            Value : copia.titolo.titolo,
        },
        {
            $Type : 'UI.DataField',
            Label : 'Biblioteca Origine',
            Value : bibliotecaOrigine.nome,
        },
        {
            $Type : 'UI.DataField',
            Label : 'Data Richiesta',
            Value : dataRichiesta,
        },
        {
            $Type : 'UI.DataField',
            Label : 'Stato',
            Value : stato,
        },
    ]
);

annotate service.PrestitiInterbiblioteca with @(
    UI.LineItem #PrestitiInviati : [
        {
            $Type : 'UI.DataField',
            Label : 'Titolo',
            Value : copia.titolo.titolo,
        },
        {
            $Type : 'UI.DataField',
            Label : 'Biblioteca Destinazione',
            Value : bibliotecaDestinazione.nome,
        },
        {
            $Type : 'UI.DataField',
            Label : 'Data Richiesta',
            Value : dataRichiesta,
        },
        {
            $Type : 'UI.DataField',
            Label : 'Stato',
            Value : stato,
        },
    ]
);