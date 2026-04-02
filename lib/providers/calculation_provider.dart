import 'package:flutter/foundation.dart';
import 'package:mathdf/models/calculation_type.dart';
import 'package:mathdf/models/calculation_result.dart';
import 'package:mathdf/services/api_service.dart';

class CalculationProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // 状态
  CalculationType _selectedType = CalculationType.integral;
  String _expression = '';
  String _variable = 'x';
  String _lowerLimit = '';
  String _upperLimit = '';
  String? _additionalParam;

  CalculationResult? _result;
  bool _isLoading = false;
  String? _error;

  // Getters
  CalculationType get selectedType => _selectedType;
  String get expression => _expression;
  String get variable => _variable;
  String get lowerLimit => _lowerLimit;
  String get upperLimit => _upperLimit;
  String? get additionalParam => _additionalParam;
  CalculationResult? get result => _result;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 是否显示积分上下限输入
  bool get showIntegralLimits => _selectedType == CalculationType.integral;

  // 是否显示极限点输入
  bool get showLimitPoint => _selectedType == CalculationType.limit;

  // 是否显示变量输入
  bool get showVariableInput => _selectedType != CalculationType.calculator;

  // Actions
  void setType(CalculationType type) {
    _selectedType = type;
    _result = null;
    _error = null;
    notifyListeners();
  }

  void setExpression(String expression) {
    _expression = expression;
    notifyListeners();
  }

  void setVariable(String variable) {
    _variable = variable;
    notifyListeners();
  }

  void setLowerLimit(String limit) {
    _lowerLimit = limit;
    notifyListeners();
  }

  void setUpperLimit(String limit) {
    _upperLimit = limit;
    notifyListeners();
  }

  void setAdditionalParam(String? param) {
    _additionalParam = param;
    notifyListeners();
  }

  void clearResult() {
    _result = null;
    _error = null;
    notifyListeners();
  }

  void clearAll() {
    _expression = '';
    _variable = 'x';
    _lowerLimit = '';
    _upperLimit = '';
    _additionalParam = null;
    _result = null;
    _error = null;
    notifyListeners();
  }

  // 计算
  Future<void> calculate() async {
    if (_expression.isEmpty) {
      _error = '请输入表达式';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    _result = null;
    notifyListeners();

    try {
      _result = await _apiService.calculate(
        type: _selectedType,
        expression: _expression,
        variable: _variable,
        lowerLimit: _lowerLimit.isNotEmpty ? _lowerLimit : null,
        upperLimit: _upperLimit.isNotEmpty ? _upperLimit : null,
        additionalParam: _additionalParam,
      );

      if (!_result!.success) {
        _error = _result!.error;
      }
    } catch (e) {
      _error = '计算失败: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 快捷方法
  Future<void> calculateIntegral() async {
    _selectedType = CalculationType.integral;
    await calculate();
  }

  Future<void> calculateEquation() async {
    _selectedType = CalculationType.equation;
    await calculate();
  }

  Future<void> calculateLimit() async {
    _selectedType = CalculationType.limit;
    await calculate();
  }

  Future<void> calculateDerivative() async {
    _selectedType = CalculationType.derivative;
    await calculate();
  }

  Future<void> calculateODE() async {
    _selectedType = CalculationType.ode;
    await calculate();
  }

  Future<void> calculateComplex() async {
    _selectedType = CalculationType.complex;
    await calculate();
  }

  Future<void> calculateBasic() async {
    _selectedType = CalculationType.calculator;
    await calculate();
  }

  Future<void> calculateMatrix() async {
    _selectedType = CalculationType.matrix;
    await calculate();
  }
}
