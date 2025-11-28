using {biblioteca.rete as db} from '../db/schema';

/**
 * Service for Mobile Interlibrary Loan Registration
 * 
 * This service provides simplified endpoints for the mobile app.
 * REST-style handlers are implemented in prestiti-mobile-service.js
 */
service PrestitiMobileService {
  // Entities used by the REST handlers
  entity Biblioteche as projection on db.Biblioteche {
    ID,
    nome,
    citta
  };
  
  entity Copie as projection on db.Copie;
  entity PrestitiInterbiblioteca as projection on db.PrestitiInterbiblioteca;
}
