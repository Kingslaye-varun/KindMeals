const mongoose = require('mongoose');

const finalDonationSchema = new mongoose.Schema({
  // Original donation data
  originalDonationId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'LiveDonation'
  },
  acceptedDonationId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'AcceptedDonation'
  },
  
  // Donor information
  donorId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'DirectDonor'
  },
  donorName: {
    type: String,
    required: true
  },
  donorContact: String,
  donorAddress: String,
  
  // Recipient information
  recipientId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'DirectRecipient'
  },
  recipientName: {
    type: String,
    required: true
  },
  recipientContact: String,
  recipientAddress: String,
  
  // Volunteer information
  volunteerId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'DirectVolunteer'
  },
  volunteerName: {
    type: String,
    required: true
  },
  volunteerContact: String,
  
  // Food details
  foodName: {
    type: String,
    required: true
  },
  foodType: {
    type: String,
    enum: ['veg', 'nonveg', 'jain'],
    required: true
  },
  quantity: {
    type: Number,
    required: true
  },
  description: String,
  imageUrl: String,
  
  // Delivery information
  pickupDateTime: {
    type: Date,
    default: Date.now
  },
  deliveryDateTime: {
    type: Date
  },
  deliveryStatus: {
    type: String,
    enum: ['picked_up', 'in_transit', 'delivered'],
    default: 'picked_up'
  },
  
  // Feedback
  donorFeedback: {
    rating: Number,
    comment: String,
    timestamp: Date
  },
  recipientFeedback: {
    rating: Number,
    comment: String,
    timestamp: Date
  },
  volunteerFeedback: {
    rating: Number,
    comment: String,
    timestamp: Date
  },
  
  // Timestamps
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

// Update the 'updatedAt' field on document changes
finalDonationSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

module.exports = mongoose.model('FinalDonation', finalDonationSchema); 