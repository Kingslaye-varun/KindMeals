// ignore_for_file: equal_keys_in_map

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Supported languages
enum AppLanguage {
  english,
  hindi,
  marathi,
  gujarati,
  tamil,
  telugu,
  kannada,
  malayalam,
  bengali
}

// Language codes for each supported language
final Map<AppLanguage, String> languageCodes = {
  AppLanguage.english: 'en',
  AppLanguage.hindi: 'hi',
  AppLanguage.marathi: 'mr',
  AppLanguage.gujarati: 'gu',
  AppLanguage.tamil: 'ta',
  AppLanguage.telugu: 'te',
  // AppLanguage.kannada: 'kn',
  // AppLanguage.malayalam: 'ml',
  AppLanguage.bengali: 'bn',
};

// Get the AppLanguage from a language code
AppLanguage getLanguageFromCode(String code) {
  return languageCodes.entries
      .firstWhere((entry) => entry.value == code,
          orElse: () => const MapEntry(AppLanguage.english, 'en'))
      .key;
}

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  // Helper method to keep the code in the widgets concise
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // Static member to have a simple access to the delegate from the MaterialApp
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // Translation maps for each supported language
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Common strings
      'app_name': 'KindMeals',
      'app_slogan': 'Share Food, Share Love',
      'get_started': 'Get Started',
      'continue': 'Continue',
      'inspirational_quote':
          'When we give cheerfully and accept gratefully, everyone is blessed.',
      'no_image_available': 'No image available',

      // Dashboard screen
      'welcome_to': 'Welcome to',
      'top_volunteers': 'Top Volunteers',
      'top_donors': 'Top Donors',
      'view_full_leaderboard': 'View Full Leaderboard',
      'reviews_feedback': 'Reviews & Feedback',
      'view_all_reviews': 'View All Reviews',
      'support_a_cause': 'Support a Cause',
      'donate_to_kindmeals': 'Donate to KindMeals',
      'donate_subtitle': 'Support our mission to reduce food waste and hunger',
      'donate_now': 'Donate Now',
      'view_all_charities': 'View All Charities',
      'name': 'Name',
      'deliveries': 'Deliveries',
      'meals': 'Meals',
      'no_volunteers_found': 'No volunteers found',
      'no_donors_found': 'No donors found',
      'refresh_data': 'Refresh Data',

      // Volunteers Screen
      'volunteers': 'Volunteers',
      'volunteer_leaderboard': 'Volunteer Leaderboard',
      'total_volunteers': 'Total Volunteers',
      'total_deliveries': 'Total Deliveries',
      'avg_deliveries': 'Avg Deliveries',
      'rank': 'Rank',
      'volunteer': 'Volunteer',
      'deliveries_made': 'deliveries made',
      'become_volunteer': 'Become a Volunteer',

      // Motivational content
      'feed_smile': 'Feed a Smile Today',
      'meal_brighten': 'One meal can brighten someone\'s whole day',
      'share_table': 'Share Your Table',
      'no_hunger': 'No one should go hungry in our community',
      'food_waste': 'Food Waste to Food Taste',
      'rescue_food': 'Rescue surplus food and feed those in need',
      'donate_what': 'Donate What You Can',
      'every_contribution': 'Every contribution makes a difference',
      'hunger_stat': '1 in 9 People Go Hungry',
      'change_stat': 'Your donation can change this statistic',

      // Social Media Footer
      'privacy_policy': 'Privacy Policy',
      'terms_of_service': 'Terms of Service',
      'contact_us': 'Contact Us',
      'all_rights_reserved': '© 2025 KindMeals. All rights reserved.',

      // Profile Screen
      'profile': 'Profile',
      'try_again': 'Try Again',
      'edit': 'Edit',
      'logout': 'Log Out',
      'logout_confirm': 'Are you sure you want to log out?',
      'cancel': 'Cancel',
      'error_loading_profile': 'Error loading profile',
      'change_language': 'Change Language',
      'personal_information': 'Personal Information',
      'contact_information': 'Contact Information',
      'organization_information': 'Organization Information',
      'about': 'About',
      'full_name': 'Full Name',
      'email_address': 'Email Address',
      'contact_number': 'Contact Number',
      'address': 'Address',
      'organization_name': 'Organization Name',
      'organization_id': 'Organization ID',
      'description': 'Description',
      'no_description': 'No description available',
      'profile_image_updated': 'Profile image updated successfully',
      'failed_upload_image': 'Failed to upload profile image:',
      'logout_failed': 'Logout failed:',

      // Language screen
      'select_language': 'Select Language',
      'choose_language': 'Choose your preferred language',

      // Login screen
      'login': 'Login',
      'email': 'Email',
      'password': 'Password',
      'forgot_password': 'Forgot Password?',
      'or': 'OR',
      'continue_with_google': 'Continue with Google',
      'dont_have_account': 'Don\'t have an account?',
      'register': 'Register',
      'want_to_help': 'Want to help people?',
      'register_as_volunteer': 'Register as Volunteer',
      'login_successful': 'Login successful!',
      'google_signup': 'Continue with Google',

      // Register screen
      'aadhar_id': 'Aadhar ID / Restaurant ID',
      'address': 'Address / Location (Click to detect)',
      'contact': 'Contact Number',
      'about': 'About',
      'org_name': 'Organization Name / Individual',
      'user_type': 'Type',
      'profile_pic': 'Add Profile Picture',
      'change_profile_pic': 'Change Profile Picture',
      'registration_successful': 'Registration successful!',
      'get_address': 'Please get your address by clicking the location button',
      'type': 'Type',
      'contact_number': 'Contact Number',

      // Register volunteer screen
      'volunteer_registration': 'Volunteer Registration',
      'full_name': 'Full Name',
      'aadhar_number': 'Aadhar Number',
      'address_click_detect': 'Address (Click to detect)',
      'about_yourself': 'About Yourself',
      'have_vehicle': 'Do you have a vehicle for deliveries?',
      'vehicle_type': 'Vehicle Type',
      'vehicle_number': 'Vehicle Number',
      'driving_license': 'Driving License Image',
      'upload_license': 'Upload License Image',

      // Logout
      'logging_out': 'Logging out...',
      'error_logout': 'Error logging out: ',

      // Validation messages
      'enter_email': 'Please enter your email',
      'valid_email': 'Please enter a valid email',
      'enter_password': 'Please enter your password',
      'password_length': 'Password must be at least 6 characters',
      'enter_name': 'Please enter your name',
      'enter_id': 'Please enter your ID',
      'enter_contact': 'Please enter your contact number',
      'valid_contact': 'Please enter a valid contact number',
      'enter_about': 'Please enter about yourself',
      'enter_org_name': 'Please enter organization name or individual',
      'select_type': 'Please select a type',
      'select_vehicle_type': 'Please select a vehicle type',
      'enter_vehicle_number': 'Please enter your vehicle number',

      // Charity related translations
      'donate_to_charity': 'Donate to Charity',
      'error': 'Error',
      'no_charities_available': 'No Charities Available',
      'check_back_later': 'Check back later for charity donation opportunities',
      'refresh': 'Refresh',
      'make_a_difference': 'Make a Difference',
      'contribution_help':
          'Your contribution can help those in need. Choose a charity below to donate.',
      'food_relief': 'Food Relief',
      'from': 'From',
      'make_a_donation': 'Make a Donation',
      'donation_history': 'Donation History',
      'select_amount': 'Select Amount',
      'custom_amount': 'Custom Amount',
      'your_information': 'Your Information',
      'full_name': 'Full Name',
      'email': 'Email',
      'phone_number': 'Phone Number',
      'request_tax_benefits': 'Request Tax Benefits (80G)',
      'pan_card_number': 'PAN Card Number',
      'required_for_tax_benefits': 'Required for tax benefits',
      'payment_method': 'Payment Method',
      'credit_debit_card': 'Credit/Debit Card',
      'net_banking': 'Net Banking',
      'upi_gpay_phonepe': 'UPI / Google Pay / PhonePe',
      'initializing_payment': 'Initializing payment...',
      'processing_donation': 'Processing your donation...',
      'thank_you': 'Thank You!',
      'donation_successful': 'Your donation was successful!',
      'amount': 'Amount',
      'date': 'Date',
      'transaction_id': 'Transaction ID',
      'charity': 'Charity',
      'contribution_difference':
          'Your contribution will make a real difference in someone\'s life.',
      'view_history': 'View History',
      'done': 'Done',
      'information_secure':
          'Your information is secure and will only be used for donation purposes.',
      'support_our_cause': 'Support our cause',

      // Post Donation Screen
      'post_donation': 'Post Donation',
      'refresh_authentication': 'Refresh Authentication',
      'sign_out_sign_in_again': 'Sign Out & Sign In Again',
      'go_to_profile': 'Go to Profile',
      'go_back': 'Go Back',
      'refresh_profile_note':
          'Note: If you just registered, please log out and log back in to refresh your profile status.',
      'refresh_status': 'Refresh Status',
      'food_name': 'Food Name',
      'please_enter_food_name': 'Please enter food name',
      'quantity': 'Quantity',
      'please_enter_quantity': 'Please enter quantity',
      'please_enter_valid_number': 'Please enter a valid number',
      'description': 'Description',
      'please_enter_description': 'Please enter description',
      'food_type': 'Food Type',
      'veg': 'Vegetarian',
      'nonveg': 'Non-Vegetarian',
      'jain': 'Jain',
      'please_select_food_type': 'Please select food type',
      'pickup_address_click_detect': 'Pickup Address (Click to detect)',
      'get_current_location': 'Get Current Location',
      'please_get_pickup_address':
          'Please get pickup address by clicking the location button',
      'location': 'Location',
      'expiry_date_time': 'Expiry Date & Time',
      'select_expiry_date_time': 'Select expiry date and time',
      'please_select_expiry_date_time':
          'Please select a valid expiry date and time',
      'local_time': 'Local time',
      'need_volunteer_for_delivery': 'Need Volunteer for Delivery',
      'volunteer_note':
          'Note: When your donation is accepted by a recipient, they will be able to request a volunteer for delivery.',
      'donation_posted_successfully': 'Donation posted successfully!',
      'failed_to_post_donation': 'Failed to post donation. Please try again.',
      'authentication_error_refresh':
          'Authentication error: Please sign out and sign in again to refresh your credentials.',
      'authentication_error': 'Authentication Error',
      'auth_error_details':
          'Your donor profile could not be verified. This could happen if:\n\n1. You recently registered and your profile is not fully synced\n2. Your authentication token has expired\n\nPlease sign out and sign back in to refresh your credentials.',
      'ok': 'OK',
      'sign_out_now': 'Sign Out Now',

      // Donor history translations
      'no_donations_found': 'No donations found',
      'create_donations_to_see': 'Create a donation to see it here',
      'create_donation': 'Create Donation',
      'no_donation_history_found':
          'No donation history found. Please try again later.',
      'sign_in_to_view_donations':
          'Please sign in to view your donation history.',
      'all': 'All',
      'signed_out': 'Signed Out',
      'sign_out_confirmation': 'Are you sure you want to sign out?',
      'sign_out': 'Sign Out',
      'yes': 'Yes',
      'no': 'No',

      // View donations screen
      'available_donations': 'Available Donations',
      'filter_donations': 'Filter Donations',
      'food_type': 'Food Type',
      'sort_by': 'Sort By',
      'sort_by_expiry': 'Expiry Date',
      'sort_by_distance': 'Distance',
      'sort_by_quantity': 'Quantity',
      'maximum_distance': 'Maximum Distance',
      'km': 'km',
      'show_needs_volunteer': 'Show donations that need volunteer help',
      'reset': 'Reset',
      'apply_filters': 'Apply Filters',
      'search_food': 'Search food...',
      'filter': 'Filter',
      'needs_volunteer': 'Needs Volunteer',
      'no_available_donations': 'No available donations found',
      'no_results_for': 'No results found for',
      'check_back_later': 'Check back later for new donations',
      'try_changing_filters': 'Try changing your filters to see more donations',
      'clear_filters': 'Clear Filters',
      'profile_not_found_recipient':
          'Your profile was not found. Make sure you are registered as a recipient to view donations.',
      'unable_to_load_donations':
          'Unable to load donations at this time. Please try again later.',
      'retry': 'Retry',
      'go_to_profile': 'Go to Profile',
      'no_image_available': 'No image available',
      'expiring_soon': 'Expiring Soon',
      'quantity': 'Quantity',
      'servings': 'servings',
      'tap_to_read_more': 'Tap to read more',
      'donor': 'Donor',
      'call_donor': 'Call Donor',
      'get_directions': 'Get Directions',
      'expires': 'Expires',
      'view_details': 'View Details',
      'unknown_location': 'Unknown Location',
      'anonymous': 'Anonymous',
      'error': 'Error',
      'refresh': 'Refresh',

      // Recipient history screen
      'filter_donation_history': 'Filter Donation History',
      'time_period': 'Time Period',
      'today': 'Today',
      'yesterday': 'Yesterday',
      'days_ago': 'days ago',
      'this_week': 'This Week',
      'this_month': 'This Month',
      'time': 'Time',
      'type': 'Type',
      'accept_donations_to_see': 'Accept donations to see them here',
      'browse_donations': 'Browse Donations',
      'no_donations_match_criteria': 'No donations match your criteria',
      'try_adjusting_filters':
          'Try adjusting your filters to see more donations',
      'clear_all_filters': 'Clear All Filters',
      'update_location': 'Update Location',
      'location_updated_donations_refreshed':
          'Location updated. Donations refreshed with distance information.',
      'could_not_get_location':
          'Could not get your location. Please ensure location services are enabled.',
      'error_updating_location': 'Error updating location',
      'donated_by': 'Donated by',
      'accepted_on': 'Accepted on',
      'at': 'at',
      'delivery_method': 'Delivery method',
      'self_pickup': 'Self-pickup',
      'add_feedback': 'Add Feedback',
      'edit_feedback': 'Edit Feedback',
      'your_feedback': 'Your Feedback',
      'share_experience_hint': 'Share your experience about this donation...',
      'feedback_submitted_successfully': 'Feedback submitted successfully!',
      'error_submitting_feedback': 'Error submitting feedback',
      'distance': 'Distance',
      'submit': 'Submit',

      // Donation detail screen
      'donation_details': 'Donation Details',
      'unknown_food': 'Unknown Food',
      'no_description_available': 'No description available',
      'unknown': 'Unknown',
      'servings': 'servings',
      'anonymous_donor': 'Anonymous Donor',
      'donor_information': 'Donor Information',
      'donor': 'Donor',
      'location': 'Location',
      'food_description': 'Food Description',
      'expires': 'Expires',
      'exact_expiry': 'Exact expiry',
      'delivery_options': 'Delivery Options',
      'need_volunteer_assistance': 'Need volunteer assistance?',
      'yes_request_volunteer': 'Yes, request volunteer help for delivery',
      'no_pickup_myself': 'No, I will pick up this donation myself',
      'changed_from_original':
          'You changed this from the donor\'s original setting',
      'using_donor_preference': 'Using donor\'s preferred delivery option',
      'accept_donation': 'Accept this donation',
      'donation_accepted_with_volunteer':
          'Donation accepted successfully. A volunteer will assist with delivery.',
      'donation_accepted_self_pickup':
          'Donation accepted successfully. You will need to collect this yourself.',
    },
    'hi': {
      // Common strings
      'app_name': 'काइंडमील्स',
      'app_slogan': 'भोजन बांटें, प्यार बांटें',
      'get_started': 'शुरू करें',
      'continue': 'जारी रखें',
      'inspirational_quote':
          'जब हम खुशी से देते हैं और कृतज्ञता से स्वीकार करते हैं, तो हर कोई आशीर्वादित होता है।',
      'no_image_available': 'कोई छवि उपलब्ध नहीं',

      // Dashboard screen
      'welcome_to': 'स्वागत है',
      'top_volunteers': 'शीर्ष स्वयंसेवक',
      'top_donors': 'शीर्ष दानदाता',
      'view_full_leaderboard': 'पूरी लीडरबोर्ड देखें',
      'reviews_feedback': 'समीक्षाएँ और प्रतिक्रिया',
      'view_all_reviews': 'सभी समीक्षाएँ देखें',
      'support_a_cause': 'एक कारण का समर्थन करें',
      'donate_to_kindmeals': 'काइंडमील्स को दान करें',
      'donate_subtitle':
          'खाद्य अपशिष्ट और भूख को कम करने के हमारे मिशन का समर्थन करें',
      'donate_now': 'अभी दान करें',
      'view_all_charities': 'सभी धर्मार्थ संस्थाएँ देखें',
      'name': 'नाम',
      'deliveries': 'डिलीवरी',
      'meals': 'भोजन',
      'no_volunteers_found': 'कोई स्वयंसेवक नहीं मिला',
      'no_donors_found': 'कोई दानदाता नहीं मिला',
      'refresh_data': 'डेटा रीफ्रेश करें',

      // Volunteers Screen
      'volunteers': 'स्वयंसेवक',
      'volunteer_leaderboard': 'स्वयंसेवक लीडरबोर्ड',
      'total_volunteers': 'कुल स्वयंसेवक',
      'total_deliveries': 'कुल डिलीवरी',
      'avg_deliveries': 'औसत डिलीवरी',
      'rank': 'रैंक',
      'volunteer': 'स्वयंसेवक',
      'deliveries_made': 'डिलीवरी की गई',
      'become_volunteer': 'स्वयंसेवक बनें',

      // Motivational content
      'feed_smile': 'आज एक मुस्कान खिलाएं',
      'meal_brighten': 'एक भोजन किसी के पूरे दिन को उज्जवल कर सकता है',
      'share_table': 'अपनी मेज साझा करें',
      'no_hunger': 'हमारे समुदाय में किसी को भी भूखा नहीं रहना चाहिए',
      'food_waste': 'खाद्य अपशिष्ट से खाद्य स्वाद',
      'rescue_food': 'अतिरिक्त भोजन को बचाएं और जरूरतमंदों को खिलाएं',
      'donate_what': 'जो आप दे सकते हैं वह दान करें',
      'every_contribution': 'हर योगदान अंतर लाता है',
      'hunger_stat': '9 में से 1 व्यक्ति भूखा रहता है',
      'change_stat': 'आपका दान इस आंकड़े को बदल सकता है',

      // Social Media Footer
      'privacy_policy': 'गोपनीयता नीति',
      'terms_of_service': 'सेवा की शर्तें',
      'contact_us': 'संपर्क करें',
      'all_rights_reserved': '© 2025 काइंडमील्स। सभी अधिकार सुरक्षित।',

      // Profile Screen
      'profile': 'प्रोफ़ाइल',
      'try_again': 'पुनः प्रयास करें',
      'edit': 'संपादित करें',
      'logout': 'लॉगआउट',
      'logout_confirm': 'क्या आप वाकई लॉगआउट करना चाहते हैं?',
      'cancel': 'रद्द करें',
      'error_loading_profile': 'प्रोफ़ाइल लोड करने में त्रुटि',
      'change_language': 'भाषा बदलें',
      'personal_information': 'व्यक्तिगत जानकारी',
      'contact_information': 'संपर्क जानकारी',
      'organization_information': 'संगठन की जानकारी',
      'about': 'बारे में',
      'full_name': 'पूरा नाम',
      'email_address': 'ईमेल पता',
      'contact_number': 'संपर्क नंबर',
      'address': 'पता',
      'organization_name': 'संगठन का नाम',
      'organization_id': 'संगठन आईडी',
      'description': 'विवरण',
      'no_description': 'कोई विवरण उपलब्ध नहीं',
      'profile_image_updated': 'प्रोफ़ाइल छवि सफलतापूर्वक अपडेट की गई',
      'failed_upload_image': 'प्रोफ़ाइल छवि अपलोड करने में विफल:',
      'logout_failed': 'लॉगआउट विफल:',

      // Language screen
      'select_language': 'भाषा चुनें',
      'choose_language': 'अपनी पसंदीदा भाषा चुनें',

      // Login screen
      'login': 'लॉगिन',
      'email': 'ईमेल',
      'password': 'पासवर्ड',
      'forgot_password': 'पासवर्ड भूल गए?',
      'or': 'या',
      'continue_with_google': 'गूगल के साथ जारी रखें',
      'dont_have_account': 'खाता नहीं है?',
      'register': 'पंजीकरण करें',
      'want_to_help': 'लोगों की मदद करना चाहते हैं?',
      'register_as_volunteer': 'स्वयंसेवक के रूप में पंजीकरण करें',
      'login_successful': 'लॉगिन सफल!',
      'google_signup': 'गूगल के साथ जारी रखें',

      // Register screen
      'aadhar_id': 'आधार आईडी / रेस्टोरेंट आईडी',
      'address': 'पता / स्थान (पता लगाने के लिए क्लिक करें)',
      'contact': 'संपर्क नंबर',
      'about': 'बारे में',
      'org_name': 'संगठन का नाम / व्यक्तिगत',
      'user_type': 'प्रकार',
      'profile_pic': 'प्रोफ़ाइल चित्र जोड़ें',
      'change_profile_pic': 'प्रोफ़ाइल चित्र बदलें',
      'registration_successful': 'पंजीकरण सफल!',
      'get_address': 'कृपया स्थान बटन पर क्लिक करके अपना पता प्राप्त करें',
      'type': 'प्रकार',
      'contact_number': 'संपर्क नंबर',

      // Register volunteer screen
      'volunteer_registration': 'स्वयंसेवक पंजीकरण',
      'full_name': 'पूरा नाम',
      'aadhar_number': 'आधार नंबर',
      'address_click_detect': 'पता (पता लगाने के लिए क्लिक करें)',
      'about_yourself': 'अपने बारे में',
      'have_vehicle': 'क्या आपके पास डिलीवरी के लिए वाहन है?',
      'vehicle_type': 'वाहन प्रकार',
      'vehicle_number': 'वाहन नंबर',
      'driving_license': 'ड्राइविंग लाइसेंस छवि',
      'upload_license': 'लाइसेंस छवि अपलोड करें',

      // Logout
      'logging_out': 'लॉग आउट हो रहा है...',
      'error_logout': 'लॉगआउट में त्रुटि: ',

      // Validation messages
      'enter_email': 'कृपया अपना ईमेल दर्ज करें',
      'valid_email': 'कृपया एक वैध ईमेल दर्ज करें',
      'enter_password': 'कृपया अपना पासवर्ड दर्ज करें',
      'password_length': 'पासवर्ड कम से कम 6 अक्षर का होना चाहिए',
      'enter_name': 'कृपया अपना नाम दर्ज करें',
      'enter_id': 'कृपया अपनी आईडी दर्ज करें',
      'enter_contact': 'कृपया अपना संपर्क नंबर दर्ज करें',
      'valid_contact': 'कृपया एक वैध संपर्क नंबर दर्ज करें',
      'enter_about': 'कृपया अपने बारे में दर्ज करें',
      'enter_org_name': 'कृपया संगठन का नाम या व्यक्तिगत दर्ज करें',
      'select_type': 'कृपया एक प्रकार चुनें',
      'select_vehicle_type': 'कृपया एक वाहन प्रकार चुनें',
      'enter_vehicle_number': 'कृपया अपना वाहन नंबर दर्ज करें',

      // Charity related translations
      'donate_to_charity': 'धर्मार्थ संस्था को दान करें',
      'error': 'त्रुटि',
      'no_charities_available': 'कोई धर्मार्थ संस्था उपलब्ध नहीं है',
      'check_back_later': 'धर्मार्थ दान के अवसरों के लिए बाद में फिर से जांचें',
      'refresh': 'रीफ्रेश करें',
      'make_a_difference': 'एक अंतर बनाएं',
      'contribution_help':
          'आपका योगदान जरूरतमंदों की मदद कर सकता है। दान करने के लिए नीचे एक धर्मार्थ संस्था चुनें।',
      'food_relief': 'खाद्य राहत',
      'from': 'से',
      'make_a_donation': 'दान करें',
      'donation_history': 'दान इतिहास',
      'select_amount': 'राशि चुनें',
      'custom_amount': 'कस्टम राशि',
      'your_information': 'आपकी जानकारी',
      'full_name': 'पूरा नाम',
      'email': 'ईमेल',
      'phone_number': 'फोन नंबर',
      'request_tax_benefits': 'कर लाभ का अनुरोध करें (80G)',
      'pan_card_number': 'पैन कार्ड नंबर',
      'required_for_tax_benefits': 'कर लाभ के लिए आवश्यक',
      'payment_method': 'भुगतान विधि',
      'credit_debit_card': 'क्रेडिट/डेबिट कार्ड',
      'net_banking': 'नेट बैंकिंग',
      'upi_gpay_phonepe': 'यूपीआई / गूगल पे / फोनपे',
      'initializing_payment': 'भुगतान प्रारंभ कर रहा है...',
      'processing_donation': 'आपके दान पर प्रक्रिया हो रही है...',
      'thank_you': 'धन्यवाद!',
      'donation_successful': 'आपका दान सफल रहा!',
      'amount': 'राशि',
      'date': 'तारीख',
      'transaction_id': 'लेनदेन आईडी',
      'charity': 'धर्मार्थ संस्था',
      'contribution_difference':
          'आपका योगदान किसी के जीवन में वास्तविक अंतर लाएगा।',
      'view_history': 'इतिहास देखें',
      'done': 'हो गया',
      'information_secure':
          'आपकी जानकारी सुरक्षित है और केवल दान उद्देश्यों के लिए उपयोग की जाएगी।',
      'support_our_cause': 'हमारे उद्देश्य का समर्थन करें',

      // Post Donation Screen
      'post_donation': 'दान पोस्ट करें',
      'refresh_authentication': 'प्रमाणीकरण रीफ्रेश करें',
      'sign_out_sign_in_again': 'साइन आउट करें और फिर से साइन इन करें',
      'go_to_profile': 'प्रोफाइल पर जाएं',
      'go_back': 'वापस जाएं',
      'refresh_profile_note':
          'नोट: अगर आपने अभी पंजीकरण किया है, तो कृपया अपनी प्रोफ़ाइल स्थिति को रीफ्रेश करने के लिए लॉग आउट करें और फिर से लॉग इन करें।',
      'refresh_status': 'स्थिति रीफ्रेश करें',
      'food_name': 'भोजन का नाम',
      'please_enter_food_name': 'कृपया भोजन का नाम दर्ज करें',
      'quantity': 'मात्रा',
      'please_enter_quantity': 'कृपया मात्रा दर्ज करें',
      'please_enter_valid_number': 'कृपया एक वैध संख्या दर्ज करें',
      'description': 'विवरण',
      'please_enter_description': 'कृपया विवरण दर्ज करें',
      'food_type': 'भोजन का प्रकार',
      'veg': 'शाकाहारी',
      'nonveg': 'मांसाहारी',
      'jain': 'जैन',
      'please_select_food_type': 'कृपया भोजन का प्रकार चुनें',
      'pickup_address_click_detect': 'पिकअप पता (पता लगाने के लिए क्लिक करें)',
      'get_current_location': 'वर्तमान स्थान प्राप्त करें',
      'please_get_pickup_address':
          'कृपया स्थान बटन पर क्लिक करके पिकअप पता प्राप्त करें',
      'location': 'स्थान',
      'expiry_date_time': 'समाप्ति तिथि और समय',
      'select_expiry_date_time': 'समाप्ति तिथि और समय चुनें',
      'please_select_expiry_date_time':
          'कृपया एक वैध समाप्ति तिथि और समय चुनें',
      'local_time': 'स्थानीय समय',
      'need_volunteer_for_delivery': 'डिलीवरी के लिए स्वयंसेवक की आवश्यकता है',
      'volunteer_note':
          'नोट: जब आपका दान किसी प्राप्तकर्ता द्वारा स्वीकार किया जाता है, तो वे डिलीवरी के लिए एक स्वयंसेवक का अनुरोध कर सकते हैं।',
      'donation_posted_successfully': 'दान सफलतापूर्वक पोस्ट किया गया!',
      'failed_to_post_donation':
          'दान पोस्ट करने में विफल। कृपया पुनः प्रयास करें।',
      'authentication_error_refresh':
          'प्रमाणीकरण त्रुटि: अपने क्रेडेंशियल्स को रीफ्रेश करने के लिए कृपया साइन आउट करें और फिर से साइन इन करें।',
      'authentication_error': 'प्रमाणीकरण त्रुटि',
      'auth_error_details':
          'आपकी दाता प्रोफ़ाइल सत्यापित नहीं की जा सकी। यह हो सकता है यदि:\n\n1. आपने हाल ही में पंजीकरण किया है और आपकी प्रोफ़ाइल पूरी तरह से सिंक नहीं हुई है\n2. आपका प्रमाणीकरण टोकन समाप्त हो गया है\n\nकृपया अपने क्रेडेंशियल्स को रीफ्रेश करने के लिए साइन आउट करें और फिर से साइन इन करें।',
      'ok': 'ठीक है',
      'sign_out_now': 'अभी साइन आउट करें',

      // Donor history translations
      'no_donations_found': 'कोई दान नहीं मिला',
      'create_donations_to_see': 'इसे यहां देखने के लिए एक दान बनाएं',
      'create_donation': 'दान बनाएं',
      'no_donation_history_found':
          'कोई दान इतिहास नहीं मिला। कृपया बाद में पुन: प्रयास करें।',
      'sign_in_to_view_donations':
          'अपने दान इतिहास को देखने के लिए कृपया साइन इन करें।',
      'all': 'सभी',
      'signed_out': 'साइन आउट किया गया',
      'sign_out_confirmation': 'क्या आप वाकई साइन आउट करना चाहते हैं?',
      'sign_out': 'साइन आउट',
      'yes': 'हां',
      'no': 'नहीं',

      // View donations screen
      'available_donations': 'उपलब्ध दान',
      'filter_donations': 'दान फ़िल्टर करें',
      'food_type': 'भोजन का प्रकार',
      'sort_by': 'इसके अनुसार क्रमबद्ध करें',
      'sort_by_expiry': 'समाप्ति तिथि',
      'sort_by_distance': 'दूरी',
      'sort_by_quantity': 'मात्रा',
      'maximum_distance': 'अधिकतम दूरी',
      'km': 'किमी',
      'show_needs_volunteer':
          'ऐसे दान दिखाएं जिन्हें स्वयंसेवक सहायता की आवश्यकता है',
      'reset': 'रीसेट',
      'apply_filters': 'फ़िल्टर लागू करें',
      'search_food': 'भोजन खोजें...',
      'filter': 'फ़िल्टर',
      'needs_volunteer': 'स्वयंसेवक की आवश्यकता है',
      'no_available_donations': 'कोई उपलब्ध दान नहीं मिला',
      'no_results_for': 'इसके लिए कोई परिणाम नहीं मिला',
      'check_back_later': 'नए दानों के लिए बाद में फिर से जांचें',
      'try_changing_filters':
          'अधिक दान देखने के लिए अपने फ़िल्टर बदलने का प्रयास करें',
      'clear_filters': 'फ़िल्टर साफ़ करें',
      'profile_not_found_recipient':
          'आपकी प्रोफ़ाइल नहीं मिली। दान देखने के लिए सुनिश्चित करें कि आप प्राप्तकर्ता के रूप में पंजीकृत हैं।',
      'unable_to_load_donations':
          'इस समय दान लोड करने में असमर्थ। कृपया बाद में पुन: प्रयास करें।',
      'retry': 'पुनः प्रयास करें',
      'go_to_profile': 'प्रोफ़ाइल पर जाएं',
      'no_image_available': 'कोई छवि उपलब्ध नहीं',
      'expiring_soon': 'जल्द ही समाप्त हो रहा है',
      'quantity': 'मात्रा',
      'servings': 'परोसने',
      'tap_to_read_more': 'अधिक पढ़ने के लिए टैप करें',
      'donor': 'दाता',
      'call_donor': 'दाता को कॉल करें',
      'get_directions': 'दिशाएँ प्राप्त करें',
      'expires': 'समाप्त होता है',
      'view_details': 'विवरण देखें',
      'unknown_location': 'अज्ञात स्थान',
      'anonymous': 'अनाम',
      'error': 'त्रुटि',
      'refresh': 'रीफ्रेश करें',

      // Recipient history screen
      'filter_donation_history': 'दान इतिहास फ़िल्टर करें',
      'time_period': 'समय अवधि',
      'today': 'आज',
      'yesterday': 'कल',
      'days_ago': 'दिन पहले',
      'this_week': 'इस सप्ताह',
      'this_month': 'इस महीने',
      'time': 'समय',
      'type': 'प्रकार',
      'accept_donations_to_see': 'उन्हें यहां देखने के लिए दान स्वीकार करें',
      'browse_donations': 'दान ब्राउज़ करें',
      'no_donations_match_criteria': 'कोई दान आपके मानदंडों से मेल नहीं खाता',
      'try_adjusting_filters':
          'अधिक दान देखने के लिए अपने फ़िल्टर समायोजित करने का प्रयास करें',
      'clear_all_filters': 'सभी फ़िल्टर साफ़ करें',
      'update_location': 'स्थान अपडेट करें',
      'location_updated_donations_refreshed':
          'स्थान अपडेट किया गया। दूरी जानकारी के साथ दान रीफ्रेश किए गए।',
      'could_not_get_location':
          'आपका स्थान प्राप्त नहीं कर सका। कृपया सुनिश्चित करें कि स्थान सेवाएं सक्षम हैं।',
      'error_updating_location': 'स्थान अपडेट करने में त्रुटि',
      'donated_by': 'द्वारा दान किया गया',
      'accepted_on': 'स्वीकृत दिनांक',
      'at': 'पर',
      'delivery_method': 'डिलीवरी का तरीका',
      'self_pickup': 'स्वयं पिकअप',
      'add_feedback': 'प्रतिक्रिया जोड़ें',
      'edit_feedback': 'प्रतिक्रिया संपादित करें',
      'your_feedback': 'आपकी प्रतिक्रिया',
      'share_experience_hint': 'इस दान के बारे में अपना अनुभव साझा करें...',
      'feedback_submitted_successfully': 'प्रतिक्रिया सफलतापूर्वक जमा की गई!',
      'error_submitting_feedback': 'प्रतिक्रिया जमा करने में त्रुटि',
      'distance': 'दूरी',
      'submit': 'जमा करें',

      // Donation detail screen
      'donation_details': 'दान विवरण',
      'unknown_food': 'अज्ञात भोजन',
      'no_description_available': 'कोई विवरण उपलब्ध नहीं',
      'unknown': 'अज्ञात',
      'servings': 'परोसने',
      'anonymous_donor': 'अनाम दाता',
      'donor_information': 'दाता जानकारी',
      'donor': 'दाता',
      'location': 'स्थान',
      'food_description': 'भोजन विवरण',
      'expires': 'समाप्त होता है',
      'exact_expiry': 'सटीक समाप्ति',
      'delivery_options': 'डिलीवरी विकल्प',
      'need_volunteer_assistance': 'स्वयंसेवक सहायता की आवश्यकता है?',
      'yes_request_volunteer':
          'हां, डिलीवरी के लिए स्वयंसेवक सहायता का अनुरोध करें',
      'no_pickup_myself': 'नहीं, मैं स्वयं इस दान को लेने जाऊंगा',
      'changed_from_original': 'आपने दाता की मूल सेटिंग से इसे बदल दिया है',
      'using_donor_preference': 'दाता की पसंदीदा डिलीवरी विकल्प का उपयोग करना',
      'accept_donation': 'इस दान को स्वीकार करें',
      'donation_accepted_with_volunteer':
          'दान सफलतापूर्वक स्वीकार किया गया। एक स्वयंसेवक डिलीवरी में सहायता करेगा।',
      'donation_accepted_self_pickup':
          'दान सफलतापूर्वक स्वीकार किया गया। आपको इसे स्वयं लेने की आवश्यकता होगी।',
    },
    'mr': {
      // Common strings
      'app_name': 'काइंडमील्स',
      'app_slogan': 'अन्न वाटा, प्रेम वाटा',
      'get_started': 'सुरू करा',
      'continue': 'पुढे जा',
      'inspirational_quote':
          'जेव्हा आपण आनंदाने देतो आणि कृतज्ञतेने स्वीकारतो, तेव्हा प्रत्येकाला आशीर्वाद मिळतो.',
      'no_image_available': 'प्रतिमा उपलब्ध नाही',

      // Dashboard screen
      'welcome_to': 'स्वागत आहे',
      'top_volunteers': 'टॉप स्वयंसेवक',
      'top_donors': 'टॉप दानकर्ते',
      'view_full_leaderboard': 'संपूर्ण लीडरबोर्ड पहा',
      'reviews_feedback': 'समीक्षा आणि प्रतिक्रिया',
      'view_all_reviews': 'सर्व समीक्षा पहा',
      'support_a_cause': 'कारणाला समर्थन द्या',
      'donate_to_kindmeals': 'काइंडमील्सला दान करा',
      'donate_subtitle':
          'अन्न नष्ट होणे आणि भूक कमी करण्याच्या आमच्या मिशनला समर्थन द्या',
      'donate_now': 'आता दान करा',
      'view_all_charities': 'सर्व दानशील संस्था पहा',
      'name': 'नाव',
      'deliveries': 'वितरणे',
      'meals': 'जेवणे',
      'no_volunteers_found': 'कोणतेही स्वयंसेवक सापडले नाहीत',
      'no_donors_found': 'कोणतेही दानकर्ते सापडले नाहीत',
      'refresh_data': 'डेटा रिफ्रेश करा',

      // Volunteers Screen
      'volunteers': 'स्वयंसेवक',
      'volunteer_leaderboard': 'स्वयंसेवक लीडरबोर्ड',
      'total_volunteers': 'एकूण स्वयंसेवक',
      'total_deliveries': 'एकूण वितरणे',
      'avg_deliveries': 'सरासरी वितरणे',
      'rank': 'क्रमांक',
      'volunteer': 'स्वयंसेवक',
      'deliveries_made': 'वितरणे केले',
      'become_volunteer': 'स्वयंसेवक व्हा',

      // Motivational content
      'feed_smile': 'आज एक हास्य पोसा',
      'meal_brighten': 'एक जेवण कोणाचा संपूर्ण दिवस उजळू शकते',
      'share_table': 'तुमचे टेबल शेअर करा',
      'no_hunger': 'आपल्या समुदायात कोणीही भुकेला राहू नये',
      'food_waste': 'अन्न नष्ट होण्यापासून अन्न चवीपर्यंत',
      'rescue_food': 'अतिरिक्त अन्न वाचवा आणि गरजूंना खाऊ घाला',
      'donate_what': 'तुम्ही जे देऊ शकता ते दान करा',
      'every_contribution': 'प्रत्येक योगदान फरक करते',
      'hunger_stat': '९ पैकी १ व्यक्ती भुकेली राहते',
      'change_stat': 'तुमचे दान हे आकडेवारी बदलू शकते',

      // Social Media Footer
      'privacy_policy': 'गोपनीयता धोरण',
      'terms_of_service': 'सेवेच्या अटी',
      'contact_us': 'आमच्याशी संपर्क साधा',
      'all_rights_reserved': '© २०२५ काइंडमील्स. सर्व हक्क राखीव.',

      // Profile Screen
      'profile': 'प्रोफाइल',
      'try_again': 'पुन्हा प्रयत्न करा',
      'edit': 'संपादित करा',
      'logout': 'लॉग आउट',
      'logout_confirm': 'तुम्हाला खात्री आहे की तुम्ही लॉग आउट करू इच्छिता?',
      'cancel': 'रद्द करा',
      'error_loading_profile': 'प्रोफाइल लोड करताना त्रुटी',
      'change_language': 'भाषा बदला',
      'personal_information': 'वैयक्तिक माहिती',
      'contact_information': 'संपर्क माहिती',
      'organization_information': 'संस्थेची माहिती',
      'about': 'माझ्याबद्दल',
      'full_name': 'पूर्ण नाव',
      'email_address': 'ईमेल पत्ता',
      'contact_number': 'संपर्क क्रमांक',
      'address': 'पत्ता',
      'organization_name': 'संस्थेचे नाव',
      'organization_id': 'संस्था आयडी',
      'description': 'वर्णन',
      'no_description': 'कोणतेही वर्णन उपलब्ध नाही',
      'profile_image_updated': 'प्रोफाइल प्रतिमा यशस्वीरित्या अपडेट केली',
      'failed_upload_image': 'प्रोफाइल प्रतिमा अपलोड करण्यात अयशस्वी:',
      'logout_failed': 'लॉग आउट अयशस्वी:',

      // Language screen
      'select_language': 'भाषा निवडा',
      'choose_language': 'तुमची पसंतीची भाषा निवडा',

      // Login screen
      'login': 'लॉगिन',
      'email': 'ईमेल',
      'password': 'पासवर्ड',
      'forgot_password': 'पासवर्ड विसरलात?',
      'or': 'किंवा',
      'continue_with_google': 'Google सह चालू ठेवा',
      'dont_have_account': 'खाते नाही?',
      'register': 'नोंदणी करा',
      'want_to_help': 'लोकांना मदत करू इच्छिता?',
      'register_as_volunteer': 'स्वयंसेवक म्हणून नोंदणी करा',
      'login_successful': 'लॉगिन यशस्वी!',
      'google_signup': 'Google सह चालू ठेवा',

      // Register screen
      'aadhar_id': 'आधार आयडी / रेस्टॉरंट आयडी',
      'address': 'पत्ता / स्थान (शोधण्यासाठी क्लिक करा)',
      'contact': 'संपर्क क्रमांक',
      'about': 'माझ्याबद्दल',
      'org_name': 'संस्थेचे नाव / व्यक्तिगत',
      'user_type': 'प्रकार',
      'profile_pic': 'प्रोफाइल चित्र जोडा',
      'change_profile_pic': 'प्रोफाइल चित्र बदला',
      'registration_successful': 'नोंदणी यशस्वी!',
      'get_address': 'कृपया स्थान बटणावर क्लिक करून आपला पत्ता मिळवा',
      'type': 'प्रकार',
      'contact_number': 'संपर्क क्रमांक',

      // Register volunteer screen
      'volunteer_registration': 'स्वयंसेवक नोंदणी',
      'full_name': 'पूर्ण नाव',
      'aadhar_number': 'आधार क्रमांक',
      'address_click_detect': 'पत्ता (शोधण्यासाठी क्लिक करा)',
      'about_yourself': 'स्वतःबद्दल',
      'have_vehicle': 'वितरणासाठी तुमच्याकडे वाहन आहे का?',
      'vehicle_type': 'वाहन प्रकार',
      'vehicle_number': 'वाहन क्रमांक',
      'driving_license': 'ड्रायव्हिंग लायसन्स प्रतिमा',
      'upload_license': 'लायसन्स प्रतिमा अपलोड करा',

      // Logout
      'logging_out': 'लॉग आउट होत आहे...',
      'error_logout': 'लॉग आउट करताना त्रुटी: ',

      // Validation messages
      'enter_email': 'कृपया आपला ईमेल प्रविष्ट करा',
      'valid_email': 'कृपया वैध ईमेल प्रविष्ट करा',
      'enter_password': 'कृपया आपला पासवर्ड प्रविष्ट करा',
      'password_length': 'पासवर्ड किमान ६ अक्षरे असावा',
      'enter_name': 'कृपया आपले नाव प्रविष्ट करा',
      'enter_id': 'कृपया आपला आयडी प्रविष्ट करा',
      'enter_contact': 'कृपया आपला संपर्क क्रमांक प्रविष्ट करा',
      'valid_contact': 'कृपया वैध संपर्क क्रमांक प्रविष्ट करा',
      'enter_about': 'कृपया स्वतःबद्दल प्रविष्ट करा',
      'enter_org_name': 'कृपया संस्थेचे नाव किंवा व्यक्तिगत प्रविष्ट करा',
      'select_type': 'कृपया प्रकार निवडा',
      'select_vehicle_type': 'कृपया वाहन प्रकार निवडा',
      'enter_vehicle_number': 'कृपया आपला वाहन क्रमांक प्रविष्ट करा',

      // Charity related translations
      'donate_to_charity': 'दानशील संस्थेला दान करा',
      'error': 'त्रुटी',
      'no_charities_available': 'कोणत्याही दानशील संस्था उपलब्ध नाहीत',
      'check_back_later': 'दानशील संस्थांच्या दान संधींसाठी नंतर पुन्हा तपासा',
      'refresh': 'रिफ्रेश',
      'make_a_difference': 'फरक करा',
      'contribution_help':
          'तुमचे योगदान गरजूंना मदत करू शकते. दान करण्यासाठी खालील दानशील संस्था निवडा.',
      'food_relief': 'अन्न मदत',
      'from': 'कडून',
      'make_a_donation': 'दान करा',
      'donation_history': 'दान इतिहास',
      'select_amount': 'रक्कम निवडा',
      'custom_amount': 'कस्टम रक्कम',
      'your_information': 'तुमची माहिती',
      'full_name': 'पूर्ण नाव',
      'email': 'ईमेल',
      'phone_number': 'फोन नंबर',
      'request_tax_benefits': 'कर फायदे विनंती करा (८०जी)',
      'pan_card_number': 'पॅन कार्ड नंबर',
      'required_for_tax_benefits': 'कर फायद्यांसाठी आवश्यक',
      'payment_method': 'पेमेंट पद्धत',
      'credit_debit_card': 'क्रेडिट/डेबिट कार्ड',
      'net_banking': 'नेट बँकिंग',
      'upi_gpay_phonepe': 'यूपीआय / गूगल पे / फोन पे',
      'initializing_payment': 'पेमेंट सुरू करत आहे...',
      'processing_donation': 'तुमचे दान प्रक्रिया करत आहे...',
      'thank_you': 'धन्यवाद!',
      'donation_successful': 'तुमचे दान यशस्वी झाले!',
      'amount': 'रक्कम',
      'date': 'तारीख',
      'transaction_id': 'व्यवहार आयडी',
      'charity': 'दानशील संस्था',
      'contribution_difference':
          'तुमचे योगदान कोणाच्या तरी जीवनात खरा फरक करेल.',
      'view_history': 'इतिहास पहा',
      'done': 'पूर्ण',
      'information_secure':
          'तुमची माहिती सुरक्षित आहे आणि केवळ दान उद्देशांसाठी वापरली जाईल.',
      'support_our_cause': 'आमच्या कारणाला समर्थन द्या',

      // Post Donation Screen
      'post_donation': 'दान पोस्ट करा',
      'refresh_authentication': 'प्रमाणीकरण रिफ्रेश करा',
      'sign_out_sign_in_again': 'साइन आउट करा आणि पुन्हा साइन इन करा',
      'go_to_profile': 'प्रोफाइलवर जा',
      'go_back': 'मागे जा',
      'refresh_profile_note':
          'टीप: जर तुम्ही नुकतीच नोंदणी केली असेल, तर कृपया आपल्या प्रोफाइल स्थितीचे रिफ्रेश करण्यासाठी लॉग आउट करा आणि पुन्हा लॉग इन करा.',
      'refresh_status': 'स्थिती रिफ्रेश करा',
      'food_name': 'अन्नाचे नाव',
      'please_enter_food_name': 'कृपया अन्नाचे नाव प्रविष्ट करा',
      'quantity': 'प्रमाण',
      'please_enter_quantity': 'कृपया प्रमाण प्रविष्ट करा',
      'please_enter_valid_number': 'कृपया वैध संख्या प्रविष्ट करा',
      'description': 'वर्णन',
      'please_enter_description': 'कृपया वर्णन प्रविष्ट करा',
      'food_type': 'अन्न प्रकार',
      'veg': 'शाकाहारी',
      'nonveg': 'मांसाहारी',
      'jain': 'जैन',
      'please_select_food_type': 'कृपया अन्न प्रकार निवडा',
      'pickup_address_click_detect': 'पिकअप पत्ता (शोधण्यासाठी क्लिक करा)',
      'get_current_location': 'वर्तमान स्थान मिळवा',
      'please_get_pickup_address':
          'कृपया स्थान बटणावर क्लिक करून पिकअप पत्ता मिळवा',
      'location': 'स्थान',
      'expiry_date_time': 'समाप्ती तारीख आणि वेळ',
      'select_expiry_date_time': 'समाप्ती तारीख आणि वेळ निवडा',
      'please_select_expiry_date_time': 'कृपया वैध समाप्ती तारीख आणि वेळ निवडा',
      'local_time': 'स्थानिक वेळ',
      'need_volunteer_for_delivery': 'वितरणासाठी स्वयंसेवकांची आवश्यकता आहे',
      'volunteer_note':
          'टीप: जेव्हा तुमचे दान प्राप्तकर्त्याकडून स्वीकारले जाईल, तेव्हा ते वितरणासाठी स्वयंसेवकाची विनंती करू शकतील.',
      'donation_posted_successfully': 'दान यशस्वीरित्या पोस्ट केले!',
      'failed_to_post_donation':
          'दान पोस्ट करण्यात अयशस्वी. कृपया पुन्हा प्रयत्न करा.',
      'authentication_error_refresh':
          'प्रमाणीकरण त्रुटी: कृपया आपल्या क्रेडेन्शियल्स रिफ्रेश करण्यासाठी साइन आउट करा आणि पुन्हा साइन इन करा.',
      'authentication_error': 'प्रमाणीकरण त्रुटी',
      'auth_error_details':
          'तुमचे दानकर्ता प्रोफाइल सत्यापित केले जाऊ शकले नाही. हे याकारणाने होऊ शकते:\n\n1. तुम्ही अलीकडे नोंदणी केली आहे आणि तुमचे प्रोफाइल पूर्णपणे सिंक झालेले नाही\n2. तुमचे प्रमाणीकरण टोकन कालबाह्य झाले आहे\n\nकृपया आपल्या क्रेडेन्शियल्स रिफ्रेश करण्यासाठी साइन आउट करा आणि पुन्हा साइन इन करा.',
      'ok': 'ठीक आहे',
      'sign_out_now': 'आता साइन आउट करा',

      // Donor history translations
      'no_donations_found': 'कोणतेही दान सापडले नाही',
      'create_donations_to_see': 'येथे पाहण्यासाठी दान तयार करा',
      'create_donation': 'दान तयार करा',
      'no_donation_history_found':
          'कोणताही दान इतिहास सापडला नाही. कृपया नंतर पुन्हा प्रयत्न करा.',
      'sign_in_to_view_donations':
          'कृपया तुमचा दान इतिहास पाहण्यासाठी साइन इन करा.',
      'all': 'सर्व',
      'signed_out': 'साइन आउट केले',
      'sign_out_confirmation':
          'तुम्हाला खात्री आहे की तुम्ही साइन आउट करू इच्छिता?',
      'sign_out': 'साइन आउट',
      'yes': 'होय',
      'no': 'नाही',

      // View donations screen
      'available_donations': 'उपलब्ध दाने',
      'filter_donations': 'दान फिल्टर करा',
      'food_type': 'अन्न प्रकार',
      'sort_by': 'यानुसार क्रमवारी लावा',
      'sort_by_expiry': 'समाप्ती तारीख',
      'sort_by_distance': 'अंतर',
      'sort_by_quantity': 'प्रमाण',
      'maximum_distance': 'कमाल अंतर',
      'km': 'कि.मी.',
      'show_needs_volunteer': 'स्वयंसेवक मदत आवश्यक असलेली दाने दाखवा',
      'reset': 'रीसेट',
      'apply_filters': 'फिल्टर लागू करा',
      'search_food': 'अन्न शोधा...',
      'filter': 'फिल्टर',
      'needs_volunteer': 'स्वयंसेवक आवश्यक',
      'no_available_donations': 'कोणतेही उपलब्ध दान सापडले नाही',
      'no_results_for': 'यासाठी कोणतेही परिणाम सापडले नाहीत',
      'check_back_later': 'नवीन दानांसाठी नंतर पुन्हा तपासा',
      'try_changing_filters':
          'अधिक दाने पाहण्यासाठी आपले फिल्टर बदलण्याचा प्रयत्न करा',
      'clear_filters': 'फिल्टर साफ करा',
      'profile_not_found_recipient':
          'तुमचे प्रोफाइल सापडले नाही. दाने पाहण्यासाठी तुम्ही प्राप्तकर्ता म्हणून नोंदणीकृत आहात याची खात्री करा.',
      'unable_to_load_donations':
          'यावेळी दाने लोड करण्यात अक्षम. कृपया नंतर पुन्हा प्रयत्न करा.',
      'retry': 'पुन्हा प्रयत्न करा',
      'go_to_profile': 'प्रोफाइलवर जा',
      'no_image_available': 'प्रतिमा उपलब्ध नाही',
      'expiring_soon': 'लवकरच समाप्त होणार',
      'quantity': 'प्रमाण',
      'servings': 'वाटे',
      'tap_to_read_more': 'अधिक वाचण्यासाठी टॅप करा',
      'donor': 'दानकर्ता',
      'call_donor': 'दानकर्त्याला कॉल करा',
      'get_directions': 'दिशा मिळवा',
      'expires': 'समाप्ती',
      'view_details': 'तपशील पहा',
      'unknown_location': 'अज्ञात स्थान',
      'anonymous': 'अनामित',
      'error': 'त्रुटी',
      'refresh': 'रिफ्रेश',

      // Recipient history screen
      'filter_donation_history': 'दान इतिहास फिल्टर करा',
      'time_period': 'कालावधी',
      'today': 'आज',
      'yesterday': 'काल',
      'days_ago': 'दिवसांपूर्वी',
      'this_week': 'या आठवड्यात',
      'this_month': 'या महिन्यात',
      'time': 'वेळ',
      'type': 'प्रकार',
      'accept_donations_to_see': 'येथे पाहण्यासाठी दाने स्वीकारा',
      'browse_donations': 'दाने ब्राउझ करा',
      'no_donations_match_criteria': 'कोणतेही दान तुमच्या निकषांशी जुळत नाही',
      'try_adjusting_filters':
          'अधिक दाने पाहण्यासाठी आपले फिल्टर समायोजित करण्याचा प्रयत्न करा',
      'clear_all_filters': 'सर्व फिल्टर साफ करा',
      'update_location': 'स्थान अपडेट करा',
      'location_updated_donations_refreshed':
          'स्थान अपडेट केले. अंतर माहितीसह दाने रिफ्रेश केली.',
      'could_not_get_location':
          'तुमचे स्थान मिळवू शकलो नाही. कृपया स्थान सेवा सक्षम आहेत याची खात्री करा.',
      'error_updating_location': 'स्थान अपडेट करताना त्रुटी',
      'donated_by': 'यांनी दान केले',
      'accepted_on': 'स्वीकृत दिनांक',
      'at': 'येथे',
      'delivery_method': 'वितरण पद्धत',
      'self_pickup': 'स्वतः पिकअप',
      'add_feedback': 'प्रतिक्रिया जोडा',
      'edit_feedback': 'प्रतिक्रिया संपादित करा',
      'your_feedback': 'तुमची प्रतिक्रिया',
      'share_experience_hint': 'या दानाबद्दल आपला अनुभव शेअर करा...',
      'feedback_submitted_successfully': 'प्रतिक्रिया यशस्वीरित्या सबमिट केली!',
      'error_submitting_feedback': 'प्रतिक्रिया सबमिट करताना त्रुटी',
      'distance': 'अंतर',
      'submit': 'सबमिट करा',

      // Donation detail screen
      'donation_details': 'दान तपशील',
      'unknown_food': 'अज्ञात अन्न',
      'no_description_available': 'कोणतेही वर्णन उपलब्ध नाही',
      'unknown': 'अज्ञात',
      'servings': 'वाटे',
      'anonymous_donor': 'अनामित दानकर्ता',
      'donor_information': 'दानकर्ता माहिती',
      'donor': 'दानकर्ता',
      'location': 'स्थान',
      'food_description': 'अन्न वर्णन',
      'expires': 'समाप्ती',
      'exact_expiry': 'अचूक समाप्ती',
      'delivery_options': 'वितरण पर्याय',
      'need_volunteer_assistance': 'स्वयंसेवक मदत हवी आहे?',
      'yes_request_volunteer': 'होय, वितरणासाठी स्वयंसेवक मदत विनंती करा',
      'no_pickup_myself': 'नाही, मी हे दान स्वतः पिकअप करेन',
      'changed_from_original':
          'तुम्ही हे दानकर्त्याच्या मूळ सेटिंगमधून बदलले आहे',
      'using_donor_preference':
          'दानकर्त्याच्या पसंतीच्या वितरण पर्यायाचा वापर करत आहे',
      'accept_donation': 'हे दान स्वीकारा',
      'donation_accepted_with_volunteer':
          'दान यशस्वीरित्या स्वीकारले. वितरणासाठी एक स्वयंसेवक मदत करेल.',
      'donation_accepted_self_pickup':
          'दान यशस्वीरित्या स्वीकारले. तुम्हाला हे स्वतः संकलित करावे लागेल.',
    },
    'te': {
      // Common strings
      'app_name': 'కిండ్ మీల్స్',
      'app_slogan': 'ఆహారం పంచుకోండి, ప్రేమను పంచుకోండి',
      'get_started': 'ప్రారంభించండి',
      'continue': 'కొనసాగించు',
      'inspirational_quote':
          'మనం సంతోషంగా ఇచ్చినప్పుడు మరియు కృతజ్ఞతతో అంగీకరించినప్పుడు, అందరికీ ఆశీర్వాదాలు లభిస్తాయి.',
      'no_image_available': 'చిత్రం అందుబాటులో లేదు',

      // Dashboard screen
      'welcome_to': 'స్వాగతం',
      'top_volunteers': 'అగ్ర స్వచ్ఛంద సేవకులు',
      'top_donors': 'అగ్ర దాతలు',
      'view_full_leaderboard': 'పూర్తి లీడర్ బోర్డ్ చూడండి',
      'reviews_feedback': 'సమీక్షలు & ప్రతిస్పందన',
      'view_all_reviews': 'అన్ని సమీక్షలు చూడండి',
      'support_a_cause': 'ఒక ఉద్దేశ్యానికి మద్దతు ఇవ్వండి',
      'donate_to_kindmeals': 'కిండ్ మీల్స్ కు విరాళం ఇవ్వండి',
      'donate_subtitle':
          'ఆహార వ్యర్థ్యం మరియు ఆకలిని తగ్గించే మా లక్ష్యానికి మద్దతు ఇవ్వండి',
      'donate_now': 'ఇప్పుడు విరాళం ఇవ్వండి',
      'view_all_charities': 'అన్ని సంస్థలు చూడండి',
      'name': 'పేరు',
      'deliveries': 'డెలివరీలు',
      'meals': 'భోజనాలు',
      'no_volunteers_found': 'స్వచ్ఛంద సేవకులు కనుగొనబడలేదు',
      'no_donors_found': 'దాతలు కనుగొనబడలేదు',
      'refresh_data': 'డేటాను రిఫ్రెష్ చేయండి',

      // Volunteers Screen
      'volunteers': 'స్వచ్ఛంద సేవకులు',
      'volunteer_leaderboard': 'స్వచ్ఛంద సేవకుల లీడర్ బోర్డ్',
      'total_volunteers': 'మొత్తం స్వచ్ఛంద సేవకులు',
      'total_deliveries': 'మొత్తం డెలివరీలు',
      'avg_deliveries': 'సగటు డెలివరీలు',
      'rank': 'ర్యాంక్',
      'volunteer': 'స్వచ్ఛంద సేవకుడు',
      'deliveries_made': 'డెలివరీలు చేసారు',
      'become_volunteer': 'స్వచ్ఛంద సేవకుడిగా చేరండి',

      // Motivational content
      'feed_smile': 'ఈ రోజు ఒక చిరునవ్వును పోషించండి',
      'meal_brighten': 'ఒక భోజనం ఒకరి రోజును ప్రకాశవంతం చేయగలదు',
      'share_table': 'మీ టేబుల్ ను పంచుకోండి',
      'no_hunger': 'మన సమాజంలో ఎవరూ ఆకలితో ఉండకూడదు',
      'food_waste': 'ఆహార వ్యర్థ్యం నుండి ఆహార రుచికి',
      'rescue_food': 'మిగిలిన ఆహారాన్ని కాపాడి అవసరమున్నవారికి పంపిణీ చేయండి',
      'donate_what': 'మీరు చేయగలిగినదాన్ని దానం చేయండి',
      'every_contribution': 'ప్రతి సహాయం ఒక తేడా చేస్తుంది',
      'hunger_stat': '9 మందిలో 1 మంది ఆకలితో ఉన్నారు',
      'change_stat': 'మీ దానం ఈ గణాంకాన్ని మార్చగలదు',

      // Social Media Footer
      'privacy_policy': 'గోప్యతా విధానం',
      'terms_of_service': 'సేవా నిబంధనలు',
      'contact_us': 'మమ్మల్ని సంప్రదించండి',
      'all_rights_reserved':
          '© 2025 కిండ్ మీల్స్. అన్ని హక్కులు ప్రత్యేకించబడ్డాయి.',

      // Profile Screen
      'profile': 'ప్రొఫైల్',
      'try_again': 'మళ్లీ ప్రయత్నించండి',
      'edit': 'సవరించు',
      'logout': 'లాగ్ అవుట్',
      'logout_confirm': 'మీరు ఖచ్చితంగా లాగ్ అవుట్ చేయాలనుకుంటున్నారా?',
      'cancel': 'రద్దు చేయి',
      'error_loading_profile': 'ప్రొఫైల్ లోడ్ చేయడంలో లోపం',
      'change_language': 'భాష మార్చు',
      'personal_information': 'వ్యక్తిగత సమాచారం',
      'contact_information': 'సంప్రదింపు సమాచారం',
      'organization_information': 'సంస్థ సమాచారం',
      'about': 'గురించి',
      'full_name': 'పూర్తి పేరు',
      'email_address': 'ఇమెయిల్ చిరునామా',
      'contact_number': 'సంప్రదింపు నంబర్',
      'address': 'చిరునామా',
      'organization_name': 'సంస్థ పేరు',
      'organization_id': 'సంస్థ ID',
      'description': 'వివరణ',
      'no_description': 'వివరణ అందుబాటులో లేదు',
      'profile_image_updated': 'ప్రొఫైల్ చిత్రం విజయవంతంగా నవీకరించబడింది',
      'failed_upload_image': 'ప్రొఫైల్ చిత్రం అప్లోడ్ చేయడంలో విఫలమైంది:',
      'logout_failed': 'లాగ్ అవుట్ విఫలమైంది:',

      // Language screen
      'select_language': 'భాషను ఎంచుకోండి',
      'choose_language': 'మీకు నచ్చిన భాషను ఎంచుకోండి',

      // Login screen
      'login': 'లాగిన్',
      'email': 'ఇమెయిల్',
      'password': 'పాస్వర్డ్',
      'forgot_password': 'పాస్వర్డ్ మర్చిపోయారా?',
      'or': 'లేదా',
      'continue_with_google': 'Google తో కొనసాగించు',
      'dont_have_account': 'ఖాతా లేదా?',
      'register': 'నమోదు చేసుకోండి',
      'want_to_help': 'ప్రజలకు సహాయం చేయాలనుకుంటున్నారా?',
      'register_as_volunteer': 'స్వచ్ఛంద సేవకుడిగా నమోదు చేసుకోండి',
      'login_successful': 'లాగిన్ విజయవంతమైంది!',
      'google_signup': 'Google తో నమోదు చేసుకోండి',

      // Register screen
      'aadhar_id': 'ఆధార్ ID / రెస్టారెంట్ ID',
      'address': 'చిరునామా / స్థానం (గుర్తించడానికి క్లిక్ చేయండి)',
      'contact': 'సంప్రదింపు నంబర్',
      'about': 'గురించి',
      'org_name': 'సంస్థ పేరు / వ్యక్తిగతం',
      'user_type': 'రకం',
      'profile_pic': 'ప్రొఫైల్ చిత్రాన్ని జోడించండి',
      'change_profile_pic': 'ప్రొఫైల్ చిత్రాన్ని మార్చండి',
      'registration_successful': 'నమోదు విజయవంతమైంది!',
      'get_address':
          'దయచేసి లొకేషన్ బటన్ క్లిక్ చేయడం ద్వారా మీ చిరునామాను పొందండి',
      'type': 'రకం',
      'contact_number': 'సంప్రదింపు నంబర్',

      // Register volunteer screen
      'volunteer_registration': 'స్వచ్ఛంద సేవకుని నమోదు',
      'full_name': 'పూర్తి పేరు',
      'aadhar_number': 'ఆధార్ నంబర్',
      'address_click_detect': 'చిరునామా (గుర్తించడానికి క్లిక్ చేయండి)',
      'about_yourself': 'మీ గురించి',
      'have_vehicle': 'డెలివరీల కోసం మీకు వాహనం ఉందా?',
      'vehicle_type': 'వాహనం రకం',
      'vehicle_number': 'వాహనం నంబర్',
      'driving_license': 'డ్రైవింగ్ లైసెన్స్ చిత్రం',
      'upload_license': 'లైసెన్స్ చిత్రాన్ని అప్లోడ్ చేయండి',

      // Logout
      'logging_out': 'లాగ్ అవుట్ అవుతోంది...',
      'error_logout': 'లాగ్ అవుట్ చేయడంలో లోపం: ',

      // Validation messages
      'enter_email': 'దయచేసి మీ ఇమెయిల్ ను నమోదు చేయండి',
      'valid_email': 'దయచేసి సరైన ఇమెయిల్ ను నమోదు చేయండి',
      'enter_password': 'దయచేసి మీ పాస్వర్డ్ ను నమోదు చేయండి',
      'password_length': 'పాస్వర్డ్ కనీసం 6 అక్షరాలు ఉండాలి',
      'enter_name': 'దయచేసి మీ పేరును నమోదు చేయండి',
      'enter_id': 'దయచేసి మీ ID ను నమోదు చేయండి',
      'enter_contact': 'దయచేసి మీ సంప్రదింపు నంబర్ ను నమోదు చేయండి',
      'valid_contact': 'దయచేసి సరైన సంప్రదింపు నంబర్ ను నమోదు చేయండి',
      'enter_about': 'దయచేసి మీ గురించి నమోదు చేయండి',
      'enter_org_name': 'దయచేసి సంస్థ పేరు లేదా వ్యక్తిగతం నమోదు చేయండి',
      'select_type': 'దయచేసి ఒక రకాన్ని ఎంచుకోండి',
      'select_vehicle_type': 'దయచేసి వాహనం రకాన్ని ఎంచుకోండి',
      'enter_vehicle_number': 'దయచేసి మీ వాహనం నంబర్ ను నమోదు చేయండి',

      // Charity related translations
      'donate_to_charity': 'సంస్థకు విరాళం ఇవ్వండి',
      'error': 'లోపం',
      'no_charities_available': 'సంస్థలు అందుబాటులో లేవు',
      'check_back_later': 'సంస్థ విరాళ అవకాశాల కోసం తర్వాత తనిఖీ చేయండి',
      'refresh': 'రిఫ్రెష్',
      'make_a_difference': 'ఒక తేడాను చూపించండి',
      'contribution_help':
          'మీ సహాయం అవసరమున్నవారికి ఉపయోగపడుతుంది. దిగువ నుండి ఒక సంస్థను ఎంచుకోండి.',
      'food_relief': 'ఆహార సహాయం',
      'from': 'నుండి',
      'make_a_donation': 'విరాళం ఇవ్వండి',
      'donation_history': 'విరాళ చరిత్ర',
      'select_amount': 'మొత్తాన్ని ఎంచుకోండి',
      'custom_amount': 'కస్టమ్ మొత్తం',
      'your_information': 'మీ సమాచారం',
      'full_name': 'పూర్తి పేరు',
      'email': 'ఇమెయిల్',
      'phone_number': 'ఫోన్ నంబర్',
      'request_tax_benefits': 'పన్ను ప్రయోజనాలు కోరండి (80G)',
      'pan_card_number': 'PAN కార్డ్ నంబర్',
      'required_for_tax_benefits': 'పన్ను ప్రయోజనాల కోసం అవసరం',
      'payment_method': 'చెల్లింపు పద్ధతి',
      'credit_debit_card': 'క్రెడిట్/డెబిట్ కార్డ్',
      'net_banking': 'నెట్ బ్యాంకింగ్',
      'upi_gpay_phonepe': 'UPI / Google Pay / PhonePe',
      'initializing_payment': 'చెల్లింపును ప్రారంభిస్తోంది...',
      'processing_donation': 'మీ విరాళాన్ని ప్రాసెస్ చేస్తోంది...',
      'thank_you': 'ధన్యవాదాలు!',
      'donation_successful': 'మీ విరాళం విజయవంతంగా పూర్తయింది!',
      'amount': 'మొత్తం',
      'date': 'తేదీ',
      'transaction_id': 'లావాదేవీ ID',
      'charity': 'సంస్థ',
      'contribution_difference':
          'మీ సహాయం ఒకరి జీవితంలో నిజమైన తేడాను చూపిస్తుంది.',
      'view_history': 'చరిత్రను చూడండి',
      'done': 'పూర్తి',
      'information_secure':
          'మీ సమాచారం సురక్షితంగా ఉంటుంది మరియు విరాళ ప్రయోజనాల కోసం మాత్రమే ఉపయోగించబడుతుంది.',
      'support_our_cause': 'మా ఉద్దేశ్యానికి మద్దతు ఇవ్వండి',

      // Post Donation Screen
      'post_donation': 'విరాళాన్ని పోస్ట్ చేయండి',
      'refresh_authentication': 'అధీకరణను రిఫ్రెష్ చేయండి',
      'sign_out_sign_in_again': 'సైన్ అవుట్ చేసి మళ్లీ సైన్ ఇన్ చేయండి',
      'go_to_profile': 'ప్రొఫైల్ కు వెళ్లండి',
      'go_back': 'వెనక్కి వెళ్లండి',
      'refresh_profile_note':
          'గమనిక: మీరు ఇప్పుడే నమోదు చేసుకుంటే, దయచేసి మీ ప్రొఫైల్ స్థితిని రిఫ్రెష్ చేయడానికి లాగ్ అవుట్ చేసి లాగిన్ చేయండి.',
      'refresh_status': 'స్థితిని రిఫ్రెష్ చేయండి',
      'food_name': 'ఆహారం పేరు',
      'please_enter_food_name': 'దయచేసి ఆహారం పేరును నమోదు చేయండి',
      'quantity': 'పరిమాణం',
      'please_enter_quantity': 'దయచేసి పరిమాణాన్ని నమోదు చేయండి',
      'please_enter_valid_number': 'దయచేసి సరైన సంఖ్యను నమోదు చేయండి',
      'description': 'వివరణ',
      'please_enter_description': 'దయచేసి వివరణను నమోదు చేయండి',
      'food_type': 'ఆహారం రకం',
      'veg': 'శాకాహారి',
      'nonveg': 'అశాకాహారి',
      'jain': 'జైన్',
      'please_select_food_type': 'దయచేసి ఆహారం రకాన్ని ఎంచుకోండి',
      'pickup_address_click_detect':
          'పికప్ చిరునామా (గుర్తించడానికి క్లిక్ చేయండి)',
      'get_current_location': 'ప్రస్తుత స్థానాన్ని పొందండి',
      'please_get_pickup_address':
          'దయచేసి లొకేషన్ బటన్ క్లిక్ చేయడం ద్వారా పికప్ చిరునామాను పొందండి',
      'location': 'స్థానం',
      'expiry_date_time': 'గడువు తేదీ & సమయం',
      'select_expiry_date_time': 'గడువు తేదీ మరియు సమయాన్ని ఎంచుకోండి',
      'please_select_expiry_date_time':
          'దయచేసి సరైన గడువు తేదీ మరియు సమయాన్ని ఎంచుకోండి',
      'local_time': 'స్థానిక సమయం',
      'need_volunteer_for_delivery': 'డెలివరీ కోసం స్వచ్ఛంద సేవకుడు అవసరం',
      'volunteer_note':
          'గమనిక: మీ విరాళాన్ని ఒక రిసిపియెంట్ అంగీకరించినప్పుడు, వారు డెలివరీ కోసం స్వచ్ఛంద సేవకుని అభ్యర్థించగలరు.',
      'donation_posted_successfully': 'విరాళం విజయవంతంగా పోస్ట్ చేయబడింది!',
      'failed_to_post_donation':
          'విరాళాన్ని పోస్ట్ చేయడంలో విఫలమైంది. దయచేసి మళ్లీ ప్రయత్నించండి.',
      'authentication_error_refresh':
          'అధీకరణ లోపం: దయచేసి మీ ఆధారాలను రిఫ్రెష్ చేయడానికి సైన్ అవుట్ చేసి సైన్ ఇన్ చేయండి.',
      'authentication_error': 'అధీకరణ లోపం',
      'auth_error_details':
          'మీ దాత ప్రొఫైల్ ధృవీకరించబడలేదు. ఇది ఈ కారణాల వల్ల సంభవించవచ్చు:\n\n1. మీరు ఇటీవల నమోదు చేసుకున్నారు మరియు మీ ప్రొఫైల్ పూర్తిగా సమకాలీకరించబడలేదు\n2. మీ అధీకరణ టోకెన్ గడువు ముగిసింది\n\nదయచేసి మీ ఆధారాలను రిఫ్రెష్ చేయడానికి సైన్ అవుట్ చేసి సైన్ ఇన్ చేయండి.',
      'ok': 'సరే',
      'sign_out_now': 'ఇప్పుడే సైన్ అవుట్ చేయండి',

      // Donor history translations
      'no_donations_found': 'విరాళాలు కనుగొనబడలేదు',
      'create_donations_to_see': 'ఇక్కడ చూడటానికి ఒక విరాళాన్ని సృష్టించండి',
      'create_donation': 'విరాళాన్ని సృష్టించండి',
      'no_donation_history_found':
          'విరాళ చరిత్ర కనుగొనబడలేదు. దయచేసి తర్వాత మళ్లీ ప్రయత్నించండి.',
      'sign_in_to_view_donations':
          'మీ విరాళ చరిత్రను చూడటానికి దయచేసి సైన్ ఇన్ చేయండి.',
      'all': 'అన్ని',
      'signed_out': 'సైన్ అవుట్ చేయబడింది',
      'sign_out_confirmation': 'మీరు ఖచ్చితంగా సైన్ అవుట్ చేయాలనుకుంటున్నారా?',
      'sign_out': 'సైన్ అవుట్',
      'yes': 'అవును',
      'no': 'కాదు',

      // View donations screen
      'available_donations': 'అందుబాటులో ఉన్న విరాళాలు',
      'filter_donations': 'విరాళాలను ఫిల్టర్ చేయండి',
      'food_type': 'ఆహారం రకం',
      'sort_by': 'ద్వారా క్రమబద్ధీకరించు',
      'sort_by_expiry': 'గడువు తేదీ',
      'sort_by_distance': 'దూరం',
      'sort_by_quantity': 'పరిమాణం',
      'maximum_distance': 'గరిష్ట దూరం',
      'km': 'కి.మీ',
      'show_needs_volunteer': 'స్వచ్ఛంద సహాయం అవసరమయ్యే విరాళాలను చూపించు',
      'reset': 'రీసెట్',
      'apply_filters': 'ఫిల్టర్లను వర్తింపజేయండి',
      'search_food': 'ఆహారాన్ని శోధించండి...',
      'filter': 'ఫిల్టర్',
      'needs_volunteer': 'స్వచ్ఛంద సహాయం అవసరం',
      'no_available_donations': 'అందుబాటులో ఉన్న విరాళాలు కనుగొనబడలేదు',
      'no_results_for': 'కోసం ఫలితాలు లేవు',
      'check_back_later': 'కొత్త విరాళాల కోసం తర్వాత తనిఖీ చేయండి',
      'try_changing_filters':
          'మరిన్ని విరాళాలను చూడటానికి మీ ఫిల్టర్లను మార్చండి',
      'clear_filters': 'ఫిల్టర్లను క్లియర్ చేయండి',
      'profile_not_found_recipient':
          'మీ ప్రొఫైల్ కనుగొనబడలేదు. విరాళాలను చూడటానికి మీరు రిసిపియెంట్ గా నమోదు చేసుకున్నారని నిర్ధారించుకోండి.',
      'unable_to_load_donations':
          'ప్రస్తుతం విరాళాలను లోడ్ చేయడం సాధ్యపడలేదు. దయచేసి తర్వాత మళ్లీ ప్రయత్నించండి.',
      'retry': 'మళ్లీ ప్రయత్నించండి',
      'go_to_profile': 'ప్రొఫైల్ కు వెళ్లండి',
      'no_image_available': 'చిత్రం అందుబాటులో లేదు',
      'expiring_soon': 'త్వరలో గడువు ముగుస్తుంది',
      'quantity': 'పరిమాణం',
      'servings': 'సర్వింగ్స్',
      'tap_to_read_more': 'మరింత చదవడానికి టాప్ చేయండి',
      'donor': 'దాత',
      'call_donor': 'దాతను కాల్ చేయండి',
      'get_directions': 'దిశలను పొందండి',
      'expires': 'గడువు ముగుస్తుంది',
      'view_details': 'వివరాలను చూడండి',
      'unknown_location': 'తెలియని స్థానం',
      'anonymous': 'అనామక',
      'error': 'లోపం',
      'refresh': 'రిఫ్రెష్',

      // Recipient history screen
      'filter_donation_history': 'విరాళ చరిత్రను ఫిల్టర్ చేయండి',
      'time_period': 'సమయ వ్యవధి',
      'today': 'ఈ రోజు',
      'yesterday': 'నిన్న',
      'days_ago': 'రోజుల క్రితం',
      'this_week': 'ఈ వారం',
      'this_month': 'ఈ నెల',
      'time': 'సమయం',
      'type': 'రకం',
      'accept_donations_to_see':
          'విరాళాలను అంగీకరించండి వాటిని ఇక్కడ చూడటానికి',
      'browse_donations': 'విరాళాలను బ్రౌజ్ చేయండి',
      'no_donations_match_criteria': 'మీ ప్రమాణాలతో ఏ విరాళాలు సరిపోలలేదు',
      'try_adjusting_filters':
          'మరిన్ని విరాళాలను చూడటానికి మీ ఫిల్టర్లను సర్దుబాటు చేయండి',
      'clear_all_filters': 'అన్ని ఫిల్టర్లను క్లియర్ చేయండి',
      'update_location': 'స్థానాన్ని నవీకరించండి',
      'location_updated_donations_refreshed':
          'స్థానం నవీకరించబడింది. దూర సమాచారంతో విరాళాలు రిఫ్రెష్ చేయబడ్డాయి.',
      'could_not_get_location':
          'మీ స్థానాన్ని పొందలేకపోయాము. దయచేసి లొకేషన్ సేవలు ప్రారంభించబడి ఉన్నాయని నిర్ధారించుకోండి.',
      'error_updating_location': 'స్థానాన్ని నవీకరించడంలో లోపం',
      'donated_by': 'ద్వారా విరాళం ఇవ్వబడింది',
      'accepted_on': 'న అంగీకరించబడింది',
      'at': 'వద్ద',
      'delivery_method': 'డెలివరీ పద్ధతి',
      'self_pickup': 'స్వీయ-పికప్',
      'add_feedback': 'ప్రతిస్పందనను జోడించండి',
      'edit_feedback': 'ప్రతిస్పందనను సవరించండి',
      'your_feedback': 'మీ ప్రతిస్పందన',
      'share_experience_hint': 'ఈ విరాళం గురించి మీ అనుభవాన్ని పంచుకోండి...',
      'feedback_submitted_successfully':
          'ప్రతిస్పందన విజయవంతంగా సమర్పించబడింది!',
      'error_submitting_feedback': 'ప్రతిస్పందన సమర్పించడంలో లోపం',
      'distance': 'దూరం',
      'submit': 'సమర్పించండి',

      // Donation detail screen
      'donation_details': 'విరాళ వివరాలు',
      'unknown_food': 'తెలియని ఆహారం',
      'no_description_available': 'వివరణ అందుబాటులో లేదు',
      'unknown': 'తెలియదు',
      'servings': 'సర్వింగ్స్',
      'anonymous_donor': 'అనామక దాత',
      'donor_information': 'దాత సమాచారం',
      'donor': 'దాత',
      'location': 'స్థానం',
      'food_description': 'ఆహార వివరణ',
      'expires': 'గడువు ముగుస్తుంది',
      'exact_expiry': 'ఖచ్చితమైన గడువు',
      'delivery_options': 'డెలివరీ ఎంపికలు',
      'need_volunteer_assistance': 'స్వచ్ఛంద సహాయం అవసరమా?',
      'yes_request_volunteer':
          'అవును, డెలివరీ కోసం స్వచ్ఛంద సహాయాన్ని అభ్యర్థించండి',
      'no_pickup_myself': 'కాదు, నేను ఈ విరాళాన్ని నేనే సేకరిస్తాను',
      'changed_from_original':
          'మీరు దీన్ని దాత యొక్క అసలు సెట్టింగ్ నుండి మార్చారు',
      'using_donor_preference':
          'దాత యొక్క ప్రాధాన్యత డెలివరీ ఎంపికను ఉపయోగిస్తోంది',
      'accept_donation': 'ఈ విరాళాన్ని అంగీకరించండి',
      'donation_accepted_with_volunteer': 'విరాళం విజయవంతంగా అ'
    },
    'gu': {
      // Common strings
      'app_name': 'કાઇન્ડમિલ્સ',
      'app_slogan': 'ખોરાક વહેંચો, પ્રેમ વહેંચો',
      'get_started': 'શરૂ કરો',
      'continue': 'ચાલુ રાખો',
      'inspirational_quote':
          'જ્યારે આપણે ખુશીથી આપીએ છીએ અને કૃતજ્ઞતાથી સ્વીકારીએ છીએ, ત્યારે દરેક આશીર્વાદિત થાય છે.',
      'no_image_available': 'કોઈ છબી ઉપલબ્ધ નથી',

      // Dashboard screen
      'welcome_to': 'આપનું સ્વાગત છે',
      'top_volunteers': 'શ્રેષ્ઠ સ્વયંસેવકો',
      'top_donors': 'શ્રેષ્ઠ દાનકર્તાઓ',
      'view_full_leaderboard': 'સંપૂર્ણ લીડરબોર્ડ જુઓ',
      'reviews_feedback': 'સમીક્ષાઓ અને પ્રતિસાદ',
      'view_all_reviews': 'બધી સમીક્ષાઓ જુઓ',
      'support_a_cause': 'કોઈ હેતુને સમર્થન આપો',
      'donate_to_kindmeals': 'કાઇન્ડમિલ્સને દાન કરો',
      'donate_subtitle':
          'ખોરાકના બગાડ અને ભૂખમરાને ઘટાડવાના અમારા મિશનને સમર્થન આપો',
      'donate_now': 'હવે દાન કરો',
      'view_all_charities': 'બધી ચેરિટીઓ જુઓ',
      'name': 'નામ',
      'deliveries': 'ડિલિવરીઓ',
      'meals': 'ભોજન',
      'no_volunteers_found': 'કોઈ સ્વયંસેવકો મળ્યા નથી',
      'no_donors_found': 'કોઈ દાતાઓ મળ્યા નથી',
      'refresh_data': 'ડેટા રિફ્રેશ કરો',

      // Volunteers Screen
      'volunteers': 'સ્વયંસેવકો',
      'volunteer_leaderboard': 'સ્વયંસેવક લીડરબોર્ડ',
      'total_volunteers': 'કુલ સ્વયંસેવકો',
      'total_deliveries': 'કુલ ડિલિવરીઓ',
      'avg_deliveries': 'સરેરાશ ડિલિવરીઓ',
      'rank': 'રેન્ક',
      'volunteer': 'સ્વયંસેવક',
      'deliveries_made': 'ડિલિવરીઓ કરી',
      'become_volunteer': 'સ્વયંસેવક બનો',

      // Motivational content
      'feed_smile': 'આજે એક સ્મિત ખવડાવો',
      'meal_brighten': 'એક ભોજન કોઈના દિવસને ઉજળો બનાવી શકે છે',
      'share_table': 'તમારો ટેબલ શેર કરો',
      'no_hunger': 'આપણા સમુદાયમાં કોઈને ભૂખ્યા રહેવું જોઈએ નહીં',
      'food_waste': 'ખોરાકનો બગાડ ખોરાકના સ્વાદમાં',
      'rescue_food': 'વધારાના ખોરાકને બચાવો અને જરૂરિયાતમંદોને ખવડાવો',
      'donate_what': 'જે આપી શકો તે દાન કરો',
      'every_contribution': 'દરેક યોગદાન તફાવત લાવે છે',
      'hunger_stat': '9 માંથી 1 વ્યક્તિ ભૂખ્યા રહે છે',
      'change_stat': 'તમારું દાન આ આંકડામાં ફેરફાર કરી શકે છે',

      // Social Media Footer
      'privacy_policy': 'ગોપનીયતા નીતિ',
      'terms_of_service': 'સેવાની શરતો',
      'contact_us': 'અમારો સંપર્ક કરો',
      'all_rights_reserved': '© 2025 કાઇન્ડમિલ્સ. બધા અધિકારો સુરક્ષિત.',

      // Profile Screen
      'profile': 'પ્રોફાઇલ',
      'try_again': 'ફરી પ્રયાસ કરો',
      'edit': 'સંપાદિત કરો',
      'logout': 'લૉગ આઉટ',
      'logout_confirm': 'શું તમે ખરેખર લૉગ આઉટ કરવા માંગો છો?',
      'cancel': 'રદ કરો',
      'error_loading_profile': 'પ્રોફાઇલ લોડ કરવામાં ભૂલ',
      'change_language': 'ભાષા બદલો',
      'personal_information': 'વ્યક્તિગત માહિતી',
      'contact_information': 'સંપર્ક માહિતી',
      'organization_information': 'સંસ્થાની માહિતી',
      'about': 'વિશે',
      'full_name': 'પૂરું નામ',
      'email_address': 'ઈમેલ એડ્રેસ',
      'contact_number': 'સંપર્ક નંબર',
      'address': 'સરનામું',
      'organization_name': 'સંસ્થાનું નામ',
      'organization_id': 'સંસ્થા આઈડી',
      'description': 'વિવરણ',
      'no_description': 'કોઈ વિવરણ ઉપલબ્ધ નથી',
      'profile_image_updated': 'પ્રોફાઇલ છબી સફળતાપૂર્વક અપડેટ થઈ',
      'failed_upload_image': 'પ્રોફાઇલ છબી અપલોડ કરવામાં નિષ્ફળ:',
      'logout_failed': 'લૉગઆઉટ નિષ્ફળ:',

      // Language screen
      'select_language': 'ભાષા પસંદ કરો',
      'choose_language': 'તમારી પસંદીદા ભાષા પસંદ કરો',

      // Login screen
      'login': 'લૉગિન',
      'email': 'ઈમેલ',
      'password': 'પાસવર્ડ',
      'forgot_password': 'પાસવર્ડ ભૂલી ગયા?',
      'or': 'અથવા',
      'continue_with_google': 'ગૂગલ સાથે ચાલુ રાખો',
      'dont_have_account': 'ખાતું નથી?',
      'register': 'રજિસ્ટર',
      'want_to_help': 'લોકોને મદદ કરવા માંગો છો?',
      'register_as_volunteer': 'સ્વયંસેવક તરીકે રજિસ્ટર કરો',
      'login_successful': 'લૉગિન સફળ!',
      'google_signup': 'ગૂગલ સાથે ચાલુ રાખો',

      // Register screen
      'aadhar_id': 'આધાર આઈડી / રેસ્ટોરન્ટ આઈડી',
      'address': 'સરનામું / સ્થાન (શોધવા માટે ક્લિક કરો)',
      'contact': 'સંપર્ક નંબર',
      'about': 'વિશે',
      'org_name': 'સંસ્થાનું નામ / વ્યક્તિગત',
      'user_type': 'પ્રકાર',
      'profile_pic': 'પ્રોફાઇલ છબી ઉમેરો',
      'change_profile_pic': 'પ્રોફાઇલ છબી બદલો',
      'registration_successful': 'રજિસ્ટ્રેશન સફળ!',
      'get_address':
          'કૃપા કરીને લોકેશન બટન પર ક્લિક કરીને તમારું સરનામું મેળવો',
      'type': 'પ્રકાર',
      'contact_number': 'સંપર્ક નંબર',

      // Register volunteer screen
      'volunteer_registration': 'સ્વયંસેવક નોંધણી',
      'full_name': 'પૂરું નામ',
      'aadhar_number': 'આધાર નંબર',
      'address_click_detect': 'સરનામું (શોધવા માટે ક્લિક કરો)',
      'about_yourself': 'તમારા વિશે',
      'have_vehicle': 'શું તમારી પાસે ડિલિવરી માટે વાહન છે?',
      'vehicle_type': 'વાહનનો પ્રકાર',
      'vehicle_number': 'વાહન નંબર',
      'driving_license': 'ડ્રાઇવિંગ લાઇસન્સ છબી',
      'upload_license': 'લાઇસન્સ છબી અપલોડ કરો',

      // Logout
      'logging_out': 'લૉગ આઉટ થઈ રહ્યું છે...',
      'error_logout': 'લૉગ આઉટ કરવામાં ભૂલ: ',

      // Validation messages
      'enter_email': 'કૃપા કરીને તમારો ઈમેલ દાખલ કરો',
      'valid_email': 'કૃપા કરીને માન્ય ઈમેલ દાખલ કરો',
      'enter_password': 'કૃપા કરીને તમારો પાસવર્ડ દાખલ કરો',
      'password_length': 'પાસવર્ડ ઓછામાં ઓછા 6 અક્ષરોનો હોવો જોઈએ',
      'enter_name': 'કૃપા કરીને તમારું નામ દાખલ કરો',
      'enter_id': 'કૃપા કરીને તમારો આઈડી દાખલ કરો',
      'enter_contact': 'કૃપા કરીને તમારો સંપર્ક નંબર દાખલ કરો',
      'valid_contact': 'કૃપા કરીને માન્ય સંપર્ક નંબર દાખલ કરો',
      'enter_about': 'કૃપા કરીને તમારા વિશે દાખલ કરો',
      'enter_org_name': 'કૃપા કરીને સંસ્થાનું નામ અથવા વ્યક્તિગત દાખલ કરો',
      'select_type': 'કૃપા કરીને એક પ્રકાર પસંદ કરો',
      'select_vehicle_type': 'કૃપા કરીને વાહનનો પ્રકાર પસંદ કરો',
      'enter_vehicle_number': 'કૃપા કરીને તમારો વાહન નંબર દાખલ કરો',

      // Charity related translations
      'donate_to_charity': 'ચેરિટીને દાન કરો',
      'error': 'ભૂલ',
      'no_charities_available': 'કોઈ ચેરિટીઓ ઉપલબ્ધ નથી',
      'check_back_later': 'ચેરિટી દાન તકો માટે પછીથી તપાસો',
      'refresh': 'રિફ્રેશ',
      'make_a_difference': 'ફરક પાડો',
      'contribution_help':
          'તમારું યોગદાન જરૂરિયાતમંદોને મદદ કરી શકે છે. દાન કરવા માટે નીચે એક ચેરિટી પસંદ કરો.',
      'food_relief': 'અન્ન રાહત',
      'from': 'તરફથી',
      'make_a_donation': 'દાન કરો',
      'donation_history': 'દાનનો ઇતિહાસ',
      'select_amount': 'રકમ પસંદ કરો',
      'custom_amount': 'કસ્ટમ રકમ',
      'your_information': 'તમારી માહિતી',
      'full_name': 'પૂરું નામ',
      'email': 'ઈમેલ',
      'phone_number': 'ફોન નંબર',
      'request_tax_benefits': 'કર લાભ માંગો (80G)',
      'pan_card_number': 'પાન કાર્ડ નંબર',
      'required_for_tax_benefits': 'કર લાભો માટે જરૂરી',
      'payment_method': 'ચુકવણી પદ્ધતિ',
      'credit_debit_card': 'ક્રેડિટ/ડેબિટ કાર્ડ',
      'net_banking': 'નેટ બેન્કિંગ',
      'upi_gpay_phonepe': 'UPI / Google Pay / PhonePe',
      'initializing_payment': 'ચુકવણી શરૂ કરી રહ્યા છીએ...',
      'processing_donation': 'તમારું દાન પ્રક્રિયા કરી રહ્યા છીએ...',
      'thank_you': 'આભાર!',
      'donation_successful': 'તમારું દાન સફળ રહ્યું!',
      'amount': 'રકમ',
      'date': 'તારીખ',
      'transaction_id': 'ટ્રાન્ઝેક્શન આઈડી',
      'charity': 'ચેરિટી',
      'contribution_difference': 'તમારું યોગદાન કોઈના જીવનમાં ખરેખર ફરક પાડશે.',
      'view_history': 'ઇતિહાસ જુઓ',
      'done': 'થઈ ગયું',
      'information_secure':
          'તમારી માહિતી સુરક્ષિત છે અને માત્ર દાન હેતુઓ માટે જ ઉપયોગમાં લેવાશે.',
      'support_our_cause': 'અમારા હેતુને સમર્થન આપો',

      // Post Donation Screen
      'post_donation': 'દાન પોસ્ટ કરો',
      'refresh_authentication': 'પ્રમાણીકરણ રિફ્રેશ કરો',
      'sign_out_sign_in_again': 'સાઇન આઉટ કરો અને ફરી સાઇન ઇન કરો',
      'go_to_profile': 'પ્રોફાઇલ પર જાઓ',
      'go_back': 'પાછા જાઓ',
      'refresh_profile_note':
          'નોંધ: જો તમે હમણાં જ રજિસ્ટર કર્યું હોય, તો કૃપા કરીને લૉગ આઉટ કરો અને તમારી પ્રોફાઇલ સ્થિતિ રિફ્રેશ કરવા માટે ફરી લૉગ ઇન કરો.',
      'refresh_status': 'સ્થિતિ રિફ્રેશ કરો',
      'food_name': 'ખોરાકનું નામ',
      'please_enter_food_name': 'કૃપા કરીને ખોરાકનું નામ દાખલ કરો',
      'quantity': 'જથ્થો',
      'please_enter_quantity': 'કૃપા કરીને જથ્થો દાખલ કરો',
      'please_enter_valid_number': 'કૃપા કરીને માન્ય નંબર દાખલ કરો',
      'description': 'વિવરણ',
      'please_enter_description': 'કૃપા કરીને વિવરણ દાખલ કરો',
      'food_type': 'ખોરાકનો પ્રકાર',
      'veg': 'શાકાહારી',
      'nonveg': 'માંસાહારી',
      'jain': 'જૈન',
      'please_select_food_type': 'કૃપા કરીને ખોરાકનો પ્રકાર પસંદ કરો',
      'pickup_address_click_detect': 'પિકઅપ સરનામું (શોધવા માટે ક્લિક કરો)',
      'get_current_location': 'વર્તમાન સ્થાન મેળવો',
      'please_get_pickup_address':
          'કૃપા કરીને લોકેશન બટન પર ક્લિક કરીને પિકઅપ સરનામું મેળવો',
      'location': 'સ્થાન',
      'expiry_date_time': 'સમાપ્તિ તારીખ અને સમય',
      'select_expiry_date_time': 'સમાપ્તિ તારીખ અને સમય પસંદ કરો',
      'please_select_expiry_date_time':
          'કૃપા કરીને માન્ય સમાપ્તિ તારીખ અને સમય પસંદ કરો',
      'local_time': 'સ્થાનિક સમય',
      'need_volunteer_for_delivery': 'ડિલિવરી માટે સ્વયંસેવકની જરૂર છે',
      'volunteer_note':
          'નોંધ: જ્યારે તમારું દાન કોઈ પ્રાપ્તકર્તા દ્વારા સ્વીકારવામાં આવે છે, ત્યારે તેઓ ડિલિવરી માટે સ્વયંસેવકની વિનંતી કરી શકશે.',
      'donation_posted_successfully': 'દાન સફળતાપૂર્વક પોસ્ટ કર્યું!',
      'failed_to_post_donation':
          'દાન પોસ્ટ કરવામાં નિષ્ફળ. કૃપા કરીને ફરી પ્રયાસ કરો.',
      'authentication_error_refresh':
          'પ્રમાણીકરણ ભૂલ: કૃપા કરીને તમારા એક્રેડેન્શિયલ્સ રિફ્રેશ કરવા માટે સાઇન આઉટ કરો અને ફરી સાઇન ઇન કરો.',
      'authentication_error': 'પ્રમાણીકરણ ભૂલ',
      'auth_error_details':
          'તમારી દાતા પ્રોફાઇલ ચકાસી શકાઈ નથી. આવું થઈ શકે છે જો:\n\n1. તમે તાજેતરમાં રજિસ્ટર કર્યું છે અને તમારી પ્રોફાઇલ સંપૂર્ણપણે સિંક થઈ નથી\n2. તમારો પ્રમાણીકરણ ટોકન સમાપ્ત થયો છે\n\nકૃપા કરીને તમારા એક્રેડેન્શિયલ્સ રિફ્રેશ કરવા માટે સાઇન આઉટ કરો અને ફરી સાઇન ઇન કરો.',
      'ok': 'બરાબર',
      'sign_out_now': 'હવે સાઇન આઉટ કરો',

      // Donor history translations
      'no_donations_found': 'કોઈ દાન મળ્યા નથી',
      'create_donations_to_see': 'અહીં જોવા માટે દાન બનાવો',
      'create_donation': 'દાન બનાવો',
      'no_donation_history_found':
          'કોઈ દાનનો ઇતિહાસ મળ્યો નથી. કૃપા કરીને પછીથી ફરી પ્રયાસ કરો.',
      'sign_in_to_view_donations':
          'કૃપા કરીને તમારા દાનનો ઇતિહાસ જોવા માટે સાઇન ઇન કરો.',
      'all': 'બધા',
      'signed_out': 'સાઇન આઉટ',
      'sign_out_confirmation': 'શું તમે ખરેખર સાઇન આઉટ કરવા માંગો છો?',
      'sign_out': 'સાઇન આઉટ',
      'yes': 'હા',
      'no': 'ના',

      // View donations screen
      'available_donations': 'ઉપલબ્ધ દાન',
      'filter_donations': 'દાન ફિલ્ટર કરો',
      'food_type': 'ખોરાકનો પ્રકાર',
      'sort_by': 'આના દ્વારા ક્રમ કરો',
      'sort_by_expiry': 'સમાપ્તિ તારીખ',
      'sort_by_distance': 'અંતર',
      'sort_by_quantity': 'જથ્થો',
      'maximum_distance': 'મહત્તમ અંતર',
      'km': 'કિમી',
      'show_needs_volunteer': 'સ્વયંસેવક મદદની જરૂર હોય તેવા દાન બતાવો',
      'reset': 'રીસેટ',
      'apply_filters': 'ફિલ્ટર્સ લાગુ કરો',
      'search_food': 'ખોરાક શોધો...',
      'filter': 'ફિલ્ટર',
      'needs_volunteer': 'સ્વયંસેવકની જરૂર છે',
      'no_available_donations': 'કોઈ ઉપલબ્ધ દાન મળ્યા નથી',
      'no_results_for': 'માટે કોઈ પરિણામો મળ્યા નથી',
      'check_back_later': 'નવા દાન માટે પછીથી તપાસો',
      'try_changing_filters':
          'વધુ દાન જોવા માટે તમારા ફિલ્ટર્સ બદલવાનો પ્રયાસ કરો',
      'clear_filters': 'ફિલ્ટર્સ સાફ કરો',
      'profile_not_found_recipient':
          'તમારી પ્રોફાઇલ મળી નથી. દાન જોવા માટે તમે પ્રાપ્તકર્તા તરીકે રજિસ્ટર્ડ છો તેની ખાતરી કરો.',
      'unable_to_load_donations':
          'આ સમયે દાન લોડ કરવામાં અસમર્થ. કૃપા કરીને પછીથી ફરી પ્રયાસ કરો.',
      'retry': 'ફરી પ્રયાસ કરો',
      'go_to_profile': 'પ્રોફાઇલ પર જાઓ',
      'no_image_available': 'કોઈ છબી ઉપલબ્ધ નથી',
      'expiring_soon': 'જલ્દી સમાપ્ત થઈ રહ્યું છે',
      'quantity': 'જથ્થો',
      'servings': 'સર્વિંગ્સ',
      'tap_to_read_more': 'વધુ વાંચવા માટે ટેપ કરો',
      'donor': 'દાતા',
      'call_donor': 'દાતાને કૉલ કરો',
      'get_directions': 'દિશાઓ મેળવો',
      'expires': 'સમાપ્ત થાય છે',
      'view_details': 'વિગતો જુઓ',
      'unknown_location': 'અજ્ઞાત સ્થાન',
      'anonymous': 'અનામી',
      'error': 'ભૂલ',
      'refresh': 'રિફ્રેશ',

      // Recipient history screen
      'filter_donation_history': 'દાનનો ઇતિહાસ ફિલ્ટર કરો',
      'time_period': 'સમયગાળો',
      'today': 'આજે',
      'yesterday': 'ગઇકાલે',
      'days_ago': 'દિવસ પહેલા',
      'this_week': 'આ અઠવાડિયે',
      'this_month': 'આ મહિને',
      'time': 'સમય',
      'type': 'પ્રકાર',
      'accept_donations_to_see': 'તેમને અહીં જોવા માટે દાન સ્વીકારો',
      'browse_donations': 'દાન બ્રાઉઝ કરો',
      'no_donations_match_criteria': 'કોઈ દાન તમારા માપદંડ સાથે મેળ ખાતા નથી',
      'try_adjusting_filters':
          'વધુ દાન જોવા માટે તમારા ફિલ્ટર્સ સમાયોજિત કરવાનો પ્રયાસ કરો',
      'clear_all_filters': 'બધા ફિલ્ટર્સ સાફ કરો',
      'update_location': 'સ્થાન અપડેટ કરો',
      'location_updated_donations_refreshed':
          'સ્થાન અપડેટ કર્યું. અંતર માહિતી સાથે દાન રિફ્રેશ કર્યા.',
      'could_not_get_location':
          'તમારું સ્થાન મેળવી શક્યા નહીં. કૃપા કરીને ખાતરી કરો કે લોકેશન સેવાઓ સક્ષમ છે.',
      'error_updating_location': 'સ્થાન અપડેટ કરવામાં ભૂલ',
      'donated_by': 'દ્વારા દાન કર્યું',
      'accepted_on': 'સ્વીકૃત',
      'at': 'સમયે',
      'delivery_method': 'ડિલિવરી પદ્ધતિ',
      'self_pickup': 'સેલ્ફ-પિકઅપ',
      'add_feedback': 'પ્રતિસાદ ઉમેરો',
      'edit_feedback': 'પ્રતિસાદ સંપાદિત કરો',
      'your_feedback': 'તમારો પ્રતિસાદ',
      'share_experience_hint': 'આ દાન વિશે તમારો અનુભવ શેર કરો...',
      'feedback_submitted_successfully': 'પ્રતિસાદ સફળતાપૂર્વક સબમિટ કર્યો!',
      'error_submitting_feedback': 'પ્રતિસાદ સબમિટ કરવામાં ભૂલ',
      'distance': 'અંતર',
      'submit': 'સબમિટ કરો',

      // Donation detail screen
      'donation_details': 'દાનની વિગતો',
      'unknown_food': 'અજ્ઞાત ખોરાક',
      'no_description_available': 'કોઈ વિવરણ ઉપલબ્ધ નથી',
      'unknown': 'અજ્ઞાત',
      'servings': 'સર્વિંગ્સ',
      'anonymous_donor': 'અનામી દાતા',
      'donor_information': 'દાતાની માહિતી',
      'donor': 'દાતા',
      'location': 'સ્થાન',
      'food_description': 'ખોરાકનું વિવરણ',
      'expires': 'સમાપ્ત થાય છે',
      'exact_expiry': 'ચોક્કસ સમાપ્તિ',
      'delivery_options': 'ડિલિવરી વિકલ્પો',
      'need_volunteer_assistance': 'સ્વયંસેવક સહાયની જરૂર છે?',
      'yes_request_volunteer': 'હા, ડિલિવરી માટે સ્વયંસેવક સહાયની વિનંતી કરો',
      'no_pickup_myself': 'ના, હું આ દાન જાતે પિકઅપ કરીશ',
      'changed_from_original': 'તમે આને દાતાની મૂળ સેટિંગથી બદલી છે',
      'using_donor_preference':
          'દાતાના પસંદીદા ડિલિવરી વિકલ્પનો ઉપયોગ કરી રહ્યા છીએ',
      'accept_donation': 'આ દાન સ્વીકારો',
      'donation_accepted_with_volunteer':
          'દાન સફળતાપૂર્વક સ્વીકારવામાં આવ્યું. ડિલિવરી માટે સ્વયંસેવક સહાય કરશે.',
      'donation_accepted_self_pickup':
          'દાન સફળતાપૂર્વક સ્વીકારવામાં આવ્યું. તમારે આને જાતે લેવાની જરૂર પડશે.',
    },
    'ta': {
      // Common strings
      'app_name': 'கைண்ட்மீல்ஸ்',
      'app_slogan': 'உணவைப் பகிர்க, அன்பைப் பகிர்க',
      'get_started': 'தொடங்கவும்',
      'continue': 'தொடரவும்',
      'inspirational_quote':
          'நாம் மகிழ்ச்சியுடன் கொடுக்கும்போதும், நன்றியுடன் ஏற்றுக்கொள்ளும்போதும், அனைவரும் ஆசீர்வதிக்கப்படுகிறார்கள்.',
      'no_image_available': 'படம் கிடைக்கவில்லை',

      // Dashboard screen
      'welcome_to': 'வரவேற்கிறோம்',
      'top_volunteers': 'சிறந்த தொண்டர்கள்',
      'top_donors': 'சிறந்த நன்கொடையாளர்கள்',
      'view_full_leaderboard': 'முழு தரவரிசை பட்டியலைக் காண',
      'reviews_feedback': 'மதிப்புரைகள் & கருத்துகள்',
      'view_all_reviews': 'அனைத்து மதிப்புரைகளையும் காண',
      'support_a_cause': 'ஒரு நோக்கத்திற்கு ஆதரவளிக்க',
      'donate_to_kindmeals': 'கைண்ட்மீல்ஸுக்கு நன்கொடை அளிக்க',
      'donate_subtitle':
          'உணவு வீணாதல் மற்றும் பசியைக் குறைக்கும் எங்கள் நோக்கத்திற்கு ஆதரவளிக்கவும்',
      'donate_now': 'இப்போதே நன்கொடை அளிக்க',
      'view_all_charities': 'அனைத்து அறக்கட்டளைகளையும் காண',
      'name': 'பெயர்',
      'deliveries': 'விநியோகங்கள்',
      'meals': 'உணவுகள்',
      'no_volunteers_found': 'தொண்டர்கள் எவரும் கிடைக்கவில்லை',
      'no_donors_found': 'நன்கொடையாளர்கள் எவரும் கிடைக்கவில்லை',
      'refresh_data': 'தரவைப் புதுப்பிக்க',

      // Volunteers Screen
      'volunteers': 'தொண்டர்கள்',
      'volunteer_leaderboard': 'தொண்டர் தரவரிசைப் பட்டியல்',
      'total_volunteers': 'மொத்த தொண்டர்கள்',
      'total_deliveries': 'மொத்த விநியோகங்கள்',
      'avg_deliveries': 'சராசரி விநியோகங்கள்',
      'rank': 'தரவரிசை',
      'volunteer': 'தொண்டர்',
      'deliveries_made': 'விநியோகங்கள் செய்யப்பட்டன',
      'become_volunteer': 'தொண்டராக மாறுங்கள்',

      // Motivational content
      'feed_smile': 'இன்று ஒரு புன்னகையை உணவளிக்கவும்',
      'meal_brighten': 'ஒரு உணவு ஒருவரின் முழு நாளையும் ஒளிரச் செய்யும்',
      'share_table': 'உங்கள் மேஜையைப் பகிரவும்',
      'no_hunger': 'நமது சமூகத்தில் யாரும் பசியுடன் இருக்கக்கூடாது',
      'food_waste': 'உணவு வீணாக்கலில் இருந்து உணவு சுவைக்கு',
      'rescue_food': 'மிகுதியான உணவை மீட்டு தேவைப்படுவோருக்கு உணவளிக்கவும்',
      'donate_what': 'உங்களால் முடிந்ததை நன்கொடை அளிக்கவும்',
      'every_contribution':
          'ஒவ்வொரு பங்களிப்பும் வித்தியாசத்தை ஏற்படுத்துகிறது',
      'hunger_stat': '9 பேரில் 1 பேர் பசியுடன் உள்ளனர்',
      'change_stat': 'உங்கள் நன்கொடை இந்த புள்ளிவிவரத்தை மாற்றும்',

      // Social Media Footer
      'privacy_policy': 'தனியுரிமைக் கொள்கை',
      'terms_of_service': 'சேவை விதிமுறைகள்',
      'contact_us': 'எங்களை தொடர்பு கொள்ள',
      'all_rights_reserved':
          '© 2025 கைண்ட்மீல்ஸ். அனைத்து உரிமைகளும் பாதுகாக்கப்பட்டவை.',

      // Profile Screen
      'profile': 'சுயவிவரம்',
      'try_again': 'மீண்டும் முயற்சிக்கவும்',
      'edit': 'திருத்து',
      'logout': 'வெளியேறு',
      'logout_confirm': 'நிச்சயமாக வெளியேற விரும்புகிறீர்களா?',
      'cancel': 'ரத்து செய்',
      'error_loading_profile': 'சுயவிவரத்தை ஏற்றுவதில் பிழை',
      'change_language': 'மொழியை மாற்று',
      'personal_information': 'தனிப்பட்ட தகவல்',
      'contact_information': 'தொடர்பு தகவல்',
      'organization_information': 'நிறுவன தகவல்',
      'about': 'பற்றி',
      'full_name': 'முழுப் பெயர்',
      'email_address': 'மின்னஞ்சல் முகவரி',
      'contact_number': 'தொடர்பு எண்',
      'address': 'முகவரி',
      'organization_name': 'நிறுவனத்தின் பெயர்',
      'organization_id': 'நிறுவன அடையாள எண்',
      'description': 'விளக்கம்',
      'no_description': 'விளக்கம் எதுவும் கிடைக்கவில்லை',
      'profile_image_updated': 'சுயவிவரப் படம் வெற்றிகரமாக புதுப்பிக்கப்பட்டது',
      'failed_upload_image': 'சுயவிவரப் படத்தை பதிவேற்றுவதில் தோல்வி:',
      'logout_failed': 'வெளியேறுவதில் தோல்வி:',

      // Language screen
      'select_language': 'மொழியைத் தேர்ந்தெடுக்கவும்',
      'choose_language': 'உங்களுக்கு விருப்பமான மொழியைத் தேர்ந்தெடுக்கவும்',

      // Login screen
      'login': 'உள்நுழைக',
      'email': 'மின்னஞ்சல்',
      'password': 'கடவுச்சொல்',
      'forgot_password': 'கடவுச்சொல் மறந்துவிட்டதா?',
      'or': 'அல்லது',
      'continue_with_google': 'Google மூலம் தொடரவும்',
      'dont_have_account': 'கணக்கு இல்லையா?',
      'register': 'பதிவு செய்',
      'want_to_help': 'மக்களுக்கு உதவ விரும்புகிறீர்களா?',
      'register_as_volunteer': 'தொண்டராக பதிவு செய்யவும்',
      'login_successful': 'உள்நுழைவு வெற்றி!',
      'google_signup': 'Google மூலம் தொடரவும்',

      // Register screen
      'aadhar_id': 'ஆதார் அடையாள அட்டை / உணவகம் அடையாள அட்டை',
      'address': 'முகவரி / இருப்பிடம் (கண்டறிய கிளிக் செய்யவும்)',
      'contact': 'தொடர்பு எண்',
      'about': 'பற்றி',
      'org_name': 'நிறுவனத்தின் பெயர் / தனிநபர்',
      'user_type': 'வகை',
      'profile_pic': 'சுயவிவரப் படத்தைச் சேர்க்கவும்',
      'change_profile_pic': 'சுயவிவரப் படத்தை மாற்றவும்',
      'registration_successful': 'பதிவு வெற்றி!',
      'get_address':
          'இருப்பிட பொத்தானைக் கிளிக் செய்வதன் மூலம் உங்கள் முகவரியைப் பெறவும்',
      'type': 'வகை',
      'contact_number': 'தொடர்பு எண்',

      // Register volunteer screen
      'volunteer_registration': 'தொண்டர் பதிவு',
      'full_name': 'முழுப் பெயர்',
      'aadhar_number': 'ஆதார் எண்',
      'address_click_detect': 'முகவரி (கண்டறிய கிளிக் செய்யவும்)',
      'about_yourself': 'உங்களைப் பற்றி',
      'have_vehicle': 'விநியோகங்களுக்கு உங்களிடம் வாகனம் உள்ளதா?',
      'vehicle_type': 'வாகன வகை',
      'vehicle_number': 'வாகன எண்',
      'driving_license': 'ஓட்டுநர் உரிமப் படம்',
      'upload_license': 'உரிமப் படத்தைப் பதிவேற்றவும்',

      // Logout
      'logging_out': 'வெளியேறுகிறது...',
      'error_logout': 'வெளியேறுவதில் பிழை: ',

      // Validation messages
      'enter_email': 'உங்கள் மின்னஞ்சலை உள்ளிடவும்',
      'valid_email': 'சரியான மின்னஞ்சலை உள்ளிடவும்',
      'enter_password': 'உங்கள் கடவுச்சொல்லை உள்ளிடவும்',
      'password_length': 'கடவுச்சொல் குறைந்தது 6 எழுத்துகள் இருக்க வேண்டும்',
      'enter_name': 'உங்கள் பெயரை உள்ளிடவும்',
      'enter_id': 'உங்கள் அடையாள எண்ணை உள்ளிடவும்',
      'enter_contact': 'உங்கள் தொடர்பு எண்ணை உள்ளிடவும்',
      'valid_contact': 'சரியான தொடர்பு எண்ணை உள்ளிடவும்',
      'enter_about': 'உங்களைப் பற்றி உள்ளிடவும்',
      'enter_org_name': 'நிறுவனத்தின் பெயர் அல்லது தனிநபர் பெயரை உள்ளிடவும்',
      'select_type': 'ஒரு வகையைத் தேர்ந்தெடுக்கவும்',
      'select_vehicle_type': 'வாகன வகையைத் தேர்ந்தெடுக்கவும்',
      'enter_vehicle_number': 'உங்கள் வாகன எண்ணை உள்ளிடவும்',

      // Charity related translations
      'donate_to_charity': 'அறக்கட்டளைக்கு நன்கொடை அளிக்க',
      'error': 'பிழை',
      'no_charities_available': 'அறக்கட்டளைகள் எதுவும் கிடைக்கவில்லை',
      'check_back_later':
          'அறக்கட்டளை நன்கொடை வாய்ப்புகளுக்கு பின்னர் மீண்டும் சரிபார்க்கவும்',
      'refresh': 'புதுப்பிக்க',
      'make_a_difference': 'வித்தியாசத்தை ஏற்படுத்துங்கள்',
      'contribution_help':
          'உங்கள் பங்களிப்பு தேவைப்படுவோருக்கு உதவலாம். நன்கொடை அளிக்க கீழே ஒரு அறக்கட்டளையைத் தேர்ந்தெடுக்கவும்.',
      'food_relief': 'உணவு நிவாரணம்',
      'from': 'இருந்து',
      'make_a_donation': 'நன்கொடை அளிக்க',
      'donation_history': 'நன்கொடை வரலாறு',
      'select_amount': 'தொகையைத் தேர்ந்தெடுக்கவும்',
      'custom_amount': 'விருப்ப தொகை',
      'your_information': 'உங்கள் தகவல்',
      'full_name': 'முழுப் பெயர்',
      'email': 'மின்னஞ்சல்',
      'phone_number': 'தொலைபேசி எண்',
      'request_tax_benefits': 'வரி சலுகைகளைக் கோரவும் (80G)',
      'pan_card_number': 'பான் அட்டை எண்',
      'required_for_tax_benefits': 'வரி சலுகைகளுக்கு தேவை',
      'payment_method': 'கட்டண முறை',
      'credit_debit_card': 'கிரெடிட்/டெபிட் அட்டை',
      'net_banking': 'இணையவழி வங்கி',
      'upi_gpay_phonepe': 'UPI / Google Pay / PhonePe',
      'initializing_payment': 'கட்டணத்தைத் தொடங்குகிறது...',
      'processing_donation': 'உங்கள் நன்கொடையை செயலாக்குகிறது...',
      'thank_you': 'நன்றி!',
      'donation_successful': 'உங்கள் நன்கொடை வெற்றி!',
      'amount': 'தொகை',
      'date': 'தேதி',
      'transaction_id': 'பரிவர்த்தனை அடையாள எண்',
      'charity': 'அறக்கட்டளை',
      'contribution_difference':
          'உங்கள் பங்களிப்பு ஒருவரின் வாழ்க்கையில் உண்மையான வித்தியாசத்தை ஏற்படுத்தும்.',
      'view_history': 'வரலாற்றைக் காண',
      'done': 'முடிந்தது',
      'information_secure':
          'உங்கள் தகவல் பாதுகாப்பானது மற்றும் நன்கொடை நோக்கங்களுக்கு மட்டுமே பயன்படுத்தப்படும்.',
      'support_our_cause': 'எங்கள் நோக்கத்திற்கு ஆதரவளிக்கவும்',

      // Post Donation Screen
      'post_donation': 'நன்கொடை இடுகை',
      'refresh_authentication': 'அங்கீகாரத்தைப் புதுப்பிக்க',
      'sign_out_sign_in_again': 'வெளியேறிவிட்டு மீண்டும் உள்நுழைக',
      'go_to_profile': 'சுயவிவரத்திற்குச் செல்க',
      'go_back': 'திரும்பிச் செல்',
      'refresh_profile_note':
          'குறிப்பு: நீங்கள் சமீபத்தில் பதிவு செய்திருந்தால், உங்கள் சுயவிவர நிலையைப் புதுப்பிக்க வெளியேறி, மீண்டும் உள்நுழைக.',
      'refresh_status': 'நிலையைப் புதுப்பிக்க',
      'food_name': 'உணவின் பெயர்',
      'please_enter_food_name': 'உணவின் பெயரை உள்ளிடவும்',
      'quantity': 'அளவு',
      'please_enter_quantity': 'அளவை உள்ளிடவும்',
      'please_enter_valid_number': 'சரியான எண்ணை உள்ளிடவும்',
      'description': 'விளக்கம்',
      'please_enter_description': 'விளக்கத்தை உள்ளிடவும்',
      'food_type': 'உணவு வகை',
      'veg': 'சைவம்',
      'nonveg': 'அசைவம்',
      'jain': 'ஜைனம்',
      'please_select_food_type': 'உணவு வகையைத் தேர்ந்தெடுக்கவும்',
      'pickup_address_click_detect':
          'எடுக்கும் முகவரி (கண்டறிய கிளிக் செய்யவும்)',
      'get_current_location': 'தற்போதைய இருப்பிடத்தைப் பெறவும்',
      'please_get_pickup_address':
          'இருப்பிட பொத்தானைக் கிளிக் செய்வதன் மூலம் எடுக்கும் முகவரியைப் பெறவும்',
      'location': 'இருப்பிடம்',
      'expiry_date_time': 'காலாவதி தேதி & நேரம்',
      'select_expiry_date_time':
          'காலாவதி தேதி மற்றும் நேரத்தைத் தேர்ந்தெடுக்கவும்',
      'please_select_expiry_date_time':
          'சரியான காலாவதி தேதி மற்றும் நேரத்தைத் தேர்ந்தெடுக்கவும்',
      'local_time': 'உள்ளூர் நேரம்',
      'need_volunteer_for_delivery': 'விநியோகத்திற்கு தொண்டர் தேவை',
      'volunteer_note':
          'குறிப்பு: உங்கள் நன்கொடையை ஒரு பெறுநர் ஏற்றுக்கொள்ளும்போது, அவர்கள் விநியோகத்திற்கு தொண்டர் உதவியைக் கோரலாம்.',
      'donation_posted_successfully': 'நன்கொடை வெற்றிகரமாக பதிவிடப்பட்டது!',
      'failed_to_post_donation':
          'நன்கொடையை பதிவிட முடியவில்லை. மீண்டும் முயற்சிக்கவும்.',
      'authentication_error_refresh':
          'அங்கீகார பிழை: உங்கள் அறிமுகச் சான்றுகளைப் புதுப்பிக்க வெளியேறிவிட்டு மீண்டும் உள்நுழைக.',
      'authentication_error': 'அங்கீகார பிழை',
      'auth_error_details':
          'உங்கள் நன்கொடையாளர் சுயவிவரத்தைச் சரிபார்க்க முடியவில்லை. இது நடக்கலாம் ஏனெனில்:\n\n1. நீங்கள் சமீபத்தில் பதிவு செய்துள்ளீர்கள் மற்றும் உங்கள் சுயவிவரம் முழுமையாக ஒத்திசைக்கப்படவில்லை\n2. உங்கள் அங்கீகார டோக்கன் காலாவதியாகிவிட்டது\n\nஉங்கள் அறிமுகச் சான்றுகளைப் புதுப்பிக்க வெளியேறிவிட்டு மீண்டும் உள்நுழைக.',
      'ok': 'சரி',
      'sign_out_now': 'இப்போது வெளியேறு',

      // Donor history translations
      'no_donations_found': 'நன்கொடைகள் எதுவும் கிடைக்கவில்லை',
      'create_donations_to_see': 'இங்கே பார்க்க ஒரு நன்கொடையை உருவாக்கவும்',
      'create_donation': 'நன்கொடை உருவாக்க',
      'no_donation_history_found':
          'நன்கொடை வரலாறு எதுவும் கிடைக்கவில்லை. பின்னர் மீண்டும் முயற்சிக்கவும்.',
      'sign_in_to_view_donations': 'உங்கள் நன்கொடை வரலாற்றைக் காண உள்நுழைக.',
      'all': 'அனைத்தும்',
      'signed_out': 'வெளியேறியுள்ளீர்',
      'sign_out_confirmation': 'நிச்சயமாக வெளியேற விரும்புகிறீர்களா?',
      'sign_out': 'வெளியேறு',
      'yes': 'ஆம்',
      'no': 'இல்லை',

      // View donations screen
      'available_donations': 'கிடைக்கக்கூடிய நன்கொடைகள்',
      'filter_donations': 'நன்கொடைகளை வடிகட்டவும்',
      'food_type': 'உணவு வகை',
      'sort_by': 'வரிசைப்படுத்துவது',
      'sort_by_expiry': 'காலாவதி தேதி',
      'sort_by_distance': 'தூரம்',
      'sort_by_quantity': 'அளவு',
      'maximum_distance': 'அதிகபட்ச தூரம்',
      'km': 'கி.மீ',
      'show_needs_volunteer': 'தொண்டர் உதவி தேவைப்படும் நன்கொடைகளைக் காட்டு',
      'reset': 'மீட்டமை',
      'apply_filters': 'வடிகட்டிகளைப் பயன்படுத்து',
      'search_food': 'உணவைத் தேடு...',
      'filter': 'வடிகட்டி',
      'needs_volunteer': 'தொண்டர் தேவை',
      'no_available_donations':
          'கிடைக்கக்கூடிய நன்கொடைகள் எதுவும் கிடைக்கவில்லை',
      'no_results_for': 'இதற்கான முடிவுகள் இல்லை',
      'check_back_later':
          'புதிய நன்கொடைகளுக்கு பின்னர் மீண்டும் சரிபார்க்கவும்',
      'try_changing_filters':
          'மேலும் நன்கொடைகளைக் காண உங்கள் வடிகட்டிகளை மாற்ற முயற்சிக்கவும்',
      'clear_filters': 'வடிகட்டிகளை அழிக்க',
      'profile_not_found_recipient':
          'உங்கள் சுயவிவரம் கிடைக்கவில்லை. நன்கொடைகளைக் காண நீங்கள் பெறுநராக பதிவு செய்துள்ளீர்கள் என்பதை உறுதிப்படுத்திக் கொள்ளுங்கள்.',
      'unable_to_load_donations':
          'இந்த நேரத்தில் நன்கொடைகளை ஏற்ற முடியாது. பின்னர் மீண்டும் முயற்சிக்கவும்.',
      'retry': 'மீண்டும் முயற்சிக்கவும்',
      'go_to_profile': 'சுயவிவரத்திற்குச் செல்க',
      'no_image_available': 'படம் கிடைக்கவில்லை',
      'expiring_soon': 'விரைவில் காலாவதியாகிறது',
      'quantity': 'அளவு',
      'servings': 'பரிமாறல்கள்',
      'tap_to_read_more': 'மேலும் படிக்க தட்டவும்',
      'donor': 'நன்கொடையாளர்',
      'call_donor': 'நன்கொடையாளரை அழைக்க',
      'get_directions': 'வழிகளைப் பெறுக',
      'expires': 'காலாவதியாகும்',
      'view_details': 'விவரங்களைக் காண',
      'unknown_location': 'தெரியாத இருப்பிடம்',
      'anonymous': 'அடையாளம் தெரியாத',
      'error': 'பிழை',
      'refresh': 'புதுப்பிக்க',

      // Recipient history screen
      'filter_donation_history': 'நன்கொடை வரலாற்றை வடிகட்டவும்',
      'time_period': 'கால அளவு',
      'today': 'இன்று',
      'yesterday': 'நேற்று',
      'days_ago': 'நாட்களுக்கு முன்',
      'this_week': 'இந்த வாரம்',
      'this_month': 'இந்த மாதம்',
      'time': 'நேரம்',
      'type': 'வகை',
      'accept_donations_to_see': 'இங்கே பார்க்க நன்கொடைகளை ஏற்றுக்கொள்ளவும்',
      'browse_donations': 'நன்கொடைகளை உலாவவும்',
      'no_donations_match_criteria':
          'உங்கள் அளவுகோல்களுடன் எந்த நன்கொடைகளும் பொருந்தவில்லை',
      'try_adjusting_filters':
          'மேலும் நன்கொடைகளைக் காண உங்கள் வடிகட்டிகளைச் சரிசெய்ய முயற்சிக்கவும்',
      'clear_all_filters': 'அனைத்து வடிகட்டிகளையும் அழிக்க',
      'update_location': 'இருப்பிடத்தைப் புதுப்பிக்க',
      'location_updated_donations_refreshed':
          'இருப்பிடம் புதுப்பிக்கப்பட்டது. தூர தகவலுடன் நன்கொடைகள் புதுப்பிக்கப்பட்டன.',
      'could_not_get_location':
          'உங்கள் இருப்பிடத்தைப் பெற முடியவில்லை. இருப்பிட சேவைகள் இயக்கப்பட்டுள்ளதை உறுதிசெய்யவும்.',
      'error_updating_location': 'இருப்பிடத்தைப் புதுப்பிப்பதில் பிழை',
      'donated_by': 'நன்கொடை அளித்தவர்',
      'accepted_on': 'ஏற்றுக்கொள்ளப்பட்ட தேதி',
      'at': 'இல்',
      'delivery_method': 'விநியோக முறை',
      'self_pickup': 'சுய-எடுப்பு',
      'add_feedback': 'கருத்தை சேர்க்க',
      'edit_feedback': 'கருத்தைத் திருத்த',
      'your_feedback': 'உங்கள் கருத்து',
      'share_experience_hint':
          'இந்த நன்கொடை பற்றிய உங்கள் அனுபவத்தைப் பகிரவும்...',
      'feedback_submitted_successfully':
          'கருத்து வெற்றிகரமாக சமர்ப்பிக்கப்பட்டது!',
      'error_submitting_feedback': 'கருத்தைச் சமர்ப்பிப்பதில் பிழை',
      'distance': 'தூரம்',
      'submit': 'சமர்ப்பிக்க',

      // Donation detail screen
      'donation_details': 'நன்கொடை விவரங்கள்',
      'unknown_food': 'தெரியாத உணவு',
      'no_description_available': 'விளக்கம் எதுவும் கிடைக்கவில்லை',
      'unknown': 'தெரியாத',
      'servings': 'பரிமாறல்கள்',
      'anonymous_donor': 'அடையாளம் தெரியாத நன்கொடையாளர்',
      'donor_information': 'நன்கொடையாளர் தகவல்',
      'donor': 'நன்கொடையாளர்',
      'location': 'இருப்பிடம்',
      'food_description': 'உணவு விளக்கம்',
      'expires': 'காலாவதியாகும்',
      'exact_expiry': 'துல்லியமான காலாவதி',
      'delivery_options': 'விநியோக விருப்பங்கள்',
      'need_volunteer_assistance': 'தொண்டர் உதவி தேவையா?',
      'yes_request_volunteer': 'ஆம், விநியோகத்திற்கு தொண்டர் உதவியை கோரவும்',
      'no_pickup_myself': 'இல்லை, நான் இந்த நன்கொடையை நானே எடுத்துச் செல்வேன்',
      'changed_from_original':
          'நன்கொடையாளரின் அசல் அமைப்பிலிருந்து இதை மாற்றியுள்ளீர்கள்',
      'using_donor_preference':
          'நன்கொடையாளரின் விருப்பமான விநியோக விருப்பத்தைப் பயன்படுத்துகிறது',
      'accept_donation': 'இந்த நன்கொடையை ஏற்றுக்கொள்ளவும்',
      'donation_accepted_with_volunteer':
          'நன்கொடை வெற்றிகரமாக ஏற்றுக்கொள்ளப்பட்டது. ஒரு தொண்டர் விநியோகத்திற்கு உதவுவார்.',
      'donation_accepted_self_pickup':
          'நன்கொடை வெற்றிகரமாக ஏற்றுக்கொள்ளப்பட்டது. நீங்கள் இதை சுயமாக சேகரிக்க வேண்டியிருக்கும்.',
    },
    'bn': {
      // Common strings
      'app_name': 'কাইন্ডমিলস',
      'app_slogan': 'খাবার ভাগ করুন, ভালোবাসা ভাগ করুন',
      'get_started': 'শুরু করুন',
      'continue': 'চালিয়ে যান',
      'inspirational_quote':
          'যখন আমরা আনন্দের সাথে দেই এবং কৃতজ্ঞতার সাথে গ্রহণ করি, তখন সবাই আশীর্বাদপ্রাপ্ত হয়',
      'no_image_available': 'কোন ছবি উপলব্ধ নেই',

      // Dashboard screen
      'welcome_to': 'স্বাগতম',
      'top_volunteers': 'সেরা স্বেচ্ছাসেবকগণ',
      'top_donors': 'সেরা দাতাগণ',
      'view_full_leaderboard': 'পূর্ণ লিডারবোর্ড দেখুন',
      'reviews_feedback': 'পর্যালোচনা ও মতামত',
      'view_all_reviews': 'সমস্ত পর্যালোচনা দেখুন',
      'support_a_cause': 'একটি কারণ সমর্থন করুন',
      'donate_to_kindmeals': 'কাইন্ডমিলসে দান করুন',
      'donate_subtitle': 'খাদ্য অপচয় এবং ক্ষুধা কমাতে আমাদের মিশন সমর্থন করুন',
      'donate_now': 'এখনই দান করুন',
      'view_all_charities': 'সমস্ত দাতব্য প্রতিষ্ঠান দেখুন',
      'name': 'নাম',
      'deliveries': 'ডেলিভারি',
      'meals': 'খাবার',
      'no_volunteers_found': 'কোন স্বেচ্ছাসেবক পাওয়া যায়নি',
      'no_donors_found': 'কোন দাতা পাওয়া যায়নি',
      'refresh_data': 'তথ্য রিফ্রেশ করুন',

      // Volunteers Screen
      'volunteers': 'স্বেচ্ছাসেবকগণ',
      'volunteer_leaderboard': 'স্বেচ্ছাসেবক লিডারবোর্ড',
      'total_volunteers': 'মোট স্বেচ্ছাসেবক',
      'total_deliveries': 'মোট ডেলিভারি',
      'avg_deliveries': 'গড় ডেলিভারি',
      'rank': 'র‍্যাঙ্ক',
      'volunteer': 'স্বেচ্ছাসেবক',
      'deliveries_made': 'ডেলিভারি করেছেন',
      'become_volunteer': 'স্বেচ্ছাসেবক হউন',

      // Motivational content
      'feed_smile': 'আজ একটি হাসি খাওয়ান',
      'meal_brighten': 'একটি খাবার কারও সারাদিন উজ্জ্বল করতে পারে',
      'share_table': 'আপনার টেবিল ভাগ করুন',
      'no_hunger': 'আমাদের সম্প্রদায়ে কাউকে ক্ষুধার্ত থাকা উচিত নয়',
      'food_waste': 'খাদ্য অপচয় থেকে খাদ্য স্বাদ',
      'rescue_food': 'অতিরিক্ত খাবার উদ্ধার করুন এবং প্রয়োজনীয়দের খাওয়ান',
      'donate_what': 'যা পারেন তাই দান করুন',
      'every_contribution': 'প্রতিটি অবদান পার্থক্য তৈরি করে',
      'hunger_stat': 'প্রতি ৯ জনে ১ জন ক্ষুধার্ত থাকে',
      'change_stat': 'আপনার দান এই পরিসংখ্যান পরিবর্তন করতে পারে',

      // Social Media Footer
      'privacy_policy': 'গোপনীয়তা নীতি',
      'terms_of_service': 'সেবার শর্তাবলী',
      'contact_us': 'যোগাযোগ করুন',
      'all_rights_reserved': '© ২০২৫ কাইন্ডমিলস। সর্বস্বত্ব সংরক্ষিত।',

      // Profile Screen
      'profile': 'প্রোফাইল',
      'try_again': 'আবার চেষ্টা করুন',
      'edit': 'সম্পাদনা',
      'logout': 'লগআউট',
      'logout_confirm': 'আপনি কি নিশ্চিত যে আপনি লগআউট করতে চান?',
      'cancel': 'বাতিল',
      'error_loading_profile': 'প্রোফাইল লোড করতে সমস্যা',
      'change_language': 'ভাষা পরিবর্তন করুন',
      'personal_information': 'ব্যক্তিগত তথ্য',
      'contact_information': 'যোগাযোগের তথ্য',
      'organization_information': 'সংস্থার তথ্য',
      'about': 'সম্পর্কে',
      'full_name': 'পুরো নাম',
      'email_address': 'ইমেইল ঠিকানা',
      'contact_number': 'যোগাযোগের নম্বর',
      'address': 'ঠিকানা',
      'organization_name': 'সংস্থার নাম',
      'organization_id': 'সংস্থার আইডি',
      'description': 'বিবরণ',
      'no_description': 'কোন বিবরণ উপলব্ধ নেই',
      'profile_image_updated': 'প্রোফাইল ছবি সফলভাবে আপডেট করা হয়েছে',
      'failed_upload_image': 'প্রোফাইল ছবি আপলোড করতে ব্যর্থ:',
      'logout_failed': 'লগআউট ব্যর্থ:',

      // Language screen
      'select_language': 'ভাষা নির্বাচন করুন',
      'choose_language': 'আপনার পছন্দের ভাষা চয়ন করুন',

      // Login screen
      'login': 'লগইন',
      'email': 'ইমেইল',
      'password': 'পাসওয়ার্ড',
      'forgot_password': 'পাসওয়ার্ড ভুলে গেছেন?',
      'or': 'অথবা',
      'continue_with_google': 'গুগল দিয়ে চালিয়ে যান',
      'dont_have_account': 'অ্যাকাউন্ট নেই?',
      'register': 'নিবন্ধন করুন',
      'want_to_help': 'মানুষকে সাহায্য করতে চান?',
      'register_as_volunteer': 'স্বেচ্ছাসেবক হিসাবে নিবন্ধন করুন',
      'login_successful': 'লগইন সফল!',
      'google_signup': 'গুগল দিয়ে চালিয়ে যান',

      // Register screen
      'aadhar_id': 'আধার আইডি / রেস্তোরাঁ আইডি',
      'address': 'ঠিকানা / অবস্থান (সনাক্ত করতে ক্লিক করুন)',
      'contact': 'যোগাযোগের নম্বর',
      'about': 'সম্পর্কে',
      'org_name': 'সংস্থার নাম / ব্যক্তিগত',
      'user_type': 'ধরন',
      'profile_pic': 'প্রোফাইল ছবি যোগ করুন',
      'change_profile_pic': 'প্রোফাইল ছবি পরিবর্তন করুন',
      'registration_successful': 'নিবন্ধন সফল!',
      'get_address': 'অনুগ্রহ করে অবস্থান বাটনে ক্লিক করে আপনার ঠিকানা নিন',
      'type': 'ধরন',
      'contact_number': 'যোগাযোগের নম্বর',

      // Register volunteer screen
      'volunteer_registration': 'স্বেচ্ছাসেবক নিবন্ধন',
      'full_name': 'পুরো নাম',
      'aadhar_number': 'আধার নম্বর',
      'address_click_detect': 'ঠিকানা (সনাক্ত করতে ক্লিক করুন)',
      'about_yourself': 'নিজের সম্পর্কে',
      'have_vehicle': 'আপনার কি ডেলিভারির জন্য গাড়ি আছে?',
      'vehicle_type': 'গাড়ির ধরন',
      'vehicle_number': 'গাড়ির নম্বর',
      'driving_license': 'ড্রাইভিং লাইসেন্স ছবি',
      'upload_license': 'লাইসেন্স ছবি আপলোড করুন',

      // Logout
      'logging_out': 'লগআউট হচ্ছে...',
      'error_logout': 'লগআউট করতে ত্রুটি: ',

      // Validation messages
      'enter_email': 'অনুগ্রহ করে আপনার ইমেইল প্রবেশ করান',
      'valid_email': 'অনুগ্রহ করে একটি বৈধ ইমেইল প্রবেশ করান',
      'enter_password': 'অনুগ্রহ করে আপনার পাসওয়ার্ড প্রবেশ করান',
      'password_length': 'পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে',
      'enter_name': 'অনুগ্রহ করে আপনার নাম প্রবেশ করান',
      'enter_id': 'অনুগ্রহ করে আপনার আইডি প্রবেশ করান',
      'enter_contact': 'অনুগ্রহ করে আপনার যোগাযোগের নম্বর প্রবেশ করান',
      'valid_contact': 'অনুগ্রহ করে একটি বৈধ যোগাযোগের নম্বর প্রবেশ করান',
      'enter_about': 'অনুগ্রহ করে নিজের সম্পর্কে লিখুন',
      'enter_org_name': 'অনুগ্রহ করে সংস্থার নাম বা ব্যক্তিগত নাম প্রবেশ করান',
      'select_type': 'অনুগ্রহ করে একটি ধরন নির্বাচন করুন',
      'select_vehicle_type': 'অনুগ্রহ করে একটি গাড়ির ধরন নির্বাচন করুন',
      'enter_vehicle_number': 'অনুগ্রহ করে আপনার গাড়ির নম্বর প্রবেশ করান',

      // Charity related translations
      'donate_to_charity': 'দাতব্য প্রতিষ্ঠানে দান করুন',
      'error': 'ত্রুটি',
      'no_charities_available': 'কোন দাতব্য প্রতিষ্ঠান উপলব্ধ নেই',
      'check_back_later': 'দাতব্য দানের সুযোগের জন্য পরে আবার দেখুন',
      'refresh': 'রিফ্রেশ',
      'make_a_difference': 'পার্থক্য তৈরি করুন',
      'contribution_help':
          'আপনার অবদান প্রয়োজনীয়দের সাহায্য করতে পারে। দান করতে নীচের একটি দাতব্য প্রতিষ্ঠান বেছে নিন।',
      'food_relief': 'খাদ্য সাহায্য',
      'from': 'থেকে',
      'make_a_donation': 'দান করুন',
      'donation_history': 'দানের ইতিহাস',
      'select_amount': 'পরিমাণ নির্বাচন করুন',
      'custom_amount': 'কাস্টম পরিমাণ',
      'your_information': 'আপনার তথ্য',
      'full_name': 'পুরো নাম',
      'email': 'ইমেইল',
      'phone_number': 'ফোন নম্বর',
      'request_tax_benefits': 'কর সুবিধা অনুরোধ করুন (৮০জি)',
      'pan_card_number': 'প্যান কার্ড নম্বর',
      'required_for_tax_benefits': 'কর সুবিধার জন্য প্রয়োজনীয়',
      'payment_method': 'পেমেন্ট পদ্ধতি',
      'credit_debit_card': 'ক্রেডিট/ডেবিট কার্ড',
      'net_banking': 'নেট ব্যাঙ্কিং',
      'upi_gpay_phonepe': 'ইউপিআই / গুগল পে / ফোনপে',
      'initializing_payment': 'পেমেন্ট শুরু করা হচ্ছে...',
      'processing_donation': 'আপনার দান প্রক্রিয়া করা হচ্ছে...',
      'thank_you': 'ধন্যবাদ!',
      'donation_successful': 'আপনার দান সফল হয়েছে!',
      'amount': 'পরিমাণ',
      'date': 'তারিখ',
      'transaction_id': 'লেনদেন আইডি',
      'charity': 'দাতব্য প্রতিষ্ঠান',
      'contribution_difference':
          'আপনার অবদান কারও জীবনে একটি বাস্তব পার্থক্য তৈরি করবে।',
      'view_history': 'ইতিহাস দেখুন',
      'done': 'সম্পন্ন',
      'information_secure':
          'আপনার তথ্য সুরক্ষিত এবং শুধুমাত্র দানের উদ্দেশ্যে ব্যবহৃত হবে।',
      'support_our_cause': 'আমাদের কারণ সমর্থন করুন',

      // Post Donation Screen
      'post_donation': 'দান পোস্ট করুন',
      'refresh_authentication': 'প্রমাণীকরণ রিফ্রেশ করুন',
      'sign_out_sign_in_again': 'সাইন আউট করুন এবং আবার সাইন ইন করুন',
      'go_to_profile': 'প্রোফাইলে যান',
      'go_back': 'ফিরে যান',
      'refresh_profile_note':
          'নোট: আপনি যদি সবেমাত্র নিবন্ধন করে থাকেন, তাহলে আপনার প্রোফাইল স্ট্যাটাস রিফ্রেশ করতে লগ আউট করে আবার লগ ইন করুন।',
      'refresh_status': 'স্ট্যাটাস রিফ্রেশ করুন',
      'food_name': 'খাবারের নাম',
      'please_enter_food_name': 'অনুগ্রহ করে খাবারের নাম প্রবেশ করান',
      'quantity': 'পরিমাণ',
      'please_enter_quantity': 'অনুগ্রহ করে পরিমাণ প্রবেশ করান',
      'please_enter_valid_number': 'অনুগ্রহ করে একটি বৈধ সংখ্যা প্রবেশ করান',
      'description': 'বিবরণ',
      'please_enter_description': 'অনুগ্রহ করে বিবরণ প্রবেশ করান',
      'food_type': 'খাবারের ধরন',
      'veg': 'নিরামিষ',
      'nonveg': 'আমিষ',
      'jain': 'জৈন',
      'please_select_food_type': 'অনুগ্রহ করে খাবারের ধরন নির্বাচন করুন',
      'pickup_address_click_detect': 'পিকআপ ঠিকানা (সনাক্ত করতে ক্লিক করুন)',
      'get_current_location': 'বর্তমান অবস্থান নিন',
      'please_get_pickup_address':
          'অনুগ্রহ করে অবস্থান বাটনে ক্লিক করে পিকআপ ঠিকানা নিন',
      'location': 'অবস্থান',
      'expiry_date_time': 'মেয়াদ শেষের তারিখ ও সময়',
      'select_expiry_date_time': 'মেয়াদ শেষের তারিখ ও সময় নির্বাচন করুন',
      'please_select_expiry_date_time':
          'অনুগ্রহ করে একটি বৈধ মেয়াদ শেষের তারিখ ও সময় নির্বাচন করুন',
      'local_time': 'স্থানীয় সময়',
      'need_volunteer_for_delivery': 'ডেলিভারির জন্য স্বেচ্ছাসেবক প্রয়োজন',
      'volunteer_note':
          'নোট: যখন আপনার দান একজন গ্রহীতা দ্বারা গৃহীত হবে, তখন তারা ডেলিভারির জন্য একজন স্বেচ্ছাসেবক অনুরোধ করতে পারবেন।',
      'donation_posted_successfully': 'দান সফলভাবে পোস্ট করা হয়েছে!',
      'failed_to_post_donation':
          'দান পোস্ট করতে ব্যর্থ হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।',
      'authentication_error_refresh':
          'প্রমাণীকরণ ত্রুটি: আপনার শংসাপত্র রিফ্রেশ করতে অনুগ্রহ করে সাইন আউট করুন এবং আবার সাইন ইন করুন।',
      'authentication_error': 'প্রমাণীকরণ ত্রুটি',
      'auth_error_details':
          'আপনার দাতা প্রোফাইল যাচাই করা যায়নি। এটি হতে পারে যদি:\n\n১. আপনি সম্প্রতি নিবন্ধন করেছেন এবং আপনার প্রোফাইল সম্পূর্ণভাবে সিঙ্ক হয়নি\n২. আপনার প্রমাণীকরণ টোকেনের মেয়াদ শেষ হয়েছে\n\nঅনুগ্রহ করে আপনার শংসাপত্র রিফ্রেশ করতে সাইন আউট করুন এবং আবার সাইন ইন করুন।',
      'ok': 'ঠিক আছে',
      'sign_out_now': 'এখনই সাইন আউট করুন',

      // Donor history translations
      'no_donations_found': 'কোন দান পাওয়া যায়নি',
      'create_donations_to_see': 'এখানে দেখতে একটি দান তৈরি করুন',
      'create_donation': 'দান তৈরি করুন',
      'no_donation_history_found':
          'কোন দানের ইতিহাস পাওয়া যায়নি। অনুগ্রহ করে পরে আবার চেষ্টা করুন।',
      'sign_in_to_view_donations':
          'আপনার দানের ইতিহাস দেখতে অনুগ্রহ করে সাইন ইন করুন।',
      'all': 'সকল',
      'signed_out': 'সাইন আউট',
      'sign_out_confirmation': 'আপনি কি নিশ্চিত যে আপনি সাইন আউট করতে চান?',
      'sign_out': 'সাইন আউট',
      'yes': 'হ্যাঁ',
      'no': 'না',

      // View donations screen
      'available_donations': 'উপলব্ধ দান',
      'filter_donations': 'দান ফিল্টার করুন',
      'food_type': 'খাবারের ধরন',
      'sort_by': 'সাজান',
      'sort_by_expiry': 'মেয়াদ শেষের তারিখ',
      'sort_by_distance': 'দূরত্ব',
      'sort_by_quantity': 'পরিমাণ',
      'maximum_distance': 'সর্বাধিক দূরত্ব',
      'km': 'কিমি',
      'show_needs_volunteer':
          'যেসব দানে স্বেচ্ছাসেবকের সাহায্য প্রয়োজন তা দেখান',
      'reset': 'রিসেট',
      'apply_filters': 'ফিল্টার প্রয়োগ করুন',
      'search_food': 'খাবার অনুসন্ধান করুন...',
      'filter': 'ফিল্টার',
      'needs_volunteer': 'স্বেচ্ছাসেবক প্রয়োজন',
      'no_available_donations': 'কোন উপলব্ধ দান পাওয়া যায়নি',
      'no_results_for': 'এর জন্য কোন ফলাফল পাওয়া যায়নি',
      'check_back_later': 'নতুন দানের জন্য পরে আবার দেখুন',
      'try_changing_filters': 'আরও দান দেখতে আপনার ফিল্টার পরিবর্তন করে দেখুন',
      'clear_filters': 'ফিল্টার মুছুন',
      'profile_not_found_recipient':
          'আপনার প্রোফাইল পাওয়া যায়নি। দান দেখতে নিশ্চিত করুন যে আপনি একজন গ্রহীতা হিসাবে নিবন্ধিত আছেন।',
      'unable_to_load_donations':
          'এই মুহূর্তে দান লোড করতে অক্ষম। অনুগ্রহ করে পরে আবার চেষ্টা করুন।',
      'retry': 'আবার চেষ্টা করুন',
      'go_to_profile': 'প্রোফাইলে যান',
      'no_image_available': 'কোন ছবি উপলব্ধ নেই',
      'expiring_soon': 'শীঘ্রই মেয়াদ শেষ হচ্ছে',
      'quantity': 'পরিমাণ',
      'servings': 'পরিবেশন',
      'tap_to_read_more': 'আরও পড়তে ট্যাপ করুন',
      'donor': 'দাতা',
      'call_donor': 'দাতাকে কল করুন',
      'get_directions': 'দিকনির্দেশ পান',
      'expires': 'মেয়াদ শেষ',
      'view_details': 'বিস্তারিত দেখুন',
      'unknown_location': 'অজানা অবস্থান',
      'anonymous': 'বেনামী',
      'error': 'ত্রুটি',
      'refresh': 'রিফ্রেশ',

      // Recipient history screen
      'filter_donation_history': 'দানের ইতিহাস ফিল্টার করুন',
      'time_period': 'সময়কাল',
      'today': 'আজ',
      'yesterday': 'গতকাল',
      'days_ago': 'দিন আগে',
      'this_week': 'এই সপ্তাহ',
      'this_month': 'এই মাস',
      'time': 'সময়',
      'type': 'ধরন',
      'accept_donations_to_see': 'এখানে দেখতে দান গ্রহণ করুন',
      'browse_donations': 'দান ব্রাউজ করুন',
      'no_donations_match_criteria': 'কোন দান আপনার মাপদণ্ড মেলে না',
      'try_adjusting_filters':
          'আরও দান দেখতে আপনার ফিল্টার সামঞ্জস্য করে দেখুন',
      'clear_all_filters': 'সমস্ত ফিল্টার মুছুন',
      'update_location': 'অবস্থান আপডেট করুন',
      'location_updated_donations_refreshed':
          'অবস্থান আপডেট করা হয়েছে। দূরত্ব তথ্য সহ দান রিফ্রেশ করা হয়েছে।',
      'could_not_get_location':
          'আপনার অবস্থান পাওয়া যায়নি। অনুগ্রহ করে নিশ্চিত করুন যে অবস্থান পরিষেবা সক্রিয় আছে।',
      'error_updating_location': 'অবস্থান আপডেট করতে ত্রুটি',
      'donated_by': 'দাতা',
      'accepted_on': 'গৃহীত হয়েছে',
      'at': 'সময়',
      'delivery_method': 'ডেলিভারি পদ্ধতি',
      'self_pickup': 'নিজে সংগ্রহ',
      'add_feedback': 'মতামত যোগ করুন',
      'edit_feedback': 'মতামত সম্পাদনা করুন',
      'your_feedback': 'আপনার মতামত',
      'share_experience_hint': 'এই দান সম্পর্কে আপনার অভিজ্ঞতা শেয়ার করুন...',
      'feedback_submitted_successfully': 'মতামত সফলভাবে জমা দেওয়া হয়েছে!',
      'error_submitting_feedback': 'মতামত জমা দিতে ত্রুটি',
      'distance': 'দূরত্ব',
      'submit': 'জমা দিন',

      // Donation detail screen
      'donation_details': 'দানের বিবরণ',
      'unknown_food': 'অজানা খাবার',
      'no_description_available': 'কোন বিবরণ উপলব্ধ নেই',
      'unknown': 'অজানা',
      'servings': 'পরিবেশন',
      'anonymous_donor': 'বেনামী দাতা',
      'donor_information': 'দাতার তথ্য',
      'donor': 'দাতা',
      'location': 'অবস্থান',
      'food_description': 'খাবারের বিবরণ',
      'expires': 'মেয়াদ শেষ',
      'exact_expiry': 'সঠিক মেয়াদ শেষ',
      'delivery_options': 'ডেলিভারি বিকল্প',
      'need_volunteer_assistance': 'স্বেচ্ছাসেবক সহায়তা প্রয়োজন?',
      'yes_request_volunteer':
          'হ্যাঁ, ডেলিভারি সাহায্যের জন্য স্বেচ্ছাসেবক অনুরোধ করুন',
      'no_pickup_myself': 'না, আমি নিজেই এই দান সংগ্রহ করব',
      'changed_from_original': 'আপনি এটি দাতার মূল সেটিং থেকে পরিবর্তন করেছেন',
      'using_donor_preference':
          'দাতার পছন্দের ডেলিভারি বিকল্প ব্যবহার করা হচ্ছে',
      'accept_donation': 'এই দান গ্রহণ করুন',
      'donation_accepted_with_volunteer':
          'দান সফলভাবে গ্রহণ করা হয়েছে। একজন স্বেচ্ছাসেবক ডেলিভারিতে সাহায্য করবেন।',
      'donation_accepted_self_pickup':
          'দান সফলভাবে গ্রহণ করা হয়েছে। আপনাকে নিজেই এটি সংগ্রহ করতে হবে।',
    },
  };

  // Method to get translation for a key
  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  // Singleton instance to keep track of the current language
  static final AppLocalizationsService localizationsService =
      AppLocalizationsService();
}

// A class to manage the app language state
class AppLocalizationsService extends ChangeNotifier {
  AppLanguage _currentLanguage = AppLanguage.english;

  // Local storage key for saving language preference
  static const String _languagePreferenceKey = 'app_language';

  AppLanguage get currentLanguage => _currentLanguage;

  // Get the current locale
  Locale get currentLocale => Locale(languageCodes[_currentLanguage]!);

  // Load the saved language preference
  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_languagePreferenceKey);

    if (savedCode != null) {
      _currentLanguage = getLanguageFromCode(savedCode);
      notifyListeners();
    }
  }

  // Change the app language
  Future<void> changeLanguage(AppLanguage language) async {
    if (_currentLanguage != language) {
      _currentLanguage = language;

      // Save the language preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languagePreferenceKey, languageCodes[language]!);

      notifyListeners();
    }
  }
}

// LocalizationsDelegate implementation
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi', 'mr', 'gu', 'te', 'bn', 'ta']
        .contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
