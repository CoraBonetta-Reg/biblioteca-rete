const cds = require('@sap/cds');

module.exports = cds.service.impl(async function() {
  // This service provides the OData endpoints for PrestitiMobileService
  // The REST endpoints are registered in srv/server.js using cds.on('bootstrap')
  
  // Custom event handlers for the OData service can be added here
  // For example:
  // this.on('READ', 'Biblioteche', async (req) => {
  //   return SELECT.from(req.target);
  // });
});
