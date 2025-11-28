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
  Chip,
} from '@mui/material';
import { KeyboardReturn, AssignmentReturn } from '@mui/icons-material';
import Link from 'next/link';

interface Biblioteca {
  ID: string;
  nome: string;
  citta: string;
}

interface PrestitoAttivo {
  ID: string;
  numeroPrestito: string;
  copiaID: string;
  numeroInventario: string;
  titoloLibro: string;
  autoreLibro: string;
  bibliotecaOrigine: string;
  stato: string;
}

export default function RestituzioniPage() {
  const [biblioteche, setBiblioteche] = useState<Biblioteca[]>([]);
  const [bibliotecaSelezionata, setBibliotecaSelezionata] = useState<string>('');
  const [prestitiAttivi, setPrestitiAttivi] = useState<PrestitoAttivo[]>([]);
  const [prestitoSelezionato, setPrestitoSelezionato] = useState<string>('');
  const [loading, setLoading] = useState(false);
  const [loadingPrestiti, setLoadingPrestiti] = useState(false);
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

  // Load active loans when library changes
  useEffect(() => {
    if (bibliotecaSelezionata) {
      setLoadingPrestiti(true);
      setPrestitiAttivi([]);
      setPrestitoSelezionato('');
      fetch(`${API_BASE}/rest/prestiti-attivi?bibliotecaId=${bibliotecaSelezionata}`)
        .then((res) => res.json())
        .then((data) => {
          setPrestitiAttivi(data);
          setLoadingPrestiti(false);
        })
        .catch((err) => {
          setError('Errore nel caricamento dei prestiti attivi');
          setLoadingPrestiti(false);
        });
    } else {
      setPrestitiAttivi([]);
      setPrestitoSelezionato('');
    }
  }, [bibliotecaSelezionata, API_BASE]);

  const handleSubmit = async () => {
    setError(null);
    setSuccess(null);

    if (!prestitoSelezionato) {
      setError('Per favore, seleziona un prestito da restituire');
      return;
    }

    setLoading(true);

    try {
      const response = await fetch(`${API_BASE}/rest/restituisci`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          prestitoID: prestitoSelezionato,
        }),
      });

      const data = await response.json();

      if (data.success) {
        setSuccess(`Prestito restituito con successo! Numero: ${data.numeroPrestito}`);
        // Reset form and reload active loans
        setPrestitoSelezionato('');
        // Reload active loans
        if (bibliotecaSelezionata) {
          const res = await fetch(`${API_BASE}/rest/prestiti-attivi?bibliotecaId=${bibliotecaSelezionata}`);
          const updatedData = await res.json();
          setPrestitiAttivi(updatedData);
        }
      } else {
        setError(data.message || 'Errore durante la restituzione del prestito');
      }
    } catch (err) {
      setError('Errore di connessione al server');
    } finally {
      setLoading(false);
    }
  };

  const getStatoColor = (stato: string) => {
    switch (stato) {
      case 'richiesto': return 'warning';
      case 'approvato': return 'info';
      case 'in_transito': return 'primary';
      case 'ricevuto': return 'success';
      default: return 'default';
    }
  };

  const getStatoLabel = (stato: string) => {
    switch (stato) {
      case 'richiesto': return 'Richiesto';
      case 'approvato': return 'Approvato';
      case 'in_transito': return 'In Transito';
      case 'ricevuto': return 'Ricevuto';
      default: return stato;
    }
  };

  return (
    <>
      <AppBar position="static" elevation={0}>
        <Toolbar>
          <AssignmentReturn sx={{ mr: 2 }} />
          <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
            Restituzioni Prestiti
          </Typography>
          <Link href="/" passHref style={{ textDecoration: 'none' }}>
            <Button color="inherit" startIcon={<KeyboardReturn />}>
              Nuovo Prestito
            </Button>
          </Link>
        </Toolbar>
      </AppBar>

      <Container maxWidth="sm" sx={{ mt: 3, mb: 3 }}>
        <Card>
          <CardContent>
            <Typography variant="h5" component="h1" gutterBottom align="center" sx={{ mb: 3 }}>
              Restituisci Prestito
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

            {/* Step 1: Select library */}
            <Box sx={{ mb: 3 }}>
              <FormControl fullWidth>
                <InputLabel>Biblioteca</InputLabel>
                <Select
                  value={bibliotecaSelezionata}
                  label="Biblioteca"
                  onChange={(e: SelectChangeEvent) => setBibliotecaSelezionata(e.target.value)}
                >
                  {biblioteche.map((bib) => (
                    <MenuItem key={bib.ID} value={bib.ID}>
                      {bib.nome} - {bib.citta}
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>
            </Box>

            {/* Step 2: Select loan to return */}
            {bibliotecaSelezionata && (
              <Box sx={{ mb: 3 }}>
                <Typography variant="subtitle1" gutterBottom sx={{ fontWeight: 500 }}>
                  Seleziona Prestito da Restituire
                </Typography>
                {loadingPrestiti ? (
                  <Box sx={{ display: 'flex', justifyContent: 'center', py: 3 }}>
                    <CircularProgress />
                  </Box>
                ) : prestitiAttivi.length === 0 ? (
                  <Alert severity="info">
                    Nessun prestito attivo per questa biblioteca
                  </Alert>
                ) : (
                  <List sx={{ bgcolor: 'background.paper', borderRadius: 1, border: '1px solid #e0e0e0' }}>
                    {prestitiAttivi.map((prestito) => (
                      <ListItem key={prestito.ID} disablePadding>
                        <ListItemButton
                          selected={prestitoSelezionato === prestito.ID}
                          onClick={() => setPrestitoSelezionato(prestito.ID)}
                        >
                          <ListItemText
                            primary={
                              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                                <span>{prestito.titoloLibro}</span>
                                <Chip 
                                  label={getStatoLabel(prestito.stato)} 
                                  size="small" 
                                  color={getStatoColor(prestito.stato)}
                                />
                              </Box>
                            }
                            secondary={
                              <>
                                Autore: {prestito.autoreLibro} | Inv: {prestito.numeroInventario}
                                <br />
                                Provenienza: {prestito.bibliotecaOrigine}
                              </>
                            }
                          />
                        </ListItemButton>
                      </ListItem>
                    ))}
                  </List>
                )}
              </Box>
            )}

            {/* Submit button */}
            {prestitoSelezionato && (
              <Button
                variant="contained"
                color="primary"
                fullWidth
                size="large"
                startIcon={loading ? <CircularProgress size={20} color="inherit" /> : <KeyboardReturn />}
                onClick={handleSubmit}
                disabled={loading}
                sx={{ mt: 2 }}
              >
                {loading ? 'Restituzione in corso...' : 'Conferma Restituzione'}
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
