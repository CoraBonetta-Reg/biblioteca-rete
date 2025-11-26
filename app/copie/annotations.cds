using BibliotecaService as service from '../../srv/biblioteca-service';

annotate service.Copie with @(
    UI.HeaderInfo : {
        TypeName : 'Copia',
        TypeNamePlural : 'Copie',
        Title : {
            $Type : 'UI.DataField',
            Value : numeroInventario,
        },
        Description : {
            $Type : 'UI.DataField',
            Value : titolo.titolo,
        }
    },
    UI.LineItem : [
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
);

annotate service.Copie with @(
    UI.FieldGroup #GeneralInformation : {
        $Type : 'UI.FieldGroupType',
        Data : [
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
            {
                $Type : 'UI.DataField',
                Label : 'Note',
                Value : note,
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
            Label : 'Prestiti Interbiblioteca',
            ID : 'Prestiti',
            Target : 'prestiti/@UI.LineItem#Prestiti',
        },
    ]
);

annotate service.PrestitiInterbiblioteca with @(
    UI.LineItem #Prestiti : [
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
        {
            $Type : 'UI.DataField',
            Label : 'Data Prevista Restituzione',
            Value : dataPrevistaRestituzione,
        },
    ]
) {
    copia @Common.ValueList : {
        Label: 'Copie',
        CollectionPath: 'Copie',
        Parameters: [
            { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: copia_ID, ValueListProperty: 'ID' },
            { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'numeroInventario' }
        ]
    }
    @Common.ValueListWithFixedValues;
    bibliotecaOrigine @Common.ValueList : {
        Label: 'Biblioteca Origine',
        CollectionPath: 'Biblioteche',
        Parameters: [
            { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: bibliotecaOrigine_ID, ValueListProperty: 'ID' },
            { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'nome' }
        ]
    }
    @Common.ValueListWithFixedValues;
    bibliotecaDestinazione @Common.ValueList : {
        Label: 'Biblioteca Destinazione',
        CollectionPath: 'Biblioteche',
        Parameters: [
            { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: bibliotecaDestinazione_ID, ValueListProperty: 'ID' },
            { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'nome' }
        ]
    }
    @Common.ValueListWithFixedValues;
};