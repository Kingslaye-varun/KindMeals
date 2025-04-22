import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/register_volunteer_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/volunteer/volunteer_dashboard.dart';
import 'screens/charity/charity_list_screen.dart';
import 'dart:developer' as developer;
import 'services/firebase_service.dart';
import 'services/api_service.dart';
import 'utils/env_config.dart';
import 'utils/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load environment variables
    await dotenv.load(fileName: '.env');
    developer.log('Environment variables loaded successfully');

    // Validate environment variables
    if (!EnvConfig.validateEnvironment()) {
      developer
          .log('Warning: Some required environment variables are not set!');
    }

    // Initialize Firebase only if it hasn't been initialized yet
    if (Firebase.apps.isEmpty) {
      developer.log('Initializing Firebase...');
      await Firebase.initializeApp();
      developer.log('Firebase initialized successfully');
    } else {
      developer.log('Firebase already initialized');
    }
    
    // Load saved language preference
    await AppLocalizations.localizationsService.loadSavedLanguage();
    
  } catch (e) {
    developer.log('Error during initialization: $e', error: e);
    rethrow;
  }

  runApp(
    ChangeNotifierProvider.value(
      value: AppLocalizations.localizationsService,
      child: const KindMealsApp(),
    ),
  );
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
    // Get current locale from the localization service
    final currentLocale = Provider.of<AppLocalizationsService>(context).currentLocale;

    return MaterialApp(
      title: 'KindMeals',
      debugShowCheckedModeBanner: false,
      
      // Localization setup
      locale: currentLocale,
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('hi', ''), // Hindi
        Locale('mr', ''), // Marathi
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
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
              ? const _InitialLoadingScreen()
              : const WelcomeScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/register/volunteer': (context) => const RegisterVolunteerScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/volunteer/dashboard': (context) => const VolunteerDashboardScreen(),
        '/charities': (context) => const CharityListScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle any undefined routes by going to the welcome screen if not signed in
        return MaterialPageRoute(
          builder: (context) =>
              _isUserSignedIn ? const DashboardScreen() : const WelcomeScreen(),
        );
      },
    );
  }
}

// Screen to check user type and redirect accordingly
class _InitialLoadingScreen extends StatefulWidget {
  const _InitialLoadingScreen({Key? key}) : super(key: key);

  @override
  State<_InitialLoadingScreen> createState() => _InitialLoadingScreenState();
}

class _InitialLoadingScreenState extends State<_InitialLoadingScreen> {
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _checkUserTypeAndRedirect();
  }

  Future<void> _checkUserTypeAndRedirect() async {
    try {
      final userProfile = await _apiService.getDirectUserProfile();
      final userType = userProfile['userType'] ?? '';

      if (mounted) {
        if (userType.toLowerCase() == 'volunteer') {
          Navigator.pushReplacementNamed(context, '/volunteer/dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      }
    } catch (e) {
      print('Error checking user type: $e');
      // Default to regular dashboard if error occurs
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Loading your profile...'),
          ],
        ),
      ),
    );
  }
}
