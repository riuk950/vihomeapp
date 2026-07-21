import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvDef {
  static String title = 'Vihome Dev';
  static String get appName => dotenv.env['APP_NAME'] ?? 'Vihome';
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static String get apiVersion => dotenv.env['API_VERSION'] ?? 'v1';
  static String get authTokenKey =>
      dotenv.env['AUTH_TOKEN_KEY'] ?? 'auth_token';
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get mapboxAccessToken =>
      dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
  static bool isDebugMode = dotenv.env['DEBUG_MODE'] == 'true';
  static String get googleWebClientId =>
      dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';

  static String get admobBannerId => dotenv.env['ADMOB_BANNER_ID'] ?? '';

  static String get admobInterstitialId =>
      dotenv.env['ADMOB_INTERSTITIAL_ID'] ?? '';

  static bool get isProduction => dotenv.env['DEBUG_MODE'] != 'true';
  static bool get isDevelopment => !isProduction;
  static String get flavor => isProduction ? 'prod' : 'dev';
  static String get appVersion => '1.0.8+9';
}
