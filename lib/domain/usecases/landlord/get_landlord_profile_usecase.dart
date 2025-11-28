import 'package:vihomeapp/core/errors/failures.dart';
import 'package:vihomeapp/core/utils/either.dart';
import 'package:vihomeapp/domain/entities/landlord.dart';
import 'package:vihomeapp/domain/repositories/landlord_repository.dart';

class GetLandlordProfileUseCase {
  final LandlordRepository repository;

  GetLandlordProfileUseCase(this.repository);

  Future<Either<Failure, Landlord>> call(String userId) async {
    return await repository.getLandlordProfile(userId);
  }
}
