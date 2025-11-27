# Fiori MCP Server Instructions

## Mandatory Rules for SAP Fiori Elements Development

### Application Structure
- When asked to create an SAP Fiori elements app, check whether the user input can be interpreted as an application organized into one or more pages containing table data or forms
- These can be translated into a SAP Fiori elements application, else ask the user for suitable input

### Page Types
- The application typically starts with a **List Report page** showing the data of the base entity of the application in a table
- Details of a specific table row are shown in the **Object Page**
- This first Object Page is therefore based on the base entity of the application
- An Object Page can contain one or more table sections based on to-many associations of its entity type
- The details of a table section row can be shown in another Object Page based on the association's target entity

### Data Model Requirements
- The data model must be suitable for usage in a SAP Fiori elements frontend application
- There must be one main entity and one or more navigation properties to related entities
- Each property of an entity must have a proper datatype
- For all entities in the data model provide primary keys of type UUID

### Sample Data Format
- When creating sample data in CSV files, all primary keys and foreign keys MUST be in UUID format
- Example: `550e8400-e29b-41d4-a716-446655440001`

### MCP Server Usage
- When generating or modifying the SAP Fiori elements application on top of the CAP service, use the Fiori MCP server if available
- When attempting to modify the SAP Fiori elements application (like adding columns), you must NOT use screen personalization
- Instead, modify the code of the project
- Before making changes, first check whether an MCP server provides a suitable function

### Preview and Testing
- When previewing the SAP Fiori elements application, use the most specific `npm run watch-*` script for the app in the `package.json`
- Example: `npm run watch-titoli` for the Titoli app

## MCP Server Three-Step Workflow

### Step 1: List Available Functionality
Use `mcp_fiori-mcp_list_functionality` to retrieve a comprehensive list of functionalities available for Fiori applications.

**When to use:**
- Before creating a new Fiori app
- Before modifying an existing app
- To understand available capabilities

### Step 2: Get Functionality Details
Use `mcp_fiori-mcp_get_functionality_details` to get detailed parameters necessary for executing a specific functionality.

**Parameters needed:**
- Functionality name from Step 1
- Any context-specific information

**Returns:**
- Required parameters
- Optional parameters
- Parameter types and validation rules

### Step 3: Execute Functionality
Use `mcp_fiori-mcp_execute_functionality` to perform the actual creation or modification of the application based on the parameters gathered in Step 2.

**Common functionalities:**
- Create new Fiori Elements app
- Add columns to table
- Add fields to form
- Configure navigation
- Add custom actions

## Discovery Tools

### List Fiori Apps
Use `mcp_fiori-mcp_list_fiori_apps` or `mcp_fiori-mcp2_list_fiori_apps` to scan for existing applications in a directory.

**When to use:**
- Before modifying an app (to get its exact name/path)
- To avoid creating duplicate apps
- As a preliminary step before the main workflow

## Documentation Search

### Search Fiori Docs
Use `mcp_fiori-mcp_search_docs` or `mcp_fiori-mcp2_search_docs` to search for documentation and code snippets related to SAP Fiori, Fiori Elements, Annotations, and SAPUI5.

**When to use:**
- When unsure about Fiori APIs
- When implementing Fiori-specific features
- When adding complex annotations
- For understanding Fiori Elements patterns

**Example queries:**
- "How to add custom columns to List Report"
- "Object Page facet configuration"
- "Value help configuration in Fiori Elements"
- "HeaderInfo annotation usage"

## Common Workflows

### Creating a New Fiori Elements App
1. List functionality: `list_functionality()`
2. Get details: `get_functionality_details("create_app")`
3. Execute: `execute_functionality(params)` with:
   - App name
   - Base entity
   - Service path
   - App type (List Report, Object Page, etc.)

### Adding Columns to Existing App
1. List apps: `list_fiori_apps(directory)` to find app path
2. Search docs: `search_docs("add columns to LineItem annotation")`
3. List functionality: `list_functionality()`
4. Get details: `get_functionality_details("add_column")`
5. Execute: `execute_functionality(params)`

### Modifying Annotations
1. Search docs: `search_docs("Fiori Elements [annotation type]")`
2. Review current annotations in `app/[appname]/annotations.cds`
3. Use MCP server if available, otherwise edit directly
4. Test with `npm run watch-[appname]`
