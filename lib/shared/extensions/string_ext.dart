extension StringExtension on String {
  /// Checks if the string contains Persian/Arabic characters.
  bool get isPersian => RegExp(r'[\u0600-\u06FF]').hasMatch(this);

  /// Returns the string with leading/trailing whitespace removed
  /// and internal whitespace normalized.
  String get normalized => trim().replaceAll(RegExp(r'\s+'), ' ');

  /// Capitalizes the first letter.
  String get capitalized =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
