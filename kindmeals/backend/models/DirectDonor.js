const mongoose = require('mongoose');

const directDonorSchema = new mongoose.Schema({
  firebaseUid: { type: String, required: true, unique: true },
  email: { type: String, required: true, unique: true },
  profileImage: { type: String },
  donorname: { type: String, required: true },
  orgName: { type: String, required: true },
  identificationId: { type: String, required: true },
  donoraddress: { type: String, required: true },
  donorcontact: { type: String, required: true },
  type: { type: String, required: true },
  donorabout: { type: String },
  donorlocation: {
    latitude: { type: Number },
    longitude: { type: Number }
  },
  createdAt: { type: Date, default: Date.now }
}, { timestamps: true });

module.exports = mongoose.model('DirectDonor', directDonorSchema); 