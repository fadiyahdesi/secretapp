import 'package:bicaraku/app/data/models/activity_history.dart';

class ApiConstants {
  static String baseUrl = 'http://192.168.100.8:5000';

  // Auth
  static const login = '/api/login';
  static const register = '/api/register';
  static const deleteAccount = '/api/profil';
  static const profil = '/api/profil';
  static const avatarUpload = '/api/profil/avatar';
  static const resetpassword = '/api/reset-password';
  static const createpassword = '/api/create-password';
  static const historyactivity = '/api/history-activity';

  // Object Detection
  static String detect = '/deteksi';
  static const googleLogin = '/api/google-login';
}
