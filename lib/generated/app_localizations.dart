import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_si.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('si'),
    Locale('ta')
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'ViaGo'**
  String get appTitle;

  /// Home tab label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Activity tab label
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// Notifications tab label
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Account tab label
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// Profile screen title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Edit profile menu item
  ///
  /// In en, this message translates to:
  /// **'Edit profile information'**
  String get editProfile;

  /// Notification settings menu item
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationSettings;

  /// Language menu item
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Security menu item
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// Theme menu item
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Help menu item
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get help;

  /// Contact field label
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// Privacy policy menu item
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacy;

  /// Logout button
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// Language settings screen title
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// Choose language instruction
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get chooseLanguage;

  /// Available languages section title
  ///
  /// In en, this message translates to:
  /// **'Available Languages'**
  String get availableLanguages;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Sinhala language name
  ///
  /// In en, this message translates to:
  /// **'Sinhala'**
  String get sinhala;

  /// Tamil language name
  ///
  /// In en, this message translates to:
  /// **'Tamil'**
  String get tamil;

  /// Language changed confirmation message
  ///
  /// In en, this message translates to:
  /// **'Language changed to {language}'**
  String languageChanged(String language);

  /// Language support section title
  ///
  /// In en, this message translates to:
  /// **'Language Support'**
  String get languageSupport;

  /// Language support description
  ///
  /// In en, this message translates to:
  /// **'• All interface elements will be translated\n• Date and time formats will be localized\n• Number formats will follow regional standards\n• Some content may remain in English'**
  String get languageSupportDesc;

  /// Language selection information
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language for the app interface. This will change all text and labels throughout the app.'**
  String get selectLanguageInfo;

  /// Incoming ride requests screen title
  ///
  /// In en, this message translates to:
  /// **'Incoming Ride Requests'**
  String get incomingRideRequests;

  /// Manage requests description
  ///
  /// In en, this message translates to:
  /// **'Manage passenger booking requests'**
  String get manageRequests;

  /// My ride requests screen title
  ///
  /// In en, this message translates to:
  /// **'My Ride Requests'**
  String get myRideRequests;

  /// Track requests description
  ///
  /// In en, this message translates to:
  /// **'Track your booking requests'**
  String get trackRequests;

  /// Matching riders screen title
  ///
  /// In en, this message translates to:
  /// **'Matching Riders'**
  String get matchingRiders;

  /// From location label
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// To location label
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// Ride request label
  ///
  /// In en, this message translates to:
  /// **'Ride Request'**
  String get rideRequest;

  /// Passenger details section
  ///
  /// In en, this message translates to:
  /// **'Passenger Details'**
  String get passengerDetails;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Requested time label
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get requested;

  /// Accept ride button
  ///
  /// In en, this message translates to:
  /// **'Accept Ride'**
  String get accept;

  /// Reject ride button
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// Accepted status
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// Rejected status
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// Pending status
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// Ride accepted message
  ///
  /// In en, this message translates to:
  /// **'Ride accepted!'**
  String get rideAccepted;

  /// Ride rejected message
  ///
  /// In en, this message translates to:
  /// **'Ride rejected.'**
  String get rideRejected;

  /// Waiting for response message
  ///
  /// In en, this message translates to:
  /// **'Waiting for rider response...'**
  String get waitingResponse;

  /// Reviews button
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// Send request button
  ///
  /// In en, this message translates to:
  /// **'Send Request'**
  String get sendRequest;

  /// Rate ride button
  ///
  /// In en, this message translates to:
  /// **'Rate Ride'**
  String get rateRide;

  /// No requests message
  ///
  /// In en, this message translates to:
  /// **'No incoming ride requests'**
  String get noRequests;

  /// Requests will appear message
  ///
  /// In en, this message translates to:
  /// **'Requests will appear here when passengers book your rides'**
  String get requestsWillAppear;

  /// No ride requests message
  ///
  /// In en, this message translates to:
  /// **'No ride requests found'**
  String get noRideRequests;

  /// Start requesting message
  ///
  /// In en, this message translates to:
  /// **'Start by requesting a ride!'**
  String get startRequesting;

  /// No matching riders message
  ///
  /// In en, this message translates to:
  /// **'No matching riders found'**
  String get noMatchingRiders;

  /// Adjust criteria message
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search criteria.'**
  String get adjustCriteria;

  /// Request sent message
  ///
  /// In en, this message translates to:
  /// **'Ride request sent successfully! 🚗'**
  String get requestSent;

  /// Request accepted message
  ///
  /// In en, this message translates to:
  /// **'Request accepted successfully! 🚗'**
  String get requestAccepted;

  /// Request rejected message
  ///
  /// In en, this message translates to:
  /// **'Request rejected successfully! 🚗'**
  String get requestRejected;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'si', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'si': return AppLocalizationsSi();
    case 'ta': return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
