import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:package_info_plus/package_info_plus.dart';

class EnvDef {
  // Inicialización con valores por defecto tal como en el ejemplo oficial
  static PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  /// Método de inicialización asíncrono
  static Future<void> initPackageInfo() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }

  static String title = 'Vihome Dev';

  static String get appName => dotenv.env['APP_NAME'] ?? _packageInfo.appName;
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

  // --- Propiedades dinámicas obtenidas de PackageInfo ---

  /// Nombre del paquete (ej: com.example.vihome)
  static String get packageName => _packageInfo.packageName;

  /// Versión de la app (ej: "1.0.8")
  static String get version => _packageInfo.version;

  /// Número de compilación (ej: "9")
  static String get buildNumber => _packageInfo.buildNumber;

  /// Firma de compilación
  static String get buildSignature => _packageInfo.buildSignature;

  /// Tienda de instalación (Play Store, App Store, etc.)
  static String? get installerStore => _packageInfo.installerStore;

  /// Versión completa en formato "1.0.8+9"
  static String get appVersion => '$version+$buildNumber';
}
