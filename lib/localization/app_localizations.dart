import 'package:flutter/material.dart';

/// Simple, scalable localization helper.
///
/// - Add new languages by extending `_localizedValues`.
/// - Use keys instead of hard-coded strings in widgets.
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [
    Locale('en'),
    Locale('hi'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final AppLocalizations? result =
        Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(result != null, 'No AppLocalizations found in context');
    return result!;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // General / common
      'app_title': 'Rozgar Adda',
      'ok': 'OK',
      'cancel': 'Cancel',
      'continue': 'Continue',
      'back': 'Back',

      // Splash
      'splash_tagline': 'Your Gateway to Opportunities',
      'splash_launching': 'Launching your future...',
      'splash_secure_verified': 'SECURE & VERIFIED JOBS',

      // Login
      'login_title': 'Rozgar Adda',
      'login_welcome_back': 'Welcome Back',
      'login_subtitle':
          'Enter your credentials to access your job portal',
      'login_email_label': 'Email Address',
      'login_email_hint': 'name@company.com',
      'login_password_label': 'Password',
      'login_forgot': 'Forgot?',
      'login_button': 'Login',
      'login_no_account': 'Don\'t have an account? ',
      'login_register': 'Register',
      'login_error_title': 'Login Failed',
      'login_error_empty': 'Please enter username and password.',

      // Registration
      'registration_progress': 'Registration Progress',
      'registration_step': 'Step 1 of 3',
      'registration_personal_info': 'Personal Info',
      'registration_full_name': 'Full Name',
      'registration_full_name_hint': 'Enter your full name',
      'registration_phone_number': 'Phone Number',
      'registration_email': 'Email Address',
      'registration_email_hint': 'name@example.com',
      'registration_address_details': 'Address Details',
      'registration_state': 'State',
      'registration_select_state': 'Select State',
      'registration_district': 'District',
      'registration_area': 'Area / Locality',
      'registration_area_hint': 'Area',
      'registration_pincode': 'Pincode',
      'registration_pincode_hint': '000000',
      'registration_full_address': 'Full Address',
      'registration_full_address_hint': 'House no, Street name...',
      'registration_identity_verification': 'Identity Verification',
      'registration_account_credentials': 'Account Credentials',
      'registration_username': 'Username',
      'registration_username_hint': 'Choose a unique username',
      'registration_password': 'Password',
      'registration_terms_prefix': 'I agree to the ',
      'registration_terms_link': 'Terms & Conditions',
      'registration_create_account': 'Create Account',
      'registration_already_account': 'Already have an account? ',
      'registration_login': 'Log In',

      // Select State
      'select_state_appbar': 'Select State / राज्य चुनें',
      'select_state_step_label': 'STEP 2 OF 3',
      'select_state_progress': '66% Complete',
      'select_state_heading': 'Where are you looking for jobs?',
      'select_state_subheading':
          'Choose your state to see the best local opportunities tailored for you',
      'select_state_search_hint': 'Search state name...',

      // Language dialog
      'language_dialog_title': 'Select Language',
      'language_dialog_message':
          'Choose your preferred app language. You can change it anytime later.',
      'language_english': 'English',
      'language_hindi': 'Hindi',

      // Home / navigation
      'nav_home': 'HOME',
      'nav_explore': 'EXPLORE',
      'nav_saved': 'SAVED',
      'nav_profile': 'PROFILE',

      // Explore careers / job categories
      'explore_careers_title': 'Explore Careers',
      'explore_job_categories': 'Job Categories',
      'explore_job_categories_subtitle':
          'Find the perfect role across various industries',
      'explore_opportunities_pill': 'OPPORTUNITIES',
      'explore_custom_search': 'Custom Search',
      'explore_custom_search_sub':
          'Find roles based on your skills',

      // Career hub / job list
      'careerhub_title': 'CareerHub',
      'careerhub_search_hint': 'Search for jobs, companies...',
      'careerhub_tab_all': 'All Jobs',
      'careerhub_tab_remote': 'Remote',
      'careerhub_tab_fulltime': 'Full-time',
      'careerhub_tab_salary': 'Salary',

      // Job detail
      'jobdetail_appbar_title': 'Job Opportunity',
      'jobdetail_annual_salary': 'ANNUAL SALARY',
      'jobdetail_experience': 'EXPERIENCE',
      'jobdetail_applicants': 'APPLICANTS',
      'jobdetail_role_description': 'Role Description',
      'jobdetail_requirements': 'Requirements',
      'jobdetail_location': 'Location',
      'jobdetail_apply_now': 'Apply Now',

      // Job application form
      'apply_header_title': 'Senior Product Designer',
      'apply_step_label': 'STEP 2 OF 4:\nEXPERIENCE',
      'apply_complete': 'Complete',
      'apply_personal_info': 'Personal Information',
      'apply_first_name': 'First Name',
      'apply_last_name': 'Last Name',
      'apply_email': 'Email Address',
      'apply_professional_details': 'Professional Details',
      'apply_current_position': 'Current Position',
      'apply_linkedin': 'LinkedIn Profile',
      'apply_resume_upload': 'Resume Upload',
      'apply_upload_cta': 'Click to upload or drag and drop',
      'apply_upload_hint': 'Max file size 10MB • PDF or DOCX',
      'apply_why_hire': 'Why should we hire you?',
      'apply_why_hire_hint':
          'Tell us briefly about your experience and why you are a great fit for this role.',
      'apply_agree':
          'I agree to share my application details with the employer.',
      'apply_submit': 'Submit Application',
      'apply_footer':
          'By submitting, you agree to our privacy policy and terms.',
    },
    'hi': {
      // General / common
      'app_title': 'रोज़गार अड्डा',
      'ok': 'ठीक है',
      'cancel': 'रद्द करें',
      'continue': 'आगे बढ़ें',
      'back': 'वापस',

      // Splash
      'splash_tagline': 'आपके अवसरों का द्वार',
      'splash_launching': 'आपका भविष्य शुरू हो रहा है...',
      'splash_secure_verified': 'सुरक्षित और सत्यापित नौकरियां',

      // Login
      'login_title': 'रोज़गार अड्डा',
      'login_welcome_back': 'दोबारा स्वागत है',
      'login_subtitle':
          'अपना जॉब पोर्टल एक्सेस करने के लिए विवरण दर्ज करें',
      'login_email_label': 'ईमेल पता',
      'login_email_hint': 'name@company.com',
      'login_password_label': 'पासवर्ड',
      'login_forgot': 'भूल गए?',
      'login_button': 'लॉगिन',
      'login_no_account': 'अब तक खाता नहीं है? ',
      'login_register': 'रजिस्टर करें',
      'login_error_title': 'लॉगिन विफल',
      'login_error_empty': 'कृपया उपयोगकर्ता नाम और पासवर्ड दर्ज करें।',

      // Registration
      'registration_progress': 'पंजीकरण प्रगति',
      'registration_step': 'स्टेप 1 / 3',
      'registration_personal_info': 'व्यक्तिगत जानकारी',
      'registration_full_name': 'पूरा नाम',
      'registration_full_name_hint': 'अपना पूरा नाम दर्ज करें',
      'registration_phone_number': 'मोबाइल नंबर',
      'registration_email': 'ईमेल पता',
      'registration_email_hint': 'name@example.com',
      'registration_address_details': 'पता विवरण',
      'registration_state': 'राज्य',
      'registration_select_state': 'राज्य चुनें',
      'registration_district': 'ज़िला',
      'registration_area': 'क्षेत्र / लोकैलिटी',
      'registration_area_hint': 'क्षेत्र',
      'registration_pincode': 'पिनकोड',
      'registration_pincode_hint': '000000',
      'registration_full_address': 'पूरा पता',
      'registration_full_address_hint': 'मकान नंबर, गली का नाम...',
      'registration_identity_verification': 'पहचान सत्यापन',
      'registration_account_credentials': 'अकाउंट विवरण',
      'registration_username': 'यूज़रनेम',
      'registration_username_hint': 'एक यूनिक यूज़रनेम चुनें',
      'registration_password': 'पासवर्ड',
      'registration_terms_prefix': 'मैं ',
      'registration_terms_link': 'नियम और शर्तें',
      'registration_create_account': 'अकाउंट बनाएं',
      'registration_already_account': 'पहले से अकाउंट है? ',
      'registration_login': 'लॉगिन',

      // Select State
      'select_state_appbar': 'राज्य चुनें',
      'select_state_step_label': 'स्टेप 2 / 3',
      'select_state_progress': '66% पूरा',
      'select_state_heading': 'आप कहां नौकरी ढूंढ रहे हैं?',
      'select_state_subheading':
          'अपने राज्य का चयन करें ताकि आपके लिए स्थानीय अवसर दिखाए जा सकें',
      'select_state_search_hint': 'राज्य का नाम खोजें...',

      // Language dialog
      'language_dialog_title': 'भाषा चुनें',
      'language_dialog_message':
          'अपनी पसंदीदा ऐप भाषा चुनें। आप इसे बाद में भी बदल सकते हैं।',
      'language_english': 'अंग्रेज़ी',
      'language_hindi': 'हिंदी',

      // Home / navigation
      'nav_home': 'होम',
      'nav_explore': 'एक्सप्लोर',
      'nav_saved': 'सेव्ड',
      'nav_profile': 'प्रोफ़ाइल',

      // Explore careers / job categories
      'explore_careers_title': 'करियर खोजें',
      'explore_job_categories': 'जॉब कैटेगरी',
      'explore_job_categories_subtitle':
          'विभिन्न उद्योगों में सही भूमिका खोजें',
      'explore_opportunities_pill': 'अवसर',
      'explore_custom_search': 'कस्टम सर्च',
      'explore_custom_search_sub': 'अपनी स्किल के अनुसार नौकरी खोजें',

      // Career hub / job list
      'careerhub_title': 'करियर हब',
      'careerhub_search_hint': 'नौकरियां, कंपनियां खोजें...',
      'careerhub_tab_all': 'सभी नौकरियां',
      'careerhub_tab_remote': 'रिमोट',
      'careerhub_tab_fulltime': 'फुल-टाइम',
      'careerhub_tab_salary': 'सैलरी',

      // Job detail
      'jobdetail_appbar_title': 'जॉब अवसर',
      'jobdetail_annual_salary': 'वार्षिक वेतन',
      'jobdetail_experience': 'अनुभव',
      'jobdetail_applicants': 'आवेदक',
      'jobdetail_role_description': 'भूमिका विवरण',
      'jobdetail_requirements': 'आवश्यकताएँ',
      'jobdetail_location': 'स्थान',
      'jobdetail_apply_now': 'अभी आवेदन करें',

      // Job application form
      'apply_header_title': 'सीनियर प्रोडक्ट डिज़ाइनर',
      'apply_step_label': 'स्टेप 2 / 4:\nअनुभव',
      'apply_complete': 'पूरा',
      'apply_personal_info': 'व्यक्तिगत जानकारी',
      'apply_first_name': 'पहला नाम',
      'apply_last_name': 'अंतिम नाम',
      'apply_email': 'ईमेल पता',
      'apply_professional_details': 'प्रोफेशनल विवरण',
      'apply_current_position': 'वर्तमान पद',
      'apply_linkedin': 'लिंक्डइन प्रोफाइल',
      'apply_resume_upload': 'रिज़्यूमे अपलोड',
      'apply_upload_cta': 'क्लिक कर अपलोड करें या ड्रैग और ड्रॉप करें',
      'apply_upload_hint':
          'अधिकतम फ़ाइल साइज़ 10MB • केवल PDF या DOCX',
      'apply_why_hire': 'हमें आपको क्यों रखना चाहिए?',
      'apply_why_hire_hint':
          'संक्षेप में हमें अपने अनुभव और इस भूमिका के लिए अपनी उपयुक्तता के बारे में बताएं।',
      'apply_agree':
          'मैं अपनी एप्लिकेशन डिटेल्स नियोक्ता के साथ साझा करने के लिए सहमत हूँ।',
      'apply_submit': 'आवेदन सबमिट करें',
      'apply_footer':
          'सबमिट करके, आप हमारी प्राइवेसी नीति और नियमों से सहमत होते हैं।',
    },
  };

  String text(String key) {
    final langCode = locale.languageCode;
    final langMap = _localizedValues[langCode] ?? _localizedValues['en']!;
    return langMap[key] ?? _localizedValues['en']![key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales
          .map((e) => e.languageCode)
          .contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

