# KindMeals

KindMeals is a food donation app that connects donors, volunteers, and recipients to reduce food waste and help those in need. This project was developed as part of the Semester IV Field Project.

## About the Project

KindMeals aims to address the dual challenge of food waste and hunger by creating a platform where:
- Restaurants and individuals can donate excess food
- Volunteers can sign up to deliver donations
- Those in need can receive food
- Charities can receive direct donations and support

## Features

- User authentication with email and Google Sign-In
- Role-based access for donors, volunteers, and recipients
- Real-time food donation listings
- Location-based volunteer matching
- In-app donation tracking
- Digital payment integration with Razorpay
- Multi-language support (English, Hindi, Marathi)
- Impact statistics and leaderboards

## Technology Stack

- Frontend: Flutter
- Backend: Node.js with Express
- Database: MongoDB
- Authentication: Firebase Auth
- Payment Integration: Razorpay
- Geolocation Services: Google Maps API
- Push Notifications: Firebase Cloud Messaging

## Getting Started

### Prerequisites

- Flutter SDK (2.0 or higher)
- Dart (2.12 or higher)
- Android Studio or VS Code with Flutter plugins
- Firebase account
- Razorpay account for payment integration

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/tanaya2005/kindmeals.git
   cd kindmeals
   ```

2. Install dependencies:
   ```
   flutter pub get
   ```

3. Create a `.env` file in the root directory with your configuration (see `.env.example` for format)

4. Run the app:
   ```
   flutter run
   ```

## Backend Integration

The backend for this application is already deployed on Render and is ready to use. The API endpoints are pre-configured in the app.

## APK Release

The APK will soon be released on GitHub Releases. Follow the repository for updates.

## Project Documentation

Detailed project documentation can be found in the `Final_Field_Project_Report.pdf` which contains comprehensive information about:
- Project objectives
- System architecture
- Database schema
- User flows
- API documentation
- Testing results

## Contributors

- Varun Rahatgaonkar
- Atharva Pingale
- Tanaya Jain

## License

This project is licensed under the MIT License - see the LICENSE file for details.
