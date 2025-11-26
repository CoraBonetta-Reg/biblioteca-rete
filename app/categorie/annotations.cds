using BibliotecaService as service from '../../srv/biblioteca-service';

annotate service.Categorie with @(
    UI.HeaderInfo : {
        TypeName : 'Categoria',
        TypeNamePlural : 'Categorie',
        Title : {
            $Type : 'UI.DataField',
            Value : nome,
        },
        Description : {
            $Type : 'UI.DataField',
            Value : descrizione,
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
            Label : 'Categoria Padre',
            Value : categoriaPadre.nome,
        },
        {
            $Type : 'UI.DataField',
            Label : 'Descrizione',
            Value : descrizione,
        },
    ]
);

annotate service.Categorie with @(
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
                Label : 'Categoria Padre',
                Value : parent.nome,
            },
            {
                $Type : 'UI.DataField',
                Label : 'Descrizione',
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
            Label : 'Sottocategorie',
            ID : 'Sottocategorie',
            Target : 'children/@UI.LineItem#Sottocategorie',
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Titoli',
            ID : 'Titoli',
            Target : 'titoli/@UI.LineItem#TitoliCategoria',
        },
    ]
);

annotate service.Categorie with @(
    UI.LineItem #Sottocategorie : [
        {
            $Type : 'UI.DataField',
            Label : 'Nome',
            Value : nome,
        },
        {
            $Type : 'UI.DataField',
            Label : 'Descrizione',
            Value : descrizione,
        },
    ]
) {
    parent @Common.ValueList : {
        Label: 'Categoria Padre',
        CollectionPath: 'Categorie',
        Parameters: [
            { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: parent_ID, ValueListProperty: 'ID' },
            { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'nome' }
        ]
    }
    @Common.ValueListWithFixedValues;
};

annotate service.Titoli with @(
    UI.LineItem #TitoliCategoria : [
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
            Label : 'Casa Editrice',
            Value : casaEditrice.nome,
        },
        {
            $Type : 'UI.DataField',
            Label : 'Anno Pubblicazione',
            Value : annoPubblicazione,
        },
    ]
);