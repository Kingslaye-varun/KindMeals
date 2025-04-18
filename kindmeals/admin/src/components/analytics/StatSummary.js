import React from 'react';
import { Card, CardContent, Box, Typography, Grid, Divider, LinearProgress } from '@mui/material';
import { TrendingUp, TrendingDown, TrendingFlat } from '@mui/icons-material';

const StatSummary = ({ title, stats }) => {
  const getTrendIcon = (trend) => {
    if (trend > 0) return <TrendingUp fontSize="small" color="success" />;
    if (trend < 0) return <TrendingDown fontSize="small" color="error" />;
    return <TrendingFlat fontSize="small" color="action" />;
  };

  const getTrendColor = (trend) => {
    if (trend > 0) return 'success.main';
    if (trend < 0) return 'error.main';
    return 'text.secondary';
  };

  return (
    <Card
      sx={{
        boxShadow: '0 4px 12px rgba(0, 0, 0, 0.05)',
        borderRadius: 2,
        height: '100%'
      }}
    >
      <CardContent>
        <Typography variant="h6" gutterBottom>
          {title}
        </Typography>
        <Divider sx={{ mb: 2 }} />
        
        <Grid container spacing={2}>
          {stats.map((stat, index) => (
            <Grid item xs={12} key={index}>
              <Box sx={{ mb: 1 }}>
                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 0.5 }}>
                  <Typography variant="body2" color="text.secondary">
                    {stat.label}
                  </Typography>
                  <Box sx={{ display: 'flex', alignItems: 'center' }}>
                    <Typography 
                      variant="body2" 
                      sx={{ 
                        mr: 0.5, 
                        color: getTrendColor(stat.trend) 
                      }}
                    >
                      {stat.trend > 0 ? '+' : ''}{stat.trend}%
                    </Typography>
                    {getTrendIcon(stat.trend)}
                  </Box>
                </Box>
                <Box sx={{ display: 'flex', alignItems: 'center' }}>
                  <Typography variant="h6" sx={{ mr: 2, minWidth: '80px' }}>
                    {stat.value}
                  </Typography>
                  <Box sx={{ flexGrow: 1 }}>
                    <LinearProgress 
                      variant="determinate" 
                      value={stat.percentage} 
                      color={
                        stat.trend > 0 ? 'success' : 
                        stat.trend < 0 ? 'error' : 
                        'primary'
                      }
                      sx={{ height: 6, borderRadius: 3 }}
                    />
                  </Box>
                </Box>
              </Box>
            </Grid>
          ))}
        </Grid>
      </CardContent>
    </Card>
  );
};

export default StatSummary; 