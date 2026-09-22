import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/data/models/user_model.dart';
import 'package:vihomeapp/domain/entities/user.dart';
import '../../fixtures/fixtures.dart';

void main() {
  group('UserModel Serialization & Domain Entity Tests [RF-01]', () {
    test('should correctly deserialize valid landlord JSON into UserModel and User entity', () {
      final json = UserFixtures.validLandlordJson;
      final model = UserModel.fromJson(json);

      expect(model.id, json['id']);
      expect(model.email, json['email']);
      expect(model.name, json['name']);
      expect(model.role, json['role']);
      expect(model.isPremium, isFalse);
      expect(model.createdAt, DateTime.parse(json['created_at']));
      expect(model, isA<User>());
    });

    test('should correctly deserialize valid tenant JSON into UserModel', () {
      final json = UserFixtures.validTenantJson;
      final model = UserModel.fromJson(json);

      expect(model.id, json['id']);
      expect(model.email, json['email']);
      expect(model.role, 'tenant');
    });

    test('should serialize UserModel back to JSON matching expected structure', () {
      final model = UserModel.fromJson(UserFixtures.validLandlordJson);
      final json = model.toJson();

      expect(json['id'], model.id);
      expect(json['email'], model.email);
      expect(json['name'], model.name);
      expect(json['role'], model.role);
      expect(json['is_premium'], isFalse);
      expect(json['created_at'], isNotNull);
    });

    test('toEntity should convert UserModel to a clean domain User entity', () {
      final model = UserModel.fromJson(UserFixtures.validLandlordJson);
      final entity = model.toEntity();

      expect(entity, isA<User>());
      expect(entity.id, model.id);
      expect(entity.email, model.email);
      expect(entity.role, model.role);
    });
  });
}
