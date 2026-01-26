import 'package:vihomeapp/core/errors/failures.dart';
import 'package:vihomeapp/core/utils/either.dart';
import 'package:vihomeapp/domain/entities/landlord.dart';

abstract class LandlordRepository {
  Future<Either<Failure, Landlord>> getLandlordProfile(String userId);
  Future<Either<Failure, void>> saveLandlordProfile(Landlord landlord);
}
