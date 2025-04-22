const mongoose = require('mongoose');

const liveDonationSchema = new mongoose.Schema({
  donorId: { 
    type: mongoose.Schema.Types.ObjectId, 
    required: true,
    ref: 'DirectDonor'
  },
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
  volunteerInfo: {
    volunteerId: { type: mongoose.Schema.Types.ObjectId, ref: 'DirectVolunteer' },
    volunteerName: { type: String },
    volunteerContact: { type: String },
    assignedAt: { type: Date }
  }
});

module.exports = mongoose.model('LiveDonation', liveDonationSchema); 