# KindMeals

A food donation app that connects donors, volunteers, and recipients to reduce food waste and help those in need.

## Environment Setup

This project uses environment variables for sensitive data like API keys. Before running the app, follow these steps:

1. Create a `.env` file in the root directory of the project
2. Add the following variables to your `.env` file:

```
# KindMeals API Keys
RAZORPAY_KEY_ID=your_razorpay_key_id
RAZORPAY_KEY_SECRET=your_razorpay_key_secret

# Firebase Configuration
FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_AUTH_DOMAIN=your_firebase_auth_domain
FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_STORAGE_BUCKET=your_firebase_storage_bucket
FIREBASE_MESSAGING_SENDER_ID=your_firebase_messaging_sender_id
FIREBASE_APP_ID=your_firebase_app_id

# Other Configuration
API_URL=your_api_url
```

3. Replace `your_razorpay_key_id`, etc. with your actual API keys and configuration values.

## Important Note

- The `.env` file is listed in `.gitignore` and should never be committed to version control.
- For production deployments, use a secure method to set environment variables.

## Getting Started

1. Clone the repository
2. Set up the `.env` file as described above
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the app

## Features

- Donate food to recipients in need
- Track donations and impact
- Volunteer for food delivery
- Support charities through direct donations
- Leaderboards to recognize top donors and volunteers

## Backend

This app requires a backend service to function properly. The backend code is available in the `backend` directory.
