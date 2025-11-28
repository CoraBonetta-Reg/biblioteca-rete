const cds = require('@sap/cds');

cds.on('bootstrap', app => {
  // Add body parser for JSON
  app.use(require('express').json());
  
  // Add CORS middleware for REST endpoints
  app.use('/rest', (req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.header('Access-Control-Allow-Headers', 'Content-Type');
    if (req.method === 'OPTIONS') {
      return res.sendStatus(200);
    }
    next();
  });
  
  // GET /rest/biblioteche - List all libraries
  app.get('/rest/biblioteche', async (req, res) => {
    try {
      const db = await cds.connect.to('db');
      const { Biblioteche } = db.entities('biblioteca.rete');
      
      const biblioteche = await SELECT.from(Biblioteche)
        .columns('ID', 'nome', 'citta')
        .orderBy('nome');
      res.json(biblioteche);
    } catch (error) {
      console.error('Error fetching libraries:', error);
      res.status(500).json({ error: 'Errore nel caricamento delle biblioteche' });
    }
  });
  
  // GET /rest/copie-disponibili - Get available copies for a specific library
  app.get('/rest/copie-disponibili', async (req, res) => {
    try {
      const bibliotecaId = req.query.bibliotecaId;
      
      if (!bibliotecaId) {
        return res.status(400).json({ error: 'Parameter bibliotecaId is required' });
      }
      
      const db = await cds.connect.to('db');
      const { Copie, TitoliAutori } = db.entities('biblioteca.rete');
      
      // Query available copies in the specified library
      const copie = await SELECT.from(Copie)
        .where({ 
          stato: 'disponibile',
          biblioteca_ID: bibliotecaId 
        })
        .columns('ID', 'numeroInventario');
      
      // Enrich with title and author information
      const copieArricchite = [];
      for (const copia of copie) {
        const copiaCompleta = await SELECT.one.from(Copie, ['ID', 'numeroInventario', 'titolo_ID'])
          .where({ ID: copia.ID });
        
        if (copiaCompleta && copiaCompleta.titolo_ID) {
          // Get title information
          const titolo = await SELECT.one.from('biblioteca.rete.Titoli')
            .where({ ID: copiaCompleta.titolo_ID })
            .columns('ID', 'titolo');
          
          // Get authors for this title
          const titoliAutori = await SELECT.from(TitoliAutori)
            .where({ 'titolo_ID': copiaCompleta.titolo_ID });
          
          const autori = [];
          for (const ta of titoliAutori) {
            const autore = await SELECT.one.from('biblioteca.rete.Autori')
              .where({ ID: ta.autore_ID })
              .columns('cognome', 'nome');
            if (autore) {
              autori.push(autore.cognome);
            }
          }
          
          copieArricchite.push({
            ID: copiaCompleta.ID,
            numeroInventario: copiaCompleta.numeroInventario,
            titoloLibro: titolo?.titolo || 'N/A',
            autoreLibro: autori.join(', ') || 'N/A'
          });
        }
      }
      
      res.json(copieArricchite);
    } catch (error) {
      console.error('Error fetching copies:', error);
      res.status(500).json({ error: 'Errore nel caricamento delle copie' });
    }
  });
  
  // POST /rest/prestiti - Create new interlibrary loan
  app.post('/rest/prestiti', async (req, res) => {
    try {
      const { copiaID, bibliotecaOrigineID, bibliotecaDestinazioneID, richiedente } = req.body;
      
      // Validate input
      if (!copiaID || !bibliotecaOrigineID || !bibliotecaDestinazioneID) {
        return res.status(400).json({
          success: false,
          message: 'Dati mancanti: copiaID, bibliotecaOrigineID e bibliotecaDestinazioneID sono obbligatori'
        });
      }
      
      // Check if origin and destination are different
      if (bibliotecaOrigineID === bibliotecaDestinazioneID) {
        return res.status(400).json({
          success: false,
          message: 'La biblioteca di origine e destinazione devono essere diverse'
        });
      }
      
      const db = await cds.connect.to('db');
      const { Copie, PrestitiInterbiblioteca } = db.entities('biblioteca.rete');
      
      // Verify the copy exists and is available
      const copia = await SELECT.one.from(Copie)
        .where({ ID: copiaID })
        .columns('ID', 'stato', 'biblioteca_ID');
      
      if (!copia) {
        return res.status(404).json({
          success: false,
          message: 'Copia non trovata'
        });
      }
      
      if (copia.stato !== 'disponibile') {
        return res.status(400).json({
          success: false,
          message: 'La copia selezionata non è disponibile'
        });
      }
      
      // Verify the biblioteca matches
      if (copia.biblioteca_ID !== bibliotecaOrigineID) {
        return res.status(400).json({
          success: false,
          message: 'La copia non appartiene alla biblioteca di origine specificata'
        });
      }
      
      // Generate unique numeroPrestito
      const oggi = new Date();
      const anno = oggi.getFullYear();
      const numeroPrestito = `PIL-${anno}-${Date.now().toString().slice(-8)}`;
      
      // Create the interlibrary loan
      await INSERT.into(PrestitiInterbiblioteca).entries({
        numeroPrestito: numeroPrestito,
        dataRichiesta: oggi.toISOString().split('T')[0],
        stato: 'richiesto',
        copia_ID: copiaID,
        bibliotecaOrigine_ID: bibliotecaOrigineID,
        bibliotecaDestinazione_ID: bibliotecaDestinazioneID,
        richiedente: richiedente || 'Mobile App'
      });
      
      // Update copy status to 'prestato'
      await UPDATE(Copie)
        .set({ stato: 'prestato' })
        .where({ ID: copiaID });
      
      res.json({
        success: true,
        message: 'Prestito creato con successo',
        prestitoID: numeroPrestito
      });
      
    } catch (error) {
      console.error('Error creating loan:', error);
      res.status(500).json({
        success: false,
        message: `Errore durante la creazione del prestito: ${error.message}`
      });
    }
  });
  
  // GET /rest/prestiti-attivi - Get active loans for a specific library
  app.get('/rest/prestiti-attivi', async (req, res) => {
    try {
      const bibliotecaId = req.query.bibliotecaId;
      
      if (!bibliotecaId) {
        return res.status(400).json({ error: 'Parameter bibliotecaId is required' });
      }
      
      const db = await cds.connect.to('db');
      const { PrestitiInterbiblioteca, Copie, TitoliAutori } = db.entities('biblioteca.rete');
      
      // Query active loans where the library is the destination
      const prestiti = await SELECT.from(PrestitiInterbiblioteca)
        .where({ 
          bibliotecaDestinazione_ID: bibliotecaId,
          stato: { in: ['richiesto', 'approvato', 'in_transito', 'ricevuto'] }
        })
        .columns('ID', 'numeroPrestito', 'copia_ID', 'bibliotecaOrigine_ID', 'stato');
      
      // Enrich with copy and title information
      const prestitiArricchiti = [];
      for (const prestito of prestiti) {
        const copia = await SELECT.one.from(Copie, ['ID', 'numeroInventario', 'titolo_ID', 'biblioteca_ID'])
          .where({ ID: prestito.copia_ID });
        
        if (copia && copia.titolo_ID) {
          // Get title information
          const titolo = await SELECT.one.from('biblioteca.rete.Titoli')
            .where({ ID: copia.titolo_ID })
            .columns('ID', 'titolo');
          
          // Get authors for this title
          const titoliAutori = await SELECT.from(TitoliAutori)
            .where({ 'titolo_ID': copia.titolo_ID });
          
          const autori = [];
          for (const ta of titoliAutori) {
            const autore = await SELECT.one.from('biblioteca.rete.Autori')
              .where({ ID: ta.autore_ID })
              .columns('cognome', 'nome');
            if (autore) {
              autori.push(autore.cognome);
            }
          }
          
          // Get origin library name
          const bibliotecaOrigine = await SELECT.one.from('biblioteca.rete.Biblioteche')
            .where({ ID: prestito.bibliotecaOrigine_ID })
            .columns('nome', 'citta');
          
          prestitiArricchiti.push({
            ID: prestito.ID,
            numeroPrestito: prestito.numeroPrestito,
            copiaID: copia.ID,
            numeroInventario: copia.numeroInventario,
            titoloLibro: titolo?.titolo || 'N/A',
            autoreLibro: autori.join(', ') || 'N/A',
            bibliotecaOrigine: bibliotecaOrigine ? `${bibliotecaOrigine.nome} - ${bibliotecaOrigine.citta}` : 'N/A',
            stato: prestito.stato
          });
        }
      }
      
      res.json(prestitiArricchiti);
    } catch (error) {
      console.error('Error fetching active loans:', error);
      res.status(500).json({ error: 'Errore nel caricamento dei prestiti attivi' });
    }
  });
  
  // POST /rest/restituisci - Return a loaned copy
  app.post('/rest/restituisci', async (req, res) => {
    try {
      const { prestitoID } = req.body;
      
      // Validate input
      if (!prestitoID) {
        return res.status(400).json({
          success: false,
          message: 'Dati mancanti: prestitoID è obbligatorio'
        });
      }
      
      const db = await cds.connect.to('db');
      const { PrestitiInterbiblioteca, Copie } = db.entities('biblioteca.rete');
      
      // Verify the loan exists and is active
      const prestito = await SELECT.one.from(PrestitiInterbiblioteca)
        .where({ ID: prestitoID })
        .columns('ID', 'stato', 'copia_ID', 'numeroPrestito');
      
      if (!prestito) {
        return res.status(404).json({
          success: false,
          message: 'Prestito non trovato'
        });
      }
      
      if (prestito.stato === 'restituito') {
        return res.status(400).json({
          success: false,
          message: 'Il prestito è già stato restituito'
        });
      }
      
      const oggi = new Date();
      
      // Update loan status to 'restituito'
      await UPDATE(PrestitiInterbiblioteca)
        .set({ 
          stato: 'restituito',
          dataRestituzioneEffettiva: oggi.toISOString().split('T')[0]
        })
        .where({ ID: prestitoID });
      
      // Update copy status back to 'disponibile'
      await UPDATE(Copie)
        .set({ stato: 'disponibile' })
        .where({ ID: prestito.copia_ID });
      
      res.json({
        success: true,
        message: 'Prestito restituito con successo',
        numeroPrestito: prestito.numeroPrestito
      });
      
    } catch (error) {
      console.error('Error returning loan:', error);
      res.status(500).json({
        success: false,
        message: `Errore durante la restituzione del prestito: ${error.message}`
      });
    }
  });
});

module.exports = cds.server;
