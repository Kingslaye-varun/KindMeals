# KindMeals Flutter App

This is the Flutter front-end application for KindMeals, a food donation platform connecting donors, volunteers, and recipients.

## Setting Up Development Environment

### Prerequisites
- Flutter SDK (2.0 or higher)
- Dart (2.12 or higher)
- Android Studio / VS Code with Flutter plugins
- A Firebase project with Authentication enabled
- A Razorpay test account for payment integration

### Installation Steps

1. **Clone the repository and navigate to the Flutter project**
   ```
   git clone https://github.com/yourusername/kindmeals.git
   cd kindmeals
   ```

2. **Install dependencies**
   ```
   flutter pub get
   ```

3. **Run the app**
   ```
   flutter run
   ```

### App Logo

The app uses a custom logo located at `assets/images/KindMeals_applogo.jpg`. To update the app icon on both Android and iOS platforms:

1. Replace the placeholder file at `assets/images/KindMeals_applogo.jpg` with your logo image
2. Run the following command to generate the app icons:
   ```
   flutter pub run flutter_launcher_icons
   ```

This will update all necessary app icon files for both Android and iOS.

### Firebase Configuration

The app requires Firebase for authentication and data storage. To set up Firebase:

1. Create a project in the [Firebase Console](https://console.firebase.google.com/)
2. Add your app to the Firebase project
3. Download the `google-services.json` file for Android and place it in `android/app/`
4. Download the `GoogleService-Info.plist` file for iOS and place it in `ios/Runner/`

### Environment Configuration

Create a `.env` file in the root directory with the following variables:
```
API_URL=your_backend_api_url
RAZORPAY_KEY_ID=your_razorpay_key_id
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
```

## Project Structure

- `lib/main.dart` - Entry point of the application
- `lib/screens/` - UI screens
- `lib/widgets/` - Reusable UI components
- `lib/models/` - Data models
- `lib/services/` - API services and business logic
- `lib/utils/` - Utility functions and helpers

## Features

- Multi-language support (English, Hindi, Marathi)
- Firebase authentication
- Role-based access control
- Food donation listing and management
- Volunteer matching system
- Razorpay payment integration
- Location services

## Building for Production

### Android

```
flutter build apk --release
```

The APK will be available at `build/app/outputs/flutter-apk/app-release.apk`

### iOS

```
flutter build ios --release
```

Then archive the app using Xcode.

## Troubleshooting

- If you encounter Firebase related errors, ensure the `google-services.json` file is properly placed and the dependencies are up to date
- For Razorpay issues, verify your API keys and check the implementation in the services directory

## Backend Integration

The backend API is deployed at: [API URL]
You can find the backend repository at: [Backend Repository URL]

## Contact

For any queries regarding the Flutter application, please contact:
[Your Contact Information]
