const cloudinary = require('cloudinary').v2;
require('dotenv').config();

// Configure Cloudinary with credentials from environment variables
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
  secure: true
});

// Upload function that returns a promise
const uploadToCloudinary = (filePath, folder = 'kindmeals') => {
  return new Promise((resolve, reject) => {
    cloudinary.uploader.upload(
      filePath, 
      { 
        folder: folder,
        resource_type: 'auto'
      },
      (error, result) => {
        if (error) {
          console.error('Cloudinary upload error:', error);
          reject(error);
        } else {
          console.log('Cloudinary upload success:', result.public_id);
          resolve(result);
        }
      }
    );
  });
};

module.exports = {
  cloudinary,
  uploadToCloudinary
}; 