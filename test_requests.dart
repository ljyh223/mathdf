import 'dart:convert';
import 'package:mathdf/models/calculation_request.dart';

void main() {
  // 测试导数请求
  final derivRequest = CalculationRequest.derivative(expr: 'x^2');
  print('=== Derivative Request ===');
  print('toMap: ${derivRequest.toMap()}');
  print('toJson: ${derivRequest.toJson()}');

  // 测试方程请求
  final eqRequest = CalculationRequest.equation(expr: 'x^2=4');
  print('\n=== Equation Request ===');
  print('toMap: ${eqRequest.toMap()}');
  print('toJson: ${eqRequest.toJson()}');

  // 测试积分请求
  final intRequest = CalculationRequest.integral(expr: 'sin(x)');
  print('\n=== Integral Request ===');
  print('toMap: ${intRequest.toMap()}');
  print('toJson: ${intRequest.toJson()}');
}
