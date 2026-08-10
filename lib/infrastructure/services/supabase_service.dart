import 'package:supabase_flutter/supabase_flutter.dart';
import '../../env/env_def.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  SupabaseService._();

  Future<void> initialize() async {
    await Supabase.initialize(
      url: EnvDef.supabaseUrl,
      publishableKey: EnvDef.supabaseAnonKey,
    );
  }

  SupabaseClient get client => Supabase.instance.client;

  User? get currentUser => client.auth.currentUser;

  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  bool get isAuthenticated => currentUser != null;
}
