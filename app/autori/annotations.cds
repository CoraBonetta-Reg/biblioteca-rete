using BibliotecaService as service from '../../srv/biblioteca-service';

annotate service.Autori with @(
    UI.HeaderInfo : {
        TypeName : 'Autore',
        TypeNamePlural : 'Autori',
        Title : {
            $Type : 'UI.DataField',
            Value : cognome,
        },
        Description : {
            $Type : 'UI.DataField',
            Value : nome,
        }
    },
    UI.LineItem : [
        {
            $Type : 'UI.DataField',
            Label : 'Cognome',
            Value : cognome,
        },
        {
            $Type : 'UI.DataField',
            Label : 'Nome',
            Value : nome,
        },
        {
            $Type : 'UI.DataField',
            Label : 'Nazionalità',
            Value : nazionalita_code,
        },
        {
            $Type : 'UI.DataField',
            Label : 'Data di Nascita',
            Value : dataNascita,
        },
    ]
);

annotate service.Autori with @(
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
                Label : 'Cognome',
                Value : cognome,
            },
            {
                $Type : 'UI.DataField',
                Label : 'Data di Nascita',
                Value : dataNascita,
            },
            {
                $Type : 'UI.DataField',
                Label : 'Data di Morte',
                Value : dataMorte,
            },
            {
                $Type : 'UI.DataField',
                Label : 'Nazionalità',
                Value : nazionalita_code,
            },
            {
                $Type : 'UI.DataField',
                Label : 'Biografia',
                Value : biografia,
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
            Label : 'Titoli',
            ID : 'Titoli',
            Target : 'titoli/@UI.LineItem#Titoli',
        },
    ]
) {
    // Disable inline editing of titoli association in Autori context
    titoli @(
        Capabilities.InsertRestrictions.Insertable : false,
        Capabilities.UpdateRestrictions.Updatable : false,
        Capabilities.DeleteRestrictions.Deletable : false
    );
};

annotate service.TitoliAutori with @(
    UI.LineItem #Titoli : [
        {
            $Type : 'UI.DataField',
            Label : 'Titolo',
            Value : titolo.titolo,
        },
        {
            $Type : 'UI.DataField',
            Label : 'ISBN',
            Value : titolo.isbn,
        },
        {
            $Type : 'UI.DataField',
            Label : 'Ruolo',
            Value : ruolo,
        },
        {
            $Type : 'UI.DataField',
            Label : 'Anno Pubblicazione',
            Value : titolo.annoPubblicazione,
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