````instructions
# Biblioteca Rete - AI Agent Instructions

## Architecture Overview

This is a **SAP Cloud Application Programming Model (CAP)** project for managing a library network with:
- **Backend**: Node.js OData V4 service (`srv/biblioteca-service.cds`)
- **Database**: SQLite in-memory for development
- **Frontend**: 6 SAP Fiori Elements applications (List Report + Object Page)
- **Namespace**: `biblioteca.rete` used throughout
- **i18n**: Italian/English bilingual support (`_i18n/i18n.properties`, `_i18n/i18n_it.properties`)

### Core Entity Relationships
```
Titoli (1) ──→ (N) Copie ──→ (N) PrestitiInterbiblioteca
   ↓                ↓                      ↓
CaseEditrici   Biblioteche           Biblioteche (origine/destinazione)
Categorie

Titoli (N) ←──→ (N) Autori  (via TitoliAutori junction table)
```

All entities use **`cuid`** (UUID keys) and **`managed`** aspects (createdAt, modifiedAt, etc).

## Critical Patterns & Conventions

### 1. CDS Model Structure
- **Schema**: `db/schema.cds` - Domain model with Italian comments, localized fields (`titolo`, `biografia`)
- **Service**: `srv/biblioteca-service.cds` - Service projections + ALL field labels/value helps/immutability annotations
- **App Annotations**: `app/{appname}/annotations.cds` - UI.HeaderInfo, UI.LineItem, UI.Facets, UI.FieldGroup
- **Data**: `db/data/biblioteca.rete-{EntityName}.csv` - **Semicolon-separated**, UUID keys, `_ID` suffix for foreign keys

### 2. Annotation Distribution (CRITICAL)
**Service file** (`srv/biblioteca-service.cds`) contains:
- `@title` with i18n keys for all fields
- `@Common.Text` + `@Common.TextArrangement: #TextOnly` for human-readable association display
- `@Common.ValueList` + `@Common.ValueListWithFixedValues` for dropdown enforcement
- `@Core.Immutable` on junction table keys (TitoliAutori, Copie, PrestitiInterbiblioteca)

**App files** (`app/*/annotations.cds`) contain:
- `@UI.HeaderInfo` (TypeName, Title, Description)
- `@UI.LineItem` (main table + qualified variants like `#Autori`, `#Copie`)
- `@UI.FieldGroup #GeneralInformation` (detail fields)
- `@UI.Facets` (Object Page layout with ReferenceFacets)

**DO NOT duplicate entity-level annotations** (Capabilities, UI visibility) across multiple app files - they are entity-scoped and will cause compilation errors.

### 3. Human-Readable Display Pattern
Always use **navigation properties** instead of `_ID` fields in UI:

```cds
// In FieldGroup/LineItem - CORRECT:
Value : casaEditrice.nome,        // Shows "Einaudi"
Value : categoria.nome,           // Shows "Narrativa"

// WRONG (shows UUID):
Value : casaEditrice_ID,          // Shows "550e8400-..."
```

Service-level annotations ensure text-only display:
```cds
annotate BibliotecaService.Titoli with {
  casaEditrice @Common.Text: casaEditrice.nome 
               @Common.TextArrangement: #TextOnly;
};
```

### 4. Value Help & Immutability
Force dropdown selection on all associations:
```cds
titolo @Common.ValueList : {
    Label: 'Titoli',
    CollectionPath: 'Titoli',
    Parameters: [
        { $Type: 'Common.ValueListParameterInOut', 
          LocalDataProperty: titolo_ID, 
          ValueListProperty: 'ID' },
        { $Type: 'Common.ValueListParameterDisplayOnly', 
          ValueListProperty: 'titolo' }
    ]
}
@Common.ValueListWithFixedValues
@Core.Immutable;  // Prevents modification after creation
```

Apply `@Core.Immutable` to junction table keys and critical foreign keys (Copie, PrestitiInterbiblioteca).

### 5. Draft Mode
All entities are `@odata.draft.enabled` for collaborative editing. This means:
- Edit operations create draft copies
- Changes saved to drafts, not active entities directly
- **Cannot inline-edit related entities from draft** (known limitation)

## Development Workflows

### Running the Application
```bash
npm start                         # Start server on http://localhost:4004
cds watch                         # With live reload

# Run specific app:
npm run watch-titoli              # Opens Titoli app
npm run watch-autori              # Opens Autori app
# (see package.json for all 6 apps)
```

### Service Endpoints
- **OData Service**: `http://localhost:4004/biblioteca/`
- **Metadata**: `http://localhost:4004/biblioteca/$metadata`
- **Fiori Apps**: `http://localhost:4004/biblioteca.rete.{appname}/webapp/`
- **App Index**: `http://localhost:4004/`

### Testing Changes
```bash
npx cds compile srv              # Verify CDS compilation
npx cds compile srv 2>&1 | Select-String -Pattern "error"  # Windows: show errors only
```

Server auto-reloads on `.cds` file changes when using `cds watch`.

### Adding New Entities - Checklist
1. **Define in `db/schema.cds`** with `cuid, managed` aspects
2. **Add projection in `srv/biblioteca-service.cds`** with `@odata.draft.enabled`
3. **Add field labels** in same service file with `@title: '{i18n>key}'`
4. **Add text/value help** annotations in service file
5. **Update i18n files** with new keys in both `_i18n/i18n.properties` and `_i18n/i18n_it.properties`
6. **Create CSV** in `db/data/biblioteca.rete-{EntityName}.csv` with semicolon separators
7. **Generate Fiori app** using Fiori MCP server (see below)
8. **Add UI annotations** in `app/{appname}/annotations.cds`

### Using MCP Servers (REQUIRED)

**CAP MCP** (`mcp_cds-mcp_*`):
- `search_docs` - **Query CAP documentation BEFORE using CAP APIs** (mandatory for model/service changes)
- `search_model` - Find entities, services, fields in current project

**Fiori MCP** (`mcp_fiori-mcp_*`):
- `list_functionality` - Get available Fiori operations
- `get_functionality_details` - Get parameters for operation
- `execute_functionality` - Generate/modify Fiori apps

**UI5 MCP** (`mcp_ui5_mcp-serv_*`):
- `get_guidelines` - UI5 best practices and coding standards
- `get_api_reference` - UI5 API documentation

**Always use `search_docs` before making CDS changes to ensure correct syntax and patterns.**

## Data File Format

CSV files use **semicolon (;) separators** and **UUID format**:
```csv
ID;titolo;isbn;annoPubblicazione;casaEditrice_ID;categoria_ID
550e8400-e29b-41d4-a716-446655440301;Le città invisibili;978-88-04-52803-7;1972;550e8400-e29b-41d4-a716-446655440001;550e8400-e29b-41d4-a716-446655440202
```

**Foreign key columns** must use `_ID` suffix matching CAP's auto-generated fields (e.g., `casaEditrice_ID`, NOT `casaEditrice_code`).

## Common Pitfalls

1. **CSV Association Mismatch**: Always use `associationName_ID` in CSV headers
2. **Duplicate Annotations**: Entity-level annotations (Capabilities, UI visibility) cannot be in multiple app files - causes compilation errors
3. **ID Fields in UI**: Use `association.field` (e.g., `casaEditrice.nome`), never `association_ID` in LineItem/FieldGroup
4. **Missing TextArrangement**: Always pair `@Common.Text` with `@Common.TextArrangement: #TextOnly`
5. **Missing ValueListWithFixedValues**: Users can type UUIDs without this annotation - always enforce dropdown selection
6. **Missing Immutability**: Junction table keys (TitoliAutori) should be `@Core.Immutable` to prevent data integrity issues
7. **Inline Editing Limitations**: Draft entities cannot inline-create/edit related entities - use dedicated apps instead

## Project Structure

```
biblioteca-rete/
├── db/
│   ├── schema.cds                     # Domain model (8 entities)
│   └── data/                          # CSV with semicolon separators
├── srv/
│   └── biblioteca-service.cds         # Service + field annotations (300+ lines)
├── app/
│   ├── services.cds                   # Auto-generated imports
│   ├── titoli/                        # Fiori app for Titoli
│   │   ├── annotations.cds            # UI.HeaderInfo, LineItem, Facets
│   │   └── webapp/manifest.json       # UI5 descriptor
│   ├── autori/                        # Fiori app for Autori
│   ├── biblioteche/                   # Fiori app for Biblioteche
│   ├── copie/                         # Fiori app for Copie
│   ├── case-editrici/                 # Fiori app for Case Editrici
│   └── categorie/                     # Fiori app for Categorie (hierarchical)
├── _i18n/
│   ├── i18n.properties                # English labels
│   └── i18n_it.properties             # Italian labels
├── package.json                       # npm workspaces, watch-* scripts
└── DEVELOPMENT_REPORT.md              # Complete development history & metrics
```

## Technology Stack

- **CAP**: v9 (@sap/cds)
- **UI5**: v1.136.7 (SAPUI5)
- **Database**: @cap-js/sqlite (in-memory)
- **Tooling**: cds-plugin-ui5 v0.13, @sap/ux-ui5-tooling v1.19
- **Node.js**: Compatible with CAP v9

## Key Design Decisions

1. **Localized Fields**: `titolo` (Titoli), `biografia` (Autori), `nome/descrizione` (Categorie) use `localized` aspect
2. **Hierarchical Categories**: Self-referencing with `parent` association and `children` composition
3. **Junction Table**: TitoliAutori for many-to-many Titoli-Autori relationship with `ruolo` attribute
4. **Immutable Keys**: Copie (titolo, biblioteca) and PrestitiInterbiblioteca (all associations) prevent accidental changes
5. **Text-Only Display**: All associations show descriptive text, never UUIDs in UI
6. **Draft-Enabled**: All entities support collaborative editing with automatic conflict resolution

## References

- CAP Documentation: https://cap.cloud.sap/docs/
- Fiori Elements: https://ui5.sap.com/test-resources/sap/fe/demokit/
- Development Report: See `DEVELOPMENT_REPORT.md` for complete development history, metrics, and lessons learned

````
