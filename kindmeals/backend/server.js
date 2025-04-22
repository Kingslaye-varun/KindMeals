const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const multer = require('multer');
const path = require('path');
const { admin, verifyToken } = require('./firebase-admin');
require('dotenv').config();
const fs = require('fs');

// Import models
const LiveDonation = require('./models/LiveDonation');
const AcceptedDonation = require('./models/AcceptedDonation');
const FinalDonation = require('./models/FinalDonation');
const ExpiredDonation = require('./models/ExpiredDonation');
const DirectDonor = require('./models/DirectDonor');
const DirectRecipient = require('./models/DirectRecipient');
const DirectVolunteer = require('./models/DirectVolunteer');
const Notification = require('./models/Notification');

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 5000;

// Set timezone to India Standard Time (IST)
process.env.TZ = 'Asia/Kolkata';
console.log(`Server timezone set to: ${process.env.TZ} (${new Date().toString()})`);

// Configure Mongoose to use the correct timezone for dates
mongoose.set('toJSON', {
  virtuals: true,
  transform: (doc, converted) => {
    if (converted.expiryDateTime) {
      // Ensure expiryDateTime is in the correct timezone
      const date = new Date(converted.expiryDateTime);
      converted.expiryDateTime = date.toISOString();
    }
    if (converted.timeOfUpload) {
      // Ensure timeOfUpload is in the correct timezone
      const date = new Date(converted.timeOfUpload);
      converted.timeOfUpload = date.toISOString();
    }
    if (converted.acceptedAt) {
      // Ensure acceptedAt is in the correct timezone
      const date = new Date(converted.acceptedAt);
      converted.acceptedAt = date.toISOString();
    }
    // Handle any other date fields as needed
    return converted;
  }
});

// Configure uploads directory
// Use environment variable for uploads path if available, otherwise use default
const uploadsDir = process.env.UPLOADS_DIR || path.join(__dirname, 'uploads');
console.log('Uploads directory path:', uploadsDir);

// Ensure uploads directory exists
if (!fs.existsSync(uploadsDir)) {
  console.log('Creating uploads directory');
  fs.mkdirSync(uploadsDir, { recursive: true });

  // Create a .gitkeep file to ensure the directory is tracked in git
  const gitkeepPath = path.join(uploadsDir, '.gitkeep');
  if (!fs.existsSync(gitkeepPath)) {
    fs.writeFileSync(gitkeepPath, '');
    console.log('Created .gitkeep file in uploads directory');
  }
}

// Middleware
app.use(express.json());
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
}));

// Configure static file serving for uploads
// Make sure this path is accessible and persisted in production
app.use('/uploads', express.static(uploadsDir));
console.log('Uploads directory configured at:', uploadsDir);

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

    // Print timezone information for debugging
    console.log('Current timezone:', process.env.TZ);
    console.log('Current server time:', new Date().toString());
    console.log('Current server time (ISO):', new Date().toISOString());

    // Parse and correct the expiry date time from the request
    console.log('Input expiryDateTime from client:', req.body.expiryDateTime);
    let expiryDateTime;
    try {
      // Parse the date directly - it will be interpreted in the server's timezone (IST)
      expiryDateTime = new Date(req.body.expiryDateTime);
      console.log('Parsed expiryDateTime (server local time):', expiryDateTime.toString());
      console.log('Parsed expiryDateTime (ISO format):', expiryDateTime.toISOString());
    } catch (e) {
      console.error('Error parsing date:', e);
      expiryDateTime = new Date(); // Default to current time if parsing fails
      expiryDateTime.setHours(expiryDateTime.getHours() + 1); // Default expiry 1 hour from now
    }

    const newDonation = new LiveDonation({
      donorId: donor._id,
      donorName: donor.donorname,
      foodName: req.body.foodName,
      quantity: req.body.quantity,
      description: req.body.description,
      expiryDateTime: expiryDateTime,
      timeOfUpload: new Date(), // Current time in server's timezone (IST)
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
      expiryDateTime: newDonation.expiryDateTime,
      expiryDateTimeISO: newDonation.expiryDateTime.toISOString()
    });

    const savedDonation = await newDonation.save();
    console.log('Donation saved successfully with ID:', savedDonation._id);
    console.log('Saved expiryDateTime:', savedDonation.expiryDateTime);
    console.log('Saved expiryDateTime (ISO):', savedDonation.expiryDateTime.toISOString());

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

    // Get full donor information
    const donor = await DirectDonor.findById(donation.donorId);
    if (!donor) {
      console.log('Warning: Donor not found with ID:', donation.donorId);
    }

    // Create accepted donation record with enhanced donor info
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
      imageUrl: donation.imageUrl,
      deliveredby: volunteerInfo,
      feedback: "", // Initialize empty feedback
      // Enhanced donor info
      donorInfo: {
        donorId: donation.donorId,
        donorName: donation.donorName,
        donorContact: donor ? donor.donorcontact : '',
        donorAddress: donation.location && donation.location.address ? donation.location.address : (donor ? donor.donoraddress : '')
      },
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

    // Increment volunteer's delivery count
    try {
      // Find the volunteer and increment their delivery count
      const updatedVolunteer = await DirectVolunteer.findByIdAndUpdate(
        volunteer._id,
        { $inc: { deliveries: 1 } }, // Increment deliveries field by 1
        { new: true } // Return the updated document
      );
      console.log(`Incremented delivery count for volunteer ${volunteer.volunteerName} to ${updatedVolunteer.deliveries}`);
    } catch (updateErr) {
      console.error('Error updating volunteer delivery count:', updateErr);
      // Continue execution even if the update fails
    }

    // Create notification for donor
    try {
      const donorNotification = {
        userId: acceptedDonation.donorId,
        userType: 'donor',
        title: 'Volunteer Assigned',
        message: `${volunteer.volunteerName} has accepted to deliver your donation "${acceptedDonation.foodName}" to the recipient.`,
        type: 'volunteer_assigned',
        relatedDonationId: acceptedDonation._id,
        isRead: false,
        createdAt: new Date()
      };

      // Add to notifications collection if it exists, otherwise log
      if (mongoose.connection.models['Notification']) {
        await mongoose.connection.models['Notification'].create(donorNotification);
        console.log('Donor notification created');
      } else {
        console.log('Would create donor notification:', donorNotification);
      }
    } catch (notificationErr) {
      console.error('Error creating donor notification:', notificationErr);
      // Continue execution even if notification fails
    }

    // Create notification for recipient
    try {
      const recipientNotification = {
        userId: acceptedDonation.acceptedBy,
        userType: 'recipient',
        title: 'Volunteer Assigned',
        message: `${volunteer.volunteerName} has accepted to deliver your requested donation "${acceptedDonation.foodName}".`,
        type: 'volunteer_assigned',
        relatedDonationId: acceptedDonation._id,
        isRead: false,
        createdAt: new Date()
      };

      // Add to notifications collection if it exists, otherwise log
      if (mongoose.connection.models['Notification']) {
        await mongoose.connection.models['Notification'].create(recipientNotification);
        console.log('Recipient notification created');
      } else {
        console.log('Would create recipient notification:', recipientNotification);
      }
    } catch (notificationErr) {
      console.error('Error creating recipient notification:', notificationErr);
      // Continue execution even if notification fails
    }

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
    let acceptedDonations = await AcceptedDonation.find({
      // Only show donations where the volunteer is actually assigned or the deliveredby field has the volunteer's name
      $or: [
        { deliveredby: volunteer.volunteerName },
        { 'volunteerInfo.volunteerId': volunteer._id }
      ]
    })
      .sort({ acceptedAt: -1 });

    console.log(`Found ${acceptedDonations.length} donations delivered by this volunteer`);

    // Enhance donor information if needed
    const enhancedDonations = await Promise.all(acceptedDonations.map(async (donation) => {
      const donationObj = donation.toObject();

      // If donor info is missing, try to fetch it
      if (!donationObj.donorInfo || !donationObj.donorInfo.donorContact) {
        try {
          const donor = await DirectDonor.findById(donationObj.donorId);
          if (donor) {
            donationObj.donorInfo = {
              donorId: donor._id,
              donorName: donor.donorName,
              donorContact: donor.donorcontact,
              donorAddress: donor.donoraddress
            };
          }
        } catch (err) {
          console.log(`Error fetching donor info for donation ${donationObj._id}:`, err);
        }
      }

      return donationObj;
    }));

    res.status(200).json(enhancedDonations);
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

    // Enhanced: Populate donor and recipient information, especially coordinates
    const enhancedDeliveries = await Promise.all(pendingDeliveries.map(async (donation) => {
      const donationObj = donation.toObject();

      // Initialize location coordinates in the response
      if (!donationObj.locationCoordinates) {
        donationObj.locationCoordinates = {
          donor: { latitude: null, longitude: null },
          recipient: { latitude: null, longitude: null }
        };
      }

      // Check if donor info is missing or incomplete
      const hasDonorContactInfo = donationObj.donorInfo &&
        (donationObj.donorInfo.donorContact || donationObj.donorInfo.donorcontact);
      const hasDonorAddressInfo = donationObj.donorInfo &&
        (donationObj.donorInfo.donorAddress || donationObj.donorInfo.donoraddress);

      // Get donor info including coordinates
      try {
        console.log(`Fetching complete donor info for donation: ${donationObj._id}`);
        // Find the donor to get complete information
        const donor = await DirectDonor.findById(donationObj.donorId);
        if (donor) {
          // Make sure donorInfo exists
          if (!donationObj.donorInfo) {
            donationObj.donorInfo = {};
          }

          // Add donor details to ensure both camelCase and lowercase field names are provided
          donationObj.donorInfo.donorName = donor.donorname;
          donationObj.donorInfo.donorname = donor.donorname;
          donationObj.donorInfo.donorContact = donor.donorcontact;
          donationObj.donorInfo.donorcontact = donor.donorcontact;
          donationObj.donorInfo.donorAddress = donor.donoraddress;
          donationObj.donorInfo.donoraddress = donor.donoraddress;

          // Store donor coordinates for the Google Maps directions
          if (donor.donorlocation && donor.donorlocation.latitude && donor.donorlocation.longitude) {
            donationObj.locationCoordinates.donor.latitude = donor.donorlocation.latitude;
            donationObj.locationCoordinates.donor.longitude = donor.donorlocation.longitude;
          }

          console.log(`Enhanced donor info for donation: ${donationObj._id}`);
        }
      } catch (err) {
        console.log(`Error enhancing donor info for donation ${donationObj._id}:`, err);
      }

      // Get recipient info including coordinates
      try {
        console.log(`Fetching complete recipient info for donation: ${donationObj._id}`);
        // Find the recipient to get complete information
        const recipient = await DirectRecipient.findById(donationObj.acceptedBy);
        if (recipient) {
          // Make sure recipientInfo exists
          if (!donationObj.recipientInfo) {
            donationObj.recipientInfo = {};
          }

          // Add recipient details
          donationObj.recipientInfo.recipientName = recipient.reciname;
          donationObj.recipientInfo.recipientContact = recipient.recicontact;
          donationObj.recipientInfo.recipientAddress = recipient.reciaddress;

          // Store recipient coordinates for the Google Maps directions
          if (recipient.recilocation && recipient.recilocation.latitude && recipient.recilocation.longitude) {
            donationObj.locationCoordinates.recipient.latitude = recipient.recilocation.latitude;
            donationObj.locationCoordinates.recipient.longitude = recipient.recilocation.longitude;
          }

          console.log(`Enhanced recipient info for donation: ${donationObj._id}`);
        }
      } catch (err) {
        console.log(`Error enhancing recipient info for donation ${donationObj._id}:`, err);
      }

      return donationObj;
    }));

    res.status(200).json(enhancedDeliveries);
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

    // Enhanced: Populate donor and recipient information, especially coordinates
    const enhancedDeliveries = await Promise.all(pendingDeliveries.map(async (donation) => {
      const donationObj = donation.toObject();

      // Initialize location coordinates in the response
      if (!donationObj.locationCoordinates) {
        donationObj.locationCoordinates = {
          donor: { latitude: null, longitude: null },
          recipient: { latitude: null, longitude: null }
        };
      }

      // Check if donor info is missing or incomplete
      const hasDonorContactInfo = donationObj.donorInfo &&
        (donationObj.donorInfo.donorContact || donationObj.donorInfo.donorcontact);
      const hasDonorAddressInfo = donationObj.donorInfo &&
        (donationObj.donorInfo.donorAddress || donationObj.donorInfo.donoraddress);

      // Get donor info including coordinates
      try {
        console.log(`Fetching complete donor info for donation: ${donationObj._id}`);
        // Find the donor to get complete information
        const donor = await DirectDonor.findById(donationObj.donorId);
        if (donor) {
          // Make sure donorInfo exists
          if (!donationObj.donorInfo) {
            donationObj.donorInfo = {};
          }

          // Add donor details to ensure both camelCase and lowercase field names are provided
          donationObj.donorInfo.donorName = donor.donorname;
          donationObj.donorInfo.donorname = donor.donorname;
          donationObj.donorInfo.donorContact = donor.donorcontact;
          donationObj.donorInfo.donorcontact = donor.donorcontact;
          donationObj.donorInfo.donorAddress = donor.donoraddress;
          donationObj.donorInfo.donoraddress = donor.donoraddress;

          // Store donor coordinates for the Google Maps directions
          if (donor.donorlocation && donor.donorlocation.latitude && donor.donorlocation.longitude) {
            donationObj.locationCoordinates.donor.latitude = donor.donorlocation.latitude;
            donationObj.locationCoordinates.donor.longitude = donor.donorlocation.longitude;
          }

          console.log(`Enhanced donor info for donation: ${donationObj._id}`);
        }
      } catch (err) {
        console.log(`Error enhancing donor info for donation ${donationObj._id}:`, err);
      }

      // Get recipient info including coordinates
      try {
        console.log(`Fetching complete recipient info for donation: ${donationObj._id}`);
        // Find the recipient to get complete information
        const recipient = await DirectRecipient.findById(donationObj.acceptedBy);
        if (recipient) {
          // Make sure recipientInfo exists
          if (!donationObj.recipientInfo) {
            donationObj.recipientInfo = {};
          }

          // Add recipient details
          donationObj.recipientInfo.recipientName = recipient.reciname;
          donationObj.recipientInfo.recipientContact = recipient.recicontact;
          donationObj.recipientInfo.recipientAddress = recipient.reciaddress;

          // Store recipient coordinates for the Google Maps directions
          if (recipient.recilocation && recipient.recilocation.latitude && recipient.recilocation.longitude) {
            donationObj.locationCoordinates.recipient.latitude = recipient.recilocation.latitude;
            donationObj.locationCoordinates.recipient.longitude = recipient.recilocation.longitude;
          }

          console.log(`Enhanced recipient info for donation: ${donationObj._id}`);
        }
      } catch (err) {
        console.log(`Error enhancing recipient info for donation ${donationObj._id}:`, err);
      }

      return donationObj;
    }));

    // Return array even if empty
    res.status(200).json(enhancedDeliveries || []);
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

// Get user notifications
app.get('/api/notifications', firebaseAuthMiddleware, async (req, res) => {
  try {
    console.log('=== DEBUG: Get User Notifications ===');

    // Get user info from middleware
    const userId = req.user._id;
    const userType = req.userType;

    console.log(`Getting notifications for ${userType} with ID: ${userId}`);

    // Fetch notifications for this user
    const notifications = await Notification.find({
      userId: userId,
      userType: userType
    })
      .sort({ createdAt: -1 }) // Newest first
      .limit(50);  // Limit to 50 most recent notifications

    console.log(`Found ${notifications.length} notifications`);

    res.status(200).json(notifications);
  } catch (err) {
    console.error('Error getting notifications:', err);
    res.status(400).json({ error: err.message });
  }
});

// Mark notification as read
app.put('/api/notifications/:notificationId/mark-read', firebaseAuthMiddleware, async (req, res) => {
  try {
    console.log('=== DEBUG: Mark Notification Read ===');
    console.log('Notification ID:', req.params.notificationId);

    // Get user info from middleware
    const userId = req.user._id;

    // Find the notification
    const notification = await Notification.findById(req.params.notificationId);

    if (!notification) {
      return res.status(404).json({ error: 'Notification not found' });
    }

    // Verify the notification belongs to this user
    if (notification.userId.toString() !== userId.toString()) {
      console.log('Unauthorized: Notification does not belong to this user');
      return res.status(403).json({ error: 'Unauthorized: This notification does not belong to you' });
    }

    // Update as read
    notification.isRead = true;
    await notification.save();

    console.log('Notification marked as read');

    res.status(200).json({ success: true, notification });
  } catch (err) {
    console.error('Error marking notification as read:', err);
    res.status(400).json({ error: err.message });
  }
});

// NEW ENDPOINT: Get top volunteers for leaderboard
app.get('/api/volunteers/leaderboard', async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 10;
    console.log('=== DEBUG: Fetching top volunteers for leaderboard ===');

    // Get volunteers sorted by deliveries (deliveries completed)
    const volunteers = await DirectVolunteer.find({})
      .sort({ deliveries: -1 }) // Sort by deliveries field
      .limit(limit)
      .select('volunteerName profileImage deliveries totalRatings rating');

    console.log(`Found ${volunteers.length} top volunteers`);

    // Log each volunteer for debugging
    volunteers.forEach(v => {
      console.log(`Volunteer: ${v.volunteerName}, Deliveries: ${v.deliveries || 0}, Ratings: ${v.totalRatings || 0}`);
    });

    res.status(200).json(volunteers);
  } catch (err) {
    console.error('Error getting top volunteers:', err);
    res.status(400).json({ error: err.message });
  }
});

// NEW ENDPOINT: Get top donors for leaderboard
app.get('/api/donors/leaderboard', async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 10;
    console.log('=== DEBUG: Fetching top donors for leaderboard ===');

    // First, count donations for each donor across all collections
    // Count Live Donations
    const liveDonations = await LiveDonation.aggregate([
      { $group: { _id: '$donorId', count: { $sum: 1 } } }
    ]);

    // Count Accepted Donations
    const acceptedDonations = await AcceptedDonation.aggregate([
      { $group: { _id: '$donorId', count: { $sum: 1 } } }
    ]);

    // Count Expired Donations
    const expiredDonations = await ExpiredDonation.aggregate([
      { $group: { _id: '$donorId', count: { $sum: 1 } } }
    ]);

    // Count Final Donations
    const finalDonations = await FinalDonation.aggregate([
      { $group: { _id: '$donorId', count: { $sum: 1 } } }
    ]);

    // Combine all donor counts
    const donorCounts = {};

    // Helper function to add counts to the combined object
    const addCounts = (donationArray) => {
      donationArray.forEach(item => {
        if (!donorCounts[item._id]) {
          donorCounts[item._id] = 0;
        }
        donorCounts[item._id] += item.count;
      });
    };

    // Add all donation counts
    addCounts(liveDonations);
    addCounts(acceptedDonations);
    addCounts(expiredDonations);
    addCounts(finalDonations);

    console.log(`Combined donation counts for ${Object.keys(donorCounts).length} donors`);

    // Convert to array and sort by count
    const sortedDonors = Object.entries(donorCounts)
      .map(([donorId, count]) => ({ donorId, count }))
      .sort((a, b) => b.count - a.count)
      .slice(0, limit);

    // Fetch donor details for each donor
    const donorsWithDetails = await Promise.all(sortedDonors.map(async (donor) => {
      try {
        const donorDetails = await DirectDonor.findById(donor.donorId);
        if (donorDetails) {
          return {
            _id: donor.donorId,
            donationCount: donor.count,
            donorname: donorDetails.donorname,
            orgName: donorDetails.orgName,
            profileImage: donorDetails.profileImage
          };
        } else {
          return {
            _id: donor.donorId,
            donationCount: donor.count,
            donorname: 'Unknown Donor',
            orgName: '',
            profileImage: null
          };
        }
      } catch (err) {
        console.error(`Error fetching details for donor ${donor.donorId}:`, err);
        return {
          _id: donor.donorId,
          donationCount: donor.count,
          donorname: 'Unknown Donor',
          orgName: '',
          profileImage: null
        };
      }
    }));

    console.log(`Returning ${donorsWithDetails.length} top donors`);

    res.status(200).json(donorsWithDetails);
  } catch (err) {
    console.error('Error getting top donors:', err);
    res.status(400).json({ error: err.message });
  }
});

// NEW ENDPOINT: Get donation statistics
app.get('/api/donations/statistics', async (req, res) => {
  try {
    // Count total donations in different collections
    const liveDonations = await LiveDonation.countDocuments({});
    const acceptedDonations = await AcceptedDonation.countDocuments({});
    const expiredDonations = await ExpiredDonation.countDocuments({});
    const finalDonations = await FinalDonation.countDocuments({});

    // Count total volunteers and donors
    const volunteerCount = await DirectVolunteer.countDocuments({});
    const donorCount = await DirectDonor.countDocuments({});
    const recipientCount = await DirectRecipient.countDocuments({});

    // Calculate meals saved (assuming each donation serves multiple people)
    const totalMealsSaved = finalDonations * 10; // Assuming each donation serves 10 people on average

    // Return statistics
    res.status(200).json({
      totalDonations: liveDonations + acceptedDonations + expiredDonations + finalDonations,
      liveDonations,
      acceptedDonations,
      expiredDonations,
      finalDonations,
      volunteerCount,
      donorCount,
      recipientCount,
      totalMealsSaved
    });
  } catch (err) {
    console.error('Error getting donation statistics:', err);
    res.status(400).json({ error: err.message });
  }
});

// Update donor profile
app.put('/api/donor/profile', firebaseAuthMiddleware, upload, async (req, res) => {
  try {
    console.log('=== DEBUG: Update Donor Profile ===');
    console.log('Request body:', req.body);
    console.log('Request files:', req.files);

    if (!req.firebaseUid) {
      console.log('ERROR: No Firebase UID provided in the request');
      return res.status(401).json({ error: 'Authentication required' });
    }

    // Check if user is a donor
    if (req.userType !== 'donor') {
      console.log('User is not a donor:', req.userType);
      return res.status(403).json({ error: 'Only registered donors can update donor profiles' });
    }

    const donor = req.user;
    console.log('Updating donor with ID:', donor._id);

    // Prepare update object
    const updates = {};

    // Update text fields if provided
    if (req.body.donorname) updates.donorname = req.body.donorname;
    if (req.body.orgName) updates.orgName = req.body.orgName;
    if (req.body.donoraddress) updates.donoraddress = req.body.donoraddress;
    if (req.body.donorcontact) updates.donorcontact = req.body.donorcontact;
    if (req.body.donorabout) updates.donorabout = req.body.donorabout;

    // Update location if provided
    if (req.body.latitude || req.body.longitude) {
      updates.donorlocation = {
        latitude: parseFloat(req.body.latitude) || donor.donorlocation?.latitude || 0,
        longitude: parseFloat(req.body.longitude) || donor.donorlocation?.longitude || 0
      };
    }

    // Update profile image if provided
    if (req.files && req.files['profileImage']) {
      updates.profileImage = `/uploads/${req.files['profileImage'][0].filename}`;
      console.log('New profile image:', updates.profileImage);
    }

    // Update donor in database
    const updatedDonor = await DirectDonor.findByIdAndUpdate(
      donor._id,
      { $set: updates },
      { new: true, runValidators: true }
    );

    console.log('Donor profile updated successfully');
    res.status(200).json(updatedDonor);
  } catch (err) {
    console.error('Error updating donor profile:', err);
    res.status(400).json({ error: err.message });
  }
});

// Update recipient profile
app.put('/api/recipient/profile', firebaseAuthMiddleware, upload, async (req, res) => {
  try {
    console.log('=== DEBUG: Update Recipient Profile ===');
    console.log('Request body:', req.body);
    console.log('Request files:', req.files);

    if (!req.firebaseUid) {
      console.log('ERROR: No Firebase UID provided in the request');
      return res.status(401).json({ error: 'Authentication required' });
    }

    // Check if user is a recipient
    if (req.userType !== 'recipient') {
      console.log('User is not a recipient:', req.userType);
      return res.status(403).json({ error: 'Only registered recipients can update recipient profiles' });
    }

    const recipient = req.user;
    console.log('Updating recipient with ID:', recipient._id);

    // Prepare update object
    const updates = {};

    // Update text fields if provided
    if (req.body.reciname) updates.reciname = req.body.reciname;
    if (req.body.ngoName) updates.ngoName = req.body.ngoName;
    if (req.body.ngoId) updates.ngoId = req.body.ngoId;
    if (req.body.reciaddress) updates.reciaddress = req.body.reciaddress;
    if (req.body.recicontact) updates.recicontact = req.body.recicontact;
    if (req.body.reciabout) updates.reciabout = req.body.reciabout;

    // Update location if provided
    if (req.body.latitude || req.body.longitude) {
      updates.recilocation = {
        latitude: parseFloat(req.body.latitude) || recipient.recilocation?.latitude || 0,
        longitude: parseFloat(req.body.longitude) || recipient.recilocation?.longitude || 0
      };
    }

    // Update profile image if provided
    if (req.files && req.files['profileImage']) {
      updates.profileImage = `/uploads/${req.files['profileImage'][0].filename}`;
      console.log('New profile image:', updates.profileImage);
    }

    // Update recipient in database
    const updatedRecipient = await DirectRecipient.findByIdAndUpdate(
      recipient._id,
      { $set: updates },
      { new: true, runValidators: true }
    );

    console.log('Recipient profile updated successfully');
    res.status(200).json(updatedRecipient);
  } catch (err) {
    console.error('Error updating recipient profile:', err);
    res.status(400).json({ error: err.message });
  }
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});