# MCP Server Configuration for GitHub Copilot Workspace

This document describes the Model Context Protocol (MCP) servers required for developing this CAP application with Fiori Elements. GitHub Copilot Coding Agent should be configured to use these servers when available.

## Required MCP Servers

### 1. CAP MCP Server (`cds-mcp`)

**Purpose:** Provides access to SAP Cloud Application Programming Model documentation and CDS model introspection.

**Installation:**
```bash
npm install -g @sap/cds-mcp
```

**Configuration for VS Code settings.json:**
```json
{
  "mcp": {
    "servers": {
      "cds-mcp": {
        "command": "cds-mcp",
        "args": [],
        "env": {}
      }
    }
  }
}
```

**Available Tools:**
- `mcp_cds-mcp_search_docs`: Search CAP documentation
- `mcp_cds-mcp_search_model`: Query CDS model definitions

**When to use:**
- **MANDATORY** before modifying any `.cds` files
- **MANDATORY** before using CAP CLI commands (`cds` commands)
- When implementing CAP features (draft, aspects, annotations)
- When building OData queries or URLs

**Workflow:**
1. Search docs before making changes: `search_docs("feature you want to implement")`
2. Search model to understand structure: `search_model(projectPath, kind="entity|service")`
3. Make changes based on documentation
4. Validate with `cds compile srv`

See detailed instructions in [`.github/instructions/cap-mcp-server.md`](.github/instructions/cap-mcp-server.md)

---

### 2. Fiori MCP Server (`fiori-mcp`)

**Purpose:** Provides tools for generating and modifying SAP Fiori Elements applications.

**Installation:**
```bash
npm install -g @sap/fiori-mcp
```

**Configuration for VS Code settings.json:**
```json
{
  "mcp": {
    "servers": {
      "fiori-mcp": {
        "command": "fiori-mcp",
        "args": [],
        "env": {}
      }
    }
  }
}
```

**Available Tools:**
- `mcp_fiori-mcp_list_functionality`: List available operations
- `mcp_fiori-mcp_get_functionality_details`: Get parameters for operation
- `mcp_fiori-mcp_execute_functionality`: Execute the operation
- `mcp_fiori-mcp_list_fiori_apps`: Discover existing apps
- `mcp_fiori-mcp_search_docs`: Search Fiori documentation

**Mandatory Three-Step Workflow:**
1. **List**: `list_functionality()` to see available operations
2. **Details**: `get_functionality_details("operation_name")` to get required parameters
3. **Execute**: `execute_functionality(params)` to perform the operation

**When to use:**
- When creating new Fiori Elements apps
- When modifying existing apps (add columns, fields, actions)
- Before editing `annotations.cds` manually (check if MCP can do it)
- **MANDATORY** for app generation instead of manual creation

**Common Operations:**
- Create List Report Object Page app
- Add columns to LineItem
- Add fields to FieldGroup
- Configure navigation between pages
- Add custom actions

See detailed instructions in [`.github/instructions/fiori-mcp-server.md`](.github/instructions/fiori-mcp-server.md)

---

### 3. UI5 MCP Server (`ui5-mcp`)

**Purpose:** Provides UI5 coding guidelines, API reference, and project information.

**Installation:**
```bash
npm install -g @sap/ui5-mcp
```

**Configuration for VS Code settings.json:**
```json
{
  "mcp": {
    "servers": {
      "ui5-mcp": {
        "command": "ui5-mcp",
        "args": [],
        "env": {}
      }
    }
  }
}
```

**Available Tools:**
- `mcp__ui5_mcp-serv_get_guidelines`: Get UI5 best practices (CALL FIRST!)
- `mcp__ui5_mcp-serv_get_api_reference`: Search UI5 API
- `mcp__ui5_mcp-serv_get_project_info`: Get project details
- `mcp__ui5_mcp-serv_get_version_info`: Get UI5 version info

**When to use:**
- **MANDATORY** at the start of any UI5 work: call `get_guidelines()`
- When implementing UI5 controls
- When extending Fiori Elements with custom code
- When creating custom controllers or fragments
- When unsure about UI5 APIs or best practices

**Workflow:**
1. Get guidelines first: `get_guidelines()`
2. Search API reference: `get_api_reference(projectDir, "sap.m.Button")`
3. Implement following guidelines
4. Check version compatibility if needed

See detailed instructions in [`.github/instructions/ui5-mcp-server.md`](.github/instructions/ui5-mcp-server.md)

---

## Integration Points

### CAP + Fiori Workflow
1. **CAP**: `search_docs("entity definition")` → Create entity in `db/schema.cds`
2. **CAP**: `search_docs("OData service")` → Expose in `srv/*.cds`
3. **Fiori**: `list_functionality()` → `execute_functionality()` → Generate app
4. **CAP**: `search_model(kind="entity")` → Verify structure
5. **Fiori**: `search_docs("annotations")` → Add UI annotations

### Fiori + UI5 Workflow
1. **Fiori**: Use MCP to generate/modify app structure and annotations
2. **UI5**: `get_guidelines()` → Get best practices for extensions
3. **UI5**: `get_api_reference()` → Implement custom controls/logic
4. **Fiori**: Integrate custom UI5 code with Fiori Elements

### Full Stack Development
1. **CAP**: Define data model and service
2. **CAP**: Add business logic if needed
3. **Fiori**: Generate UI with MCP server
4. **UI5**: Extend with custom code following guidelines
5. **CAP**: `search_model()` to verify everything is connected

---

## Configuration for GitHub Copilot Workspace

Since GitHub Copilot Coding Agent running on GitHub infrastructure **cannot access local MCP servers**, this configuration serves as:

1. **Documentation** of the MCP servers used in development
2. **Instructions** for what to search/check before making changes
3. **Workflow guidance** even without direct MCP access

### What GitHub Copilot CAN do without MCP:
- Read the instruction files in `.github/instructions/`
- Follow the documented workflows
- Search the codebase for patterns
- Read existing `.cds`, `annotations.cds`, and other files
- Compile and validate with `cds compile srv`

### What GitHub Copilot CANNOT do without MCP:
- Query live CAP documentation with `search_docs()`
- Query CDS model with `search_model()`
- Use Fiori MCP three-step generation workflow
- Get live UI5 guidelines with `get_guidelines()`

### Recommended Approach:
When the coding agent needs information that would come from MCP:
1. Search existing codebase for similar patterns
2. Read reference files: `DOCUMENTATION.md`, `.github/copilot-instructions.md`
3. Check existing entities/services for structure examples
4. Validate changes with `cds compile srv`
5. Test with `npm run watch-[appname]`

---

## Local Development Setup

For developers working locally with full MCP access:

### VS Code Settings Configuration
Add to your `settings.json` (User or Workspace):

```json
{
  "github.copilot.chat.codeGeneration.useInstructionFiles": true,
  "mcp": {
    "servers": {
      "cds-mcp": {
        "command": "cds-mcp",
        "args": []
      },
      "fiori-mcp": {
        "command": "fiori-mcp",
        "args": []
      },
      "ui5-mcp": {
        "command": "ui5-mcp",
        "args": []
      }
    }
  }
}
```

### Instruction Files
Place in `%APPDATA%/Code/User/prompts/`:
- `cap-mcp-server.instructions.md`
- `fiori-mcp-server.instructions.md`
- `ui5-mcp-server.instructions.md`

Or use the versions in this repository:
- `.github/instructions/cap-mcp-server.md`
- `.github/instructions/fiori-mcp-server.md`
- `.github/instructions/ui5-mcp-server.md`

---

## Troubleshooting

### MCP Server Not Available
If an MCP server is not installed or not working:
1. Refer to the instruction files for manual workflows
2. Search codebase for existing patterns
3. Read `DOCUMENTATION.md` for architecture guidance
4. Use `cds compile srv` to validate CDS changes
5. Test thoroughly with the watch scripts

### MCP Commands Failing
1. Check server installation: `npm list -g @sap/cds-mcp`
2. Verify VS Code settings configuration
3. Restart VS Code to reload MCP servers
4. Check MCP server logs in VS Code Output panel

### Alternative to MCP
1. Read SAP CAP documentation: https://cap.cloud.sap/docs/
2. Read Fiori Elements documentation: https://ui5.sap.com/test-resources/sap/fe/core/fpmExplorer/index.html
3. Read SAPUI5 documentation: https://ui5.sap.com/
4. Search this codebase for existing patterns
