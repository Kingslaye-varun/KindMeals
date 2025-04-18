import React from 'react';
import { Card, CardContent, CardHeader, Box } from '@mui/material';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  BarElement,
  Title,
  Tooltip,
  Legend,
} from 'chart.js';
import { Bar } from 'react-chartjs-2';

ChartJS.register(
  CategoryScale,
  LinearScale,
  BarElement,
  Title,
  Tooltip,
  Legend
);

const UserGrowthChart = ({ title }) => {
  const options = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        position: 'top',
      },
      title: {
        display: false,
      },
    },
    scales: {
      y: {
        beginAtZero: true,
        ticks: {
          precision: 0
        }
      }
    }
  };

  const labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  const data = {
    labels,
    datasets: [
      {
        label: 'Donors',
        data: [5, 8, 10, 12, 15, 18, 20, 22, 25, 28, 32, 35],
        backgroundColor: 'rgba(76, 175, 80, 0.7)',
      },
      {
        label: 'Recipients',
        data: [3, 5, 7, 8, 10, 12, 15, 17, 19, 22, 25, 28],
        backgroundColor: 'rgba(33, 150, 243, 0.7)',
      },
      {
        label: 'Volunteers',
        data: [2, 3, 4, 6, 8, 10, 12, 13, 15, 17, 19, 22],
        backgroundColor: 'rgba(255, 152, 0, 0.7)',
      }
    ],
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
        <Box sx={{ height: 350, position: 'relative' }}>
          <Bar options={options} data={data} />
        </Box>
      </CardContent>
    </Card>
  );
};

export default UserGrowthChart; 