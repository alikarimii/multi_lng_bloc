// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'چند زبانه با بلاک';

  @override
  String get homeTitle => 'چند زبانه با بلاک';

  @override
  String get brandName => 'چند زبانه با بلاک';

  @override
  String get appSubtitle =>
      'چند زبانه با بلاک - نمونه برنامه چند زبانه با استفاده از Bloc';

  @override
  String get login => 'ورود';

  @override
  String get register => 'ثبت‌نام';

  @override
  String get emailLabel => 'ایمیل';

  @override
  String get passwordLabel => 'رمز عبور';

  @override
  String get confirmPasswordLabel => 'تکرار رمز عبور';

  @override
  String get nameOptionalLabel => 'نام (اختیاری)';

  @override
  String get emailRequired => 'لطفاً ایمیل خود را وارد کنید';

  @override
  String get emailInvalid => 'لطفاً یک ایمیل معتبر وارد کنید';

  @override
  String get passwordRequired => 'لطفاً رمز عبور خود را وارد کنید';

  @override
  String get enterPassword => 'لطفاً یک رمز عبور وارد کنید';

  @override
  String get passwordTooShort => 'رمز عبور باید حداقل ۸ کاراکتر باشد';

  @override
  String get passwordsDoNotMatch => 'رمزهای عبور مطابقت ندارند';

  @override
  String get noAccountRegister => 'حساب کاربری ندارید؟ ثبت‌نام کنید';

  @override
  String get hasAccountLogin => 'قبلاً حساب دارید؟ وارد شوید';

  @override
  String get loginSlashRegister => 'ورود / ثبت‌نام';

  @override
  String get error => 'خطا';

  @override
  String get retry => 'تلاش مجدد';

  @override
  String get ok => 'تأیید';

  @override
  String get noInternetConnection => 'اتصال اینترنت برقرار نیست';

  @override
  String get cacheError => 'خطای حافظه پنهان';

  @override
  String get authenticationFailed => 'احراز هویت ناموفق بود';

  @override
  String get free => 'رایگان';

  @override
  String get settings => 'تنظیمات';

  @override
  String get profileTitleMy => 'پروفایل من';

  @override
  String get profileTitle => 'پروفایل';

  @override
  String get usersTitle => 'کاربران';

  @override
  String get unnamedUser => 'کاربر بدون نام';

  @override
  String joinedOn(String date) {
    return 'عضویت: $date';
  }

  @override
  String get noUsersFound => 'کاربری یافت نشد';

  @override
  String get language => 'زبان';

  @override
  String get systemDefault => 'پیش‌فرض سیستم';

  @override
  String get english => 'English';

  @override
  String get persian => 'فارسی';

  @override
  String get turkish => 'Türkçe';

  @override
  String get arabic => 'العربية';

  @override
  String get developmentMode => 'حالت توسعه';

  @override
  String get cancel => 'لغو';
}
