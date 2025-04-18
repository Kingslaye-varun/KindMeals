import React from 'react';
import { Container, Grid, Box, Typography } from '@mui/material';
import DonationChart from '../components/dashboard/DonationChart';
import DonationTypeChart from '../components/analytics/DonationTypeChart';
import UserGrowthChart from '../components/analytics/UserGrowthChart';
import DonationSuccessRateChart from '../components/analytics/DonationSuccessRateChart';
import StatSummary from '../components/analytics/StatSummary';

const Analytics = () => {
  const monthlySummaryStats = [
    {
      label: 'Total Donations',
      value: '243',
      percentage: 80,
      trend: 15
    },
    {
      label: 'Donations Accepted',
      value: '182',
      percentage: 75,
      trend: 12
    },
    {
      label: 'Food Quantity (kg)',
      value: '725',
      percentage: 65,
      trend: 8
    },
    {
      label: 'People Fed',
      value: '1,450',
      percentage: 60,
      trend: 5
    }
  ];

  const userStats = [
    {
      label: 'New Donors',
      value: '35',
      percentage: 70,
      trend: 25
    },
    {
      label: 'New Recipients',
      value: '28',
      percentage: 60,
      trend: 18
    },
    {
      label: 'New Volunteers',
      value: '22',
      percentage: 50,
      trend: 15
    },
    {
      label: 'Donor Retention',
      value: '92%',
      percentage: 92,
      trend: -3
    }
  ];

  return (
    <Container maxWidth="xl">
      <Box sx={{ mb: 4 }}>
        <Typography variant="h4" fontWeight="bold" gutterBottom>
          Analytics
        </Typography>
        <Typography variant="body1" color="text.secondary">
          Detailed analytics and statistics about donations, users, and platform performance.
        </Typography>
      </Box>

      <Grid container spacing={3}>
        {/* Charts Row 1 */}
        <Grid item xs={12} md={8}>
          <DonationChart title="Donation Trends (Last 12 Months)" />
        </Grid>
        <Grid item xs={12} md={4}>
          <DonationSuccessRateChart title="Donation Success Rate" />
        </Grid>

        {/* Charts Row 2 */}
        <Grid item xs={12} md={4}>
          <DonationTypeChart title="Donation Type Distribution" />
        </Grid>
        <Grid item xs={12} md={8}>
          <UserGrowthChart title="User Growth (Last 12 Months)" />
        </Grid>

        {/* Stats Row */}
        <Grid item xs={12} md={6}>
          <StatSummary title="Monthly Statistics (vs Last Month)" stats={monthlySummaryStats} />
        </Grid>
        <Grid item xs={12} md={6}>
          <StatSummary title="User Statistics (vs Last Month)" stats={userStats} />
        </Grid>
      </Grid>
    </Container>
  );
};

export default Analytics; 