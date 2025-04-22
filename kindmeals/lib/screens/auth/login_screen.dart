import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../utils/app_localizations.dart';
import 'register_screen.dart';
import 'register_volunteer_screen.dart';
import 'forgot_password_screen.dart';
import '../../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firebaseService = FirebaseService();
  final _apiService = ApiService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (kDebugMode) {
          print('=== DEBUG: Starting Login Process ===');
        }
        if (kDebugMode) {
          print('Email: ${_emailController.text.trim()}');
        }

        // Authenticate with Firebase
        final userCredential =
            await _firebaseService.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
        if (kDebugMode) {
          print('=== DEBUG: Firebase Auth Successful ===');
        }
        if (kDebugMode) {
          print('User UID: ${userCredential.user?.uid}');
        }
        if (kDebugMode) {
          print('User Email: ${userCredential.user?.email}');
        }

        // Force token refresh to ensure we have a valid token
        final token = await userCredential.user?.getIdToken(true);
        if (kDebugMode) {
          print('=== DEBUG: Token Refresh ===');
        }
        if (kDebugMode) {
          print('New token obtained: ${token != null}');
        }

        // Verify if the user exists in our direct database collections
        try {
          if (kDebugMode) {
            print('=== DEBUG: Checking Direct Profile ===');
          }
          // Check profile without waiting
          final profile = await _apiService.getDirectUserProfile();
          if (kDebugMode) {
            print('Direct profile check successful: $profile');
          }

          // Store user type for redirection
          final userType = profile['userType'] ?? '';
          if (kDebugMode) {
            print('Detected user type: $userType');
          }

          if (mounted) {
            final localizations = AppLocalizations.of(context);
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localizations.translate('login_successful')),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
              ),
            );

            // Redirect based on user type
            if (userType.toLowerCase() == 'volunteer') {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/volunteer/dashboard',
                (route) => false,
              );
            } else {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/dashboard',
                (route) => false,
              );
            }
          }
        } catch (profileError) {
          if (kDebugMode) {
            print('=== DEBUG: Direct Profile Check Failed ===');
          }
          if (kDebugMode) {
            print('Profile check error: $profileError');
          }
          // Fallback to default dashboard if profile check fails
          if (mounted) {
            final localizations = AppLocalizations.of(context);
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localizations.translate('login_successful')),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
              ),
            );

            Navigator.pushNamedAndRemoveUntil(
              context,
              '/dashboard',
              (route) => false,
            );
          }
        }
      } catch (e) {
        if (mounted) {
          String errorMessage = 'Login failed';

          if (e.toString().contains('user-not-found')) {
            errorMessage =
                'No user found with this email. Please register first.';
          } else if (e.toString().contains('wrong-password')) {
            errorMessage = 'Incorrect password. Please try again.';
          } else if (e.toString().contains('too-many-requests')) {
            errorMessage = 'Too many login attempts. Please try again later.';
          } else {
            errorMessage = e.toString().replaceAll('Exception: ', '');
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await _firebaseService.signInWithGoogle();

      if (mounted) {
        final localizations = AppLocalizations.of(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.translate('login_successful')),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/dashboard',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('login')), 
        centerTitle: true
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: localizations.translate('email'),
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.translate('enter_email');
                    }
                    if (!value.contains('@')) {
                      return localizations.translate('valid_email');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: localizations.translate('password'),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.translate('enter_password');
                    }
                    if (value.length < 6) {
                      return localizations.translate('password_length');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: Text(localizations.translate('forgot_password')),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          localizations.translate('login'),
                          style: const TextStyle(fontSize: 18, color: Colors.white),
                        ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(localizations.translate('or')),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  icon: Image.asset(
                    'assets/images/google_logo.png',
                    height: 24,
                  ),
                  label: Text(localizations.translate('continue_with_google')),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(localizations.translate('dont_have_account')),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(localizations.translate('register')),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(localizations.translate('want_to_help')),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const RegisterVolunteerScreen(),
                          ),
                        );
                      },
                      child: Text(localizations.translate('register_as_volunteer')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
