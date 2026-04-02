import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:mathdf/models/calculation_type.dart';
import 'package:mathdf/models/calculation_result.dart';
import 'package:mathdf/services/api_service.dart';
import 'package:mathdf/services/dynamic_auth_service.dart';
import 'package:mathdf/services/ocr/latex_ocr_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class CalculationProvider with ChangeNotifier {
  final DynamicAuthService _authService = DynamicAuthService();
  late final ApiService _apiService;
  final LatexOcrService _ocrService = LatexOcrService();
  final ImagePicker _imagePicker = ImagePicker();

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
  String? _limitTo;

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

  bool get showIntegralLimits => _selectedType == CalculationType.integral;
  bool get showLimitPoint => _selectedType == CalculationType.limit;
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

  // OCR methods
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

  Future<void> pickFromCamera() async {
    if (!_ocrInitialized) {
      await initOcr();
    }

    _isOcrLoading = true;
    _error = null;
    notifyListeners();

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        await _recognizeImage(bytes);
      } else {
        _isOcrLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = '拍照识别失败: $e';
      _isOcrLoading = false;
      notifyListeners();
    }
  }

  Future<void> pickFromGallery() async {
    if (!_ocrInitialized) {
      await initOcr();
    }

    _isOcrLoading = true;
    _error = null;
    notifyListeners();

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        await _recognizeImage(bytes);
      } else {
        _isOcrLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = '相册选择失败: $e';
      _isOcrLoading = false;
      notifyListeners();
    }
  }

  Future<void> pickFromFile() async {
    if (!_ocrInitialized) {
      await initOcr();
    }

    _isOcrLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          final xfile = file.xFile;
          if (xfile != null) {
            final bytes = await xfile.readAsBytes();
            await _recognizeImage(bytes);
          }
        }
      } else {
        _isOcrLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = '文件选择失败: $e';
      _isOcrLoading = false;
      notifyListeners();
    }
  }

  Future<void> _recognizeImage(Uint8List imageBytes) async {
    try {
      final latex = await _ocrService.recognize(imageBytes);

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
