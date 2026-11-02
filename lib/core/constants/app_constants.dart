class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://mock-api.calleyacd.com/api';

  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String lists = '/list';
  static String listDetails(String listId) => '/list/$listId';

  static const Duration timeout = Duration(seconds: 20);

  /// When the hosted mock server is unreachable (network error, 404, invalid
  /// TLS certificate, HTML instead of JSON...) the app falls back to a local
  /// mock that mirrors the documented Postman responses, so the whole flow can
  /// still be demonstrated. Set to `false` to only use the live API.
  static const bool enableOfflineFallback = true;
}

class AppLinks {
  AppLinks._();

  static const String webPanel = 'https://app.getcalley.com';
  static const String website = 'https://www.getcalley.com';
  static const String introVideo = 'https://www.youtube.com/@getcalley';
  static const String whatsappSupport = 'https://wa.me/917676286822';
}

class StorageKeys {
  StorageKeys._();

  static const String language = 'language';
  static const String user = 'user';
  static const String seenIntro = 'seen_intro_';
  static const String selectedListId = 'selected_list_id';
  static const String pendingRegistration = 'pending_registration';
  static const String mockUsers = 'mock_users';
}
