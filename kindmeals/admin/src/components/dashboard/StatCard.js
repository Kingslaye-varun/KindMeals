import React from 'react';
import { Box, Card, CardContent, Typography, useTheme } from '@mui/material';

const StatCard = ({ title, value, icon, color }) => {
  const theme = useTheme();
  
  return (
    <Card 
      sx={{ 
        boxShadow: '0 4px 12px rgba(0, 0, 0, 0.05)',
        height: '100%',
        borderRadius: 2
      }}
    >
      <CardContent>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <Box>
            <Typography 
              variant="subtitle2" 
              color="text.secondary"
              gutterBottom
              sx={{ textTransform: 'uppercase', fontWeight: 'medium', fontSize: '0.75rem' }}
            >
              {title}
            </Typography>
            <Typography variant="h4" component="div" fontWeight="bold">
              {value}
            </Typography>
          </Box>
          <Box 
            sx={{ 
              width: 60, 
              height: 60, 
              bgcolor: `${color}.100`, 
              color: `${color}.main`,
              borderRadius: '50%',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center'
            }}
          >
            {icon}
          </Box>
        </Box>
      </CardContent>
    </Card>
  );
};

export default StatCard; 