# Prestiti Interbibliotecari - Mobile App

App mobile Next.js per la registrazione dei prestiti interbibliotecari.

## Caratteristiche

- **Material Design**: UI moderna e responsive ottimizzata per dispositivi mobili
- **Workflow guidato**: Processo step-by-step per la creazione di prestiti
- **Integrazione REST**: Connessione diretta al backend CAP tramite API REST

## Funzionalità

1. **Selezione Biblioteca Origine**: Dropdown per scegliere la biblioteca da cui proviene la copia
2. **Visualizzazione Copie Disponibili**: Lista delle copie disponibili nella biblioteca selezionata con titolo, autore e numero inventario
3. **Selezione Copia**: Click sulla copia desiderata per selezionarla
4. **Selezione Biblioteca Destinazione**: Dropdown per scegliere la biblioteca di destinazione (esclusa automaticamente quella di origine)
5. **Conferma**: Bottone per creare il prestito interbibliotecario

## Avvio dell'applicazione

### Prerequisiti

- Node.js 18+
- Backend CAP in esecuzione su http://localhost:4004

### Sviluppo

```bash
# Dal root del progetto
npm run dev-mobile

# Oppure direttamente dalla cartella dell'app
cd app/prestiti-mobile
npm run dev
```

L'app sarà disponibile su http://localhost:3000

### Build per produzione

```bash
cd app/prestiti-mobile
npm run build
npm start
```

## Configurazione

L'URL del backend può essere configurato tramite la variabile d'ambiente:

```bash
NEXT_PUBLIC_API_URL=http://localhost:4004
```

## Tecnologie utilizzate

- **Next.js 16**: Framework React per applicazioni web
- **Material-UI (MUI)**: Libreria di componenti Material Design
- **TypeScript**: Tipizzazione statica
- **TailwindCSS**: Utility CSS framework

## API Endpoints utilizzati

- `GET /rest/biblioteche` - Lista delle biblioteche
- `GET /rest/copie-disponibili?bibliotecaId={id}` - Copie disponibili per biblioteca
- `POST /rest/prestiti` - Creazione nuovo prestito interbibliotecario
