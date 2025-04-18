import React from 'react';
import { Card, CardContent, CardHeader, Box } from '@mui/material';
import { Chart as ChartJS, ArcElement, Tooltip, Legend } from 'chart.js';
import { Pie } from 'react-chartjs-2';

ChartJS.register(ArcElement, Tooltip, Legend);

const DonationTypeChart = ({ title }) => {
  const data = {
    labels: ['Prepared Meals', 'Raw Ingredients', 'Packed Food', 'Beverages', 'Desserts'],
    datasets: [
      {
        data: [35, 25, 20, 10, 10],
        backgroundColor: [
          'rgba(76, 175, 80, 0.7)',  // green
          'rgba(33, 150, 243, 0.7)', // blue
          'rgba(255, 152, 0, 0.7)',  // orange
          'rgba(156, 39, 176, 0.7)', // purple
          'rgba(233, 30, 99, 0.7)',  // pink
        ],
        borderColor: [
          'rgba(76, 175, 80, 1)',
          'rgba(33, 150, 243, 1)',
          'rgba(255, 152, 0, 1)',
          'rgba(156, 39, 176, 1)',
          'rgba(233, 30, 99, 1)',
        ],
        borderWidth: 1,
      },
    ],
  };

  const options = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        position: 'right',
        labels: {
          boxWidth: 15,
          padding: 15
        }
      },
      tooltip: {
        callbacks: {
          label: function(context) {
            const label = context.label || '';
            const value = context.formattedValue || '';
            return `${label}: ${value}%`;
          }
        }
      }
    },
  };

  return (
    <Card sx={{ 
      boxShadow: '0 4px 12px rgba(0, 0, 0, 0.05)',
      borderRadius: 2,
      height: '100%'
    }}>
      <CardHeader 
        title={title} 
        titleTypographyProps={{ variant: 'h6' }}
      />
      <CardContent>
        <Box sx={{ height: 300, position: 'relative' }}>
          <Pie data={data} options={options} />
        </Box>
      </CardContent>
    </Card>
  );
};

export default DonationTypeChart; 