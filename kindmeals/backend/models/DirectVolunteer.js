const mongoose = require('mongoose');

const directVolunteerSchema = new mongoose.Schema({
  firebaseUid: { type: String, required: true, unique: true },
  email: { type: String, required: true, unique: true },
  profileImage: { type: String },
  volunteerName: { type: String, required: true },
  aadharID: { type: String, required: true },
  volunteeraddress: { type: String, required: true },
  volunteercontact: { type: String, required: true },
  volunteerabout: { type: String },
  rating: { type: Number, default: 0 },
  totalRatings: { type: Number, default: 0 },
  hasVehicle: { type: Boolean, default: false },
  vehicleDetails: {
    vehicleType: { type: String },
    vehicleNumber: { type: String },
    drivingLicenseImage: { type: String }
  },
  volunteerlocation: {
    latitude: { type: Number },
    longitude: { type: Number }
  },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('DirectVolunteer', directVolunteerSchema); 