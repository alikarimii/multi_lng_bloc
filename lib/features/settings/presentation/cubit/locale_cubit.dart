import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleState extends Equatable {
  const LocaleState({this.locale});

  /// `null` means follow system locale.
  final Locale? locale;

  @override
  List<Object?> get props => [locale];
}

class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit(this._prefs) : super(const LocaleState()) {
    _loadSavedLocale();
  }

  final SharedPreferences _prefs;

  static const _key = 'app_locale';

  void _loadSavedLocale() {
    final code = _prefs.getString(_key);
    if (code != null) {
      emit(LocaleState(locale: Locale(code)));
    }
  }

  void changeLocale(Locale? locale) {
    if (locale == null) {
      _prefs.remove(_key);
    } else {
      _prefs.setString(_key, locale.languageCode);
    }
    emit(LocaleState(locale: locale));
  }
}
