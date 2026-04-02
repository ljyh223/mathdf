import 'package:flutter_test/flutter_test.dart';
import 'package:mathdf/models/calculation_type.dart';
import 'package:mathdf/models/api_requests.dart';
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
  });

  group('IntegralRequest', () {
    test('should create with required parameters', () {
      final request = IntegralRequest(expr: 'sin(x)', arg: 'x');

      expect(request.expr, equals('sin(x)'));
      expect(request.arg, equals('x'));
      expect(request.endpoint, equals('/int/calculate.php'));
    });

    test('toMap should include token', () {
      final request = IntegralRequest(expr: 'sin(x)', arg: 'x');

      final map = request.toMap('test_token');

      expect(map['expr'], equals('sin(x)'));
      expect(map['arg'], equals('x'));
      expect(map['token'], equals('test_token'));
    });

    test('toJson should return valid JSON with token', () {
      final request = IntegralRequest(expr: 'sin(x)', arg: 'x');

      final json = request.toJson('test_token');

      expect(json, contains('"expr":"sin(x)"'));
      expect(json, contains('"arg":"x"'));
      expect(json, contains('"token":"test_token"'));
    });
  });

  group('DerivativeRequest', () {
    test('should create with correct endpoint', () {
      final request = DerivativeRequest(expr: 'x^2');

      expect(request.endpoint, equals('/dif/calculate.php'));
    });

    test('toMap should include all fields', () {
      final request = DerivativeRequest(expr: 'x^2', arg: 'x');

      final map = request.toMap('token123');

      expect(map['expr'], equals('x^2'));
      expect(map['token'], equals('token123'));
      expect(map['params'], equals('simplifyresult=true,implicitresult=false'));
    });
  });

  group('EquationRequest', () {
    test('should create with correct endpoint', () {
      final request = EquationRequest(expr: 'x^2=4');

      expect(request.endpoint, equals('/equ/calculate.php'));
    });

    test('toMap should include set parameter', () {
      final request = EquationRequest(expr: 'x^2=4', set: '0');

      final map = request.toMap('token123');

      expect(map['set'], equals('0'));
      expect(map['token'], equals('token123'));
    });
  });

  group('LimitRequest', () {
    test('should require to parameter', () {
      final request = LimitRequest(expr: '1/x', to: 'inf');

      expect(request.endpoint, equals('/lim/calculate.php'));
      expect(request.to, equals('inf'));
    });
  });

  group('OdeRequest', () {
    test('should create with correct endpoint', () {
      final request = OdeRequest(expr: "y'=y");

      expect(request.endpoint, equals('/ode/calculate.php'));
    });

    test('toMap should include func parameter', () {
      final request = OdeRequest(expr: "y'=y", func: 'y');

      final map = request.toMap('token123');

      expect(map['func'], equals('y'));
      expect(map['token'], equals('token123'));
    });
  });

  group('ComplexRequest', () {
    test('should create with correct endpoint', () {
      final request = ComplexRequest(expr: 'conj(1+i)');

      expect(request.endpoint, equals('/com/calculate.php'));
    });

    test('toMap should not include arg parameter', () {
      final request = ComplexRequest(expr: 'conj(1+i)');

      final map = request.toMap('token123');

      expect(map.containsKey('arg'), isFalse);
      expect(map['func'], equals('z=x+i*y'));
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

      expect(result.success, isTrue, reason: 'Error: ${result.error}');
      expect(result.originalExpr, isNotEmpty);
      expect(result.resultLatex, isNotEmpty);
      expect(result.resultText, isNotEmpty);
    });

    test('should replace placeholders in LaTeX', () {
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

      expect(result.success, isTrue);
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
        [1, 2],
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
