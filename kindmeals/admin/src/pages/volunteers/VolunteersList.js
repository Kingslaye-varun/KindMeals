import React, { useState } from 'react';
import {
  Box,
  Button,
  TextField,
  Grid,
  Card,
  CardContent,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  IconButton,
  Chip,
  Typography
} from '@mui/material';
import {
  Add as AddIcon,
  Search as SearchIcon,
  FilterList as FilterListIcon,
  Close as CloseIcon
} from '@mui/icons-material';
import UserTable from '../../components/users/UserTable';

// Sample data for volunteers
const sampleVolunteers = [
  {
    id: 1,
    name: 'Vikram Mehta',
    organization: null,
    email: 'vikram.m@gmail.com',
    phone: '+91 9876543210',
    type: 'Driver',
    status: 'Active',
    joinDate: '2023-01-20',
    profileImage: '',
    address: '12 Volunteer Road, Mumbai, India',
    about: 'Volunteer driver helping with food delivery 3 times a week',
    skills: ['Driving', 'Logistics']
  },
  {
    id: 2,
    name: 'Anjali Singh',
    organization: null,
    email: 'anjali.s@gmail.com',
    phone: '+91 8765432109',
    type: 'Coordinator',
    status: 'Active',
    joinDate: '2023-02-25',
    profileImage: '',
    address: '45 Helper Lane, Delhi, India',
    about: 'Event coordinator with experience in managing food distribution drives',
    skills: ['Event Management', 'Coordination', 'Public Relations']
  },
  {
    id: 3,
    name: 'Rohan Kapoor',
    organization: null,
    email: 'rohan.k@gmail.com',
    phone: '+91 7654321098',
    type: 'General',
    status: 'Inactive',
    joinDate: '2023-03-10',
    profileImage: '',
    address: '78 Service Road, Bangalore, India',
    about: 'General volunteer helping with various tasks as needed',
    skills: ['Food Serving', 'Cleaning']
  },
  {
    id: 4,
    name: 'Divya Patel',
    organization: null,
    email: 'divya.p@gmail.com',
    phone: '+91 6543210987',
    type: 'Cook',
    status: 'Active',
    joinDate: '2023-04-15',
    profileImage: '',
    address: '34 Kitchen Street, Chennai, India',
    about: 'Professional chef volunteering cooking services during weekends',
    skills: ['Cooking', 'Food Preparation', 'Menu Planning']
  },
  {
    id: 5,
    name: 'Rajiv Sharma',
    organization: null,
    email: 'rajiv.s@gmail.com',
    phone: '+91 5432109876',
    type: 'Driver',
    status: 'Pending',
    joinDate: '2023-05-22',
    profileImage: '',
    address: '56 Delivery Road, Hyderabad, India',
    about: 'Part-time volunteer driver available in evenings',
    skills: ['Driving', 'Navigation']
  }
];

const VolunteersList = () => {
  const [volunteers, setVolunteers] = useState(sampleVolunteers);
  const [searchTerm, setSearchTerm] = useState('');
  const [viewDialogOpen, setViewDialogOpen] = useState(false);
  const [selectedVolunteer, setSelectedVolunteer] = useState(null);
  const [editDialogOpen, setEditDialogOpen] = useState(false);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);

  const handleSearch = () => {
    if (!searchTerm.trim()) {
      setVolunteers(sampleVolunteers);
      return;
    }
    
    const filtered = sampleVolunteers.filter(volunteer => 
      volunteer.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      volunteer.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
      volunteer.type.toLowerCase().includes(searchTerm.toLowerCase()) ||
      (volunteer.skills && volunteer.skills.some(skill => 
        skill.toLowerCase().includes(searchTerm.toLowerCase())
      ))
    );
    
    setVolunteers(filtered);
  };

  const handleViewVolunteer = (volunteer) => {
    setSelectedVolunteer(volunteer);
    setViewDialogOpen(true);
  };

  const handleEditVolunteer = (volunteer) => {
    setSelectedVolunteer(volunteer);
    setEditDialogOpen(true);
  };

  const handleDeleteVolunteer = (volunteer) => {
    setSelectedVolunteer(volunteer);
    setDeleteDialogOpen(true);
  };

  const handleDeleteConfirm = () => {
    // In a real app, you would call an API to delete the volunteer
    const updatedVolunteers = volunteers.filter(volunteer => volunteer.id !== selectedVolunteer.id);
    setVolunteers(updatedVolunteers);
    setDeleteDialogOpen(false);
  };

  return (
    <>
      {/* Actions */}
      <Box sx={{ display: 'flex', justifyContent: 'flex-end', mb: 2 }}>
        <Button 
          variant="contained" 
          startIcon={<AddIcon />}
          size="medium"
        >
          Add Volunteer
        </Button>
      </Box>

      {/* Search and Filter */}
      <Card sx={{ mb: 3 }}>
        <CardContent>
          <Grid container spacing={2} alignItems="center">
            <Grid item xs={12} md={6}>
              <TextField
                fullWidth
                placeholder="Search volunteers by name, email, type or skills..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                InputProps={{
                  endAdornment: (
                    <IconButton onClick={handleSearch}>
                      <SearchIcon />
                    </IconButton>
                  )
                }}
                size="small"
              />
            </Grid>
            <Grid item xs={12} md={6} sx={{ display: 'flex', justifyContent: { xs: 'flex-start', md: 'flex-end' } }}>
              <Button
                variant="outlined"
                startIcon={<FilterListIcon />}
                sx={{ mr: 1 }}
              >
                Filter
              </Button>
              <Button variant="outlined">
                Export
              </Button>
            </Grid>
          </Grid>
        </CardContent>
      </Card>

      {/* Volunteers Table */}
      <UserTable
        users={volunteers}
        userType="Volunteers"
        onView={handleViewVolunteer}
        onEdit={handleEditVolunteer}
        onDelete={handleDeleteVolunteer}
      />

      {/* View Volunteer Dialog */}
      <Dialog
        open={viewDialogOpen}
        onClose={() => setViewDialogOpen(false)}
        maxWidth="md"
        fullWidth
      >
        <DialogTitle>
          Volunteer Details
          <IconButton
            aria-label="close"
            onClick={() => setViewDialogOpen(false)}
            sx={{
              position: 'absolute',
              right: 8,
              top: 8,
            }}
          >
            <CloseIcon />
          </IconButton>
        </DialogTitle>
        <DialogContent dividers>
          {selectedVolunteer && (
            <Grid container spacing={2}>
              <Grid item xs={12} md={4} sx={{ textAlign: 'center' }}>
                <Box>
                  {selectedVolunteer.profileImage ? (
                    <Box
                      component="img"
                      src={selectedVolunteer.profileImage}
                      alt={selectedVolunteer.name}
                      sx={{
                        width: 150,
                        height: 150,
                        borderRadius: '50%',
                        objectFit: 'cover',
                        mb: 2
                      }}
                    />
                  ) : (
                    <Box
                      sx={{
                        width: 150,
                        height: 150,
                        borderRadius: '50%',
                        bgcolor: 'info.light',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        mb: 2,
                        mx: 'auto'
                      }}
                    >
                      <Typography variant="h3" color="white">
                        {selectedVolunteer.name.charAt(0)}
                      </Typography>
                    </Box>
                  )}
                  <Typography variant="h6" gutterBottom>
                    {selectedVolunteer.name}
                  </Typography>
                  <Typography variant="body1" color="text.secondary" gutterBottom>
                    {selectedVolunteer.type}
                  </Typography>
                </Box>
              </Grid>
              <Grid item xs={12} md={8}>
                <Grid container spacing={2}>
                  <Grid item xs={12} sm={6}>
                    <Typography variant="subtitle2" color="text.secondary">
                      Email
                    </Typography>
                    <Typography variant="body1" gutterBottom>
                      {selectedVolunteer.email}
                    </Typography>
                  </Grid>
                  <Grid item xs={12} sm={6}>
                    <Typography variant="subtitle2" color="text.secondary">
                      Phone
                    </Typography>
                    <Typography variant="body1" gutterBottom>
                      {selectedVolunteer.phone}
                    </Typography>
                  </Grid>
                  <Grid item xs={12} sm={6}>
                    <Typography variant="subtitle2" color="text.secondary">
                      Member Since
                    </Typography>
                    <Typography variant="body1" gutterBottom>
                      {new Date(selectedVolunteer.joinDate).toLocaleDateString()}
                    </Typography>
                  </Grid>
                  <Grid item xs={12} sm={6}>
                    <Typography variant="subtitle2" color="text.secondary">
                      Status
                    </Typography>
                    <Typography variant="body1" gutterBottom>
                      <Chip 
                        label={selectedVolunteer.status} 
                        size="small" 
                        color={
                          selectedVolunteer.status === 'Active' ? 'success' : 
                          selectedVolunteer.status === 'Inactive' ? 'error' : 'warning'
                        }
                      />
                    </Typography>
                  </Grid>
                  <Grid item xs={12}>
                    <Typography variant="subtitle2" color="text.secondary">
                      Address
                    </Typography>
                    <Typography variant="body1" gutterBottom>
                      {selectedVolunteer.address}
                    </Typography>
                  </Grid>
                  <Grid item xs={12}>
                    <Typography variant="subtitle2" color="text.secondary">
                      Skills
                    </Typography>
                    <Box sx={{ mt: 1 }}>
                      {selectedVolunteer.skills && selectedVolunteer.skills.map((skill, index) => (
                        <Chip 
                          key={index}
                          label={skill}
                          size="small"
                          color="primary"
                          variant="outlined"
                          sx={{ mr: 1, mb: 1 }}
                        />
                      ))}
                    </Box>
                  </Grid>
                  <Grid item xs={12}>
                    <Typography variant="subtitle2" color="text.secondary">
                      About
                    </Typography>
                    <Typography variant="body1" gutterBottom>
                      {selectedVolunteer.about}
                    </Typography>
                  </Grid>
                </Grid>
              </Grid>
            </Grid>
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setViewDialogOpen(false)}>Close</Button>
          <Button 
            variant="contained" 
            onClick={() => {
              setViewDialogOpen(false);
              handleEditVolunteer(selectedVolunteer);
            }}
          >
            Edit
          </Button>
        </DialogActions>
      </Dialog>

      {/* Delete Confirmation Dialog */}
      <Dialog
        open={deleteDialogOpen}
        onClose={() => setDeleteDialogOpen(false)}
      >
        <DialogTitle>Confirm Deletion</DialogTitle>
        <DialogContent>
          <Typography>
            Are you sure you want to delete {selectedVolunteer?.name}? 
            This action cannot be undone.
          </Typography>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setDeleteDialogOpen(false)}>Cancel</Button>
          <Button onClick={handleDeleteConfirm} color="error" variant="contained">
            Delete
          </Button>
        </DialogActions>
      </Dialog>
    </>
  );
};

export default VolunteersList; 