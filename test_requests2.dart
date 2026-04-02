import 'dart:convert';
import 'package:mathdf/models/calculation_request.dart';

void main() {
  // 使用api.md中的原始方程表达式
  final eqRequest = CalculationRequest.equation(
    expr: '4*(x^2)+12*x+12/x+4/(x^2)>=47',
  );
  print('=== Equation Request (original) ===');
  print('toMap: ${eqRequest.toMap()}');
  print('toJson: ${eqRequest.toJson()}');

  // 对比原始格式
  print('\n=== Expected Format ===');
  print(
    '{"expr":"4*(x^2)+12*x+12/x+4/(x^2)>=47","arg":"x","set":"0","params":"usefactor=false","endtofloat":"false","token":"98ae9979efca566d"}',
  );
}
