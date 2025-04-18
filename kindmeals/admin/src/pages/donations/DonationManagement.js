import React, { useState } from 'react';
import {
  Container,
  Box,
  Typography,
  Tabs,
  Tab,
  Paper,
  Card,
  CardContent,
  TextField,
  Button,
  Grid,
  IconButton,
  Chip,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  TablePagination,
  Avatar,
  MenuItem,
  Select,
  FormControl,
  InputLabel
} from '@mui/material';
import {
  Search as SearchIcon,
  FilterList as FilterListIcon,
  Visibility as VisibilityIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
  GetApp as DownloadIcon,
  Refresh as RefreshIcon
} from '@mui/icons-material';

// Tab panel component to handle showing content based on selected tab
function TabPanel(props) {
  const { children, value, index, ...other } = props;

  return (
    <div
      role="tabpanel"
      hidden={value !== index}
      id={`donation-tabpanel-${index}`}
      aria-labelledby={`donation-tab-${index}`}
      {...other}
    >
      {value === index && (
        <Box sx={{ pt: 3 }}>
          {children}
        </Box>
      )}
    </div>
  );
}

function a11yProps(index) {
  return {
    id: `donation-tab-${index}`,
    'aria-controls': `donation-tabpanel-${index}`,
  };
}

// Sample donation data - Current donations
const sampleActiveDonations = [
  {
    id: 1,
    donorName: 'Taj Restaurant',
    foodName: 'Mixed Vegetable Curry',
    quantity: 25,
    foodType: 'veg',
    postedDate: '2023-09-17T14:30:00',
    expiryDate: '2023-09-18T14:30:00',
    status: 'Available',
    location: 'Mumbai',
    image: '',
    description: 'Freshly prepared vegetable curry with rice. Ready for pickup.'
  },
  {
    id: 2,
    donorName: 'Metro Hotel',
    foodName: 'Butter Chicken',
    quantity: 15,
    foodType: 'nonveg',
    postedDate: '2023-09-17T16:30:00',
    expiryDate: '2023-09-18T16:30:00',
    status: 'Reserved',
    location: 'Delhi',
    image: '',
    description: 'North Indian specialty, mild spices, suitable for dinner. Approximately 15 servings.'
  },
  {
    id: 3,
    donorName: 'Green Cafe',
    foodName: 'Fresh Fruit Platter',
    quantity: 10,
    foodType: 'veg',
    postedDate: '2023-09-17T09:00:00',
    expiryDate: '2023-09-18T09:00:00',
    status: 'Available',
    location: 'Bangalore',
    image: '',
    description: 'Assorted fresh fruits including apples, oranges, and bananas. Ideal for breakfast or snack.'
  },
  {
    id: 4,
    donorName: 'Spice Garden',
    foodName: 'Vegetable Biryani',
    quantity: 20,
    foodType: 'veg',
    postedDate: '2023-09-17T11:30:00',
    expiryDate: '2023-09-18T11:30:00',
    status: 'In Transit',
    location: 'Chennai',
    image: '',
    description: 'Aromatic rice dish with mixed vegetables and spices. Ready to serve.'
  },
  {
    id: 5,
    donorName: 'Ahmed Khan',
    foodName: 'Homemade Bread',
    quantity: 30,
    foodType: 'veg',
    postedDate: '2023-09-17T08:00:00',
    expiryDate: '2023-09-19T08:00:00',
    status: 'Available',
    location: 'Hyderabad',
    image: '',
    description: 'Freshly baked bread loaves. Good for 2 days if stored properly.'
  },
  {
    id: 6,
    donorName: 'Royal Bakery',
    foodName: 'Assorted Pastries',
    quantity: 40,
    foodType: 'veg',
    postedDate: '2023-09-17T10:15:00',
    expiryDate: '2023-09-18T22:00:00',
    status: 'Available',
    location: 'Pune',
    image: '',
    description: 'Variety of fresh pastries including croissants and danishes. Perfect for breakfast or tea time.'
  },
  {
    id: 7,
    donorName: 'Healthy Bites',
    foodName: 'Mixed Salad Bowls',
    quantity: 12,
    foodType: 'veg',
    postedDate: '2023-09-17T11:45:00',
    expiryDate: '2023-09-18T12:00:00',
    status: 'Reserved',
    location: 'Bangalore',
    image: '',
    description: 'Fresh salad bowls with quinoa, mixed greens, and light dressing. High nutritional value.'
  },
  {
    id: 8,
    donorName: 'Food King Catering',
    foodName: 'Chicken Tikka',
    quantity: 35,
    foodType: 'nonveg',
    postedDate: '2023-09-17T13:20:00',
    expiryDate: '2023-09-18T13:20:00',
    status: 'Available',
    location: 'Delhi',
    image: '',
    description: 'Tandoori chicken tikka, marinated in yogurt and spices. From a canceled event.'
  }
];

// Sample donation data - Past donations
const samplePastDonations = [
  {
    id: 101,
    donorName: 'Taj Restaurant',
    foodName: 'Dal Makhani',
    quantity: 20,
    foodType: 'veg',
    postedDate: '2023-09-10T14:30:00',
    expiryDate: '2023-09-11T14:30:00',
    status: 'Completed',
    recipient: 'Food4All NGO',
    volunteer: 'Vikram Mehta',
    location: 'Mumbai',
    image: '',
    description: 'Creamy lentil dish, North Indian specialty.'
  },
  {
    id: 102,
    donorName: 'Green Cafe',
    foodName: 'Sandwiches',
    quantity: 15,
    foodType: 'veg',
    postedDate: '2023-09-09T10:30:00',
    expiryDate: '2023-09-10T10:30:00',
    status: 'Expired',
    recipient: null,
    volunteer: null,
    location: 'Delhi',
    image: '',
    description: 'Assorted vegetable sandwiches.'
  },
  {
    id: 103,
    donorName: 'Metro Hotel',
    foodName: 'Pasta Salad',
    quantity: 18,
    foodType: 'veg',
    postedDate: '2023-09-08T12:30:00',
    expiryDate: '2023-09-09T12:30:00',
    status: 'Completed',
    recipient: 'Happy Shelter',
    volunteer: 'Anjali Singh',
    location: 'Bangalore',
    image: '',
    description: 'Cold pasta salad with mixed vegetables and dressing.'
  },
  {
    id: 104,
    donorName: 'Spice Garden',
    foodName: 'Chicken Curry',
    quantity: 12,
    foodType: 'nonveg',
    postedDate: '2023-09-07T15:00:00',
    expiryDate: '2023-09-08T15:00:00',
    status: 'Completed',
    recipient: 'Community Kitchen',
    volunteer: 'Divya Patel',
    location: 'Chennai',
    image: '',
    description: 'Spicy chicken curry prepared with traditional spices.'
  },
  {
    id: 105,
    donorName: 'Ahmed Khan',
    foodName: 'Rice Pudding',
    quantity: 25,
    foodType: 'veg',
    postedDate: '2023-09-06T09:30:00',
    expiryDate: '2023-09-07T09:30:00',
    status: 'Canceled',
    recipient: null,
    volunteer: null,
    location: 'Hyderabad',
    image: '',
    description: 'Sweet rice pudding with cardamom and nuts.'
  },
  {
    id: 106,
    donorName: 'Royal Bakery',
    foodName: 'Birthday Cake',
    quantity: 15,
    foodType: 'veg',
    postedDate: '2023-09-05T14:00:00',
    expiryDate: '2023-09-06T14:00:00',
    status: 'Completed',
    recipient: 'Children\'s Home',
    volunteer: 'Rajiv Kumar',
    location: 'Pune',
    image: '',
    description: 'Chocolate cake with vanilla frosting. From a canceled birthday celebration.'
  },
  {
    id: 107,
    donorName: 'Healthy Bites',
    foodName: 'Fruit Juice',
    quantity: 30,
    foodType: 'veg',
    postedDate: '2023-09-04T09:00:00',
    expiryDate: '2023-09-05T09:00:00',
    status: 'Completed',
    recipient: 'Senior Center',
    volunteer: 'Meera Sharma',
    location: 'Bangalore',
    image: '',
    description: 'Freshly squeezed mixed fruit juice in sealed containers.'
  },
  {
    id: 108,
    donorName: 'Food King Catering',
    foodName: 'Vegetable Pulao',
    quantity: 25,
    foodType: 'veg',
    postedDate: '2023-09-03T11:30:00',
    expiryDate: '2023-09-04T11:30:00',
    status: 'Expired',
    recipient: null,
    volunteer: null,
    location: 'Delhi',
    image: '',
    description: 'Fragrant rice dish with mixed vegetables. Extra food from corporate event.'
  },
  {
    id: 109,
    donorName: 'Taj Restaurant',
    foodName: 'Vegetable Samosas',
    quantity: 50,
    foodType: 'veg',
    postedDate: '2023-09-02T16:00:00',
    expiryDate: '2023-09-03T16:00:00',
    status: 'Completed',
    recipient: 'Youth Center',
    volunteer: 'Sanjay Gupta',
    location: 'Mumbai',
    image: '',
    description: 'Crispy pastry filled with spiced potatoes and peas.'
  },
  {
    id: 110,
    donorName: 'Metro Hotel',
    foodName: 'Paneer Butter Masala',
    quantity: 20,
    foodType: 'veg',
    postedDate: '2023-09-01T13:00:00',
    expiryDate: '2023-09-02T13:00:00',
    status: 'Completed',
    recipient: 'Women\'s Shelter',
    volunteer: 'Priya Kapoor',
    location: 'Delhi',
    image: '',
    description: 'Rich and creamy paneer curry. Hotel restaurant surplus.'
  }
];

const DonationManagement = () => {
  const [tabValue, setTabValue] = useState(0);
  const [activeDonations, setActiveDonations] = useState(sampleActiveDonations);
  const [pastDonations, setPastDonations] = useState(samplePastDonations);
  const [searchTermActive, setSearchTermActive] = useState('');
  const [searchTermPast, setSearchTermPast] = useState('');
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  
  // Filter states
  const [filterFoodType, setFilterFoodType] = useState('all');
  const [filterLocation, setFilterLocation] = useState('');
  const [filterStatus, setFilterStatus] = useState('');
  const [isFilterVisible, setIsFilterVisible] = useState(false);

  const handleTabChange = (event, newValue) => {
    setTabValue(newValue);
    setPage(0); // Reset page when switching tabs
  };

  const handleChangePage = (event, newPage) => {
    setPage(newPage);
  };

  const handleChangeRowsPerPage = (event) => {
    setRowsPerPage(parseInt(event.target.value, 10));
    setPage(0);
  };

  const toggleFilterVisibility = () => {
    setIsFilterVisible(!isFilterVisible);
  };
  
  const resetFilters = () => {
    setFilterFoodType('all');
    setFilterLocation('');
    setFilterStatus('');
    setSearchTermActive('');
    setSearchTermPast('');
    
    // Reset the donations based on current tab
    if (tabValue === 0) {
      setActiveDonations(sampleActiveDonations);
    } else {
      setPastDonations(samplePastDonations);
    }
  };

  const handleSearchActive = () => {
    applyActiveFilters();
  };

  const handleSearchPast = () => {
    applyPastFilters();
  };
  
  const applyActiveFilters = () => {
    let filtered = [...sampleActiveDonations];
    
    // Apply search term filter
    if (searchTermActive.trim()) {
      filtered = filtered.filter(donation => 
        donation.donorName.toLowerCase().includes(searchTermActive.toLowerCase()) ||
        donation.foodName.toLowerCase().includes(searchTermActive.toLowerCase()) ||
        donation.location.toLowerCase().includes(searchTermActive.toLowerCase()) ||
        donation.status.toLowerCase().includes(searchTermActive.toLowerCase()) ||
        donation.description.toLowerCase().includes(searchTermActive.toLowerCase())
      );
    }
    
    // Apply food type filter
    if (filterFoodType !== 'all') {
      filtered = filtered.filter(donation => donation.foodType === filterFoodType);
    }
    
    // Apply location filter
    if (filterLocation) {
      filtered = filtered.filter(donation => 
        donation.location.toLowerCase().includes(filterLocation.toLowerCase())
      );
    }
    
    // Apply status filter
    if (filterStatus) {
      filtered = filtered.filter(donation => 
        donation.status.toLowerCase() === filterStatus.toLowerCase()
      );
    }
    
    setActiveDonations(filtered);
  };
  
  const applyPastFilters = () => {
    let filtered = [...samplePastDonations];
    
    // Apply search term filter
    if (searchTermPast.trim()) {
      filtered = filtered.filter(donation => 
        donation.donorName.toLowerCase().includes(searchTermPast.toLowerCase()) ||
        donation.foodName.toLowerCase().includes(searchTermPast.toLowerCase()) ||
        donation.location.toLowerCase().includes(searchTermPast.toLowerCase()) ||
        donation.status.toLowerCase().includes(searchTermPast.toLowerCase()) ||
        (donation.recipient && donation.recipient.toLowerCase().includes(searchTermPast.toLowerCase())) ||
        (donation.volunteer && donation.volunteer.toLowerCase().includes(searchTermPast.toLowerCase())) ||
        donation.description.toLowerCase().includes(searchTermPast.toLowerCase())
      );
    }
    
    // Apply food type filter
    if (filterFoodType !== 'all') {
      filtered = filtered.filter(donation => donation.foodType === filterFoodType);
    }
    
    // Apply location filter
    if (filterLocation) {
      filtered = filtered.filter(donation => 
        donation.location.toLowerCase().includes(filterLocation.toLowerCase())
      );
    }
    
    // Apply status filter
    if (filterStatus) {
      filtered = filtered.filter(donation => 
        donation.status.toLowerCase() === filterStatus.toLowerCase()
      );
    }
    
    setPastDonations(filtered);
  };

  const getStatusColor = (status) => {
    switch (status.toLowerCase()) {
      case 'available':
        return 'success';
      case 'reserved':
        return 'primary';
      case 'in transit':
        return 'info';
      case 'completed':
        return 'success';
      case 'expired':
        return 'error';
      case 'canceled':
        return 'warning';
      default:
        return 'default';
    }
  };

  const formatDateTime = (dateTimeStr) => {
    const date = new Date(dateTimeStr);
    return date.toLocaleString('en-IN', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  return (
    <Container maxWidth="xl">
      <Box sx={{ mb: 4 }}>
        <Typography variant="h4" fontWeight="bold" gutterBottom>
          Donation Management
        </Typography>
        <Typography variant="body1" color="text.secondary">
          Manage and track all food donations, both current and past.
        </Typography>
      </Box>

      <Paper sx={{ mb: 3 }}>
        <Tabs 
          value={tabValue} 
          onChange={handleTabChange} 
          variant="fullWidth"
          textColor="primary"
          indicatorColor="primary"
          aria-label="donation management tabs"
        >
          <Tab label="Current Donations" {...a11yProps(0)} />
          <Tab label="Past Donations" {...a11yProps(1)} />
        </Tabs>
      </Paper>

      {/* Current Donations Tab */}
      <TabPanel value={tabValue} index={0}>
        {/* Search Bar */}
        <Card sx={{ mb: 3 }}>
          <CardContent>
            <Grid container spacing={2} alignItems="center">
              <Grid item xs={12} md={6}>
                <TextField
                  fullWidth
                  placeholder="Search donations by donor, food, location, status or description..."
                  value={searchTermActive}
                  onChange={(e) => setSearchTermActive(e.target.value)}
                  onKeyPress={(e) => e.key === 'Enter' && handleSearchActive()}
                  InputProps={{
                    endAdornment: (
                      <IconButton onClick={handleSearchActive}>
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
                  onClick={toggleFilterVisibility}
                >
                  {isFilterVisible ? 'Hide Filters' : 'Show Filters'}
                </Button>
                <Button variant="outlined" onClick={resetFilters} sx={{ mr: 1 }}>
                  Reset
                </Button>
                <Button variant="outlined">
                  Export
                </Button>
              </Grid>
            </Grid>
            
            {/* Filter Panel */}
            {isFilterVisible && (
              <Box sx={{ mt: 2, pt: 2, borderTop: 1, borderColor: 'divider' }}>
                <Grid container spacing={2} alignItems="center">
                  <Grid item xs={12} sm={4} md={3}>
                    <Typography variant="subtitle2" gutterBottom>Food Type</Typography>
                    <FormControl fullWidth size="small">
                      <Select
                        value={filterFoodType}
                        onChange={(e) => setFilterFoodType(e.target.value)}
                      >
                        <MenuItem value="all">All Types</MenuItem>
                        <MenuItem value="veg">Vegetarian</MenuItem>
                        <MenuItem value="nonveg">Non-Vegetarian</MenuItem>
                        <MenuItem value="jain">Jain</MenuItem>
                      </Select>
                    </FormControl>
                  </Grid>
                  <Grid item xs={12} sm={4} md={3}>
                    <Typography variant="subtitle2" gutterBottom>Location</Typography>
                    <TextField
                      fullWidth
                      size="small"
                      placeholder="Filter by location"
                      value={filterLocation}
                      onChange={(e) => setFilterLocation(e.target.value)}
                    />
                  </Grid>
                  <Grid item xs={12} sm={4} md={3}>
                    <Typography variant="subtitle2" gutterBottom>Status</Typography>
                    <FormControl fullWidth size="small">
                      <Select
                        value={filterStatus}
                        onChange={(e) => setFilterStatus(e.target.value)}
                      >
                        <MenuItem value="">All Statuses</MenuItem>
                        <MenuItem value="Available">Available</MenuItem>
                        <MenuItem value="Reserved">Reserved</MenuItem>
                        <MenuItem value="In Transit">In Transit</MenuItem>
                      </Select>
                    </FormControl>
                  </Grid>
                  <Grid item xs={12} md={3} sx={{ display: 'flex', alignItems: 'flex-end', justifyContent: 'flex-end' }}>
                    <Button 
                      variant="contained" 
                      color="primary"
                      onClick={handleSearchActive}
                      sx={{ mt: { xs: 2, md: 0 } }}
                    >
                      Apply Filters
                    </Button>
                  </Grid>
                </Grid>
              </Box>
            )}
          </CardContent>
        </Card>

        {/* Current Donations Table */}
        <TableContainer component={Paper}>
          <Table sx={{ minWidth: 650 }} aria-label="current donations table">
            <TableHead>
              <TableRow sx={{ bgcolor: 'background.default' }}>
                <TableCell>Donor</TableCell>
                <TableCell>Food Item</TableCell>
                <TableCell>Quantity</TableCell>
                <TableCell>Food Type</TableCell>
                <TableCell>Posted</TableCell>
                <TableCell>Expires</TableCell>
                <TableCell>Location</TableCell>
                <TableCell>Status</TableCell>
                <TableCell align="right">Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {activeDonations.length > 0 ? (
                activeDonations
                  .slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage)
                  .map((donation) => (
                  <TableRow
                    key={donation.id}
                    hover
                    sx={{ '&:last-child td, &:last-child th': { border: 0 } }}
                  >
                    <TableCell component="th" scope="row">
                      <Box sx={{ display: 'flex', alignItems: 'center' }}>
                        <Avatar sx={{ mr: 2, bgcolor: 'primary.light' }}>
                          {donation.donorName.charAt(0)}
                        </Avatar>
                        <Typography variant="body2">{donation.donorName}</Typography>
                      </Box>
                    </TableCell>
                    <TableCell>{donation.foodName}</TableCell>
                    <TableCell>{donation.quantity} servings</TableCell>
                    <TableCell>
                      <Chip 
                        size="small" 
                        label={donation.foodType === 'veg' ? 'Vegetarian' : donation.foodType === 'jain' ? 'Jain' : 'Non-Vegetarian'} 
                        color={donation.foodType === 'veg' || donation.foodType === 'jain' ? 'success' : 'error'} 
                        variant="outlined" 
                      />
                    </TableCell>
                    <TableCell>{formatDateTime(donation.postedDate)}</TableCell>
                    <TableCell>{formatDateTime(donation.expiryDate)}</TableCell>
                    <TableCell>{donation.location}</TableCell>
                    <TableCell>
                      <Chip 
                        size="small" 
                        label={donation.status} 
                        color={getStatusColor(donation.status)} 
                      />
                    </TableCell>
                    <TableCell align="right">
                      <IconButton size="small" title="View Details">
                        <VisibilityIcon fontSize="small" />
                      </IconButton>
                      <IconButton size="small" title="Edit Donation">
                        <EditIcon fontSize="small" />
                      </IconButton>
                      <IconButton size="small" color="error" title="Delete Donation">
                        <DeleteIcon fontSize="small" />
                      </IconButton>
                    </TableCell>
                  </TableRow>
                ))
              ) : (
                <TableRow>
                  <TableCell colSpan={9} align="center" sx={{ py: 3 }}>
                    <Typography variant="body1" color="text.secondary">
                      No donations found matching your criteria.
                    </Typography>
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
          <TablePagination
            rowsPerPageOptions={[5, 10, 25, 50]}
            component="div"
            count={activeDonations.length}
            rowsPerPage={rowsPerPage}
            page={page}
            onPageChange={handleChangePage}
            onRowsPerPageChange={handleChangeRowsPerPage}
          />
        </TableContainer>
      </TabPanel>

      {/* Past Donations Tab */}
      <TabPanel value={tabValue} index={1}>
        {/* Search Bar */}
        <Card sx={{ mb: 3 }}>
          <CardContent>
            <Grid container spacing={2} alignItems="center">
              <Grid item xs={12} md={6}>
                <TextField
                  fullWidth
                  placeholder="Search by donor, food, recipient, volunteer, location or status..."
                  value={searchTermPast}
                  onChange={(e) => setSearchTermPast(e.target.value)}
                  onKeyPress={(e) => e.key === 'Enter' && handleSearchPast()}
                  InputProps={{
                    endAdornment: (
                      <IconButton onClick={handleSearchPast}>
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
                  onClick={toggleFilterVisibility}
                >
                  {isFilterVisible ? 'Hide Filters' : 'Show Filters'}
                </Button>
                <Button variant="outlined" onClick={resetFilters} sx={{ mr: 1 }}>
                  Reset
                </Button>
                <Button variant="outlined">
                  Export
                </Button>
              </Grid>
            </Grid>
            
            {/* Filter Panel */}
            {isFilterVisible && (
              <Box sx={{ mt: 2, pt: 2, borderTop: 1, borderColor: 'divider' }}>
                <Grid container spacing={2} alignItems="center">
                  <Grid item xs={12} sm={4} md={3}>
                    <Typography variant="subtitle2" gutterBottom>Food Type</Typography>
                    <FormControl fullWidth size="small">
                      <Select
                        value={filterFoodType}
                        onChange={(e) => setFilterFoodType(e.target.value)}
                      >
                        <MenuItem value="all">All Types</MenuItem>
                        <MenuItem value="veg">Vegetarian</MenuItem>
                        <MenuItem value="nonveg">Non-Vegetarian</MenuItem>
                        <MenuItem value="jain">Jain</MenuItem>
                      </Select>
                    </FormControl>
                  </Grid>
                  <Grid item xs={12} sm={4} md={3}>
                    <Typography variant="subtitle2" gutterBottom>Location</Typography>
                    <TextField
                      fullWidth
                      size="small"
                      placeholder="Filter by location"
                      value={filterLocation}
                      onChange={(e) => setFilterLocation(e.target.value)}
                    />
                  </Grid>
                  <Grid item xs={12} sm={4} md={3}>
                    <Typography variant="subtitle2" gutterBottom>Status</Typography>
                    <FormControl fullWidth size="small">
                      <Select
                        value={filterStatus}
                        onChange={(e) => setFilterStatus(e.target.value)}
                      >
                        <MenuItem value="">All Statuses</MenuItem>
                        <MenuItem value="Completed">Completed</MenuItem>
                        <MenuItem value="Expired">Expired</MenuItem>
                        <MenuItem value="Canceled">Canceled</MenuItem>
                      </Select>
                    </FormControl>
                  </Grid>
                  <Grid item xs={12} md={3} sx={{ display: 'flex', alignItems: 'flex-end', justifyContent: 'flex-end' }}>
                    <Button 
                      variant="contained" 
                      color="primary"
                      onClick={handleSearchPast}
                      sx={{ mt: { xs: 2, md: 0 } }}
                    >
                      Apply Filters
                    </Button>
                  </Grid>
                </Grid>
              </Box>
            )}
          </CardContent>
        </Card>

        {/* Past Donations Table */}
        <TableContainer component={Paper}>
          <Table sx={{ minWidth: 650 }} aria-label="past donations table">
            <TableHead>
              <TableRow sx={{ bgcolor: 'background.default' }}>
                <TableCell>Donor</TableCell>
                <TableCell>Food Item</TableCell>
                <TableCell>Quantity</TableCell>
                <TableCell>Posted</TableCell>
                <TableCell>Recipient</TableCell>
                <TableCell>Volunteer</TableCell>
                <TableCell>Location</TableCell>
                <TableCell>Status</TableCell>
                <TableCell align="right">Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {pastDonations.length > 0 ? (
                pastDonations
                  .slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage)
                  .map((donation) => (
                  <TableRow
                    key={donation.id}
                    hover
                    sx={{ '&:last-child td, &:last-child th': { border: 0 } }}
                  >
                    <TableCell component="th" scope="row">
                      <Box sx={{ display: 'flex', alignItems: 'center' }}>
                        <Avatar sx={{ mr: 2, bgcolor: 'primary.light' }}>
                          {donation.donorName.charAt(0)}
                        </Avatar>
                        <Typography variant="body2">{donation.donorName}</Typography>
                      </Box>
                    </TableCell>
                    <TableCell>{donation.foodName}</TableCell>
                    <TableCell>{donation.quantity} servings</TableCell>
                    <TableCell>{formatDateTime(donation.postedDate)}</TableCell>
                    <TableCell>
                      {donation.recipient || (
                        <Typography variant="body2" color="text.secondary">
                          —
                        </Typography>
                      )}
                    </TableCell>
                    <TableCell>
                      {donation.volunteer || (
                        <Typography variant="body2" color="text.secondary">
                          —
                        </Typography>
                      )}
                    </TableCell>
                    <TableCell>{donation.location}</TableCell>
                    <TableCell>
                      <Chip 
                        size="small" 
                        label={donation.status} 
                        color={getStatusColor(donation.status)} 
                      />
                    </TableCell>
                    <TableCell align="right">
                      <IconButton size="small" title="View Details">
                        <VisibilityIcon fontSize="small" />
                      </IconButton>
                    </TableCell>
                  </TableRow>
                ))
              ) : (
                <TableRow>
                  <TableCell colSpan={9} align="center" sx={{ py: 3 }}>
                    <Typography variant="body1" color="text.secondary">
                      No donations found matching your criteria.
                    </Typography>
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
          <TablePagination
            rowsPerPageOptions={[5, 10, 25, 50]}
            component="div"
            count={pastDonations.length}
            rowsPerPage={rowsPerPage}
            page={page}
            onPageChange={handleChangePage}
            onRowsPerPageChange={handleChangeRowsPerPage}
          />
        </TableContainer>
      </TabPanel>
    </Container>
  );
};

export default DonationManagement; 