import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/welcome_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/register_volunteer_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/volunteer/volunteer_dashboard.dart';
import 'dart:developer' as developer;
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase only if it hasn't been initialized yet
    if (Firebase.apps.isEmpty) {
      developer.log('Initializing Firebase...');
      await Firebase.initializeApp();
      developer.log('Firebase initialized successfully');
    } else {
      developer.log('Firebase already initialized');
    }
  } catch (e) {
    developer.log('Error initializing Firebase: $e', error: e);
    rethrow;
  }

  runApp(const KindMealsApp());
}

class KindMealsApp extends StatefulWidget {
  const KindMealsApp({super.key});

  @override
  State<KindMealsApp> createState() => _KindMealsAppState();
}

class _KindMealsAppState extends State<KindMealsApp> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isUserSignedIn = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _checkUserAuthentication();
    // Listen for auth state changes
    _firebaseService.authStateChanges.listen((user) {
      if (mounted) {
        setState(() {
          _isUserSignedIn = user != null;
        });
      }
    });
  }

  // Check if user is already signed in
  Future<void> _checkUserAuthentication() async {
    try {
      final isSignedIn = _firebaseService.isSignedIn;
      developer.log(
          'User authentication status: ${isSignedIn ? 'Signed In' : 'Not Signed In'}');

      if (mounted) {
        setState(() {
          _isUserSignedIn = isSignedIn;
          _isInitializing = false;
        });
      }
    } catch (e) {
      developer.log('Error checking authentication: $e', error: e);
      if (mounted) {
        setState(() {
          _isUserSignedIn = false;
          _isInitializing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KindMeals',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      home: _isInitializing
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : _isUserSignedIn
              ? const DashboardScreen()
              : const WelcomeScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/register/volunteer': (context) => const RegisterVolunteerScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/volunteer/dashboard': (context) => const VolunteerDashboardScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle any undefined routes
        return MaterialPageRoute(
          builder: (context) =>
              _isUserSignedIn ? const DashboardScreen() : const WelcomeScreen(),
        );
      },
    );
  }
}
