import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';

// Layout
import Layout from './components/layout/Layout';

// Pages
import Dashboard from './pages/Dashboard';
import UserManagement from './pages/users/UserManagement';
import Analytics from './pages/Analytics';
import DonationManagement from './pages/donations/DonationManagement';
import Settings from './pages/Settings';

// Theme configuration
const theme = createTheme({
  palette: {
    primary: {
      main: '#4caf50', // Green color for KindMeals theme
      light: '#80e27e',
      dark: '#087f23',
    },
    secondary: {
      main: '#ff9800', // Orange as secondary color
      light: '#ffc947',
      dark: '#c66900',
    },
    background: {
      default: '#f5f5f5',
    },
  },
  typography: {
    fontFamily: [
      'Poppins',
      'Roboto',
      '"Helvetica Neue"',
      'Arial',
      'sans-serif'
    ].join(','),
  },
  shape: {
    borderRadius: 8,
  },
  components: {
    MuiButton: {
      styleOverrides: {
        root: {
          textTransform: 'none',
          fontWeight: 600,
        },
      },
    },
    MuiCard: {
      styleOverrides: {
        root: {
          boxShadow: '0 4px 12px rgba(0, 0, 0, 0.05)',
        },
      },
    },
  },
});

function App() {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Router>
        <Layout>
          <Routes>
            <Route path="/" element={<Dashboard />} />
            <Route path="/users" element={<UserManagement />} />
            <Route path="/analytics" element={<Analytics />} />
            <Route path="/donations" element={<DonationManagement />} />
            <Route path="/settings" element={<Settings />} />
          </Routes>
        </Layout>
      </Router>
    </ThemeProvider>
  );
}

export default App;
