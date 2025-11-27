# UI5 MCP Server Instructions

## Guidelines for UI5 Development

### Always Get Guidelines First
Use the `get_guidelines` tool of the UI5 MCP server to retrieve the latest coding standards and best practices for UI5 development.

**When to use:**
- Before starting any UI5 project
- Before implementing UI5-specific features
- When unsure about UI5 best practices
- Before modifying UI5 components or controls

## MCP Server Tools

### `mcp__ui5_mcp-serv_get_guidelines`
Retrieves the current coding standards and best practices for UI5 development to avoid common pitfalls.

**CRITICAL:** Use this tool at the start of any UI5 project or before implementing UI5 features.

**Returns:**
- Current best practices
- Common anti-patterns to avoid
- Recommended coding patterns
- Framework-specific guidelines

### `mcp__ui5_mcp-serv_get_api_reference`
Searches the UI5 API reference for module names and symbols.

**Parameters:**
- `projectDir`: Root directory of the UI5 project (contains `package.json` and `ui5.yaml`)
- `query`: Name of the UI5 module or symbol using dot or slash notation

**Query examples:**
- `sap.m.Button`
- `sap/ui/core/Core`
- `sap.m.Button#text` (specific property)
- `sap.ui.core.Core#init` (specific method)

**When to use:**
- When implementing UI5 controls
- When unsure about control properties or methods
- When checking API compatibility
- For understanding control inheritance

### `mcp__ui5_mcp-serv_get_project_info`
Retrieves general information about local UI5 projects.

**Parameters:**
- `projectDir`: Root directory of the UI5 project

**Returns:**
- Project structure
- Dependencies
- Configuration details
- Framework version

**When to use:**
- To understand project context
- Before making structural changes
- To verify project setup

### `mcp__ui5_mcp-serv_get_version_info`
Provides version information for UI5 (OpenUI5 or SAPUI5).

**Returns:**
- Framework version
- Available features for that version
- Compatibility information

**When to use:**
- To check feature availability
- Before using version-specific APIs
- For compatibility verification

## Common Workflows

### Starting a New UI5 Project
1. Get guidelines: `get_guidelines()`
2. Review best practices before writing code
3. Get version info: `get_version_info()` to understand available features
4. Create project structure following guidelines

### Implementing a UI5 Control
1. Get guidelines: `get_guidelines()` (if not already done)
2. Get API reference: `get_api_reference(projectDir, "sap.m.ControlName")`
3. Review control properties and methods
4. Implement following best practices from guidelines
5. Test implementation

### Modifying Existing UI5 Code
1. Get project info: `get_project_info(projectDir)` to understand context
2. Get guidelines: `get_guidelines()` to ensure compliance
3. Get API reference for specific controls being modified
4. Make changes following best practices
5. Verify version compatibility if needed

### Troubleshooting UI5 Issues
1. Get guidelines: `get_guidelines()` to check for common pitfalls
2. Get API reference for controls involved
3. Get project info to verify configuration
4. Get version info to check compatibility

## Integration with Fiori Elements

### Using UI5 in Fiori Elements Extensions
- Fiori Elements apps are built on UI5
- Use UI5 MCP server for custom controllers
- Use UI5 MCP server for custom fragments
- Always check guidelines before extending Fiori Elements

### Custom Controls in Fiori Elements
1. Get guidelines for UI5 custom controls
2. Get API reference for base control
3. Create custom control following best practices
4. Integrate with Fiori Elements annotations

## Best Practices Reminder

- **Always** call `get_guidelines()` before starting UI5 work
- Use dot notation for control names in queries: `sap.m.Button`
- Check version compatibility for new features
- Follow the coding patterns from guidelines
- Avoid common anti-patterns mentioned in guidelines
- Verify API usage with `get_api_reference` when uncertain
