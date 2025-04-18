import React from 'react';
import { Grid, Box, Typography, Container } from '@mui/material';
import {
  People as PeopleIcon,
  Business as BusinessIcon,
  Restaurant as RestaurantIcon,
  CheckCircle as CheckCircleIcon
} from '@mui/icons-material';

import StatCard from '../components/dashboard/StatCard';
import RecentActivity from '../components/dashboard/RecentActivity';

const Dashboard = () => {
  const stats = [
    {
      title: 'Total Donors',
      value: '124',
      icon: <BusinessIcon fontSize="large" />,
      color: 'primary'
    },
    {
      title: 'Total Recipients',
      value: '89',
      icon: <PeopleIcon fontSize="large" />,
      color: 'success'
    },
    {
      title: 'Active Donations',
      value: '32',
      icon: <RestaurantIcon fontSize="large" />,
      color: 'info'
    },
    {
      title: 'Completed Donations',
      value: '276',
      icon: <CheckCircleIcon fontSize="large" />,
      color: 'warning'
    }
  ];

  return (
    <Container maxWidth="xl">
      <Box sx={{ mb: 4 }}>
        <Typography variant="h4" fontWeight="bold" gutterBottom>
          Dashboard
        </Typography>
        <Typography variant="body1" color="text.secondary">
          Welcome to the KindMeals admin panel. Here's an overview of all activities.
        </Typography>
      </Box>

      <Grid container spacing={3}>
        {/* Stats Cards */}
        {stats.map((stat) => (
          <Grid item xs={12} sm={6} md={3} key={stat.title}>
            <StatCard 
              title={stat.title} 
              value={stat.value} 
              icon={stat.icon} 
              color={stat.color} 
            />
          </Grid>
        ))}

        {/* Recent Activity - Full Width */}
        <Grid item xs={12}>
          <RecentActivity />
        </Grid>
      </Grid>
    </Container>
  );
};

export default Dashboard; 