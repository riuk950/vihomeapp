import 'package:vihomeapp/core/errors/failures.dart';
import 'package:vihomeapp/core/utils/either.dart';
import 'package:vihomeapp/domain/entities/landlord.dart';
import 'package:vihomeapp/domain/repositories/landlord_repository.dart';

class SaveLandlordProfileUseCase {
  final LandlordRepository repository;

  SaveLandlordProfileUseCase(this.repository);

  Future<Either<Failure, void>> call(Landlord landlord) async {
    return await repository.saveLandlordProfile(landlord);
  }
}
