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

  static String _flavor = 'prod';
  static bool _isDebugMode = false;

  /// Método de inicialización asíncrono
  static Future<void> initPackageInfo() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }

  static bool _dotenvDebugEnabled() {
    try {
      return dotenv.env['DEBUG_MODE'] == 'true';
    } catch (_) {
      return false;
    }
  }

  static void setFlavor(String flavor) {
    final normalized = flavor.toLowerCase();
    _flavor = normalized == 'dev' ? 'dev' : 'prod';
    _isDebugMode = _flavor == 'dev' || _dotenvDebugEnabled();
  }

  static void setDebugMode(bool value) {
    _isDebugMode = value;
  }

  static String title = 'Vihome Dev';

  static String _safeGetEnv(String key, [String defaultValue = '']) {
    try {
      return dotenv.env[key] ?? defaultValue;
    } catch (_) {
      return defaultValue;
    }
  }

  static String get appName => _safeGetEnv('APP_NAME', _packageInfo.appName);
  static String get apiBaseUrl => _safeGetEnv('API_BASE_URL');
  static String get apiVersion => _safeGetEnv('API_VERSION', 'v1');
  static String get authTokenKey => _safeGetEnv('AUTH_TOKEN_KEY', 'auth_token');
  static String get supabaseUrl => _safeGetEnv('SUPABASE_URL');
  static String get supabaseAnonKey => _safeGetEnv('SUPABASE_ANON_KEY');
  static String get mapboxAccessToken => _safeGetEnv('MAPBOX_ACCESS_TOKEN');
  static bool get isDebugMode => _isDebugMode;
  static String get googleWebClientId => _safeGetEnv('GOOGLE_WEB_CLIENT_ID');

  static String get admobBannerId => _safeGetEnv('ADMOB_BANNER_ID');

  static String get admobInterstitialId => _safeGetEnv('ADMOB_INTERSTITIAL_ID');

  static bool get isProduction => _flavor == 'prod';
  static bool get isDevelopment => _flavor == 'dev';
  static String get flavor => _flavor;

  // --- Propiedades dinámicas obtenidas de PackageInfo ---

  /// Nombre del paquete (ej: com.example.vihome)
  static String get packageName => _packageInfo.packageName;

  /// Versión de la app (ej: "1.0.8")
  static String get version => _packageInfo.version;

  /// Número de compilación (ej: "9")
  //static String get buildNumber => _packageInfo.buildNumber;

  /// Firma de compilación
  static String get buildSignature => _packageInfo.buildSignature;

  /// Tienda de instalación (Play Store, App Store, etc.)
  static String? get installerStore => _packageInfo.installerStore;

  /// Versión completa en formato "1.0.8+9"
  static String get appVersion => version;
}
