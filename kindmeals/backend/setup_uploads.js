/**
 * Setup Uploads Directory Script
 * 
 * This script ensures the uploads directory is properly set up
 * and handles migration of uploads between environments if needed.
 */

const fs = require('fs');
const path = require('path');

// Get uploads directory path
const uploadsDir = process.env.UPLOADS_DIR || path.join(__dirname, 'uploads');
console.log('Setting up uploads directory at:', uploadsDir);

// Ensure the uploads directory exists
if (!fs.existsSync(uploadsDir)) {
  console.log('Creating uploads directory');
  fs.mkdirSync(uploadsDir, { recursive: true });
}

// Create a .gitkeep file to ensure the directory is tracked in git
const gitkeepPath = path.join(uploadsDir, '.gitkeep');
if (!fs.existsSync(gitkeepPath)) {
  fs.writeFileSync(gitkeepPath, '');
  console.log('Created .gitkeep file in uploads directory');
}

// Log the files in the uploads directory
console.log('Files in uploads directory:');
try {
  const files = fs.readdirSync(uploadsDir);
  if (files.length === 0) {
    console.log('No files found in uploads directory');
  } else {
    for (const file of files) {
      const filePath = path.join(uploadsDir, file);
      const stats = fs.statSync(filePath);
      console.log(`- ${file} (${(stats.size / 1024).toFixed(2)} KB)`);
    }
  }
} catch (err) {
  console.error('Error reading uploads directory:', err);
}

console.log('Uploads directory setup completed'); 