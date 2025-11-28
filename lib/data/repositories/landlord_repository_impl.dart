import 'package:vihomeapp/core/errors/failures.dart';
import 'package:vihomeapp/core/utils/either.dart';
import '../../domain/entities/landlord.dart';
import '../../domain/repositories/landlord_repository.dart';
import '../../infrastructure/services/supabase_service.dart';
import '../models/landlord_model.dart';

class LandlordRepositoryImpl implements LandlordRepository {
  final SupabaseService supabaseService;

  LandlordRepositoryImpl(this.supabaseService);

  @override
  Future<Either<Failure, Landlord>> getLandlordProfile(String userId) async {
    try {
      final response = await supabaseService.client
          .from('info_arrendadores')
          .select()
          .eq('id', userId)
          .single();

      return Right(LandlordModel.fromJson(response));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveLandlordProfile(Landlord landlord) async {
    try {
      final landlordModel = LandlordModel.fromEntity(landlord);
      await supabaseService.client
          .from('info_arrendadores')
          .upsert(landlordModel.toJson());
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
