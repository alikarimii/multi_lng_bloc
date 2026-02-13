// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'MultiLangBloc';

  @override
  String get homeTitle => 'MultiLangBloc';

  @override
  String get brandName => 'MultiLangBloc';

  @override
  String get appSubtitle =>
      'MultiLangBloc - Bloc kullanarak çok dilli uygulama örneği';

  @override
  String get login => 'Giriş';

  @override
  String get register => 'Kayıt';

  @override
  String get emailLabel => 'E-posta';

  @override
  String get passwordLabel => 'Şifre';

  @override
  String get confirmPasswordLabel => 'Şifreyi Onayla';

  @override
  String get nameOptionalLabel => 'Ad (isteğe bağlı)';

  @override
  String get emailRequired => 'Lütfen e-posta adresinizi girin';

  @override
  String get emailInvalid => 'Lütfen geçerli bir e-posta girin';

  @override
  String get passwordRequired => 'Lütfen şifrenizi girin';

  @override
  String get enterPassword => 'Lütfen bir şifre girin';

  @override
  String get passwordTooShort => 'Şifre en az 8 karakter olmalıdır';

  @override
  String get passwordsDoNotMatch => 'Şifreler eşleşmiyor';

  @override
  String get noAccountRegister => 'Hesabınız yok mu? Kayıt olun';

  @override
  String get hasAccountLogin => 'Zaten hesabınız var mı? Giriş yapın';

  @override
  String get loginSlashRegister => 'Giriş / Kayıt';

  @override
  String get error => 'Hata';

  @override
  String get retry => 'Tekrar Dene';

  @override
  String get ok => 'Tamam';

  @override
  String get noInternetConnection => 'İnternet bağlantısı yok';

  @override
  String get cacheError => 'Önbellek hatası';

  @override
  String get authenticationFailed => 'Kimlik doğrulama başarısız';

  @override
  String get free => 'Ücretsiz';

  @override
  String get settings => 'Ayarlar';

  @override
  String get language => 'Dil';

  @override
  String get systemDefault => 'Sistem Varsayılanı';

  @override
  String get english => 'English';

  @override
  String get persian => 'فارسی';

  @override
  String get turkish => 'Türkçe';

  @override
  String get arabic => 'العربية';

  @override
  String get developmentMode => 'Geliştirme Modu';

  @override
  String get cancel => 'İptal';
}
