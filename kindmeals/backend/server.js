const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const multer = require('multer');
const path = require('path');
const { admin, verifyToken } = require('./firebase-admin');
require('dotenv').config();
const fs = require('fs');

// Import models
// const User = require('./models/User'); // This model doesn't exist
const LiveDonation = require('./models/LiveDonation');
const AcceptedDonation = require('./models/AcceptedDonation');
const DirectDonor = require('./models/DirectDonor');
const DirectRecipient = require('./models/DirectRecipient');
const DirectVolunteer = require('./models/DirectVolunteer');
// const FinalDonation = require('./models/FinalDonation'); // Check if this model exists

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 5000;

// Set timezone to India Standard Time (IST)
process.env.TZ = 'Asia/Kolkata';
console.log(`Server timezone set to: ${process.env.TZ} (${new Date().toString()})`);

// Ensure uploads directory exists
const uploadsDir = path.join(__dirname, 'uploads');
console.log('Uploads directory path:', uploadsDir);
if (!fs.existsSync(uploadsDir)) {
  console.log('Creating uploads directory');
  fs.mkdirSync(uploadsDir, { recursive: true });
}

// Middleware
app.use(express.json());
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));
console.log('Uploads directory configured at:', path.join(__dirname, 'uploads'));

// Configure Multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    console.log('Saving file to:', uploadsDir);
    cb(null, uploadsDir);
  },
  filename: (req, file, cb) => {
    const filename = Date.now() + path.extname(file.originalname);
    console.log('Generated filename:', filename);
    cb(null, filename);
  }
});

const upload = multer({ 
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
  fileFilter: (req, file, cb) => {
    const filetypes = /jpeg|jpg|png/;
    const extname = filetypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = filetypes.test(file.mimetype);
    
    if (extname && mimetype) {
      return cb(null, true);
    } else {
      cb('Error: Images only (jpeg, jpg, png)!');
    }
  }
}).fields([
  { name: 'profileImage', maxCount: 1 },
  { name: 'foodImage', maxCount: 1 },
  { name: 'drivingLicenseImage', maxCount: 1 }
]);

// Add a basic health check endpoint at root path
app.get('/', (req, res) => {
  console.log('Health check requested');
  res.status(200).json({ status: 'ok', message: 'Server is running' });
});

// Add an API health check endpoint
app.get('/api/health', (req, res) => {
  console.log('API health check requested');
  res.status(200).json({ 
    status: 'ok', 
    message: 'API server is running', 
    timestamp: new Date().toISOString() 
  });
});

// MongoDB Connection
mongoose.connect(process.env.MONGODB_URI)
  .then(() => console.log('Connected to MongoDB Atlas'))
  .catch(err => console.error('MongoDB connection error:', err));

// Firebase auth middleware
const firebaseAuthMiddleware = async (req, res, next) => {
  try {
    const token = req.headers.authorization?.split('Bearer ')[1];
    if (!token) {
      return res.status(401).json({ error: 'No token provided' });
    }

    try {
      // Use the verifyToken helper
      const decodedToken = await verifyToken(token);
      console.log('Firebase token verified for UID:', decodedToken.uid);
      console.log('Decoded token payload:', decodedToken);

      // Set the Firebase user details
      req.firebaseUid = decodedToken.uid;
      req.firebaseEmail = decodedToken.email || '';

      // Check if user exists in any of our collections
      const donor = await DirectDonor.findOne({ firebaseUid: decodedToken.uid });
      if (donor) {
        req.user = donor;
        req.userType = 'donor';
        console.log('User authenticated as donor:', donor._id);
        return next();
      }

      const recipient = await DirectRecipient.findOne({ firebaseUid: decodedToken.uid });
      if (recipient) {
        req.user = recipient;
        req.userType = 'recipient';
        console.log('User authenticated as recipient:', recipient._id);
        return next();
      }

      const volunteer = await DirectVolunteer.findOne({ firebaseUid: decodedToken.uid });
      if (volunteer) {
        req.user = volunteer;
        req.userType = 'volunteer';
        console.log('User authenticated as volunteer:', volunteer._id);
        return next();
      }

      console.log('No user found with Firebase UID:', decodedToken.uid);
      next();
    } catch (error) {
      console.error('Token verification failed:', error);
      return res.status(401).json({ error: 'Invalid token' });
    }
  } catch (err) {
    console.error('Error in auth middleware:', err);
    res.status(401).json({ error: 'Authentication failed' });
  }
};

// API Routes
// Get user profile
app.get('/api/profile', firebaseAuthMiddleware, async (req, res) => {
  try {
    console.log('Profile request received');
    
    // The firebaseAuthMiddleware already checked all collections and set userType
    if (!req.userType) {
      console.log('No user profile found for this Firebase user');
      return res.status(404).json({ error: 'User profile not found' });
    }
    
    console.log(`Found user in ${req.userType} collection:`, req.user._id);
    
    res.status(200).json({
      userType: req.userType,
      profile: req.user
    });
  } catch (err) {
    console.error('Error getting profile:', err);
    res.status(400).json({ error: err.message });
  }
});

// Complete donor registration (after signup)
app.post('/api/donor/register', firebaseAuthMiddleware, upload, async (req, res) => {
  try {
    console.log('=== DEBUG: Direct Donor Registration ===');
    console.log('Request body:', req.body);
    console.log('Request files:', req.files);
    
    if (!req.firebaseUid) {
      console.log('ERROR: No Firebase UID provided in the request');
      return res.status(401).json({ error: 'Authentication required' });
    }

    console.log('Firebase UID:', req.firebaseUid);
    console.log('Email:', req.firebaseEmail);

    // Check if donor already exists
    const existingDonor = await DirectDonor.findOne({ firebaseUid: req.firebaseUid });
    if (existingDonor) {
      console.log('Donor already exists for this user');
      return res.status(400).json({ error: 'Donor profile already exists for this user' });
    }

    // Handle profile image upload
    const profileImage = req.files && req.files['profileImage'] ? 
      `/uploads/${req.files['profileImage'][0].filename}` : '';
    
    console.log('Profile image:', profileImage ? 'Uploaded' : 'Not provided');

    // Create and save new donor document
    try {
      const donor = new DirectDonor({
        firebaseUid: req.firebaseUid,
        email: req.body.email || req.firebaseEmail,
        donorname: req.body.donorname,
        orgName: req.body.orgName,
        identificationId: req.body.identificationId,
        donoraddress: req.body.donoraddress,
        donorcontact: req.body.donorcontact,
        type: req.body.type,
        donorabout: req.body.donorabout || '',
        profileImage,
        donorlocation: {
          latitude: parseFloat(req.body.latitude) || 0,
          longitude: parseFloat(req.body.longitude) || 0
        }
      });

      console.log('Creating donor with data:', {
        name: donor.donorname,
        orgName: donor.orgName,
        identificationId: donor.identificationId
      });

      const savedDonor = await donor.save();
      console.log('Donor saved successfully with ID:', savedDonor._id);
      
      res.status(201).json(savedDonor);
    } catch (validationError) {
      console.error('Validation error:', validationError);
      return res.status(400).json({ 
        error: 'Validation failed',
        details: validationError.message 
      });
    }
  } catch (err) {
    console.error('Error in donor registration:', err);
    res.status(400).json({ error: err.message });
  }
});

// Complete recipient registration (after signup)
app.post('/api/recipient/register', firebaseAuthMiddleware, upload, async (req, res) => {
  try {
    console.log('=== DEBUG: Direct Recipient Registration ===');
    console.log('Request body:', req.body);
    console.log('Request files:', req.files);
    
    if (!req.firebaseUid) {
      console.log('ERROR: No Firebase UID provided in the request');
      return res.status(401).json({ error: 'Authentication required' });
    }

    console.log('Firebase UID:', req.firebaseUid);
    console.log('Email:', req.firebaseEmail);

    // Check if recipient already exists
    const existingRecipient = await DirectRecipient.findOne({ firebaseUid: req.firebaseUid });
    if (existingRecipient) {
      console.log('Recipient already exists for this user');
      return res.status(400).json({ error: 'Recipient profile already exists for this user' });
    }

    // Handle profile image upload
    const profileImage = req.files && req.files['profileImage'] ? 
      `/uploads/${req.files['profileImage'][0].filename}` : '';
    
    console.log('Profile image:', profileImage ? 'Uploaded' : 'Not provided');

    // Create and save new recipient document
    try {
      const recipient = new DirectRecipient({
        firebaseUid: req.firebaseUid,
        email: req.body.email || req.firebaseEmail,
        reciname: req.body.reciname,
        ngoName: req.body.ngoName,
        ngoId: req.body.ngoId,
        reciaddress: req.body.reciaddress,
        recicontact: req.body.recicontact,
        type: req.body.type,
        reciabout: req.body.reciabout || '',
        profileImage,
        recilocation: {
          latitude: parseFloat(req.body.latitude) || 0,
          longitude: parseFloat(req.body.longitude) || 0
        }
      });

      console.log('Creating recipient with data:', {
        name: recipient.reciname,
        ngoName: recipient.ngoName,
        ngoId: recipient.ngoId
      });

      const savedRecipient = await recipient.save();
      console.log('Recipient saved successfully with ID:', savedRecipient._id);
      
      res.status(201).json(savedRecipient);
    } catch (validationError) {
      console.error('Validation error:', validationError);
      return res.status(400).json({ 
        error: 'Validation failed',
        details: validationError.message 
      });
    }
  } catch (err) {
    console.error('Error in recipient registration:', err);
    res.status(400).json({ error: err.message });
  }
});

// Complete volunteer registration (after signup)
app.post('/api/volunteer/register', firebaseAuthMiddleware, upload, async (req, res) => {
  try {
    console.log('=== DEBUG: Direct Volunteer Registration ===');
    console.log('Request headers:', req.headers);
    console.log('Request body:', req.body);
    console.log('Request files:', req.files);
    
    if (!req.firebaseUid) {
      console.log('ERROR: No Firebase UID provided in the request');
      return res.status(401).json({ error: 'Authentication required' });
    }

    console.log('Firebase UID:', req.firebaseUid);
    console.log('Email:', req.firebaseEmail);

    // Check if volunteer already exists
    const existingVolunteer = await DirectVolunteer.findOne({ firebaseUid: req.firebaseUid });
    if (existingVolunteer) {
      console.log('Volunteer already exists for this user');
      return res.status(400).json({ error: 'Volunteer profile already exists for this user' });
    }

    // Handle profile image upload
    const profileImage = req.files && req.files['profileImage'] ? 
      `/uploads/${req.files['profileImage'][0].filename}` : '';
    
    // Handle driving license image upload
    const drivingLicenseImage = req.files && req.files['drivingLicenseImage'] ? 
      `/uploads/${req.files['drivingLicenseImage'][0].filename}` : '';

    console.log('Profile image:', profileImage ? 'Uploaded' : 'Not provided');
    console.log('License image:', drivingLicenseImage ? 'Uploaded' : 'Not provided');

    // Get has vehicle data
    const hasVehicle = req.body.hasVehicle === 'true';
    console.log('Has vehicle:', hasVehicle);

    // Create and save new volunteer document with proper data validation
    try {
      const volunteer = new DirectVolunteer({
        firebaseUid: req.firebaseUid,
        email: req.body.email || req.firebaseEmail,
        volunteerName: req.body.volunteerName,
        aadharID: req.body.aadharID,
        volunteeraddress: req.body.volunteeraddress,
        volunteercontact: req.body.volunteercontact,
        volunteerabout: req.body.volunteerabout || '',
        profileImage,
        hasVehicle,
        vehicleDetails: hasVehicle ? {
          vehicleType: req.body.vehicleType || '',
          vehicleNumber: req.body.vehicleNumber || '',
          drivingLicenseImage
        } : undefined,
        volunteerlocation: {
          latitude: parseFloat(req.body.latitude) || 0,
          longitude: parseFloat(req.body.longitude) || 0
        }
      });

      console.log('Creating volunteer with data:', {
        name: volunteer.volunteerName,
        aadhar: volunteer.aadharID,
        hasVehicle: volunteer.hasVehicle
      });

      const savedVolunteer = await volunteer.save();
      console.log('Volunteer saved successfully with ID:', savedVolunteer._id);
      
      res.status(201).json(savedVolunteer);
    } catch (validationError) {
      console.error('Validation error:', validationError);
      return res.status(400).json({ 
        error: 'Validation failed',
        details: validationError.message 
      });
    }
  } catch (err) {
    console.error('Error in volunteer registration:', err);
    res.status(400).json({ error: err.message });
  }
});

// Donation Management Routes

// Create a new donation
app.post('/api/donations/create', firebaseAuthMiddleware, upload, async (req, res) => {
  try {
    console.log('=== DEBUG: Donation Creation ===');
    console.log('Request body:', req.body);
    console.log('Request files:', req.files);
    
    // Check if user is a donor
    if (req.userType !== 'donor') {
      console.log('User is not a donor:', req.userType);
      return res.status(403).json({ error: 'Only registered donors can create donations' });
    }

    const donor = req.user;
    console.log('User authenticated as donor:', donor._id);

    // Handle food image upload
    const foodImage = req.files && req.files['foodImage'] ? 
      `/uploads/${req.files['foodImage'][0].filename}` : '';
    
    console.log('Food image:', foodImage ? 'Uploaded' : 'Not provided');

    const newDonation = new LiveDonation({
      donorId: donor._id,
      donorName: donor.donorname,
      foodName: req.body.foodName,
      quantity: req.body.quantity,
      description: req.body.description,
      expiryDateTime: new Date(req.body.expiryDateTime),
      timeOfUpload: new Date(),
      foodType: req.body.foodType,
      imageUrl: foodImage,
      location: {
        address: req.body.address || donor.donoraddress,
        latitude: req.body.latitude || donor.donorlocation.latitude,
        longitude: req.body.longitude || donor.donorlocation.longitude
      },
      needsVolunteer: req.body.needsVolunteer === 'true'
    });

    console.log('Creating donation with data:', {
      foodName: newDonation.foodName,
      quantity: newDonation.quantity,
      expiryDateTime: newDonation.expiryDateTime
    });

    const savedDonation = await newDonation.save();
    console.log('Donation saved successfully with ID:', savedDonation._id);
    
    res.status(201).json(savedDonation);
  } catch (err) {
    console.error('Error in donation creation:', err);
    res.status(400).json({ error: err.message });
  }
});

// Get all live donations
app.get('/api/donations/live', async (req, res) => {
  try {
    // Get current time
    const currentTime = new Date();
    
    // Find all donations that haven't expired
    const donations = await LiveDonation.find({
      expiryDateTime: { $gt: currentTime }
    }).sort({ timeOfUpload: -1 });
    
    res.status(200).json(donations);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Accept a donation
app.post('/api/donations/accept/:donationId', firebaseAuthMiddleware, async (req, res) => {
  try {
    console.log('=== DEBUG: Donation Acceptance ===');
    console.log('Request body:', req.body);
    console.log('Donation ID:', req.params.donationId);
    
    // Check if user is a recipient
    if (req.userType !== 'recipient') {
      console.log('User is not a recipient:', req.userType);
      return res.status(403).json({ error: 'Only registered recipients can accept donations' });
    }

    const recipient = req.user;
    console.log('User authenticated as recipient:', recipient._id);

    const donation = await LiveDonation.findById(req.params.donationId);
    if (!donation) {
      console.log('Donation not found with ID:', req.params.donationId);
      return res.status(404).json({ error: 'Donation not found' });
    }

    // Check if donation has expired
    if (new Date(donation.expiryDateTime) < new Date()) {
      console.log('Donation has expired:', donation.expiryDateTime);
      return res.status(400).json({ error: 'This donation has expired' });
    }

    // UPDATED LOGIC: Respect donor's original volunteer preference by default
    // Only override if recipient explicitly provides a different preference
    let needsVolunteer = donation.needsVolunteer; // Default to donor's setting
    
    // If recipient explicitly specifies a preference, use that instead
    if (req.body.needsVolunteer !== undefined) {
      needsVolunteer = req.body.needsVolunteer === true || req.body.needsVolunteer === 'true';
    }
    
    // Set volunteerInfo based on needsVolunteer flag
    let volunteerInfo = needsVolunteer ? "Needs volunteer" : "Self-pickup";
    
    console.log(`Delivery preference: original=${donation.needsVolunteer}, final=${needsVolunteer}`);
    console.log(`Delivery by: ${volunteerInfo}`);

    // Create accepted donation record
    const acceptedDonation = new AcceptedDonation({
      originalDonationId: donation._id,
      acceptedBy: recipient._id,
      recipientName: recipient.reciname,
      donorId: donation.donorId,
      donorName: donation.donorName,
      acceptedAt: new Date(),
      foodName: donation.foodName,
      quantity: donation.quantity,
      description: donation.description,
      expiryDateTime: donation.expiryDateTime,
      timeOfUpload: donation.timeOfUpload,
      foodType: donation.foodType,
      deliveredby: volunteerInfo,
      feedback: "", // Initialize empty feedback
      recipientInfo: {
        recipientId: recipient._id,
        recipientName: recipient.reciname,
        recipientContact: recipient.recicontact,
        recipientAddress: recipient.reciaddress
      },
      volunteerInfo: {
        volunteerId: donation.volunteerInfo?.volunteerId,
        volunteerName: donation.volunteerInfo?.volunteerName,
        volunteerContact: donation.volunteerInfo?.volunteerContact,
        assignedAt: donation.volunteerInfo?.assignedAt
      }
    });

    const savedAcceptedDonation = await acceptedDonation.save();
    console.log('Accepted donation saved with ID:', savedAcceptedDonation._id);
    
    // Remove from live donations
    await LiveDonation.findByIdAndDelete(req.params.donationId);
    console.log('Removed from live donations:', req.params.donationId);
    
    res.status(200).json(savedAcceptedDonation);
  } catch (err) {
    console.error('Error in donation acceptance:', err);
    res.status(400).json({ error: err.message });
  }
});

// Add feedback to an accepted donation
app.post('/api/donations/feedback/:acceptedDonationId', firebaseAuthMiddleware, async (req, res) => {
  try {
    console.log('=== DEBUG: Feedback Addition ===');
    console.log('Request body:', req.body);
    console.log('Accepted Donation ID:', req.params.acceptedDonationId);
    
    // Check if user is a recipient
    if (req.userType !== 'recipient') {
      console.log('User is not a recipient:', req.userType);
      return res.status(403).json({ error: 'Only registered recipients can add feedback' });
    }

    const recipient = req.user;
    console.log('User authenticated as recipient:', recipient._id);

    const acceptedDonation = await AcceptedDonation.findById(req.params.acceptedDonationId);
    if (!acceptedDonation) {
      console.log('Accepted donation not found with ID:', req.params.acceptedDonationId);
      return res.status(404).json({ error: 'Accepted donation not found' });
    }
    
    // Check if the user is the recipient who accepted this donation
    if (acceptedDonation.acceptedBy.toString() !== recipient._id.toString()) {
      console.log('User is not authorized to provide feedback for this donation');
      console.log('Accepted by:', acceptedDonation.acceptedBy);
      console.log('Recipient ID:', recipient._id);
      return res.status(403).json({ error: 'You can only provide feedback for donations you accepted' });
    }

    // Update the feedback
    acceptedDonation.feedback = req.body.feedback;
    const updatedDonation = await acceptedDonation.save();
    console.log('Updated donation with feedback');
    
    res.status(200).json(updatedDonation);
  } catch (err) {
    console.error('Error adding feedback:', err);
    res.status(400).json({ error: err.message });
  }
});

// Clean up expired donations and move them to ExpiredDonations
const runExpiredDonationsCleanup = async () => {
  try {
    const currentTime = new Date();
    console.log('Running expired donations cleanup at:', currentTime);
    
    // Find all expired donations
    const expiredDonations = await LiveDonation.find({
      expiryDateTime: { $lt: currentTime }
    });
    
    console.log(`Found ${expiredDonations.length} expired donations`);
    
    // Move each expired donation to ExpiredDonations collection
    let movedCount = 0;
    for (const donation of expiredDonations) {
      try {
        // Create expired donation record
        const expiredDonation = new ExpiredDonation({
          originalDonationId: donation._id,
          donorId: donation.donorId,
          donorName: donation.donorName,
          foodName: donation.foodName,
          quantity: donation.quantity,
          description: donation.description,
          expiryDateTime: donation.expiryDateTime,
          timeOfUpload: donation.timeOfUpload,
          expiredAt: currentTime,
          foodType: donation.foodType,
          imageUrl: donation.imageUrl,
          location: donation.location,
          needsVolunteer: donation.needsVolunteer,
          status: 'Expired'
        });
        
        await expiredDonation.save();
        
        // Delete from live donations
        await LiveDonation.findByIdAndDelete(donation._id);
        movedCount++;
      } catch (err) {
        console.error('Error moving expired donation:', err);
      }
    }
    
    console.log(`Processed ${expiredDonations.length} expired donations, successfully moved ${movedCount} to ExpiredDonations`);
  } catch (err) {
    console.error('Error in scheduled cleanup process:', err);
  }
};

// Run the cleanup every hour
setInterval(runExpiredDonationsCleanup, 60 * 60 * 1000);
// Also run it once at server startup
setTimeout(runExpiredDonationsCleanup, 5000);

// Manual trigger for expired donations cleanup
app.post('/api/donations/cleanup', async (req, res) => {
  try {
    await runExpiredDonationsCleanup();
    res.status(200).json({ message: 'Expired donations cleanup completed' });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Volunteer accept donation opportunity
app.post('/api/volunteer/donations/accept/:donationId', firebaseAuthMiddleware, async (req, res) => {
  try {
    console.log('=== DEBUG: Volunteer Donation Acceptance ===');
    console.log('Request headers:', req.headers);
    console.log('Request body:', req.body);
    console.log('Donation ID:', req.params.donationId);
    
    // Check if user is a volunteer
    if (req.userType !== 'volunteer') {
      console.log('User is not a volunteer:', req.userType);
      return res.status(403).json({ error: 'Only registered volunteers can accept donations' });
    }

    const volunteer = req.user;
    console.log('User authenticated as volunteer:', volunteer._id);

    const donation = await LiveDonation.findById(req.params.donationId);
    if (!donation) {
      console.log('Donation not found with ID:', req.params.donationId);
      return res.status(404).json({ error: 'Donation not found' });
    }

    // Check if donation has expired
    if (new Date(donation.expiryDateTime) < new Date()) {
      console.log('Donation has expired:', donation.expiryDateTime);
      return res.status(400).json({ error: 'This donation has expired' });
    }
    
    // Check if donation needs a volunteer
    if (!donation.needsVolunteer) {
      console.log('Donation does not need a volunteer');
      return res.status(400).json({ error: 'This donation does not need volunteer assistance' });
    }

    // Check if the donation already has a volunteer assigned
    if (donation.volunteerInfo && donation.volunteerInfo.volunteerId) {
      console.log('Donation already has a volunteer assigned');
      return res.status(400).json({ error: 'This donation already has a volunteer assigned' });
    }

    // Update the donation with volunteer info
    donation.volunteerInfo = {
      volunteerId: volunteer._id,
      volunteerName: volunteer.volunteerName,
      volunteerContact: volunteer.volunteercontact,
      assignedAt: new Date()
    };

    // Save the updated donation
    const updatedDonation = await donation.save();
    console.log('Donation updated with volunteer assignment');
    
    res.status(200).json(updatedDonation);
  } catch (err) {
    console.error('Error in volunteer donation acceptance:', err);
    res.status(400).json({ error: err.message });
  }
});

// Get volunteer opportunities
app.get('/api/volunteer/opportunities', firebaseAuthMiddleware, async (req, res) => {
  try {
    console.log('Volunteer opportunities request received');
    
    // Ensure the user is a volunteer
    if (req.userType !== 'volunteer') {
      console.log('User is not a volunteer:', req.userType);
      return res.status(403).json({ error: 'Only registered volunteers can view delivery opportunities' });
    }

    // Extract the volunteer data from req.user
    const volunteer = req.user;
    console.log('User authenticated as volunteer:', volunteer._id);
    
    // Get current date/time
    const currentTime = new Date();
    
    // Find all live donations that need a volunteer and haven't expired
    const opportunities = await LiveDonation.find({
      needsVolunteer: true,
      expiryDateTime: { $gt: currentTime },
      // Exclude donations that already have a volunteer assigned
      $or: [
        { 'volunteerInfo.volunteerId': { $exists: false } },
        { 'volunteerInfo.volunteerId': null }
      ]
    }).sort({ expiryDateTime: 1 }); // Sort by expiry time, soonest first
    
    console.log(`Found ${opportunities.length} delivery opportunities for volunteers`);
    
    res.status(200).json(opportunities);
  } catch (err) {
    console.error('Error getting volunteer opportunities:', err);
    res.status(400).json({ error: err.message });
  }
});

// NEW ENDPOINT: Get accepted donations that need volunteer delivery
app.get('/api/volunteer/accepted-donations', firebaseAuthMiddleware, async (req, res) => {
  try {
    console.log('Accepted donations for volunteer request received');
    
    // Ensure the user is a volunteer
    if (req.userType !== 'volunteer') {
      console.log('User is not a volunteer:', req.userType);
      return res.status(403).json({ error: 'Only registered volunteers can view accepted donations' });
    }

    // Extract the volunteer data from req.user
    const volunteer = req.user;
    console.log('User authenticated as volunteer:', volunteer._id);
    
    // Find all accepted donations that need volunteer delivery
    const acceptedDonations = await AcceptedDonation.find({
      deliveredby: "Needs volunteer", // Look for this specific string that indicates a volunteer is needed
      // Exclude donations already assigned to a volunteer
      $or: [
        { 'volunteerInfo.volunteerId': { $exists: false } },
        { 'volunteerInfo.volunteerId': null }
      ]
    }).sort({ acceptedAt: -1 }); // Most recently accepted first
    
    console.log(`Found ${acceptedDonations.length} accepted donations that need volunteer delivery`);
    
    res.status(200).json(acceptedDonations);
  } catch (err) {
    console.error('Error getting accepted donations for volunteer:', err);
    res.status(400).json({ error: err.message });
  }
});

// NEW ENDPOINT: Volunteer accepts an accepted donation for delivery
app.post('/api/volunteer/accept-delivery/:acceptedDonationId', firebaseAuthMiddleware, async (req, res) => {
  try {
    console.log('=== DEBUG: Volunteer Accept Delivery ===');
    console.log('Request headers:', req.headers);
    console.log('Accepted donation ID:', req.params.acceptedDonationId);
    
    // Check if user is a volunteer
    if (req.userType !== 'volunteer') {
      console.log('User is not a volunteer:', req.userType);
      return res.status(403).json({ error: 'Only registered volunteers can accept deliveries' });
    }

    const volunteer = req.user;
    console.log('User authenticated as volunteer:', volunteer._id);

    const acceptedDonation = await AcceptedDonation.findById(req.params.acceptedDonationId);
    if (!acceptedDonation) {
      console.log('Accepted donation not found with ID:', req.params.acceptedDonationId);
      return res.status(404).json({ error: 'Accepted donation not found' });
    }

    // Check if this donation needs a volunteer
    if (acceptedDonation.deliveredby !== "Needs volunteer") {
      console.log('This donation does not need a volunteer delivery');
      return res.status(400).json({ error: 'This donation already has a volunteer or is marked for self-pickup' });
    }

    // Check if the donation already has a volunteer assigned
    if (acceptedDonation.volunteerInfo && acceptedDonation.volunteerInfo.volunteerId) {
      console.log('Donation already has a volunteer assigned');
      return res.status(400).json({ error: 'This donation already has a volunteer assigned' });
    }

    // Update the accepted donation with volunteer info
    acceptedDonation.deliveredby = volunteer.volunteerName;
    acceptedDonation.volunteerInfo = {
      volunteerId: volunteer._id,
      volunteerName: volunteer.volunteerName,
      volunteerContact: volunteer.volunteercontact,
      assignedAt: new Date()
    };

    // Save the updated donation
    const updatedDonation = await acceptedDonation.save();
    console.log('Accepted donation updated with volunteer assignment');
    
    res.status(200).json(updatedDonation);
  } catch (err) {
    console.error('Error in volunteer delivery acceptance:', err);
    res.status(400).json({ error: err.message });
  }
});

// Get volunteer donation history
app.get('/api/volunteer/donations/history', firebaseAuthMiddleware, async (req, res) => {
  try {
    console.log('Volunteer history request received');
    
    // Ensure the user is a volunteer
    if (req.userType !== 'volunteer') {
      console.log('User is not a volunteer:', req.userType);
      return res.status(403).json({ error: 'Only registered volunteers can access their history' });
    }

    // Extract the volunteer data from req.user
    const volunteer = req.user;
    console.log('User authenticated as volunteer:', volunteer._id);
    
    // Find all accepted donations where this volunteer was involved
    const acceptedDonations = await AcceptedDonation.find({ 
      deliveredby: volunteer.volunteerName 
    }).sort({ acceptedAt: -1 });
    
    console.log(`Found ${acceptedDonations.length} donations delivered by this volunteer`);
    
    res.status(200).json(acceptedDonations);
  } catch (err) {
    console.error('Error getting volunteer donation history:', err);
    res.status(400).json({ error: err.message });
  }
});

// Get donor donation history
app.get('/api/donor/donations', firebaseAuthMiddleware, async (req, res) => {
  try {
    console.log('=== DEBUG: Donor Donations History ===');
    console.log('Request headers:', req.headers);
    
    // Check if user is a donor
    if (req.userType !== 'donor') {
      console.log('User is not a donor:', req.userType);
      return res.status(403).json({ error: 'Only registered donors can view their donations' });
    }

    const donor = req.user;
    console.log('User authenticated as donor:', donor._id);
    
    // Get live donations by this donor
    const liveDonations = await LiveDonation.find({ donorId: donor._id });
    console.log(`Found ${liveDonations.length} active donations for donor`);
    
    // Get accepted donations that were originally created by this donor
    const acceptedDonations = await AcceptedDonation.find({ donorId: donor._id })
      .sort({ acceptedAt: -1 });
    console.log(`Found ${acceptedDonations.length} accepted donations for donor`);
      
    // Add status field to each accepted donation
    const acceptedDonationsWithStatus = acceptedDonations.map(donation => {
      const donationObj = donation.toObject();
      donationObj.status = 'Accepted';
      return donationObj;
    });
    
    // Get expired donations by this donor
    const expiredDonations = await ExpiredDonation.find({ donorId: donor._id })
      .sort({ expiredAt: -1 });
    console.log(`Found ${expiredDonations.length} expired donations for donor`);
    
    // Combine all donations into one response
    const allDonations = {
      active: liveDonations,
      accepted: acceptedDonationsWithStatus,
      expired: expiredDonations,
      // Also provide a combined list for easier rendering in a single timeline
      combined: [
        ...liveDonations,
        ...acceptedDonationsWithStatus,
        ...expiredDonations
      ].sort((a, b) => {
        // Sort by creation time descending (newest first)
        const dateA = a.timeOfUpload || a.expiredAt || a.acceptedAt;
        const dateB = b.timeOfUpload || b.expiredAt || b.acceptedAt;
        return new Date(dateB) - new Date(dateA);
      })
    };
    
    res.status(200).json(allDonations);
  } catch (err) {
    console.error('Error getting direct donor donations:', err);
    res.status(400).json({ error: err.message });
  }
});

// Get recipient donation history
app.get('/api/recipient/donations', firebaseAuthMiddleware, async (req, res) => {
  try {
    console.log('=== DEBUG: Recipient Donations History ===');
    console.log('Request headers:', req.headers);
    
    // Check if user is a recipient
    if (req.userType !== 'recipient') {
      console.log('User is not a recipient:', req.userType);
      return res.status(403).json({ error: 'Only registered recipients can view their accepted donations' });
    }

    const recipient = req.user;
    console.log('User authenticated as recipient:', recipient._id);
    
    // Get accepted donations by this recipient
    const acceptedDonations = await AcceptedDonation.find({ acceptedBy: recipient._id })
      .sort({ acceptedAt: -1 });
    
    console.log(`Found ${acceptedDonations.length} accepted donations for recipient`);
    
    res.status(200).json(acceptedDonations);
  } catch (err) {
    console.error('Error getting recipient donations:', err);
    res.status(400).json({ error: err.message });
  }
});

// Get pending volunteer deliveries (accepted by recipients and waiting for volunteer)
app.get('/api/volunteer/donations/pending', firebaseAuthMiddleware, async (req, res) => {
  try {
    console.log('=== DEBUG: Volunteer Pending Donations Request ===');
    console.log('Request headers:', req.headers);
    
    // Ensure the user is a volunteer
    if (req.userType !== 'volunteer') {
      console.log('User is not a volunteer:', req.userType);
      return res.status(403).json({ error: 'Only registered volunteers can view pending deliveries' });
    }

    // Extract the volunteer data from req.user
    const volunteer = req.user;
    console.log('User authenticated as volunteer:', volunteer._id);
    
    // Find all accepted donations that need volunteer delivery and aren't assigned yet
    const pendingDeliveries = await AcceptedDonation.find({
      // Find donations where deliveredby is "Needs volunteer" (set when recipient chose to need volunteer help)
      deliveredby: "Needs volunteer",
      // Make sure it's not already assigned to a volunteer
      $or: [
        { 'volunteerInfo.volunteerId': { $exists: false } },
        { 'volunteerInfo.volunteerId': null }
      ]
    }).sort({ acceptedAt: -1 }); // Most recently accepted first
    
    console.log(`Found ${pendingDeliveries.length} pending deliveries for volunteers`);
    
    res.status(200).json(pendingDeliveries);
  } catch (err) {
    console.error('Error getting pending deliveries for volunteer:', err);
    res.status(400).json({ error: err.message });
  }
});

// Simple test endpoint for pending volunteer deliveries
app.get('/api/volunteer/test/pending', async (req, res) => {
  try {
    console.log('=== DEBUG: Test Volunteer Pending Donations Request ===');
    
    // Simple implementation that returns empty array
    // No authentication required, just for testing
    res.status(200).json([]);
  } catch (err) {
    console.error('Error in test endpoint:', err);
    res.status(400).json({ error: err.message });
  }
});

// Alternative endpoint for volunteer pending donations (with a simple path)
app.get('/api/pending-volunteer-deliveries', firebaseAuthMiddleware, async (req, res) => {
  try {
    console.log('==========================================');
    console.log('=== DEBUG: Simple Volunteer Pending Deliveries Request ===');
    console.log('==========================================');
    console.log('Request URL:', req.url);
    console.log('Request method:', req.method);
    console.log('Request headers:', req.headers);
    
    // For this simplified endpoint, don't check the user type
    // Just log the user information
    console.log('User from request:', req.user ? req.user._id : 'No user');
    console.log('User type:', req.userType || 'No user type');
    
    // Find all accepted donations that need volunteer delivery
    const pendingDeliveries = await AcceptedDonation.find({
      deliveredby: "Needs volunteer"
    }).sort({ acceptedAt: -1 });
    
    console.log(`Found ${pendingDeliveries.length} pending deliveries for volunteers`);
    
    // Return array even if empty
    res.status(200).json(pendingDeliveries || []);
  } catch (err) {
    console.error('Error getting simplified pending deliveries for volunteer:', err);
    res.status(400).json({ error: err.message });
  }
});

// DEBUG ENDPOINT: No auth required, returns all pending volunteer deliveries
app.get('/debug/volunteer/pending', async (req, res) => {
  try {
    console.log('==========================================');
    console.log('=== DEBUG: NO AUTH Volunteer Pending Deliveries ===');
    console.log('==========================================');
    console.log('Request URL:', req.url);
    console.log('Request method:', req.method);
    
    // Find all accepted donations that need volunteer delivery
    const pendingDeliveries = await AcceptedDonation.find({
      deliveredby: "Needs volunteer"
    }).sort({ acceptedAt: -1 });
    
    console.log(`Found ${pendingDeliveries.length} pending deliveries for volunteers`);
    
    // Return array even if empty
    res.status(200).json({
      message: "Debug endpoint - No authentication required",
      count: pendingDeliveries.length,
      data: pendingDeliveries || []
    });
  } catch (err) {
    console.error('Error in debug endpoint:', err);
    res.status(400).json({ error: err.message });
  }
});

// DEBUG ENDPOINT: Update an accepted donation to need volunteer delivery
app.get('/debug/update-donation/:id', async (req, res) => {
  try {
    const donationId = req.params.id;
    console.log('==========================================');
    console.log(`=== DEBUG: Updating donation ${donationId} to need volunteer ===`);
    console.log('==========================================');
    
    // Find the donation
    const donation = await AcceptedDonation.findById(donationId);
    if (!donation) {
      return res.status(404).json({ error: 'Donation not found' });
    }
    
    // Update to need volunteer
    donation.deliveredby = "Needs volunteer";
    await donation.save();
    
    console.log(`Updated donation ${donationId} to need volunteer delivery`);
    
    // Return updated donation
    res.status(200).json({
      message: "Donation updated to need volunteer delivery",
      donation: donation
    });
  } catch (err) {
    console.error('Error updating donation:', err);
    res.status(400).json({ error: err.message });
  }
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});