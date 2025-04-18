import React from 'react';
import { 
  Box, 
  Drawer, 
  List, 
  ListItem, 
  ListItemButton, 
  ListItemIcon, 
  ListItemText,
  Typography,
  Divider,
  useTheme
} from '@mui/material';
import { 
  Dashboard as DashboardIcon,
  People as PeopleIcon,
  Inventory as InventoryIcon,
  BarChart as BarChartIcon,
  Notifications as NotificationsIcon,
  Settings as SettingsIcon
} from '@mui/icons-material';
import { Link, useLocation } from 'react-router-dom';

const Sidebar = ({ drawerWidth, mobileOpen, handleDrawerToggle }) => {
  const theme = useTheme();
  const location = useLocation();
  
  const menuItems = [
    { 
      text: 'Dashboard', 
      icon: <DashboardIcon />, 
      path: '/' 
    },
    { 
      text: 'User Management', 
      icon: <PeopleIcon />, 
      path: '/users'
    },
    { 
      text: 'Donation Management', 
      icon: <InventoryIcon />, 
      path: '/donations' 
    },
    { 
      text: 'Analytics', 
      icon: <BarChartIcon />, 
      path: '/analytics' 
    },
    { 
      text: 'Settings', 
      icon: <SettingsIcon />, 
      path: '/settings' 
    }
  ];

  const drawer = (
    <div>
      <Box 
        sx={{ 
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          p: 2,
          bgcolor: theme.palette.primary.main,
          color: 'white'
        }}
      >
        <Typography variant="h5" fontWeight="bold">
          KindMeals Admin
        </Typography>
      </Box>
      <Divider />
      <List>
        {menuItems.map((item) => (
          <ListItem 
            key={item.text}
            disablePadding
            sx={{
              bgcolor: location.pathname === item.path ? theme.palette.action.selected : ''
            }}
          >
            <ListItemButton 
              component={Link} 
              to={item.path}
              selected={location.pathname === item.path}
            >
              <ListItemIcon sx={{ 
                color: location.pathname === item.path ? theme.palette.primary.main : ''
              }}>
                {item.icon}
              </ListItemIcon>
              <ListItemText 
                primary={item.text} 
                primaryTypographyProps={{ 
                  fontWeight: location.pathname === item.path ? 'bold' : 'normal'
                }}
              />
            </ListItemButton>
          </ListItem>
        ))}
      </List>
    </div>
  );

  return (
    <Box
      component="nav"
      sx={{ width: { md: drawerWidth }, flexShrink: { md: 0 } }}
    >
      {/* Mobile drawer */}
      <Drawer
        variant="temporary"
        open={mobileOpen}
        onClose={handleDrawerToggle}
        ModalProps={{
          keepMounted: true, // Better open performance on mobile
        }}
        sx={{
          display: { xs: 'block', md: 'none' },
          '& .MuiDrawer-paper': { boxSizing: 'border-box', width: drawerWidth },
        }}
      >
        {drawer}
      </Drawer>
      
      {/* Desktop drawer */}
      <Drawer
        variant="permanent"
        sx={{
          display: { xs: 'none', md: 'block' },
          '& .MuiDrawer-paper': { boxSizing: 'border-box', width: drawerWidth },
        }}
        open
      >
        {drawer}
      </Drawer>
    </Box>
  );
};

export default Sidebar; 