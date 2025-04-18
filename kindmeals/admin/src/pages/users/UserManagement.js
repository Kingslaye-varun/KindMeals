import React, { useState } from 'react';
import {
  Container,
  Box,
  Typography,
  Tabs,
  Tab,
  Paper
} from '@mui/material';
import DonorsList from '../donors/DonorsList';
import RecipientsList from '../recipients/RecipientsList';
import VolunteersList from '../volunteers/VolunteersList';

// Tab panel component to handle showing content based on selected tab
function TabPanel(props) {
  const { children, value, index, ...other } = props;

  return (
    <div
      role="tabpanel"
      hidden={value !== index}
      id={`user-tabpanel-${index}`}
      aria-labelledby={`user-tab-${index}`}
      {...other}
    >
      {value === index && (
        <Box sx={{ pt: 3 }}>
          {children}
        </Box>
      )}
    </div>
  );
}

function a11yProps(index) {
  return {
    id: `user-tab-${index}`,
    'aria-controls': `user-tabpanel-${index}`,
  };
}

const UserManagement = () => {
  const [tabValue, setTabValue] = useState(0);

  const handleTabChange = (event, newValue) => {
    setTabValue(newValue);
  };

  return (
    <Container maxWidth="xl">
      <Box sx={{ mb: 4 }}>
        <Typography variant="h4" fontWeight="bold" gutterBottom>
          User Management
        </Typography>
        <Typography variant="body1" color="text.secondary">
          Manage all platform users including donors, recipients, and volunteers.
        </Typography>
      </Box>

      <Paper sx={{ mb: 3 }}>
        <Tabs 
          value={tabValue} 
          onChange={handleTabChange} 
          variant="fullWidth"
          textColor="primary"
          indicatorColor="primary"
          aria-label="user management tabs"
        >
          <Tab label="Donors" {...a11yProps(0)} />
          <Tab label="Recipients" {...a11yProps(1)} />
          <Tab label="Volunteers" {...a11yProps(2)} />
        </Tabs>
      </Paper>

      <TabPanel value={tabValue} index={0}>
        <DonorsList />
      </TabPanel>
      <TabPanel value={tabValue} index={1}>
        <RecipientsList />
      </TabPanel>
      <TabPanel value={tabValue} index={2}>
        <VolunteersList />
      </TabPanel>
    </Container>
  );
};

export default UserManagement; 