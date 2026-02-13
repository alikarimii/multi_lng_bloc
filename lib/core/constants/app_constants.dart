class AppConstants {
  const AppConstants._();

  static const String appName = 'MultiLangBloc';
  static const String appNameFa = 'چند زبانه با بلوک';

  // Cache
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);
  static const Duration cacheExpiry = Duration(hours: 24);

  // Image
  static const int maxImageWidth = 2048;
  static const int maxImageHeight = 4096;
  static const int imageQuality = 85;

  // Audio
  static const int defaultTempo = 120;
  static const int minTempo = 30;
  static const int maxTempo = 300;
  static const double defaultVolume = 0.8;
}
