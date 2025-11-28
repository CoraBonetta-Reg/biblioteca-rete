const cds = require('@sap/cds');

// Add CORS middleware to handle cross-origin requests from Next.js app
cds.on('bootstrap', app => {
  // CORS middleware for REST endpoints
  app.use((req, res, next) => {
    const allowedOrigins = ['http://localhost:3000', 'http://localhost:4004'];
    const origin = req.headers.origin;
    
    if (origin && allowedOrigins.includes(origin)) {
      res.header('Access-Control-Allow-Origin', origin);
      res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
      res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');
      res.header('Access-Control-Allow-Credentials', 'true');
    }
    
    // Handle preflight requests
    if (req.method === 'OPTIONS') {
      return res.sendStatus(200);
    }
    
    next();
  });
});

module.exports = cds.server;
