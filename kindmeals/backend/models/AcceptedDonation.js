const mongoose = require('mongoose');

const acceptedDonationSchema = new mongoose.Schema({
  originalDonationId: { type: mongoose.Schema.Types.ObjectId, ref: 'LiveDonation', required: true },
  acceptedBy: { 
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'DirectRecipient'
  },
  recipientName: { type: String, required: true },
  donorId: { 
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'DirectDonor'
  },
  donorName: { type: String, required: true },
  acceptedAt: { type: Date, default: Date.now },
  foodName: { type: String, required: true },
  quantity: { type: Number, required: true },
  description: { type: String, required: true },
  expiryDateTime: { type: Date, required: true },
  timeOfUpload: { type: Date },
  foodType: {
    type: String,
    enum: ['veg', 'nonveg', 'jain'],
    required: true,
  },
  deliveredby: { type: String, required: true },
  feedback: { type: String, default: '' },
  recipientInfo: {
    recipientId: { type: mongoose.Schema.Types.ObjectId, ref: 'DirectRecipient' },
    recipientName: { type: String },
    recipientContact: { type: String },
    recipientAddress: { type: String }
  },
  volunteerInfo: {
    volunteerId: { type: mongoose.Schema.Types.ObjectId, ref: 'DirectVolunteer' },
    volunteerName: { type: String },
    volunteerContact: { type: String },
    assignedAt: { type: Date }
  }
});

module.exports = mongoose.model('AcceptedDonation', acceptedDonationSchema); 