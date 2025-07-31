// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ViaGo';

  @override
  String get home => 'Home';

  @override
  String get activity => 'Activity';

  @override
  String get notifications => 'Notifications';

  @override
  String get account => 'Account';

  @override
  String get profile => 'Profile';

  @override
  String get editProfile => 'Edit profile information';

  @override
  String get notificationSettings => 'Notifications';

  @override
  String get language => 'Language';

  @override
  String get security => 'Security';

  @override
  String get theme => 'Theme';

  @override
  String get help => 'Help & Support';

  @override
  String get contact => 'Contact';

  @override
  String get privacy => 'Privacy policy';

  @override
  String get logout => 'Log Out';

  @override
  String get languageSettings => 'Language Settings';

  @override
  String get chooseLanguage => 'Choose your preferred language';

  @override
  String get availableLanguages => 'Available Languages';

  @override
  String get english => 'English';

  @override
  String get sinhala => 'Sinhala';

  @override
  String get tamil => 'Tamil';

  @override
  String languageChanged(String language) {
    return 'Language changed to $language';
  }

  @override
  String get languageSupport => 'Language Support';

  @override
  String get languageSupportDesc => '• All interface elements will be translated\n• Date and time formats will be localized\n• Number formats will follow regional standards\n• Some content may remain in English';

  @override
  String get selectLanguageInfo => 'Select your preferred language for the app interface. This will change all text and labels throughout the app.';

  @override
  String get incomingRideRequests => 'Incoming Ride Requests';

  @override
  String get manageRequests => 'Manage passenger booking requests';

  @override
  String get myRideRequests => 'My Ride Requests';

  @override
  String get trackRequests => 'Track your booking requests';

  @override
  String get matchingRiders => 'Matching Riders';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get rideRequest => 'Ride Request';

  @override
  String get passengerDetails => 'Passenger Details';

  @override
  String get name => 'Name';

  @override
  String get requested => 'Requested';

  @override
  String get accept => 'Accept Ride';

  @override
  String get reject => 'Reject';

  @override
  String get accepted => 'Accepted';

  @override
  String get rejected => 'Rejected';

  @override
  String get pending => 'Pending';

  @override
  String get rideAccepted => 'Ride accepted!';

  @override
  String get rideRejected => 'Ride rejected.';

  @override
  String get waitingResponse => 'Waiting for rider response...';

  @override
  String get reviews => 'Reviews';

  @override
  String get sendRequest => 'Send Request';

  @override
  String get rateRide => 'Rate Ride';

  @override
  String get noRequests => 'No incoming ride requests';

  @override
  String get requestsWillAppear => 'Requests will appear here when passengers book your rides';

  @override
  String get noRideRequests => 'No ride requests found';

  @override
  String get startRequesting => 'Start by requesting a ride!';

  @override
  String get noMatchingRiders => 'No matching riders found';

  @override
  String get adjustCriteria => 'Try adjusting your search criteria.';

  @override
  String get requestSent => 'Ride request sent successfully! 🚗';

  @override
  String get requestAccepted => 'Request accepted successfully! 🚗';

  @override
  String get requestRejected => 'Request rejected successfully! 🚗';
}
