import React from 'react';
import { Card, CardContent, CardHeader, Box } from '@mui/material';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
} from 'chart.js';
import { Line } from 'react-chartjs-2';

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend
);

const DonationChart = ({ title }) => {
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
        label: 'Donations Posted',
        data: [45, 52, 38, 60, 56, 70, 65, 75, 62, 81, 95, 80],
        borderColor: '#4caf50',
        backgroundColor: 'rgba(76, 175, 80, 0.5)',
        tension: 0.3
      },
      {
        label: 'Donations Accepted',
        data: [30, 40, 25, 45, 42, 55, 52, 63, 42, 60, 75, 62],
        borderColor: '#2196f3',
        backgroundColor: 'rgba(33, 150, 243, 0.5)',
        tension: 0.3
      }
    ],
  };

  return (
    <Card sx={{ 
      boxShadow: '0 4px 12px rgba(0, 0, 0, 0.05)',
      borderRadius: 2
    }}>
      <CardHeader 
        title={title} 
        titleTypographyProps={{ variant: 'h6' }}
      />
      <CardContent>
        <Box sx={{ height: 300 }}>
          <Line options={options} data={data} />
        </Box>
      </CardContent>
    </Card>
  );
};

export default DonationChart; 