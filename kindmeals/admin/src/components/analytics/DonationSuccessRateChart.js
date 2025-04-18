import React from 'react';
import { Card, CardContent, CardHeader, Box, Typography } from '@mui/material';
import { Chart as ChartJS, ArcElement, Tooltip, Legend } from 'chart.js';
import { Doughnut } from 'react-chartjs-2';

ChartJS.register(ArcElement, Tooltip, Legend);

const DonationSuccessRateChart = ({ title }) => {
  const data = {
    labels: ['Accepted', 'Expired', 'Canceled'],
    datasets: [
      {
        data: [75, 15, 10],
        backgroundColor: [
          'rgba(76, 175, 80, 0.7)',  // green
          'rgba(255, 152, 0, 0.7)',  // orange
          'rgba(244, 67, 54, 0.7)',  // red
        ],
        borderColor: [
          'rgba(76, 175, 80, 1)',
          'rgba(255, 152, 0, 1)',
          'rgba(244, 67, 54, 1)',
        ],
        borderWidth: 1,
      },
    ],
  };

  const options = {
    responsive: true,
    maintainAspectRatio: false,
    cutout: '70%',
    plugins: {
      legend: {
        position: 'bottom',
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

  // Plugin to display the total value in the center
  const textCenter = {
    id: 'textCenter',
    beforeDraw: function(chart) {
      const width = chart.width;
      const height = chart.height;
      const ctx = chart.ctx;
      
      ctx.restore();
      const fontSize = (height / 114).toFixed(2);
      ctx.font = fontSize + 'em sans-serif';
      ctx.textBaseline = 'middle';
      
      const text = '75%';
      const textX = Math.round((width - ctx.measureText(text).width) / 2);
      const textY = height / 2;
      
      ctx.fillStyle = '#000';
      ctx.fillText(text, textX, textY);
      
      const text2 = 'Success';
      const fontSize2 = (height / 200).toFixed(2);
      ctx.font = fontSize2 + 'em sans-serif';
      const text2X = Math.round((width - ctx.measureText(text2).width) / 2);
      const text2Y = height / 2 + height / 14;
      
      ctx.fillStyle = '#666';
      ctx.fillText(text2, text2X, text2Y);
      
      ctx.save();
    }
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
          <Doughnut data={data} options={options} plugins={[textCenter]} />
        </Box>
      </CardContent>
    </Card>
  );
};

export default DonationSuccessRateChart; 