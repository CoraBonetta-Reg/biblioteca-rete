# CAP MCP Server Instructions

## Mandatory Rules for CAP Development

### CDS Definition Search
- You MUST search for CDS definitions, like entities, fields and services (which include HTTP endpoints) with `cds-mcp`, only if it fails you MAY read `*.cds` files in the project.

### CAP Documentation Search
- You MUST search for CAP docs with `cds-mcp` EVERY TIME you create, modify CDS models or when using APIs or the `cds` CLI from CAP. 
- Do NOT propose, suggest or make any changes without first checking it.

### CDS Init
- When you use the `cds init` command, add the samples only if explicitly requested by the user.

## MCP Server Tools

### `mcp_cds-mcp_search_docs`
Searches code snippets of CAP documentation for the given query. Use this tool if you're unsure about CAP APIs for CDS, Node.js or Java.

**When to use:**
- Before modifying any `.cds` files
- Before using CAP CLI commands
- When implementing CAP-specific features (e.g., draft mode, aspects, annotations)
- When unsure about CAP best practices

**Example queries:**
- "How to define associations in CDS"
- "Draft enabled service configuration"
- "Localized data in CAP"
- "CDS aspects usage"

### `mcp_cds-mcp_search_model`
Returns CDS model definitions (CSN), including elements, annotations, parameters, file locations and HTTP endpoints. Useful for building queries, OData URLs, or modifying models.

**When to use:**
- Before creating OData queries
- When adding annotations to existing entities
- When checking service endpoints
- When understanding entity relationships

**Parameters:**
- `projectPath`: Root path of the project (required)
- `name`: Definition name (fuzzy search)
- `kind`: Definition kind (e.g., "service", "entity", "action")
- `topN`: Maximum number of results (default: 1)
- `namesOnly`: If true, only return definition names for overview

## Common Workflows

### Adding a New Entity
1. Search docs: `search_docs("CDS entity definition best practices")`
2. Create entity in `db/schema.cds`
3. Search model: `search_model(projectPath, kind="entity")` to verify
4. Add to service in `srv/*.cds`
5. Search docs: `search_docs("OData annotations for entities")`

### Modifying Existing Service
1. Search model: `search_model(projectPath, kind="service")` to understand current structure
2. Search docs: `search_docs("CAP service modification [specific feature]")`
3. Make changes
4. Compile with `cds compile srv` to validate

### Adding Annotations
1. Search model: `search_model(projectPath, name="EntityName")` to see current annotations
2. Search docs: `search_docs("CDS annotations [annotation type]")`
3. Add annotations in service or app-specific files
