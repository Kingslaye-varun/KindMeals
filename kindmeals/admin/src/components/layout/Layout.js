import React, { useState } from 'react';
import { Box, Toolbar, CssBaseline } from '@mui/material';
import Header from './Header';
import Sidebar from './Sidebar';

const drawerWidth = 240;

const Layout = ({ children }) => {
  const [mobileOpen, setMobileOpen] = useState(false);

  const handleDrawerToggle = () => {
    setMobileOpen(!mobileOpen);
  };

  return (
    <Box sx={{ display: 'flex' }}>
      <CssBaseline />
      <Header 
        drawerWidth={drawerWidth} 
        handleDrawerToggle={handleDrawerToggle} 
      />
      <Sidebar
        drawerWidth={drawerWidth}
        mobileOpen={mobileOpen}
        handleDrawerToggle={handleDrawerToggle}
      />
      <Box
        component="main"
        sx={{
          flexGrow: 1,
          p: 3,
          width: { md: `calc(100% - ${drawerWidth}px)` },
          bgcolor: '#f5f5f5',
          minHeight: '100vh'
        }}
      >
        <Toolbar /> {/* This empty Toolbar creates space below AppBar */}
        {children}
      </Box>
    </Box>
  );
};

export default Layout; 