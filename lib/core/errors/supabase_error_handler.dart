import 'app_error_handler.dart';
import 'failures.dart';

export 'app_error_handler.dart';

/// Alias de compatibilidad hacia [AppErrorHandler]
class SupabaseErrorHandler {
  SupabaseErrorHandler._();

  static Failure handle(dynamic error, [StackTrace? stackTrace]) =>
      AppErrorHandler.handle(error, stackTrace);
}
