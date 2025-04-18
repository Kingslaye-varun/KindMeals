import React, { useState } from 'react';
import {
  Container,
  Typography,
  Box,
  Card,
  CardHeader,
  CardContent,
  Grid,
  Switch,
  TextField,
  MenuItem,
  FormControl,
  FormControlLabel,
  Button,
  Divider,
  Alert,
  Snackbar
} from '@mui/material';
import {
  Notifications as NotificationsIcon,
  Storage as StorageIcon,
  Security as SecurityIcon,
  SettingsBackupRestore as BackupIcon
} from '@mui/icons-material';

const Settings = () => {
  const [settings, setSettings] = useState({
    // Notification Settings
    emailNotifications: true,
    newDonationAlerts: true,
    donationExpiryReminders: true,
    systemUpdates: false,
    
    // Data Retention Settings
    donationDataRetention: '6',
    userInactiveThreshold: '3',
    automaticDataCleanup: true,
    
    // Platform Configuration
    donationExpiryHours: '48',
    maximumDonationItems: '10',
    requireImageUpload: true,
    allowVolunteerSignup: true
  });

  const [showSuccess, setShowSuccess] = useState(false);

  const handleChange = (event) => {
    const { name, value, checked } = event.target;
    setSettings({
      ...settings,
      [name]: event.target.type === 'checkbox' ? checked : value
    });
  };

  const handleSave = () => {
    // In a real app, this would save to API/backend
    console.log('Saving settings:', settings);
    setShowSuccess(true);
  };

  const dataRetentionOptions = [
    { value: '3', label: '3 months' },
    { value: '6', label: '6 months' },
    { value: '12', label: '1 year' },
    { value: '24', label: '2 years' },
    { value: '36', label: '3 years' },
    { value: '-1', label: 'Never delete' }
  ];

  const inactiveThresholdOptions = [
    { value: '1', label: '1 month' },
    { value: '3', label: '3 months' },
    { value: '6', label: '6 months' },
    { value: '12', label: '1 year' }
  ];

  return (
    <Container maxWidth="xl">
      <Box sx={{ mb: 4 }}>
        <Typography variant="h4" fontWeight="bold" gutterBottom>
          Settings
        </Typography>
        <Typography variant="body1" color="text.secondary">
          Configure platform settings and preferences
        </Typography>
      </Box>

      <Grid container spacing={3}>
        {/* Notification Settings */}
        <Grid item xs={12} md={6}>
          <Card sx={{ height: '100%' }}>
            <CardHeader
              avatar={<NotificationsIcon color="primary" />}
              title="Notification Settings"
              titleTypographyProps={{ variant: 'h6' }}
            />
            <CardContent>
              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
                <FormControlLabel
                  control={
                    <Switch
                      checked={settings.emailNotifications}
                      onChange={handleChange}
                      name="emailNotifications"
                      color="primary"
                    />
                  }
                  label="Email Notifications"
                />
                <FormControlLabel
                  control={
                    <Switch
                      checked={settings.newDonationAlerts}
                      onChange={handleChange}
                      name="newDonationAlerts"
                      color="primary"
                    />
                  }
                  label="New Donation Alerts"
                />
                <FormControlLabel
                  control={
                    <Switch
                      checked={settings.donationExpiryReminders}
                      onChange={handleChange}
                      name="donationExpiryReminders"
                      color="primary"
                    />
                  }
                  label="Donation Expiry Reminders"
                />
                <FormControlLabel
                  control={
                    <Switch
                      checked={settings.systemUpdates}
                      onChange={handleChange}
                      name="systemUpdates"
                      color="primary"
                    />
                  }
                  label="System Updates & Maintenance"
                />
              </Box>
            </CardContent>
          </Card>
        </Grid>

        {/* Data Retention Settings */}
        <Grid item xs={12} md={6}>
          <Card sx={{ height: '100%' }}>
            <CardHeader
              avatar={<StorageIcon color="primary" />}
              title="Data Retention Settings"
              titleTypographyProps={{ variant: 'h6' }}
            />
            <CardContent>
              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
                <FormControl fullWidth>
                  <Typography variant="body2" gutterBottom>
                    Completed Donation Data Retention
                  </Typography>
                  <TextField
                    select
                    name="donationDataRetention"
                    value={settings.donationDataRetention}
                    onChange={handleChange}
                    size="small"
                  >
                    {dataRetentionOptions.map((option) => (
                      <MenuItem key={option.value} value={option.value}>
                        {option.label}
                      </MenuItem>
                    ))}
                  </TextField>
                </FormControl>

                <FormControl fullWidth>
                  <Typography variant="body2" gutterBottom>
                    User Inactivity Threshold
                  </Typography>
                  <TextField
                    select
                    name="userInactiveThreshold"
                    value={settings.userInactiveThreshold}
                    onChange={handleChange}
                    size="small"
                  >
                    {inactiveThresholdOptions.map((option) => (
                      <MenuItem key={option.value} value={option.value}>
                        {option.label}
                      </MenuItem>
                    ))}
                  </TextField>
                </FormControl>

                <FormControlLabel
                  control={
                    <Switch
                      checked={settings.automaticDataCleanup}
                      onChange={handleChange}
                      name="automaticDataCleanup"
                      color="primary"
                    />
                  }
                  label="Automatic Data Cleanup"
                />
                
                <Box sx={{ mt: 1 }}>
                  <Button 
                    variant="outlined" 
                    startIcon={<BackupIcon />}
                    size="small"
                  >
                    Backup Platform Data
                  </Button>
                </Box>
              </Box>
            </CardContent>
          </Card>
        </Grid>

        {/* Platform Configuration */}
        <Grid item xs={12}>
          <Card>
            <CardHeader
              avatar={<SecurityIcon color="primary" />}
              title="Donation Platform Configuration"
              titleTypographyProps={{ variant: 'h6' }}
            />
            <CardContent>
              <Grid container spacing={3}>
                <Grid item xs={12} sm={6} md={3}>
                  <FormControl fullWidth>
                    <Typography variant="body2" gutterBottom>
                      Donation Expiry Time (hours)
                    </Typography>
                    <TextField
                      name="donationExpiryHours"
                      type="number"
                      value={settings.donationExpiryHours}
                      onChange={handleChange}
                      size="small"
                      InputProps={{ inputProps: { min: 1, max: 168 } }}
                    />
                  </FormControl>
                </Grid>
                
                <Grid item xs={12} sm={6} md={3}>
                  <FormControl fullWidth>
                    <Typography variant="body2" gutterBottom>
                      Maximum Donation Items
                    </Typography>
                    <TextField
                      name="maximumDonationItems"
                      type="number"
                      value={settings.maximumDonationItems}
                      onChange={handleChange}
                      size="small"
                      InputProps={{ inputProps: { min: 1, max: 50 } }}
                    />
                  </FormControl>
                </Grid>
                
                <Grid item xs={12} sm={6} md={3}>
                  <FormControl fullWidth>
                    <FormControlLabel
                      control={
                        <Switch
                          checked={settings.requireImageUpload}
                          onChange={handleChange}
                          name="requireImageUpload"
                          color="primary"
                        />
                      }
                      label="Require Image Upload"
                    />
                  </FormControl>
                </Grid>
                
                <Grid item xs={12} sm={6} md={3}>
                  <FormControl fullWidth>
                    <FormControlLabel
                      control={
                        <Switch
                          checked={settings.allowVolunteerSignup}
                          onChange={handleChange}
                          name="allowVolunteerSignup"
                          color="primary"
                        />
                      }
                      label="Allow Volunteer Signup"
                    />
                  </FormControl>
                </Grid>
              </Grid>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      <Box sx={{ mt: 3, display: 'flex', justifyContent: 'flex-end' }}>
        <Button
          variant="contained"
          color="primary"
          onClick={handleSave}
          sx={{ px: 4 }}
        >
          Save Settings
        </Button>
      </Box>
      
      <Snackbar
        open={showSuccess}
        autoHideDuration={4000}
        onClose={() => setShowSuccess(false)}
        anchorOrigin={{ vertical: 'bottom', horizontal: 'right' }}
      >
        <Alert onClose={() => setShowSuccess(false)} severity="success">
          Settings saved successfully!
        </Alert>
      </Snackbar>
    </Container>
  );
};

export default Settings; 