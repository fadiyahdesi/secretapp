class ApiConstants {
  static String baseUrl = 'http://192.168.137.91:5000';

  // Auth
  static const login = '/api/login';
  static const register = '/api/register';
  static const deleteAccount = '/api/profil';
  static const profil = '/api/profil';
  static const avatarUpload = '/api/profil/avatar';
  static const resetpassword = '/api/reset-password';
  static const createpassword = '/api/create-password';
  static const verifycode = '/api/verify-code';
  static const historyactivity = '/api/history-activity';
  // Object Detection
  static String detect = '/deteksi';

  static const googleLogin = '/api/google-login';

  // Update Point
  static const String updatePoints = '/api/update-points';
  // Aktivitas
  static const activities = '/api/activities';
  // Poin
  static const totalPoints = '/api/total-points';
  // Learning History
  static const learningHistory = '/api/learning-history';
}
