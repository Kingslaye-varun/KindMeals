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
  Typography
} from '@mui/material';
import {
  Add as AddIcon,
  Search as SearchIcon,
  FilterList as FilterListIcon,
  Close as CloseIcon
} from '@mui/icons-material';
import UserTable from '../../components/users/UserTable';

// Sample data - in a real app this would come from an API
const sampleDonors = [
  {
    id: 1,
    name: 'John Smith',
    organization: 'Taj Restaurant',
    email: 'john@tajrestaurant.com',
    phone: '+91 9876543210',
    type: 'Restaurant',
    status: 'Active',
    joinDate: '2023-01-15',
    profileImage: '',
    address: '123 Main St, Mumbai, India',
    about: 'A luxury 5-star hotel with multiple restaurants willing to donate excess food.'
  },
  {
    id: 2,
    name: 'Priya Sharma',
    organization: 'Green Cafe',
    email: 'priya@greencafe.com',
    phone: '+91 8765432109',
    type: 'Cafe',
    status: 'Active',
    joinDate: '2023-02-10',
    profileImage: '',
    address: '45 Park Ave, Delhi, India',
    about: 'Organic cafe with a mission to reduce food waste and promote sustainable eating.'
  },
  {
    id: 3,
    name: 'Rahul Patel',
    organization: 'Spice Garden',
    email: 'rahul@spicegarden.com',
    phone: '+91 7654321098',
    type: 'Restaurant',
    status: 'Inactive',
    joinDate: '2023-03-05',
    profileImage: '',
    address: '78 Lake Road, Bangalore, India',
    about: 'Traditional Indian cuisine restaurant with large catering operations.'
  },
  {
    id: 4,
    name: 'Ananya Desai',
    organization: 'Metro Hotel',
    email: 'ananya@metrohotel.com',
    phone: '+91 6543210987',
    type: 'Hotel',
    status: 'Active',
    joinDate: '2023-04-20',
    profileImage: '',
    address: '15 Central Ave, Chennai, India',
    about: 'Business hotel with conference facilities and three restaurants.'
  },
  {
    id: 5,
    name: 'Ahmed Khan',
    organization: null, // Individual donor
    email: 'ahmed.khan@gmail.com',
    phone: '+91 5432109876',
    type: 'Individual',
    status: 'Pending',
    joinDate: '2023-05-12',
    profileImage: '',
    address: '22 River Road, Hyderabad, India',
    about: 'Regular food donor supporting local causes.'
  }
];

const DonorsList = () => {
  const [donors, setDonors] = useState(sampleDonors);
  const [searchTerm, setSearchTerm] = useState('');
  const [viewDialogOpen, setViewDialogOpen] = useState(false);
  const [selectedDonor, setSelectedDonor] = useState(null);
  const [editDialogOpen, setEditDialogOpen] = useState(false);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);

  const handleSearch = () => {
    if (!searchTerm.trim()) {
      setDonors(sampleDonors);
      return;
    }
    
    const filtered = sampleDonors.filter(donor => 
      donor.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      (donor.organization && donor.organization.toLowerCase().includes(searchTerm.toLowerCase())) ||
      donor.email.toLowerCase().includes(searchTerm.toLowerCase())
    );
    
    setDonors(filtered);
  };

  const handleViewDonor = (donor) => {
    setSelectedDonor(donor);
    setViewDialogOpen(true);
  };

  const handleEditDonor = (donor) => {
    setSelectedDonor(donor);
    setEditDialogOpen(true);
  };

  const handleDeleteDonor = (donor) => {
    setSelectedDonor(donor);
    setDeleteDialogOpen(true);
  };

  const handleDeleteConfirm = () => {
    // In a real app, you would call an API to delete the donor
    const updatedDonors = donors.filter(donor => donor.id !== selectedDonor.id);
    setDonors(updatedDonors);
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
          Add Donor
        </Button>
      </Box>

      {/* Search and Filter */}
      <Card sx={{ mb: 3 }}>
        <CardContent>
          <Grid container spacing={2} alignItems="center">
            <Grid item xs={12} md={6}>
              <TextField
                fullWidth
                placeholder="Search donors by name, email or organization..."
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

      {/* Donors Table */}
      <UserTable
        users={donors}
        userType="Donors"
        onView={handleViewDonor}
        onEdit={handleEditDonor}
        onDelete={handleDeleteDonor}
      />

      {/* View Donor Dialog */}
      <Dialog
        open={viewDialogOpen}
        onClose={() => setViewDialogOpen(false)}
        maxWidth="md"
        fullWidth
      >
        <DialogTitle>
          Donor Details
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
          {selectedDonor && (
            <Grid container spacing={2}>
              <Grid item xs={12} md={4} sx={{ textAlign: 'center' }}>
                <Box>
                  {selectedDonor.profileImage ? (
                    <Box
                      component="img"
                      src={selectedDonor.profileImage}
                      alt={selectedDonor.name}
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
                        bgcolor: 'primary.light',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        mb: 2,
                        mx: 'auto'
                      }}
                    >
                      <Typography variant="h3" color="white">
                        {selectedDonor.name.charAt(0)}
                      </Typography>
                    </Box>
                  )}
                  <Typography variant="h6" gutterBottom>
                    {selectedDonor.organization || selectedDonor.name}
                  </Typography>
                  <Typography variant="body1" color="text.secondary" gutterBottom>
                    {selectedDonor.type}
                  </Typography>
                </Box>
              </Grid>
              <Grid item xs={12} md={8}>
                <Grid container spacing={2}>
                  <Grid item xs={12} sm={6}>
                    <Typography variant="subtitle2" color="text.secondary">
                      Contact Person
                    </Typography>
                    <Typography variant="body1" gutterBottom>
                      {selectedDonor.name}
                    </Typography>
                  </Grid>
                  <Grid item xs={12} sm={6}>
                    <Typography variant="subtitle2" color="text.secondary">
                      Email
                    </Typography>
                    <Typography variant="body1" gutterBottom>
                      {selectedDonor.email}
                    </Typography>
                  </Grid>
                  <Grid item xs={12} sm={6}>
                    <Typography variant="subtitle2" color="text.secondary">
                      Phone
                    </Typography>
                    <Typography variant="body1" gutterBottom>
                      {selectedDonor.phone}
                    </Typography>
                  </Grid>
                  <Grid item xs={12} sm={6}>
                    <Typography variant="subtitle2" color="text.secondary">
                      Member Since
                    </Typography>
                    <Typography variant="body1" gutterBottom>
                      {new Date(selectedDonor.joinDate).toLocaleDateString()}
                    </Typography>
                  </Grid>
                  <Grid item xs={12}>
                    <Typography variant="subtitle2" color="text.secondary">
                      Address
                    </Typography>
                    <Typography variant="body1" gutterBottom>
                      {selectedDonor.address}
                    </Typography>
                  </Grid>
                  <Grid item xs={12}>
                    <Typography variant="subtitle2" color="text.secondary">
                      About
                    </Typography>
                    <Typography variant="body1" gutterBottom>
                      {selectedDonor.about}
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
              handleEditDonor(selectedDonor);
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
            Are you sure you want to delete {selectedDonor?.organization || selectedDonor?.name}? 
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

export default DonorsList; 