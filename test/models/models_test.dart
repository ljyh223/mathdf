import 'package:flutter_test/flutter_test.dart';
import 'package:mathdf/models/calculation_type.dart';
import 'package:mathdf/models/calculation_request.dart';
import 'package:mathdf/models/calculation_result.dart';

void main() {
  group('CalculationType', () {
    test('should have 8 types', () {
      expect(CalculationType.values.length, equals(8));
    });

    test('should have correct display names', () {
      expect(CalculationType.integral.displayName, equals('积分'));
      expect(CalculationType.equation.displayName, equals('方程'));
      expect(CalculationType.derivative.displayName, equals('导数'));
    });

    test('should have correct endpoints', () {
      expect(CalculationType.integral.endpoint, equals('/int/calculate.php'));
      expect(CalculationType.equation.endpoint, equals('/equ/calculate.php'));
    });
  });

  group('CalculationRequest', () {
    test('should create with required parameters', () {
      final request = CalculationRequest(expr: 'sin(x)', arg: 'x');

      expect(request.expr, equals('sin(x)'));
      expect(request.arg, equals('x'));
      expect(request.token, equals('98ae9979efca566d'));
    });

    test('toMap should return correct map', () {
      final request = CalculationRequest(expr: 'sin(x)', arg: 'x');

      final map = request.toMap();

      expect(map['expr'], equals('sin(x)'));
      expect(map['arg'], equals('x'));
    });

    test('toJson should return valid JSON string', () {
      final request = CalculationRequest(expr: 'sin(x)', arg: 'x');

      final json = request.toJson();

      expect(json, contains('"expr":"sin(x)"'));
      expect(json, contains('"arg":"x"'));
    });
  });

  group('CalculationResult', () {
    test('should parse valid API response', () {
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

      print('Result success: ${result.success}');
      print('Result error: ${result.error}');
      print('Result originalExpr: ${result.originalExpr}');
      print('Result resultLatex: ${result.resultLatex}');

      expect(result.success, isTrue, reason: 'Error: ${result.error}');
      expect(result.originalExpr, isNotEmpty);
      expect(result.resultLatex, isNotEmpty);
      expect(result.resultText, isNotEmpty);
    });

    test('should replace placeholders in LaTeX', () {
      // 使用API实际返回的带占位符的数据
      final response = [
        [
          -2,
          "\\int{\\002\\left(x\\right)}{\\;\\mathrm{d}x}",
          "-\\003\\left(x\\right)",
          "-cos(x)",
          "",
        ],
        [-10, 2, 3, 27],
        [
          -1,
          ["\\int{\\002\\left(x\\right)}{\\;\\mathrm{d}x}"],
          "0",
          1,
        ],
        [
          0,
          [0],
          "1",
          "-\\003\\left(x\\right)",
          "",
        ],
      ];

      final result = CalculationResult.fromApiResponse(response);

      print(
        'Original with placeholders: \\int{\\002\\left(x\\right)}{\\;\\mathrm{d}x}',
      );
      print('Processed originalExpr: ${result.originalExpr}');
      print('Processed resultLatex: ${result.resultLatex}');

      expect(result.success, isTrue);
      // 验证占位符已被替换
      expect(result.originalExpr, contains('\\sin'));
      expect(result.originalExpr, isNot(contains('\\002')));
      expect(result.resultLatex, contains('\\cos'));
      expect(result.resultLatex, isNot(contains('\\003')));
    });

    test('error factory should create error result', () {
      final result = CalculationResult.error('Test error');

      expect(result.success, isFalse);
      expect(result.error, equals('Test error'));
    });

    test('should handle empty response', () {
      final response = <dynamic>[];

      final result = CalculationResult.fromApiResponse(response);

      expect(result.success, isFalse);
    });

    test('should handle malformed response', () {
      final response = [
        [1, 2], // 缺少必要字段
      ];

      final result = CalculationResult.fromApiResponse(response);

      expect(result.success, isFalse);
    });
  });

  group('CalculationMetadata', () {
    test('should create with required parameters', () {
      final metadata = CalculationMetadata(
        stepCount: 5,
        complexity: 10,
        time: 100,
      );

      expect(metadata.stepCount, equals(5));
      expect(metadata.complexity, equals(10));
      expect(metadata.time, equals(100));
    });
  });
}
