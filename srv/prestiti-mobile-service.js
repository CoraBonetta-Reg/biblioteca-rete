const cds = require('@sap/cds');

module.exports = cds.service.impl(async function() {
  const { Biblioteche, Copie, PrestitiInterbiblioteca, TitoliAutori } = cds.entities('biblioteca.rete');
  
  // GET /rest/prestiti-mobile/getBiblioteche
  this.on('getBiblioteche', async (req) => {
    const biblioteche = await SELECT.from(Biblioteche)
      .columns('ID', 'nome', 'citta')
      .orderBy('nome');
    return biblioteche;
  });
  
  // GET /rest/prestiti-mobile/getCopieDisponibili
  this.on('getCopieDisponibili', async (req) => {
    const { bibliotecaId } = req.data;
    
    if (!bibliotecaId) {
      req.error(400, 'Parameter bibliotecaId is required');
      return;
    }
    
    // Query available copies in the specified library
    const copie = await SELECT.from(Copie)
      .where({ 
        stato: 'disponibile',
        biblioteca_ID: bibliotecaId 
      })
      .columns('ID', 'numeroInventario', 'titolo_ID');
    
    // Enrich with title and author information
    const copieArricchite = [];
    for (const copia of copie) {
      if (copia.titolo_ID) {
        // Get title information
        const titolo = await SELECT.one.from('biblioteca.rete.Titoli')
          .where({ ID: copia.titolo_ID })
          .columns('ID', 'titolo');
        
        // Get authors for this title
        const titoliAutori = await SELECT.from(TitoliAutori)
          .where({ titolo_ID: copia.titolo_ID });
        
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
          ID: copia.ID,
          numeroInventario: copia.numeroInventario,
          titoloLibro: titolo?.titolo || 'N/A',
          autoreLibro: autori.join(', ') || 'N/A'
        });
      }
    }
    
    return copieArricchite;
  });
  
  // GET /rest/prestiti-mobile/getPrestitiAttivi
  this.on('getPrestitiAttivi', async (req) => {
    const { bibliotecaId } = req.data;
    
    if (!bibliotecaId) {
      req.error(400, 'Parameter bibliotecaId is required');
      return;
    }
    
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
          .where({ titolo_ID: copia.titolo_ID });
        
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
    
    return prestitiArricchiti;
  });
  
  // POST /rest/prestiti-mobile/creaPrestito
  this.on('creaPrestito', async (req) => {
    const { copiaID, bibliotecaOrigineID, bibliotecaDestinazioneID, richiedente } = req.data;
    
    // Validate input
    if (!copiaID || !bibliotecaOrigineID || !bibliotecaDestinazioneID) {
      return {
        success: false,
        message: 'Dati mancanti: copiaID, bibliotecaOrigineID e bibliotecaDestinazioneID sono obbligatori',
        prestitoID: null
      };
    }
    
    // Check if origin and destination are different
    if (bibliotecaOrigineID === bibliotecaDestinazioneID) {
      return {
        success: false,
        message: 'La biblioteca di origine e destinazione devono essere diverse',
        prestitoID: null
      };
    }
    
    // Verify the copy exists and is available
    const copia = await SELECT.one.from(Copie)
      .where({ ID: copiaID })
      .columns('ID', 'stato', 'biblioteca_ID');
    
    if (!copia) {
      return {
        success: false,
        message: 'Copia non trovata',
        prestitoID: null
      };
    }
    
    if (copia.stato !== 'disponibile') {
      return {
        success: false,
        message: 'La copia selezionata non è disponibile',
        prestitoID: null
      };
    }
    
    // Verify the biblioteca matches
    if (copia.biblioteca_ID !== bibliotecaOrigineID) {
      return {
        success: false,
        message: 'La copia non appartiene alla biblioteca di origine specificata',
        prestitoID: null
      };
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
    
    return {
      success: true,
      message: 'Prestito creato con successo',
      prestitoID: numeroPrestito
    };
  });
  
  // POST /rest/prestiti-mobile/restituisci
  this.on('restituisci', async (req) => {
    const { prestitoID } = req.data;
    
    // Validate input
    if (!prestitoID) {
      return {
        success: false,
        message: 'Dati mancanti: prestitoID è obbligatorio',
        numeroPrestito: null
      };
    }
    
    // Verify the loan exists and is active
    const prestito = await SELECT.one.from(PrestitiInterbiblioteca)
      .where({ ID: prestitoID })
      .columns('ID', 'stato', 'copia_ID', 'numeroPrestito');
    
    if (!prestito) {
      return {
        success: false,
        message: 'Prestito non trovato',
        numeroPrestito: null
      };
    }
    
    if (prestito.stato === 'restituito') {
      return {
        success: false,
        message: 'Il prestito è già stato restituito',
        numeroPrestito: prestito.numeroPrestito
      };
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
    
    return {
      success: true,
      message: 'Prestito restituito con successo',
      numeroPrestito: prestito.numeroPrestito
    };
  });
});
