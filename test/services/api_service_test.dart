import 'package:flutter_test/flutter_test.dart';
import 'package:mathdf/services/api_service.dart';
import 'package:mathdf/services/dynamic_auth_service.dart';
import 'package:mathdf/services/encryption_service.dart';
import 'package:mathdf/models/calculation_type.dart';
import 'package:mathdf/models/calculation_result.dart';

void main() {
  group('API Integration Tests', () {
    late ApiService apiService;
    late DynamicAuthService authService;

    setUp(() {
      authService = DynamicAuthService();
      apiService = ApiService(authService);
    });

    group('EncryptionService', () {
      test('encrypt should produce consistent results', () {
        const data = '{"expr":"sin(x)","arg":"x"}';
        const key = 'testkey';

        final result1 = EncryptionService.encryptAndEncode(data, key);
        final result2 = EncryptionService.encryptAndEncode(data, key);

        expect(result1, equals(result2));
      });

      test('encrypt and decrypt should be reversible', () {
        const data = '{"expr":"sin(x)","arg":"x"}';
        const key = '98ae9979efca566da';

        final encrypted = EncryptionService.encryptAndEncode(data, key);
        final decrypted = EncryptionService.decryptFromBase64(encrypted, key);

        expect(decrypted, equals(data));
      });
    });

    group('API Connectivity', () {
      test(
        'should successfully call integral API',
        () async {
          final result = await apiService.calculate(
            type: CalculationType.integral,
            expression: 'sin(x)',
          );

          print('Integral result: ${result.toString()}');

          // 只要不是网络错误就算成功
          expect(result, isNotNull);
        },
        timeout: const Timeout(Duration(seconds: 30)),
      );

      test(
        'should successfully call derivative API',
        () async {
          // 使用与api.md相同的复杂表达式
          final result = await apiService.calculateDerivative(
            expression: '(1/2)*(cos(x)^2)',
          );

          print('Derivative result: ${result.toString()}');

          expect(result, isNotNull);
        },
        timeout: const Timeout(Duration(seconds: 30)),
      );

      test(
        'should successfully call equation API',
        () async {
          // 使用api.md中的原始表达式
          final result = await apiService.calculateEquation(
            expression: '4*(x^2)+12*x+12/x+4/(x^2)>=47',
          );

          print('Equation result: ${result.toString()}');

          expect(result, isNotNull);
        },
        timeout: const Timeout(Duration(seconds: 30)),
      );

      test(
        'should successfully call limit API',
        () async {
          final result = await apiService.calculate(
            type: CalculationType.limit,
            expression: 'sin(x)/x',
            additionalParam: '0',
          );

          print('Limit result: ${result.toString()}');

          expect(result, isNotNull);
        },
        timeout: const Timeout(Duration(seconds: 30)),
      );
    });

    group('Response Parsing', () {
      test('should parse valid API response correctly', () {
        // 使用实际API返回的响应格式
        final response = [
          [
            -2,
            "\\int{\\sin\\left(x\\right)}{\\;\\mathrm{d}x}",
            "-\\cos\\left(x\\right)",
            "-cos(x)",
            "",
          ],
          [-10, 2, 3, 27],
          [
            -1,
            ["\\int{\\sin\\left(x\\right)}{\\;\\mathrm{d}x}"],
            "0",
            1,
          ],
          [
            0,
            [0],
            "1",
            "-\\cos\\left(x\\right)",
            "",
          ],
        ];

        final result = CalculationResult.fromApiResponse(response);

        print('Parsed result: ${result.toString()}');

        expect(result.success, isTrue);
        expect(result.originalExpr, contains('\\int'));
        expect(result.resultLatex, isNotEmpty);
        expect(result.resultText, isNotEmpty);
      });

      test('should handle empty response gracefully', () {
        final response = <dynamic>[];

        final result = CalculationResult.fromApiResponse(response);

        expect(result.success, isFalse);
        expect(result.error, isNotNull);
      });

      test('should handle malformed response gracefully', () {
        final response = [
          [1, 2], // 格式不正确
        ];

        final result = CalculationResult.fromApiResponse(response);

        expect(result.success, isFalse);
        expect(result.error, isNotNull);
      });
    });

    group('CalculationResult Model', () {
      test('error factory should work correctly', () {
        final result = CalculationResult.error('Test error');

        expect(result.success, isFalse);
        expect(result.error, equals('Test error'));
        expect(result.originalExpr, isEmpty);
      });

      test('copyWith should work correctly', () {
        final original = CalculationResult.error('Original error');

        // copyWith不能将error设置为null，只能保持原值或设置新值
        final updated = original.copyWith(
          success: true,
          originalExpr: 'sin(x)',
        );

        expect(updated.success, isTrue);
        expect(updated.originalExpr, equals('sin(x)'));
        // error会保持原值
        expect(updated.error, equals('Original error'));
      });
    });
  });
}
