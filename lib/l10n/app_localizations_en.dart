// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MultiLangBloc';

  @override
  String get homeTitle => 'MultiLangBloc';

  @override
  String get brandName => 'MultiLangBloc';

  @override
  String get appSubtitle => 'Multi-language app with Bloc';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get nameOptionalLabel => 'Name (optional)';

  @override
  String get emailRequired => 'Please enter your email';

  @override
  String get emailInvalid => 'Please enter a valid email';

  @override
  String get passwordRequired => 'Please enter your password';

  @override
  String get enterPassword => 'Please enter a password';

  @override
  String get passwordTooShort => 'Password must be at least 8 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get noAccountRegister => 'Don\'t have an account? Register';

  @override
  String get hasAccountLogin => 'Already have an account? Login';

  @override
  String get loginSlashRegister => 'Login / Register';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get ok => 'OK';

  @override
  String get noInternetConnection => 'No internet connection';

  @override
  String get cacheError => 'Cache error';

  @override
  String get authenticationFailed => 'Authentication failed';

  @override
  String get free => 'Free';

  @override
  String get settings => 'Settings';

  @override
  String get profileTitleMy => 'My Profile';

  @override
  String get profileTitle => 'Profile';

  @override
  String get usersTitle => 'Users';

  @override
  String get unnamedUser => 'Unnamed User';

  @override
  String joinedOn(String date) {
    return 'Joined: $date';
  }

  @override
  String get noUsersFound => 'No users found';

  @override
  String get language => 'Language';

  @override
  String get systemDefault => 'System Default';

  @override
  String get english => 'English';

  @override
  String get persian => 'فارسی';

  @override
  String get turkish => 'Türkçe';

  @override
  String get arabic => 'العربية';

  @override
  String get developmentMode => 'Development Mode';

  @override
  String get cancel => 'Cancel';
}
