import 'dart:convert';
import 'package:mathdf/models/calculation_request.dart';

void main() {
  final request = CalculationRequest.integral(expr: 'sin(x)', arg: 'x');
  print('toMap: ${request.toMap()}');
  print('toJson: ${request.toJson()}');

  // 验证JSON格式
  try {
    final decoded = jsonDecode(request.toJson());
    print('Decoded: $decoded');
  } catch (e) {
    print('JSON decode error: $e');
  }
}
