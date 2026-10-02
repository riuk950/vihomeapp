import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/core/errors/failures.dart';
import 'package:vihomeapp/core/errors/exceptions.dart';

void main() {
  group('Domain Failures Tests', () {
    test('ServerFailure should store and return message correctly', () {
      const message = 'Error en el servidor de base de datos';
      const failure = ServerFailure(message);

      expect(failure.message, message);
      expect(failure.toString(), message);
      expect(failure, isA<Failure>());
    });

    test('NetworkFailure should store and return message correctly', () {
      const message = 'No hay conexión a internet disponible';
      const failure = NetworkFailure(message);

      expect(failure.message, message);
      expect(failure.toString(), message);
      expect(failure, isA<Failure>());
    });

    test('AuthFailure should store and return message correctly', () {
      const message = 'Credenciales inválidas o sesión expirada';
      const failure = AuthFailure(message);

      expect(failure.message, message);
      expect(failure.toString(), message);
      expect(failure, isA<Failure>());
    });

    test('ValidationFailure should store and return message correctly', () {
      const message = 'El ingreso mensual debe ser mayor a cero';
      const failure = ValidationFailure(message);

      expect(failure.message, message);
      expect(failure.toString(), message);
      expect(failure, isA<Failure>());
    });

    test('CacheFailure should store and return message correctly', () {
      const message = 'Error al leer datos locales en caché';
      const failure = CacheFailure(message);

      expect(failure.message, message);
      expect(failure.toString(), message);
      expect(failure, isA<Failure>());
    });
  });

  group('Domain Exceptions Tests', () {
    test('ServerException should implement Exception', () {
      final exception = ServerException();
      expect(exception, isA<Exception>());
    });

    test('CacheException should implement Exception', () {
      final exception = CacheException();
      expect(exception, isA<Exception>());
    });
  });
}
