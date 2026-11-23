import 'package:flutter/widgets.dart';

enum AppLanguage { en, tl }

/// Holds the current language. Call toggle() to switch English <-> Tagalog.
class LanguageController extends ChangeNotifier {
  AppLanguage _language = AppLanguage.en;
  AppLanguage get language => _language;

  void toggle() {
    _language = _language == AppLanguage.en ? AppLanguage.tl : AppLanguage.en;
    notifyListeners();
  }
}

/// Put this above MaterialApp so every screen can read the language.
class LanguageScope extends InheritedNotifier<LanguageController> {
  const LanguageScope({
    super.key,
    required LanguageController controller,
    required super.child,
  }) : super(notifier: controller);

  static LanguageController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LanguageScope>();
    assert(scope != null, 'LanguageScope not found above this context');
    return scope!.notifier!;
  }
}

extension AppStringsX on BuildContext {
  LanguageController get language => LanguageScope.of(this);

  /// Looks up a UI string in the current language. Falls back to English.
  String tr(String key) {
    final lang = LanguageScope.of(this).language;
    return _strings[lang]?[key] ?? _strings[AppLanguage.en]![key] ?? key;
  }
}

// To add or edit text: change the same key in BOTH maps below.
const Map<AppLanguage, Map<String, String>> _strings = {
  AppLanguage.en: {
    'goodMorning': 'Good morning,',
    'goodAfternoon': 'Good afternoon,',
    'goodEvening': 'Good evening,',
    'welcome': 'Welcome!',
    'tagline': 'Find the health support you need, and see how to apply.',
    'quickActions': 'Quick actions',
    'recommended': 'Recommended for you',
    'latestUpdates': 'Latest updates',
    'viewAll': 'View all',
    'findPrograms': 'Find Programs',
    'findProgramsDesc': 'Browse health assistance programs',
    'checkEligibility': 'Check Eligibility',
    'checkEligibilityDesc': 'See what you may qualify for',
    'askGabay': 'Ask GABAY',
    'askGabayDesc': 'Get answers to your questions',
    'noRecommended':
    'No recommendations yet. Check your eligibility to see programs that fit you.',
    'noUpdates': 'No updates right now. New announcements will show here.',
    'nearbyTitle': 'Find nearby assistance offices',
    'nearbyBody': 'Locate government offices where you can apply or get help.',
    'openMap': 'Open map',
    'navHome': 'Home',
    'navPrograms': 'Programs',
    'navAsk': 'Ask GABAY',
    'programsTitle': 'Programs',
    'searchHint': 'Search medical assistance',
    'noPrograms': 'No programs to show yet.',
    'noResults': 'No programs match your search.',
    'profile': 'Profile',
    'comingSoon': 'This screen is coming soon.',
    'personalInfo': 'Personal information',
    'address': 'Address',
    'assistanceInfo': 'Assistance information',
    'fullName': 'Full name',
    'birthday': 'Birthday',
    'selectDate': 'Select date',
    'age': 'Age',
    'gender': 'Gender',
    'male': 'Male',
    'female': 'Female',
    'civilStatus': 'Civil status',
    'single': 'Single',
    'married': 'Married',
    'widowed': 'Widowed',
    'separated': 'Separated',
    'sitio': 'Sitio (optional)',
    'barangay': 'Barangay',
    'city': 'City / Municipality',
    'province': 'Province',
    'philhealth': 'PhilHealth member or beneficiary?',
    'pwd': 'Person with disability (PWD)?',
    'senior': 'Senior citizen',
    'seniorAuto': 'Set automatically from your birthday (60 years old and above).',
    'yes': 'Yes',
    'no': 'No',
    'required': 'This field is required',
    'chooseOne': 'Please choose one',
    'save': 'Save',
    'profileSaved': 'Profile saved',
    'discardTitle': 'Discard changes?',
    'discardBody': 'You have unsaved changes. If you leave now, they will be lost.',
    'keepEditing': 'Keep editing',
    'discard': 'Discard',
    'logout': 'Log out',
    'saveFailed': 'Could not save. Please try again.',
    'months': 'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec',
  },
  AppLanguage.tl: {
    'goodMorning': 'Magandang umaga,',
    'goodAfternoon': 'Magandang hapon,',
    'goodEvening': 'Magandang gabi,',
    'welcome': 'Maligayang pagdating!',
    'tagline':
    'Hanapin ang tulong pangkalusugan na kailangan mo, at alamin kung paano mag-apply.',
    'quickActions': 'Mabilisang aksyon',
    'recommended': 'Inirerekomenda para sa iyo',
    'latestUpdates': 'Mga pinakabagong update',
    'viewAll': 'Tingnan lahat',
    'findPrograms': 'Maghanap ng Programa',
    'findProgramsDesc': 'Mag-browse ng mga programa sa tulong pangkalusugan',
    'checkEligibility': 'Alamin kung Kwalipikado',
    'checkEligibilityDesc': 'Tingnan kung saan ka maaaring maging kwalipikado',
    'askGabay': 'Tanungin si GABAY',
    'askGabayDesc': 'Kumuha ng sagot sa iyong mga tanong',
    'noRecommended':
    'Wala pang rekomendasyon. Alamin kung kwalipikado ka para makita ang mga programang angkop sa iyo.',
    'noUpdates': 'Wala pang bagong update. Lalabas dito ang mga bagong anunsyo.',
    'nearbyTitle': 'Maghanap ng malalapit na tanggapan ng tulong',
    'nearbyBody':
    'Hanapin ang mga tanggapan ng pamahalaan kung saan ka maaaring mag-apply o humingi ng tulong.',
    'openMap': 'Buksan ang mapa',
    'navHome': 'Home',
    'navPrograms': 'Mga Programa',
    'navAsk': 'Magtanong',
    'programsTitle': 'Mga Programa',
    'searchHint': 'Maghanap ng tulong medikal',
    'noPrograms': 'Wala pang programang maipapakita.',
    'noResults': 'Walang programang tumutugma sa hinahanap mo.',
    'profile': 'Aking Profile',
    'comingSoon': 'Malapit nang ilabas ang screen na ito.',
    'personalInfo': 'Personal na impormasyon',
    'address': 'Tirahan',
    'assistanceInfo': 'Impormasyon para sa tulong',
    'fullName': 'Buong pangalan',
    'birthday': 'Kaarawan',
    'selectDate': 'Pumili ng petsa',
    'age': 'Edad',
    'gender': 'Kasarian',
    'male': 'Lalaki',
    'female': 'Babae',
    'civilStatus': 'Katayuang sibil',
    'single': 'Single',
    'married': 'Kasal',
    'widowed': 'Balo',
    'separated': 'Hiwalay',
    'sitio': 'Sitio (opsyonal)',
    'barangay': 'Barangay',
    'city': 'Lungsod / Bayan',
    'province': 'Lalawigan',
    'philhealth': 'Miyembro o benepisyaryo ng PhilHealth?',
    'pwd': 'May kapansanan (PWD)?',
    'senior': 'Senior citizen',
    'seniorAuto': 'Awtomatikong itinatakda mula sa iyong kaarawan (60 taong gulang pataas).',
    'yes': 'Oo',
    'no': 'Hindi',
    'required': 'Kailangang punan ito',
    'chooseOne': 'Pumili ng isa',
    'save': 'I-save',
    'profileSaved': 'Na-save ang profile',
    'discardTitle': 'I-discard ang mga pagbabago?',
    'discardBody': 'May mga pagbabago kang hindi pa na-save. Mawawala ang mga ito kung aalis ka ngayon.',
    'keepEditing': 'Ituloy ang pag-edit',
    'discard': 'I-discard',
    'logout': 'Mag-log out',
    'saveFailed': 'Hindi na-save. Subukan muli.',
    'months': 'Ene,Peb,Mar,Abr,May,Hun,Hul,Ago,Set,Okt,Nob,Dis',
  },
};