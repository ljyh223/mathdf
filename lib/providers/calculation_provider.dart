import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:mathdf/models/calculation_type.dart';
import 'package:mathdf/models/calculation_result.dart';
import 'package:mathdf/services/api_service.dart';
import 'package:mathdf/services/dynamic_auth_service.dart';
import 'package:mathdf/services/ocr/latex_ocr_service.dart';

class CalculationProvider with ChangeNotifier {
  final DynamicAuthService _authService = DynamicAuthService();
  late final ApiService _apiService;
  final LatexOcrService _ocrService = LatexOcrService();

  CalculationProvider() {
    _apiService = ApiService(_authService);
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      await _authService.ensureAuthReady();
    } catch (e) {
      print('[CalculationProvider] Failed to initialize auth: $e');
    }
  }

  // 状态
  CalculationType _selectedType = CalculationType.integral;
  String _expression = '';
  String _variable = 'x';
  String _lowerLimit = '';
  String _upperLimit = '';
  String? _additionalParam;
  String? _limitTo; // 极限趋向值

  CalculationResult? _result;
  bool _isLoading = false;
  bool _isOcrLoading = false;
  String? _error;

  bool _ocrInitialized = false;

  // Getters
  CalculationType get selectedType => _selectedType;
  String get expression => _expression;
  String get variable => _variable;
  String get lowerLimit => _lowerLimit;
  String get upperLimit => _upperLimit;
  String? get additionalParam => _additionalParam;
  String? get limitTo => _limitTo;
  CalculationResult? get result => _result;
  bool get isLoading => _isLoading;
  bool get isOcrLoading => _isOcrLoading;
  String? get error => _error;
  bool get ocrInitialized => _ocrInitialized;

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

  void setLimitTo(String? to) {
    _limitTo = to;
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
    _limitTo = null;
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
        to: _selectedType == CalculationType.limit ? _limitTo : null,
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

  // OCR相关方法

  /// 初始化OCR服务
  Future<void> initOcr() async {
    if (_ocrInitialized) return;

    try {
      await _ocrService.init();
      _ocrInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Failed to init OCR: $e');
    }
  }

  /// 从图片识别LaTeX公式
  Future<void> recognizeFromImage(List<int> imageBytes) async {
    if (!_ocrInitialized) {
      await initOcr();
    }

    _isOcrLoading = true;
    _error = null;
    notifyListeners();

    try {
      final latex = await _ocrService.recognize(Uint8List.fromList(imageBytes));

      if (latex.isNotEmpty) {
        _expression = latex;
      } else {
        _error = '未能识别出公式';
      }
    } catch (e) {
      _error = 'OCR识别失败: $e';
    } finally {
      _isOcrLoading = false;
      notifyListeners();
    }
  }
}
