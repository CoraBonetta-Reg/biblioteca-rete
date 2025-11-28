'use client';

import { useState, useEffect } from 'react';
import {
  Container,
  Card,
  CardContent,
  Typography,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Button,
  Box,
  Alert,
  CircularProgress,
  List,
  ListItem,
  ListItemButton,
  ListItemText,
  AppBar,
  Toolbar,
  SelectChangeEvent,
} from '@mui/material';
import { LocalLibrary, Send, AssignmentReturn } from '@mui/icons-material';
import Link from 'next/link';

interface Biblioteca {
  ID: string;
  nome: string;
  citta: string;
}

interface Copia {
  ID: string;
  numeroInventario: string;
  titoloLibro: string;
  autoreLibro: string;
}

export default function Home() {
  const [biblioteche, setBiblioteche] = useState<Biblioteca[]>([]);
  const [bibliotecaOrigine, setBibliotecaOrigine] = useState<string>('');
  const [copieDisponibili, setCopieDisponibili] = useState<Copia[]>([]);
  const [copiaSelezionata, setCopiaSelezionata] = useState<string>('');
  const [bibliotecaDestinazione, setBibliotecaDestinazione] = useState<string>('');
  const [loading, setLoading] = useState(false);
  const [loadingCopie, setLoadingCopie] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  const API_BASE = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4004';

  // Load libraries on mount
  useEffect(() => {
    fetch(`${API_BASE}/rest/biblioteche`)
      .then((res) => res.json())
      .then((data) => setBiblioteche(data))
      .catch((err) => setError('Errore nel caricamento delle biblioteche'));
  }, [API_BASE]);

  // Load available copies when source library changes
  useEffect(() => {
    if (bibliotecaOrigine) {
      setLoadingCopie(true);
      setCopieDisponibili([]);
      setCopiaSelezionata('');
      fetch(`${API_BASE}/rest/copie-disponibili?bibliotecaId=${bibliotecaOrigine}`)
        .then((res) => res.json())
        .then((data) => {
          setCopieDisponibili(data);
          setLoadingCopie(false);
        })
        .catch((err) => {
          setError('Errore nel caricamento delle copie');
          setLoadingCopie(false);
        });
    } else {
      setCopieDisponibili([]);
      setCopiaSelezionata('');
    }
  }, [bibliotecaOrigine, API_BASE]);

  const handleSubmit = async () => {
    setError(null);
    setSuccess(null);

    if (!bibliotecaOrigine || !copiaSelezionata || !bibliotecaDestinazione) {
      setError('Per favore, compila tutti i campi');
      return;
    }

    if (bibliotecaOrigine === bibliotecaDestinazione) {
      setError('La biblioteca di origine e destinazione devono essere diverse');
      return;
    }

    setLoading(true);

    try {
      const response = await fetch(`${API_BASE}/rest/prestiti`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          copiaID: copiaSelezionata,
          bibliotecaOrigineID: bibliotecaOrigine,
          bibliotecaDestinazioneID: bibliotecaDestinazione,
          richiedente: 'Mobile App',
        }),
      });

      const data = await response.json();

      if (data.success) {
        setSuccess(`Prestito creato con successo! Numero: ${data.prestitoID}`);
        // Reset form
        setBibliotecaOrigine('');
        setCopieDisponibili([]);
        setCopiaSelezionata('');
        setBibliotecaDestinazione('');
      } else {
        setError(data.message || 'Errore durante la creazione del prestito');
      }
    } catch (err) {
      setError('Errore di connessione al server');
    } finally {
      setLoading(false);
    }
  };

  return (
    <>
      <AppBar position="static" elevation={0}>
        <Toolbar>
          <LocalLibrary sx={{ mr: 2 }} />
          <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
            Prestiti Interbibliotecari
          </Typography>
          <Link href="/restituzioni" passHref style={{ textDecoration: 'none' }}>
            <Button color="inherit" startIcon={<AssignmentReturn />}>
              Restituzioni
            </Button>
          </Link>
        </Toolbar>
      </AppBar>

      <Container maxWidth="sm" sx={{ mt: 3, mb: 3 }}>
        <Card>
          <CardContent>
            <Typography variant="h5" component="h1" gutterBottom align="center" sx={{ mb: 3 }}>
              Registra Nuovo Prestito
            </Typography>

            {error && (
              <Alert severity="error" sx={{ mb: 2 }} onClose={() => setError(null)}>
                {error}
              </Alert>
            )}

            {success && (
              <Alert severity="success" sx={{ mb: 2 }} onClose={() => setSuccess(null)}>
                {success}
              </Alert>
            )}

            {/* Step 1: Select source library */}
            <Box sx={{ mb: 3 }}>
              <FormControl fullWidth>
                <InputLabel>Biblioteca di Origine</InputLabel>
                <Select
                  value={bibliotecaOrigine}
                  label="Biblioteca di Origine"
                  onChange={(e: SelectChangeEvent) => setBibliotecaOrigine(e.target.value)}
                >
                  {biblioteche.map((bib) => (
                    <MenuItem key={bib.ID} value={bib.ID}>
                      {bib.nome} - {bib.citta}
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>
            </Box>

            {/* Step 2: Select copy */}
            {bibliotecaOrigine && (
              <Box sx={{ mb: 3 }}>
                <Typography variant="subtitle1" gutterBottom sx={{ fontWeight: 500 }}>
                  Seleziona Copia
                </Typography>
                {loadingCopie ? (
                  <Box sx={{ display: 'flex', justifyContent: 'center', py: 3 }}>
                    <CircularProgress />
                  </Box>
                ) : copieDisponibili.length === 0 ? (
                  <Alert severity="info">
                    Nessuna copia disponibile in questa biblioteca
                  </Alert>
                ) : (
                  <List sx={{ bgcolor: 'background.paper', borderRadius: 1, border: '1px solid #e0e0e0' }}>
                    {copieDisponibili.map((copia) => (
                      <ListItem key={copia.ID} disablePadding>
                        <ListItemButton
                          selected={copiaSelezionata === copia.ID}
                          onClick={() => setCopiaSelezionata(copia.ID)}
                        >
                          <ListItemText
                            primary={copia.titoloLibro}
                            secondary={`Autore: ${copia.autoreLibro} | Inv: ${copia.numeroInventario}`}
                          />
                        </ListItemButton>
                      </ListItem>
                    ))}
                  </List>
                )}
              </Box>
            )}

            {/* Step 3: Select destination library */}
            {copiaSelezionata && (
              <Box sx={{ mb: 3 }}>
                <FormControl fullWidth>
                  <InputLabel>Biblioteca di Destinazione</InputLabel>
                  <Select
                    value={bibliotecaDestinazione}
                    label="Biblioteca di Destinazione"
                    onChange={(e: SelectChangeEvent) => setBibliotecaDestinazione(e.target.value)}
                  >
                    {biblioteche
                      .filter((bib) => bib.ID !== bibliotecaOrigine)
                      .map((bib) => (
                        <MenuItem key={bib.ID} value={bib.ID}>
                          {bib.nome} - {bib.citta}
                        </MenuItem>
                      ))}
                  </Select>
                </FormControl>
              </Box>
            )}

            {/* Submit button */}
            {bibliotecaOrigine && copiaSelezionata && bibliotecaDestinazione && (
              <Button
                variant="contained"
                color="primary"
                fullWidth
                size="large"
                startIcon={loading ? <CircularProgress size={20} color="inherit" /> : <Send />}
                onClick={handleSubmit}
                disabled={loading}
                sx={{ mt: 2 }}
              >
                {loading ? 'Invio in corso...' : 'Conferma Prestito'}
              </Button>
            )}
          </CardContent>
        </Card>

        <Typography variant="caption" display="block" align="center" sx={{ mt: 3, color: 'text.secondary' }}>
          Biblioteca Rete - Sistema di Gestione Prestiti Interbibliotecari
        </Typography>
      </Container>
    </>
  );
}
