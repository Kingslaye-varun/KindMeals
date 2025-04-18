import React, { useState } from 'react';
import { 
  AppBar,
  Box,
  Toolbar,
  IconButton,
  Typography,
  Badge,
  Avatar,
  Menu,
  MenuItem,
  Tooltip,
  Divider
} from '@mui/material';
import {
  Menu as MenuIcon,
  Notifications as NotificationsIcon,
  AccountCircle,
  Settings as SettingsIcon,
  ExitToApp as LogoutIcon
} from '@mui/icons-material';

const Header = ({ drawerWidth, handleDrawerToggle }) => {
  const [anchorEl, setAnchorEl] = useState(null);
  const [notificationsAnchorEl, setNotificationsAnchorEl] = useState(null);
  
  const handleProfileMenuOpen = (event) => {
    setAnchorEl(event.currentTarget);
  };

  const handleNotificationsMenuOpen = (event) => {
    setNotificationsAnchorEl(event.currentTarget);
  };

  const handleMenuClose = () => {
    setAnchorEl(null);
  };

  const handleNotificationsMenuClose = () => {
    setNotificationsAnchorEl(null);
  };

  const isProfileMenuOpen = Boolean(anchorEl);
  const isNotificationsMenuOpen = Boolean(notificationsAnchorEl);

  const notifications = [
    { id: 1, message: 'New donor registration', time: '2 minutes ago' },
    { id: 2, message: 'New donation posted', time: '10 minutes ago' },
    { id: 3, message: 'Donation accepted by recipient', time: '30 minutes ago' }
  ];

  return (
    <>
      <AppBar
        position="fixed"
        sx={{
          width: { md: `calc(100% - ${drawerWidth}px)` },
          ml: { md: `${drawerWidth}px` },
          bgcolor: 'white',
          color: 'text.primary',
          boxShadow: 1
        }}
      >
        <Toolbar>
          <IconButton
            color="inherit"
            aria-label="open drawer"
            edge="start"
            onClick={handleDrawerToggle}
            sx={{ mr: 2, display: { md: 'none' } }}
          >
            <MenuIcon />
          </IconButton>
          <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
            KindMeals Admin Panel
          </Typography>
          <Box sx={{ display: 'flex' }}>
            <IconButton 
              size="large" 
              color="inherit"
              onClick={handleNotificationsMenuOpen}
            >
              <Badge badgeContent={notifications.length} color="error">
                <NotificationsIcon />
              </Badge>
            </IconButton>
            <Tooltip title="Account settings">
              <IconButton
                size="large"
                edge="end"
                aria-label="account of current user"
                aria-haspopup="true"
                onClick={handleProfileMenuOpen}
                color="inherit"
              >
                <Avatar sx={{ width: 32, height: 32, bgcolor: 'primary.main' }}>A</Avatar>
              </IconButton>
            </Tooltip>
          </Box>
        </Toolbar>
      </AppBar>
      
      {/* Profile menu */}
      <Menu
        anchorEl={anchorEl}
        anchorOrigin={{
          vertical: 'bottom',
          horizontal: 'right',
        }}
        keepMounted
        transformOrigin={{
          vertical: 'top',
          horizontal: 'right',
        }}
        open={isProfileMenuOpen}
        onClose={handleMenuClose}
      >
        <Box sx={{ px: 2, py: 1 }}>
          <Typography variant="subtitle1" fontWeight="bold">Admin User</Typography>
          <Typography variant="body2" color="text.secondary">admin@kindmeals.com</Typography>
        </Box>
        <Divider />
        <MenuItem onClick={handleMenuClose}>
          <IconButton size="small" sx={{ mr: 1 }}>
            <AccountCircle fontSize="small" />
          </IconButton>
          Profile
        </MenuItem>
        <MenuItem onClick={handleMenuClose}>
          <IconButton size="small" sx={{ mr: 1 }}>
            <SettingsIcon fontSize="small" />
          </IconButton>
          Settings
        </MenuItem>
        <Divider />
        <MenuItem onClick={handleMenuClose}>
          <IconButton size="small" sx={{ mr: 1 }}>
            <LogoutIcon fontSize="small" />
          </IconButton>
          Logout
        </MenuItem>
      </Menu>

      {/* Notifications menu */}
      <Menu
        anchorEl={notificationsAnchorEl}
        anchorOrigin={{
          vertical: 'bottom',
          horizontal: 'right',
        }}
        keepMounted
        transformOrigin={{
          vertical: 'top',
          horizontal: 'right',
        }}
        open={isNotificationsMenuOpen}
        onClose={handleNotificationsMenuClose}
      >
        <Typography sx={{ p: 2 }} variant="subtitle1" fontWeight="bold">
          Notifications
        </Typography>
        <Divider />
        {notifications.map((notification) => (
          <MenuItem key={notification.id} onClick={handleNotificationsMenuClose}>
            <Box sx={{ display: 'flex', flexDirection: 'column', width: '250px', py: 1 }}>
              <Typography variant="body1">{notification.message}</Typography>
              <Typography variant="caption" color="text.secondary">
                {notification.time}
              </Typography>
            </Box>
          </MenuItem>
        ))}
        <Divider />
        <MenuItem onClick={handleNotificationsMenuClose} sx={{ justifyContent: 'center' }}>
          <Typography variant="body2" color="primary">
            View All Notifications
          </Typography>
        </MenuItem>
      </Menu>
    </>
  );
};

export default Header; 