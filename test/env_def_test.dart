import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/env/env_def.dart';

void main() {
  test(
      'production environment should be explicit and not inferred from DEBUG_MODE',
      () {
    EnvDef.setFlavor('prod');
    EnvDef.setDebugMode(false);

    expect(EnvDef.isDebugMode, isFalse);
    expect(EnvDef.isProduction, isTrue);
    expect(EnvDef.flavor, 'prod');
  });

  test(
      'development environment should be explicit and not inferred from DEBUG_MODE',
      () {
    EnvDef.setFlavor('dev');
    EnvDef.setDebugMode(true);

    expect(EnvDef.isDebugMode, isTrue);
    expect(EnvDef.isProduction, isFalse);
    expect(EnvDef.flavor, 'dev');
  });
}
