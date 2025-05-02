import 'package:flutter/material.dart';
import '../utils/app_localizations.dart';
import 'auth/login_screen.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String? selectedLanguage;

  final List<Map<String, String>> languages = [
    {'name': 'English', 'code': 'en', 'english': 'English'},
    {'name': 'हिंदी', 'code': 'hi', 'english': 'Hindi'},
    {'name': 'मराठी', 'code': 'mr', 'english': 'Marathi'},
    {'name': 'ગુજરાતી', 'code': 'gu', 'english': 'Gujarati'},
    {'name': 'தமிழ்', 'code': 'ta', 'english': 'Tamil'},
    {'name': 'తెలుగు', 'code': 'te', 'english': 'Telugu'},
    {'name': 'ಕನ್ನಡ', 'code': 'kn', 'english': 'Kannada'},
    {'name': 'മലയാളം', 'code': 'ml', 'english': 'Malayalam'},
    {'name': 'বাংলা', 'code': 'bn', 'english': 'Bengali'},
    {'name': 'ਪੰਜਾਬੀ', 'code': 'pa', 'english': 'Punjabi'},
    {'name': 'ଓଡ଼ିଆ', 'code': 'or', 'english': 'Odia'},
    {'name': 'অসমীয়া', 'code': 'as', 'english': 'Assamese'},
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize with the current language
    final appLocalizationsService = AppLocalizations.localizationsService;
    final currentLangCode = languageCodes[appLocalizationsService.currentLanguage];
    selectedLanguage = currentLangCode;
  }

  Future<void> _changeLanguage(String languageCode) async {
    if (languageCode == selectedLanguage) return;
    
    setState(() {
      selectedLanguage = languageCode;
    });
    
    // Create a mapping from language code to AppLanguage enum
    final appLanguageMap = {
      'en': AppLanguage.english,
      'hi': AppLanguage.hindi,
      'mr': AppLanguage.marathi,
      'gu': AppLanguage.gujarati,
      'ta': AppLanguage.tamil,
      'te': AppLanguage.telugu,
      'kn': AppLanguage.kannada,
      'ml': AppLanguage.malayalam,
      'bn': AppLanguage.bengali,
      'pa': AppLanguage.english,
      'or': AppLanguage.english,
      'as': AppLanguage.english,
    };
    
    // Only change language if it's in our map
    if (appLanguageMap.containsKey(languageCode)) {
      final appLocalizationsService = AppLocalizations.localizationsService;
      await appLocalizationsService.changeLanguage(appLanguageMap[languageCode]!);
      
      // Force a rebuild to update UI text
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('select_language')), 
        centerTitle: true
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.translate('choose_language'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  final language = languages[index];
                  return LanguageCard(
                    language: language,
                    isSelected: selectedLanguage == language['code'],
                    onTap: () {
                      _changeLanguage(language['code']!);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedLanguage == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  localizations.translate('continue'),
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class LanguageCard extends StatelessWidget {
  final Map<String, String> language;
  final bool isSelected;
  final VoidCallback onTap;

  const LanguageCard({
    super.key,
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                language['name']!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                language['english']!,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

