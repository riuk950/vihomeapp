import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/core/errors/failures.dart';
import 'package:vihomeapp/core/utils/either.dart';
import 'package:vihomeapp/domain/entities/user.dart';
import 'package:vihomeapp/domain/repositories/auth_repository.dart';
import 'package:vihomeapp/domain/usecases/auth/delete_account_usecase.dart';

class MockAuthRepositoryForDeletion implements AuthRepository {
  bool deleteAccountCalled = false;
  Failure? failureToReturn;

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    deleteAccountCalled = true;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async => throw UnimplementedError();
  @override
  Future<Either<Failure, User>> signInWithEmail({required String email, required String password}) async => throw UnimplementedError();
  @override
  Future<Either<Failure, User>> signUp({required String email, required String password, Map<String, dynamic>? metadata}) async => throw UnimplementedError();
  @override
  Future<Either<Failure, void>> signOut() async => throw UnimplementedError();
  @override
  Future<Either<Failure, User>> signInWithGoogle() async => throw UnimplementedError();
  @override
  Future<Either<Failure, void>> resetPassword(String email) async => throw UnimplementedError();
  @override
  Future<Either<Failure, void>> updatePassword(String newPassword) async => throw UnimplementedError();
  @override
  Future<Either<Failure, void>> updateUserRole(String role) async => throw UnimplementedError();
  @override
  Stream<Either<Failure, User?>> authStateChanges() => throw UnimplementedError();
}

void main() {
  late MockAuthRepositoryForDeletion mockRepository;
  late DeleteAccountUseCase useCase;

  setUp(() {
    mockRepository = MockAuthRepositoryForDeletion();
    useCase = DeleteAccountUseCase(mockRepository);
  });

  group('DeleteAccountUseCase [RF-55, CA-3, CA-5]', () {
    test('debe retornar Right(null) y llamar al repositorio cuando la eliminación es exitosa [CA-3]', () async {
      final result = await useCase();

      expect(mockRepository.deleteAccountCalled, isTrue);
      expect(result.isRight, isTrue);
    });

    test('debe retornar Left(Failure) cuando el repositorio falla en la eliminación [CA-5]', () async {
      mockRepository.failureToReturn = const ServerFailure('Error de servidor al eliminar cuenta');

      final result = await useCase();

      expect(mockRepository.deleteAccountCalled, isTrue);
      expect(result.isLeft, isTrue);
      result.fold(
        (failure) => expect(failure.message, 'Error de servidor al eliminar cuenta'),
        (_) => fail('Se esperaba un fallo'),
      );
    });
  });
}
