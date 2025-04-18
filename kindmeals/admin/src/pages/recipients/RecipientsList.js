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

// Sample data for recipients
const sampleRecipients = [
  {
    id: 1,
    name: 'Sarah Johnson',
    organization: 'Food4All NGO',
    email: 'sarah@food4all.org',
    phone: '+91 9876543210',
    type: 'NGO',
    status: 'Active',
    joinDate: '2023-01-10',
    profileImage: '',
    address: '45 Charity Lane, Mumbai, India',
    about: 'NGO dedicated to feeding homeless people in the city'
  },
  {
    id: 2,
    name: 'Rahul Gupta',
    organization: 'Happy Shelter',
    email: 'rahul@happyshelter.org',
    phone: '+91 8765432109',
    type: 'Shelter',
    status: 'Active',
    joinDate: '2023-02-15',
    profileImage: '',
    address: '78 Hope Street, Delhi, India',
    about: 'Shelter providing accommodation and food for homeless families'
  },
  {
    id: 3,
    name: 'Priya Sharma',
    organization: 'Child Care Center',
    email: 'priya@childcare.org',
    phone: '+91 7654321098',
    type: 'Orphanage',
    status: 'Active',
    joinDate: '2023-03-20',
    profileImage: '',
    address: '34 Children\'s Way, Bangalore, India',
    about: 'Center caring for orphaned and abandoned children'
  },
  {
    id: 4,
    name: 'Anand Patel',
    organization: 'Community Kitchen',
    email: 'anand@communitykitchen.org',
    phone: '+91 6543210987',
    type: 'Community',
    status: 'Inactive',
    joinDate: '2023-04-05',
    profileImage: '',
    address: '12 Public Square, Chennai, India',
    about: 'Community kitchen providing meals to low-income families'
  },
  {
    id: 5,
    name: 'Meera Khan',
    organization: 'Rural School Trust',
    email: 'meera@ruralschool.org',
    phone: '+91 5432109876',
    type: 'School',
    status: 'Pending',
    joinDate: '2023-05-12',
    profileImage: '',
    address: '56 Education Road, Hyderabad, India',
    about: 'Trust running schools and meal programs for underprivileged rural children'
  }
];

const RecipientsList = () => {
  const [recipients, setRecipients] = useState(sampleRecipients);
  const [searchTerm, setSearchTerm] = useState('');
  const [viewDialogOpen, setViewDialogOpen] = useState(false);
  const [selectedRecipient, setSelectedRecipient] = useState(null);
  const [editDialogOpen, setEditDialogOpen] = useState(false);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);

  const handleSearch = () => {
    if (!searchTerm.trim()) {
      setRecipients(sampleRecipients);
      return;
    }
    
    const filtered = sampleRecipients.filter(recipient => 
      recipient.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      (recipient.organization && recipient.organization.toLowerCase().includes(searchTerm.toLowerCase())) ||
      recipient.email.toLowerCase().includes(searchTerm.toLowerCase())
    );
    
    setRecipients(filtered);
  };

  const handleViewRecipient = (recipient) => {
    setSelectedRecipient(recipient);
    setViewDialogOpen(true);
  };

  const handleEditRecipient = (recipient) => {
    setSelectedRecipient(recipient);
    setEditDialogOpen(true);
  };

  const handleDeleteRecipient = (recipient) => {
    setSelectedRecipient(recipient);
    setDeleteDialogOpen(true);
  };

  const handleDeleteConfirm = () => {
    // In a real app, you would call an API to delete the recipient
    const updatedRecipients = recipients.filter(recipient => recipient.id !== selectedRecipient.id);
    setRecipients(updatedRecipients);
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
          Add Recipient
        </Button>
      </Box>

      {/* Search and Filter */}
      <Card sx={{ mb: 3 }}>
        <CardContent>
          <Grid container spacing={2} alignItems="center">
            <Grid item xs={12} md={6}>
              <TextField
                fullWidth
                placeholder="Search recipients by name, email or organization..."
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

      {/* Recipients Table */}
      <UserTable
        users={recipients}
        userType="Recipients"
        onView={handleViewRecipient}
        onEdit={handleEditRecipient}
        onDelete={handleDeleteRecipient}
      />

      {/* View Recipient Dialog */}
      <Dialog
        open={viewDialogOpen}
        onClose={() => setViewDialogOpen(false)}
        maxWidth="md"
        fullWidth
      >
        <DialogTitle>
          Recipient Details
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
          {selectedRecipient && (
            <Grid container spacing={2}>
              <Grid item xs={12} md={4} sx={{ textAlign: 'center' }}>
                <Box>
                  {selectedRecipient.profileImage ? (
                    <Box
                      component="img"
                      src={selectedRecipient.profileImage}
                      alt={selectedRecipient.name}
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
                        bgcolor: 'success.light',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        mb: 2,
                        mx: 'auto'
                      }}
                    >
                      <Typography variant="h3" color="white">
                        {selectedRecipient.name.charAt(0)}
                      </Typography>
                    </Box>
                  )}
                  <Typography variant="h6" gutterBottom>
                    {selectedRecipient.organization || selectedRecipient.name}
                  </Typography>
                  <Typography variant="body1" color="text.secondary" gutterBottom>
                    {selectedRecipient.type}
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
                      {selectedRecipient.name}
                    </Typography>
                  </Grid>
                  <Grid item xs={12} sm={6}>
                    <Typography variant="subtitle2" color="text.secondary">
                      Email
                    </Typography>
                    <Typography variant="body1" gutterBottom>
                      {selectedRecipient.email}
                    </Typography>
                  </Grid>
                  <Grid item xs={12} sm={6}>
                    <Typography variant="subtitle2" color="text.secondary">
                      Phone
                    </Typography>
                    <Typography variant="body1" gutterBottom>
                      {selectedRecipient.phone}
                    </Typography>
                  </Grid>
                  <Grid item xs={12} sm={6}>
                    <Typography variant="subtitle2" color="text.secondary">
                      Member Since
                    </Typography>
                    <Typography variant="body1" gutterBottom>
                      {new Date(selectedRecipient.joinDate).toLocaleDateString()}
                    </Typography>
                  </Grid>
                  <Grid item xs={12}>
                    <Typography variant="subtitle2" color="text.secondary">
                      Address
                    </Typography>
                    <Typography variant="body1" gutterBottom>
                      {selectedRecipient.address}
                    </Typography>
                  </Grid>
                  <Grid item xs={12}>
                    <Typography variant="subtitle2" color="text.secondary">
                      About
                    </Typography>
                    <Typography variant="body1" gutterBottom>
                      {selectedRecipient.about}
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
              handleEditRecipient(selectedRecipient);
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
            Are you sure you want to delete {selectedRecipient?.organization || selectedRecipient?.name}? 
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

export default RecipientsList; 