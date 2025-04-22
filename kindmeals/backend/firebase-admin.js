const admin = require('firebase-admin');
require('dotenv').config();

// Initialize firebase admin
if (!admin.apps.length) {
  try {
    // Check if we have a service account configuration
    if (process.env.FIREBASE_SERVICE_ACCOUNT) {
      admin.initializeApp({
        credential: admin.credential.cert(JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT)),
      });
      console.log('Firebase Admin initialized successfully with service account');
    } else if (process.env.FIREBASE_ENABLE_FALLBACK === 'true') {
      // Initialize with a minimal config in fallback mode
      admin.initializeApp({
        projectId: 'kindmeals-app',
        // This will create a minimal app without actual Firebase services
      });
      console.log('Firebase Admin initialized in fallback mode');
    } else {
      throw new Error('No Firebase configuration provided');
    }
  } catch (error) {
    console.error('Error initializing Firebase Admin:', error);
  }
}

// Special module for token verification in fallback mode
const verifyToken = async (token) => {
  if (process.env.FIREBASE_ENABLE_FALLBACK === 'true') {
    // In fallback mode, we need to extract the UID from the token
    try {
      // The token is a JWT, we need to decode it to get the UID
      const base64Url = token.split('.')[1];
      const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
      // Node.js doesn't have atob, so we use Buffer instead
      const jsonPayload = Buffer.from(base64, 'base64').toString('utf8');

      const payload = JSON.parse(jsonPayload);
      console.log('Decoded token payload:', payload);
      
      if (!payload.user_id && !payload.sub) {
        throw new Error('No user_id found in token');
      }
      
      // Return the user_id or sub as the UID
      return { uid: payload.user_id || payload.sub };
    } catch (error) {
      console.error('Error decoding token in fallback mode:', error);
      throw new Error('Invalid token format');
    }
  } else {
    // In normal mode, verify the token properly
    return await admin.auth().verifyIdToken(token);
  }
};

module.exports = { admin, verifyToken }; 