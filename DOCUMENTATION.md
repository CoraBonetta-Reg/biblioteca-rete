# Documentazione Tecnica - Sistema Gestione Rete Bibliotecaria

## Indice

1. [Architettura Generale](#architettura-generale)
2. [Modello Dati](#modello-dati)
3. [Servizio OData](#servizio-odata)
4. [Annotazioni UI](#annotazioni-ui)
5. [Internazionalizzazione](#internazionalizzazione)
6. [Applicazioni Fiori](#applicazioni-fiori)
7. [Pattern e Convenzioni](#pattern-e-convenzioni)
8. [API Reference](#api-reference)

---

## Architettura Generale

### Stack Tecnologico

```
┌─────────────────────────────────────┐
│   6 Fiori Elements Applications     │ ← UI Layer (SAPUI5 1.136.7)
│   (List Report + Object Page)       │
├─────────────────────────────────────┤
│   OData V4 Service                  │ ← Service Layer (CAP)
│   (BibliotecaService)               │
├─────────────────────────────────────┤
│   CDS Domain Model                  │ ← Data Layer
│   (8 entities + relationships)      │
├─────────────────────────────────────┤
│   SQLite In-Memory Database         │ ← Persistence (dev)
└─────────────────────────────────────┘
```

### Componenti Principali

| Componente | Tecnologia | Versione | Scopo |
|------------|-----------|----------|-------|
| Backend Framework | @sap/cds | v9.x | CAP runtime e compiler |
| Frontend Framework | SAPUI5 | 1.136.7 | Fiori Elements templates |
| Database (dev) | @cap-js/sqlite | v2.x | Persistent storage locale |
| OData Protocol | OData V4 | 4.01 | API REST standardizzata |
| UI Tooling | @sap/ux-ui5-tooling | 1.19.x | Generazione e preview app |
| Build Tool | npm workspaces | - | Gestione multi-app |

### Namespace

**Primary Namespace**: `biblioteca.rete`

Tutti gli artefatti seguono questa convenzione:
- Entità: `biblioteca.rete.Titoli`, `biblioteca.rete.Autori`, ...
- Servizio: `BibliotecaService`
- App IDs: `biblioteca.rete.titoli`, `biblioteca.rete.autori`, ...
- CSV files: `biblioteca.rete-{EntityName}.csv`

---

## Modello Dati

### Schema ER (Entity-Relationship)

```
┌──────────────┐         ┌──────────────┐
│   Titoli     │◄───────►│   Autori     │
│              │ (N:M)   │              │
│ - titolo     │ via     │ - nome       │
│ - isbn       │TitoliAut│ - cognome    │
│ - anno       │ori      │ - biografia  │
└──────┬───────┘         └──────────────┘
       │
       │ (1:N)
       ▼
┌──────────────┐         ┌──────────────┐
│   Copie      │         │  Biblioteche │
│              │◄────────┤              │
│ - numInv     │  (N:1)  │ - nome       │
│ - stato      │         │ - indirizzo  │
│ - ubicazione │         │ - citta      │
└──────┬───────┘         └──────┬───────┘
       │                         │
       │                    ┌────┴────┐
       │                    │         │
       │ (1:N)          (1:N)│     (1:N)│
       ▼                     ▼         ▼
┌──────────────────────────────────────┐
│   PrestitiInterbiblioteca            │
│                                      │
│ - numeroPrestito                     │
│ - stato (richiesto/in_transito/...)  │
│ - date (richiesta/invio/ricezione)   │
└──────────────────────────────────────┘

┌──────────────┐         ┌──────────────┐
│ CaseEditrici │◄────────┤  Categorie   │
│              │  (1:N)  │              │
│ - nome       │         │ - codice     │
│ - sede       │    ┌────┤ - nome       │
│ - paese      │    │    │ - parent     │
└──────┬───────┘    │    └──────┬───────┘
       │            │           │
       └────────────┴───────────┘
              (1:N) to Titoli
```

### Entità Core

#### Titoli
```cds
entity Titoli : managed, cuid {
  titolo          : localized String(500)  @mandatory;  // Multilingual
  sottotitolo     : localized String(500);
  isbn            : String(17);                        // ISBN-13 format
  annoPubblicazione : Integer;
  lingua          : String(2);                         // ISO 639-1
  numeroPagine    : Integer;
  descrizione     : localized String(5000);
  
  // Associations
  autori          : Association to many TitoliAutori on autori.titolo = $self;
  casaEditrice    : Association to CaseEditrici;
  categoria       : Association to Categorie;
  copie           : Association to many Copie on copie.titolo = $self;
}
```

**Chiavi**:
- Primary Key: `ID` (UUID, auto-generato da `cuid`)
- Business Key: `isbn` (unique per titolo)

**Managed Aspect**: Aggiunge automaticamente `createdAt`, `createdBy`, `modifiedAt`, `modifiedBy`

#### Copie (Physical Inventory)
```cds
entity Copie : managed, cuid {
  numeroInventario : String(50)  @mandatory;
  stato           : String(20)  @mandatory default 'disponibile';
  ubicazione      : String(100);
  dataAcquisizione : Date;
  note            : String(1000);
  
  // Immutable associations (cannot change after creation)
  titolo          : Association to Titoli  @mandatory;
  biblioteca      : Association to Biblioteche  @mandatory;
  prestiti        : Association to many PrestitiInterbiblioteca on prestiti.copia = $self;
}
```

**Stati validi**:
- `disponibile` - Copia disponibile per prestito
- `prestato` - In prestito interbiblioteca
- `manutenzione` - In riparazione/restauro
- `danneggiato` - Danneggiato, non prestabile

**Regole di immutabilità**:
- `titolo_ID` e `biblioteca_ID` sono `@Core.Immutable` (non modificabili dopo creazione)
- Garantisce integrità referenziale storica

#### TitoliAutori (Junction Table)
```cds
entity TitoliAutori : managed {
  key titolo      : Association to Titoli  @mandatory;
  key autore      : Association to Autori  @mandatory;
  ruolo           : String(50);  // es. "autore principale", "coautore", "curatore"
}
```

**Pattern Many-to-Many**:
- Chiave composita: `(titolo_ID, autore_ID)`
- Attributo aggiuntivo: `ruolo` per qualificare la relazione
- Entrambe le chiavi sono `@Core.Immutable`

#### Categorie (Hierarchical)
```cds
entity Categorie : managed, cuid {
  codice          : String(20)  @mandatory;
  nome            : localized String(200)  @mandatory;
  descrizione     : localized String(1000);
  parent          : Association to Categorie;           // Self-reference
  children        : Composition of many Categorie on children.parent = $self;
  
  titoli          : Association to many Titoli on titoli.categoria = $self;
}
```

**Pattern Gerarchico**:
- Self-referencing con `parent` per categorie padre
- `Composition` per `children` (eliminazione a cascata)
- Supporta alberi di profondità arbitraria (es. Narrativa > Romanzo > Storico)

### Relazioni e Cardinalità

| Da | A | Tipo | Cardinalità | Note |
|----|---|------|-------------|------|
| Titoli | Autori | Association (via TitoliAutori) | N:M | Many-to-many con attributo ruolo |
| Titoli | CaseEditrici | Association | N:1 | Ogni titolo ha una casa editrice |
| Titoli | Categorie | Association | N:1 | Ogni titolo appartiene a una categoria |
| Titoli | Copie | Association | 1:N | Un titolo può avere più copie fisiche |
| Copie | Biblioteche | Association | N:1 | Ogni copia appartiene a una biblioteca |
| Copie | PrestitiInterbiblioteca | Association | 1:N | Storico prestiti per copia |
| Biblioteche | PrestitiInterbiblioteca | Association | 1:N (×2) | Sia origine che destinazione |
| Categorie | Categorie | Association | 1:N | Self-reference per gerarchia |

---

## Servizio OData

### Definizione Servizio

```cds
@i18n: '../_i18n/i18n'
service BibliotecaService {
  @odata.draft.enabled entity Titoli as projection on db.Titoli;
  @odata.draft.enabled entity Autori as projection on db.Autori;
  @odata.draft.enabled entity CaseEditrici as projection on db.CaseEditrici;
  @odata.draft.enabled entity Categorie as projection on db.Categorie;
  @odata.draft.enabled entity Biblioteche as projection on db.Biblioteche;
  @odata.draft.enabled entity Copie as projection on db.Copie;
  @odata.draft.enabled entity PrestitiInterbiblioteca as projection on db.PrestitiInterbiblioteca;
  @odata.draft.enabled entity TitoliAutori as projection on db.TitoliAutori;
}
```

### Draft Mode

Tutte le entità sono **draft-enabled** per supportare:

1. **Editing Collaborativo**: Più utenti possono lavorare su bozze separate
2. **Salvataggio Incrementale**: Salvare lavori parziali senza pubblicare
3. **Validazione Pre-Commit**: Validare prima del salvataggio finale
4. **Rollback**: Scartare modifiche senza impatto

**Limitazioni**:
- Non è possibile creare/modificare entità correlate inline da draft (es. creare Autore da Titolo draft)
- Necessario gestire entità correlate nelle loro app dedicate

### Endpoints OData

**Base URL**: `http://localhost:4004/biblioteca/`

| Endpoint | Metodo | Descrizione |
|----------|--------|-------------|
| `/Titoli` | GET | Lista tutti i titoli |
| `/Titoli(ID)` | GET | Dettaglio singolo titolo |
| `/Titoli` | POST | Crea nuovo titolo (draft) |
| `/Titoli(ID)` | PATCH | Modifica titolo esistente |
| `/Titoli(ID)` | DELETE | Elimina titolo |
| `/Titoli(ID)/autori` | GET | Autori del titolo (via TitoliAutori) |
| `/Titoli(ID)/copie` | GET | Copie del titolo |
| `/$metadata` | GET | Metadata EDMX |

**Expand Navigation**:
```
GET /Titoli?$expand=autori($expand=autore),casaEditrice,categoria,copie
```

**Filter Examples**:
```
GET /Titoli?$filter=annoPubblicazione eq 1972
GET /Copie?$filter=stato eq 'disponibile' and biblioteca/nome eq 'Biblioteca Nazionale'
GET /PrestitiInterbiblioteca?$filter=stato eq 'in_transito'
```

### Annotazioni a Livello Servizio

#### Field Labels (i18n)
```cds
annotate BibliotecaService.Titoli with {
  titolo @title: '{i18n>titolo}';              // Multilingual
  isbn @title: '{i18n>isbn}';
  casaEditrice @title: '{i18n>casaEditrice}';
};
```

#### Human-Readable Display
```cds
annotate BibliotecaService.Titoli with {
  casaEditrice @Common.Text: casaEditrice.nome 
               @Common.TextArrangement: #TextOnly;  // Mostra solo nome, non ID
  categoria @Common.Text: categoria.nome 
            @Common.TextArrangement: #TextOnly;
};
```

**Pattern**: Tutte le associazioni usano `@Common.Text` per mostrare campi descrittivi invece di UUID.

#### Value Help (F4)
```cds
annotate BibliotecaService.Titoli with {
  casaEditrice @Common.ValueList : {
    Label: 'Case Editrici',
    CollectionPath: 'CaseEditrici',
    Parameters: [
      { $Type: 'Common.ValueListParameterInOut', 
        LocalDataProperty: casaEditrice_ID, 
        ValueListProperty: 'ID' },
      { $Type: 'Common.ValueListParameterDisplayOnly', 
        ValueListProperty: 'nome' },
      { $Type: 'Common.ValueListParameterDisplayOnly', 
        ValueListProperty: 'paese_code' }
    ]
  }
  @Common.ValueListWithFixedValues;  // Forza selezione da dropdown
};
```

**Comportamento**:
- `@Common.ValueListWithFixedValues` disabilita input manuale
- Utente DEVE selezionare da dropdown
- Previene inserimento UUID errati

#### Immutability
```cds
annotate BibliotecaService.TitoliAutori with {
  titolo @Core.Immutable;  // Non modificabile dopo creazione
  autore @Core.Immutable;
};
```

**Applicato a**:
- Chiavi di junction tables (TitoliAutori)
- Foreign keys critiche (Copie.titolo, Copie.biblioteca)
- Relazioni in PrestitiInterbiblioteca

---

## Annotazioni UI

### Distribuzione Annotazioni

**Principio**: Separazione tra metadata service-level e presentazione UI

| Tipo Annotazione | Posizione | Scopo |
|-----------------|-----------|-------|
| `@title`, `@Common.Text`, `@Common.ValueList`, `@Core.Immutable` | `srv/biblioteca-service.cds` | Metadata indipendente da UI |
| `@UI.HeaderInfo`, `@UI.LineItem`, `@UI.Facets`, `@UI.FieldGroup` | `app/{appname}/annotations.cds` | Presentazione specifica app |

**Regola Critica**: Annotazioni entity-level (es. `Capabilities`) non possono essere duplicate tra app files → causano errori di compilazione.

### Pattern UI Comuni

#### HeaderInfo (Object Page Title)
```cds
annotate service.Titoli with @(
    UI.HeaderInfo : {
        TypeName : 'Titolo',
        TypeNamePlural : 'Titoli',
        Title : {
            $Type : 'UI.DataField',
            Value : titolo,           // Campo descrittivo principale
        },
        Description : {
            $Type : 'UI.DataField',
            Value : isbn,             // Campo secondario
        }
    }
);
```

**Risultato**: Object Page header mostra "Le città invisibili" invece di UUID.

#### LineItem (Table Columns)
```cds
annotate service.Titoli with @(
    UI.LineItem : [
        {
            $Type : 'UI.DataField',
            Label : 'Titolo',
            Value : titolo,          // Usa navigation property per testo
        },
        {
            $Type : 'UI.DataField',
            Label : 'Casa Editrice',
            Value : casaEditrice.nome,  // NON casaEditrice_ID
        },
        {
            $Type : 'UI.DataField',
            Label : 'Anno',
            Value : annoPubblicazione,
        },
    ]
);
```

**Pattern Critico**: Mai usare `_ID` fields in LineItem, sempre navigation properties.

#### FieldGroup (Detail Fields)
```cds
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
                Label : 'ISBN',
                Value : isbn,
            },
            {
                $Type : 'UI.DataField',
                Label : 'Casa Editrice',
                Value : casaEditrice.nome,  // Human-readable
            },
            // ... altri campi
        ],
    }
);
```

#### Facets (Object Page Layout)
```cds
annotate service.Titoli with @(
    UI.Facets : [
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'GeneralInformationFacet',
            Label : 'Informazioni Generali',
            Target : '@UI.FieldGroup#GeneralInformation',  // Riferimento a FieldGroup
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Autori',
            ID : 'Autori',
            Target : 'autori/@UI.LineItem#Autori',  // Navigation + LineItem qualificato
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Copie',
            ID : 'Copie',
            Target : 'copie/@UI.LineItem#Copie',
        },
    ]
);
```

**Pattern Tabelle Correlate**:
```cds
annotate service.TitoliAutori with @(
    UI.LineItem #Autori : [  // Qualified variant per evitare conflitti
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
);
```

**Qualified LineItem**: `#Autori` permette di avere multiple configurazioni LineItem per stessa entità in contesti diversi.

---

## Internazionalizzazione

### Struttura i18n

```
_i18n/
├── i18n.properties       # English (default)
└── i18n_it.properties    # Italian
```

### File Format

**i18n.properties** (Inglese):
```properties
# Entity names
Titoli=Titles
Autori=Authors
Biblioteche=Libraries

# Field labels
titolo=Title
sottotitolo=Subtitle
isbn=ISBN
annoPubblicazione=Publication Year
casaEditrice=Publisher
categoria=Category
```

**i18n_it.properties** (Italiano):
```properties
# Entity names
Titoli=Titoli
Autori=Autori
Biblioteche=Biblioteche

# Field labels
titolo=Titolo
sottotitolo=Sottotitolo
isbn=ISBN
annoPubblicazione=Anno di Pubblicazione
casaEditrice=Casa Editrice
categoria=Categoria
```

### Utilizzo nel Servizio

```cds
@i18n: '../_i18n/i18n'
service BibliotecaService {
  // ...
}

annotate BibliotecaService.Titoli with {
  titolo @title: '{i18n>titolo}';
  isbn @title: '{i18n>isbn}';
};
```

**Runtime Behavior**:
- Browser language detection automatica
- Fallback a inglese se lingua non supportata
- Labels UI si aggiornano dinamicamente

### Localized Fields

Alcuni campi usano `localized` aspect per contenuti multilingual:

```cds
entity Titoli {
  titolo : localized String(500);      // Stored per lingua
  descrizione : localized String(5000);
}
```

**Comportamento**:
- CAP crea automaticamente tabella `Titoli_texts` con `locale`, `titolo`, `descrizione`
- OData espone campo localizzato in base a `Accept-Language` header
- Gestione trasparente per utente

---

## Applicazioni Fiori

### Struttura App Standard

Ogni app segue questo template:

```
app/{appname}/
├── annotations.cds           # UI annotations (HeaderInfo, LineItem, Facets)
├── package.json              # App metadata
├── ui5.yaml                  # UI5 tooling config
├── README.md                 # App-specific docs
└── webapp/
    ├── Component.js          # UI5 component initialization
    ├── index.html            # Entry point
    ├── manifest.json         # UI5 app descriptor (CRITICAL)
    ├── i18n/
    │   └── i18n.properties   # App-specific translations
    └── test/
        ├── flpSandbox.html   # Fiori Launchpad sandbox
        └── integration/      # OPA5 tests (template, not implemented)
```

### Manifest.json (Chiave)

```json
{
  "sap.app": {
    "id": "biblioteca.rete.titoli",
    "type": "application",
    "dataSources": {
      "mainService": {
        "uri": "/biblioteca/",      // OData service path
        "type": "OData",
        "settings": {
          "odataVersion": "4.0"
        }
      }
    }
  },
  "sap.ui5": {
    "dependencies": {
      "libs": {
        "sap.fe.templates": {}       // Fiori Elements dependency
      }
    },
    "models": {
      "i18n": {...},
      "": {
        "dataSource": "mainService",
        "preload": true,
        "settings": {
          "operationMode": "Server",
          "autoExpandSelect": true,
          "earlyRequests": true
        }
      }
    },
    "routing": {
      "routes": [{
        "pattern": ":?query:",
        "name": "TitoliList",
        "target": "TitoliList"
      }, {
        "pattern": "Titoli({key}):?query:",
        "name": "TitoliObjectPage",
        "target": "TitoliObjectPage"
      }],
      "targets": {
        "TitoliList": {
          "type": "Component",
          "id": "TitoliList",
          "name": "sap.fe.templates.ListReport",
          "options": {
            "settings": {
              "entitySet": "Titoli"
            }
          }
        },
        "TitoliObjectPage": {
          "type": "Component",
          "id": "TitoliObjectPage",
          "name": "sap.fe.templates.ObjectPage",
          "options": {
            "settings": {
              "entitySet": "Titoli"
            }
          }
        }
      }
    }
  }
}
```

### Lista App e Scopo

| App | Entity Set | Scopo Principale | Facets Correlati |
|-----|-----------|------------------|------------------|
| **titoli** | Titoli | Gestire catalogo libri | autori, copie |
| **autori** | Autori | Gestire anagrafica autori | titoli |
| **biblioteche** | Biblioteche | Gestire rete biblioteche | copie, prestitiRicevuti, prestitiInviati |
| **copie** | Copie | Tracciare inventario fisico | prestiti |
| **case-editrici** | CaseEditrici | Gestire editori | titoli |
| **categorie** | Categorie | Organizzare classificazione | children, titoli |

---

## Pattern e Convenzioni

### 1. CSV Data Format

**Separatore**: Semicolon (`;`)  
**Encoding**: UTF-8  
**UUID Format**: Standard UUID v4 (8-4-4-4-12 hex digits)

```csv
ID;titolo;isbn;annoPubblicazione;casaEditrice_ID;categoria_ID
550e8400-e29b-41d4-a716-446655440301;Le città invisibili;978-88-04-52803-7;1972;550e8400-e29b-41d4-a716-446655440001;550e8400-e29b-41d4-a716-446655440202
```

**Naming Convention**:
- File: `biblioteca.rete-{EntityName}.csv`
- Foreign keys: `{associationName}_ID`
- Localized text tables: `biblioteca.rete-{EntityName}_texts.csv` (se necessario)

### 2. Naming Conventions

| Elemento | Convention | Esempio |
|----------|-----------|---------|
| Entity | PascalCase, plurale | `Titoli`, `Autori`, `CaseEditrici` |
| Field | camelCase | `titolo`, `annoPubblicazione`, `numeroInventario` |
| Association | camelCase, singolare | `casaEditrice`, `biblioteca`, `parent` |
| Service | PascalCase + "Service" | `BibliotecaService` |
| App ID | namespace + lowercase | `biblioteca.rete.titoli` |
| i18n key | camelCase | `titolo`, `annoPubblicazione` |

### 3. Association Foreign Keys

CAP auto-genera foreign key fields con pattern `{association}_ID`:

```cds
entity Copie {
  titolo : Association to Titoli;      // Genera: titolo_ID (UUID)
  biblioteca : Association to Biblioteche;  // Genera: biblioteca_ID (UUID)
}
```

**CSV MUST match**:
```csv
ID;numeroInventario;stato;titolo_ID;biblioteca_ID
...
```

**Common Mistake**: Usare `titolo_code` o `biblioteca_name` invece di `*_ID` → Errore caricamento dati.

### 4. Draft Pattern

**Ciclo di vita Draft**:
1. User clicks "Edit" → CAP crea draft copy in tabella `{Entity}_drafts`
2. User modifica campi → Salvati in draft
3. User clicks "Save" → CAP valida e "attiva" il draft (merge in tabella attiva)
4. User clicks "Cancel" → Draft eliminato

**Draft vs Active**:
- Active: Dati visibili a tutti gli utenti
- Draft: Dati visibili solo a owner del draft
- `IsActiveEntity` flag distingue record attivi da draft

**Limitazioni**:
- No inline creation di entità correlate da draft
- No modifica entità correlate se draft-enabled

### 5. Human-Readable Display Strategy

**Problema**: UUID non leggibili in UI  
**Soluzione**: 3-tier strategy

**Tier 1 - Service Level**: `@Common.Text` + `@Common.TextArrangement`
```cds
annotate BibliotecaService.Copie with {
  titolo @Common.Text: titolo.titolo 
         @Common.TextArrangement: #TextOnly;
};
```

**Tier 2 - UI Level**: Navigation properties in LineItem/FieldGroup
```cds
UI.LineItem : [
  {
    Value : titolo.titolo,  // NOT titolo_ID
  }
]
```

**Tier 3 - HeaderInfo**: Descriptive titles
```cds
UI.HeaderInfo : {
    Title : { Value : titolo },    // NOT ID
    Description : { Value : isbn },
}
```

**Result**: User vede "Le città invisibili" invece di "550e8400-e29b-41d4-a716-446655440301".

---

## API Reference

### OData V4 Endpoints

#### GET /Titoli
Lista tutti i titoli con paginazione.

**Query Parameters**:
- `$top` (int): Numero record (default 50)
- `$skip` (int): Offset
- `$filter` (string): Filtro OData
- `$orderby` (string): Ordinamento
- `$expand` (string): Expand navigations
- `$select` (string): Proiezione campi

**Response**:
```json
{
  "@odata.context": "$metadata#Titoli",
  "value": [
    {
      "ID": "550e8400-e29b-41d4-a716-446655440301",
      "titolo": "Le città invisibili",
      "isbn": "978-88-04-52803-7",
      "annoPubblicazione": 1972,
      "casaEditrice_ID": "550e8400-e29b-41d4-a716-446655440001"
    }
  ]
}
```

#### POST /Titoli (Create Draft)
Crea nuovo titolo in draft mode.

**Request Body**:
```json
{
  "titolo": "Nuovo Titolo",
  "isbn": "978-88-12-34567-8",
  "annoPubblicazione": 2025,
  "casaEditrice_ID": "550e8400-e29b-41d4-a716-446655440001",
  "categoria_ID": "550e8400-e29b-41d4-a716-446655440202"
}
```

**Response**: Draft entity con `IsActiveEntity: false`

#### PATCH /Titoli(ID)/BibliotecaService.draftEdit
Attiva draft mode su entità esistente.

**Response**: Draft copy dell'entità

#### POST /Titoli(ID)/BibliotecaService.draftActivate
Salva e attiva draft.

**Effect**: Draft mergiato in entità attiva, draft eliminato

### CAP CDS APIs (per custom handlers)

```javascript
// srv/service.js (se necessario custom logic)

module.exports = (srv) => {
  
  // Before CREATE handler
  srv.before('CREATE', 'Copie', async (req) => {
    // Validazione custom
    const { stato } = req.data;
    if (!['disponibile', 'prestato', 'manutenzione', 'danneggiato'].includes(stato)) {
      req.error(400, 'Stato non valido');
    }
  });
  
  // After READ handler
  srv.after('READ', 'Titoli', (data) => {
    // Post-processing
    if (Array.isArray(data)) {
      data.forEach(titolo => {
        // Custom logic
      });
    }
  });
  
  // Custom action
  srv.on('prestaInterbiblioteca', async (req) => {
    const { copiaID, bibliotecaDestinazioneID } = req.data;
    // Custom business logic
  });
  
};
```

---

## Estensioni Future

### Performance Optimization
- [ ] Implement server-side pagination con `$top`/`$skip`
- [ ] Add database indexes su campi filtrabili (isbn, anno, stato)
- [ ] Lazy loading per navigation deep (es. autori > titoli > copie)

### Business Logic
- [ ] Validazione ISBN-13 checksum
- [ ] Workflow prestiti con approvazione
- [ ] Notifiche email per prestiti
- [ ] Calcolo automatico data restituzione prevista
- [ ] Report statistiche utilizzo copie

### Security
- [ ] Authentication & Authorization
- [ ] Role-based access (bibliotecario, amministratore, utente)
- [ ] Field-level security (es. nascondere note interne)
- [ ] Audit log per modifiche critiche

### Integration
- [ ] API esterna per ricerca ISBN (Google Books, OpenLibrary)
- [ ] Export catalogo in formato MARC21
- [ ] Sincronizzazione con sistema ILS esistente

### Testing
- [ ] Unit tests per validazioni business logic
- [ ] Integration tests per endpoints OData
- [ ] OPA5 tests per user journeys Fiori
- [ ] Performance tests con dataset realistico (10K+ titoli)

---

## Troubleshooting

### Errori Comuni

#### 1. "Duplicate assignment with @@UI.CreateHidden"
**Causa**: Annotazioni entity-level duplicate tra app files  
**Soluzione**: Centralizzare in `srv/biblioteca-service.cds` o rimuovere duplicati

#### 2. "Active entities cannot be modified via draft request"
**Causa**: Tentativo modifica entità correlata da draft principale  
**Soluzione**: Gestire entità correlate nella loro app dedicata

#### 3. CSV load error: "Association target not found"
**Causa**: Foreign key column usa nome sbagliato (es. `titolo` invece di `titolo_ID`)  
**Soluzione**: Rinominare colonna CSV con suffix `_ID`

#### 4. UUID visibili in UI invece di nomi
**Causa**: Manca `@Common.Text` o usato `_ID` field in LineItem  
**Soluzione**: Aggiungere `@Common.Text` + `@Common.TextArrangement` e usare navigation property

#### 5. User può digitare UUID manualmente in dropdown
**Causa**: Manca `@Common.ValueListWithFixedValues`  
**Soluzione**: Aggiungere annotazione su tutte le associazioni

### Log e Debug

**Abilitare logging CAP**:
```bash
DEBUG=* cds watch
```

**Inspect OData metadata**:
```
http://localhost:4004/biblioteca/$metadata
```

**Browser DevTools**:
- Network tab → Inspect OData requests/responses
- Console → Check Fiori Elements errors

---

## Riferimenti

- **CAP Documentation**: https://cap.cloud.sap/docs/
- **OData V4 Spec**: https://www.odata.org/documentation/
- **Fiori Elements**: https://ui5.sap.com/test-resources/sap/fe/demokit/
- **CDS Language Reference**: https://cap.cloud.sap/docs/cds/
- **UI5 SDK**: https://sapui5.hana.ondemand.com/

---

**Documento generato**: 27 novembre 2025  
**Versione applicazione**: 1.0.0  
**Autore**: Cora Bonetta / GitHub Copilot
