import 'package:flutter_test/flutter_test.dart';
import 'package:mathdf/services/dynamic_auth_service.dart';

void main() {
  group('DynamicAuthService Integration Tests', () {
    late DynamicAuthService authService;

    setUp(() {
      authService = DynamicAuthService();
    });

    test(
      'should fetch auth info from mathdf.com/int/',
      () async {
        await authService.ensureAuthReady();

        expect(authService.token, isNotEmpty);
        expect(authService.token.length, greaterThan(0));
        print('Token: ${authService.token}');
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );

    test(
      'should not re-fetch if session still valid',
      () async {
        await authService.ensureAuthReady();
        final firstToken = authService.token;

        await authService.ensureAuthReady();
        expect(authService.token, equals(firstToken));
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );

    test(
      'should refresh and get new token',
      () async {
        await authService.ensureAuthReady();
        final firstToken = authService.token;

        await authService.refresh();
        expect(authService.token, isNotEmpty);
        print('Refreshed token: ${authService.token}');
      },
      timeout: const Timeout(Duration(seconds: 60)),
    );

    test(
      'should detect session expiration',
      () async {
        await authService.ensureAuthReady();
        expect(authService.isSessionExpired, isFalse);
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );
  });
}
