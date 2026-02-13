import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  const ApiConstants._();

  static String get baseUrl =>
      dotenv.get('BASE_URL', fallback: 'http://localhost:8080');
  static const String apiVersion = '/api/v1';

  // Auth
  static const String register = '$apiVersion/auth/register';
  static const String login = '$apiVersion/auth/login';
  static const String refreshToken = '$apiVersion/auth/refresh';
  static const String forgotPassword = '$apiVersion/auth/forgot-password';
  static const String deleteAccount = '$apiVersion/auth/account';

  // User
  static const String userProfile = '$apiVersion/user/profile';
  static const String userUsage = '$apiVersion/user/usage';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(seconds: 120);
}
