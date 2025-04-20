const mongoose = require('mongoose');

const expiredDonationSchema = new mongoose.Schema({
  originalDonationId: { type: mongoose.Schema.Types.ObjectId, ref: 'LiveDonation' },
  donorId: { type: mongoose.Schema.Types.ObjectId, ref: 'DirectDonor', required: true },
  donorName: { type: String, required: true },
  foodName: { type: String, required: true },
  quantity: { type: Number, required: true },
  description: { type: String, required: true },
  expiryDateTime: { type: Date, required: true },
  timeOfUpload: { type: Date },
  expiredAt: { type: Date, default: Date.now },
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
  status: { type: String, default: 'Expired' }
});

module.exports = mongoose.model('ExpiredDonation', expiredDonationSchema); 