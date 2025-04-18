import React from 'react';
import { 
  Card, 
  CardContent, 
  CardHeader, 
  List, 
  ListItem, 
  ListItemText, 
  ListItemAvatar, 
  Avatar, 
  Typography, 
  Chip,
  Divider
} from '@mui/material';
import {
  Restaurant as RestaurantIcon,
  Person as PersonIcon,
  CheckCircle as CheckCircleIcon,
  LocalShipping as LocalShippingIcon
} from '@mui/icons-material';

const RecentActivity = () => {
  const activities = [
    {
      id: 1,
      type: 'donation_posted',
      actor: 'Taj Restaurant',
      action: 'posted a new donation',
      details: '10 meals available for pickup',
      time: '2 hours ago',
      icon: <RestaurantIcon />,
      iconBg: 'primary.light'
    },
    {
      id: 2,
      type: 'user_registered',
      actor: 'Happy Shelter NGO',
      action: 'registered as a recipient',
      details: 'New recipient account',
      time: '3 hours ago',
      icon: <PersonIcon />,
      iconBg: 'success.light'
    },
    {
      id: 3,
      type: 'donation_accepted',
      actor: 'Food4All NGO',
      action: 'accepted a donation from Green Cafe',
      details: '5 meal boxes accepted',
      time: '5 hours ago',
      icon: <CheckCircleIcon />,
      iconBg: 'info.light'
    },
    {
      id: 4,
      type: 'donation_completed',
      actor: 'Metro Hotel',
      action: 'completed donation to Child Care Center',
      details: 'Donation successfully delivered',
      time: '8 hours ago',
      icon: <LocalShippingIcon />,
      iconBg: 'warning.light'
    },
    {
      id: 5,
      type: 'user_registered',
      actor: 'Spice Garden',
      action: 'registered as a donor',
      details: 'New donor account',
      time: '1 day ago',
      icon: <PersonIcon />,
      iconBg: 'success.light'
    }
  ];

  const getActivityColor = (type) => {
    switch (type) {
      case 'donation_posted':
        return 'primary';
      case 'user_registered':
        return 'success';
      case 'donation_accepted':
        return 'info';
      case 'donation_completed':
        return 'warning';
      default:
        return 'default';
    }
  };

  return (
    <Card sx={{ 
      boxShadow: '0 4px 12px rgba(0, 0, 0, 0.05)',
      borderRadius: 2,
      height: '100%'
    }}>
      <CardHeader 
        title="Recent Activity" 
        titleTypographyProps={{ variant: 'h6' }}
      />
      <CardContent sx={{ p: 0 }}>
        <List sx={{ p: 0 }}>
          {activities.map((activity, index) => (
            <React.Fragment key={activity.id}>
              <ListItem alignItems="flex-start" sx={{ px: 2, py: 1.5 }}>
                <ListItemAvatar>
                  <Avatar sx={{ bgcolor: activity.iconBg }}>
                    {activity.icon}
                  </Avatar>
                </ListItemAvatar>
                <ListItemText
                  primary={
                    <Typography variant="subtitle2" fontWeight="medium">
                      {activity.actor}
                      <Chip 
                        label={activity.type.replace('_', ' ')}
                        size="small"
                        color={getActivityColor(activity.type)}
                        sx={{ ml: 1, height: 20, fontSize: '0.7rem' }}
                      />
                    </Typography>
                  }
                  secondary={
                    <>
                      <Typography
                        component="span"
                        variant="body2"
                        color="text.primary"
                      >
                        {activity.action}
                      </Typography>
                      {" — "}{activity.details}
                      <Typography variant="caption" display="block" color="text.secondary" sx={{ mt: 0.5 }}>
                        {activity.time}
                      </Typography>
                    </>
                  }
                />
              </ListItem>
              {index < activities.length - 1 && <Divider variant="inset" component="li" />}
            </React.Fragment>
          ))}
        </List>
      </CardContent>
    </Card>
  );
};

export default RecentActivity; 