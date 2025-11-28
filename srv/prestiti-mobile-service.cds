using {biblioteca.rete as db} from '../db/schema';

/**
 * REST Service for Mobile Interlibrary Loan Registration
 * 
 * This service provides REST endpoints for the mobile app.
 * Exposed at /rest/prestiti-mobile
 */
@protocol: 'rest'
@path: 'prestiti-mobile'
service PrestitiMobileService {
  
  // GET /rest/prestiti-mobile/biblioteche
  function getBiblioteche() returns array of {
    ID: UUID;
    nome: String;
    citta: String;
  };
  
  // GET /rest/prestiti-mobile/copieDisponibili?bibliotecaId={id}
  function getCopieDisponibili(bibliotecaId: UUID) returns array of {
    ID: UUID;
    numeroInventario: String;
    titoloLibro: String;
    autoreLibro: String;
  };
  
  // GET /rest/prestiti-mobile/prestitiAttivi?bibliotecaId={id}
  function getPrestitiAttivi(bibliotecaId: UUID) returns array of {
    ID: UUID;
    numeroPrestito: String;
    copiaID: UUID;
    numeroInventario: String;
    titoloLibro: String;
    autoreLibro: String;
    bibliotecaOrigine: String;
    stato: String;
  };
  
  // POST /rest/prestiti-mobile/creaPrestito
  action creaPrestito(
    copiaID: UUID,
    bibliotecaOrigineID: UUID,
    bibliotecaDestinazioneID: UUID,
    richiedente: String
  ) returns {
    success: Boolean;
    message: String;
    prestitoID: String;
  };
  
  // POST /rest/prestiti-mobile/restituisci
  action restituisci(prestitoID: UUID) returns {
    success: Boolean;
    message: String;
    numeroPrestito: String;
  };
}
