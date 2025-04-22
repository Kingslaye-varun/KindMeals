const mongoose = require('mongoose');
require('dotenv').config();

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI)
  .then(() => console.log('Connected to MongoDB Atlas'))
  .catch(err => console.error('MongoDB connection error:', err));

// Set timezone to India Standard Time (IST)
process.env.TZ = 'Asia/Kolkata';
console.log(`Timezone set to: ${process.env.TZ} (${new Date().toString()})`);

// Define the LiveDonation schema
const liveDonationSchema = new mongoose.Schema({
  donorId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  donorName: { type: String, required: true },
  foodName: { type: String, required: true },
  quantity: { type: Number, required: true },
  description: { type: String, required: true },
  expiryDateTime: { type: Date, required: true },
  timeOfUpload: { type: Date, default: Date.now },
  foodType: {
    type: String,
    enum: ['veg', 'nonveg', 'jain'],
    required: true,
  },
  imageUrl: String,
  location: {
    address: { type: String, required: true },
    latitude: Number,
    longitude: Number,
  },
  needsVolunteer: { type: Boolean, default: false },
});

// Create the model
const LiveDonation = mongoose.model('LiveDonation', liveDonationSchema);

// Get current time
const currentTime = new Date();
console.log('Current time:', currentTime);

// Find all donations
LiveDonation.find()
  .then(donations => {
    console.log('All donations:', donations);
    
    // Find non-expired donations
    return LiveDonation.find({
      expiryDateTime: { $gt: currentTime }
    });
  })
  .then(activeDonations => {
    console.log('Active donations:', activeDonations);
    mongoose.disconnect();
  })
  .catch(err => {
    console.error('Error:', err);
    mongoose.disconnect();
  }); 