using BibliotecaService as service from '../../srv/biblioteca-service';

annotate service.CaseEditrici with @(
    UI.HeaderInfo : {
        TypeName : 'Casa Editrice',
        TypeNamePlural : 'Case Editrici',
        Title : {
            $Type : 'UI.DataField',
            Value : nome,
        },
        Description : {
            $Type : 'UI.DataField',
            Value : paese_code,
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
            Label : 'Paese',
            Value : paese_code,
        },
        {
            $Type : 'UI.DataField',
            Label : 'Sito Web',
            Value : sitoWeb,
        },
    ]
);

annotate service.CaseEditrici with @(
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
                Label : 'Città',
                Value : citta,
            },
            {
                $Type : 'UI.DataField',
                Label : 'Paese',
                Value : paese_code,
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
            Label : 'Titoli Pubblicati',
            ID : 'Titoli',
            Target : 'titoli/@UI.LineItem#TitoliEditore',
        },
    ]
);

annotate service.Titoli with @(
    UI.LineItem #TitoliEditore : [
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
            Label : 'Categoria',
            Value : categoria.nome,
        },
    ]
);