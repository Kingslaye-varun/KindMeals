const mongoose = require('mongoose');

const directRecipientSchema = new mongoose.Schema({
  firebaseUid: { type: String, required: true, unique: true },
  email: { type: String, required: true, unique: true },
  profileImage: { type: String },
  reciname: { type: String, required: true },
  ngoName: { type: String, required: true },
  ngoId: { type: String, required: true },
  reciaddress: { type: String, required: true },
  recicontact: { type: String, required: true },
  type: { type: String, required: true },
  reciabout: { type: String },
  recilocation: {
    latitude: { type: Number },
    longitude: { type: Number }
  },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('DirectRecipient', directRecipientSchema); 