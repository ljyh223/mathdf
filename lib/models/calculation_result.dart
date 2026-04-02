import 'calculation_step.dart';

/// 响应解析器
class ResponseParser {
  /// 解析API响应
  static CalculationResult parse(List<dynamic> response) {
    try {
      if (response.isEmpty) {
        return CalculationResult.error('空响应');
      }

      // 检查第一个元素是否是结果数组
      final firstElement = response[0];
      if (firstElement is! List || firstElement.isEmpty) {
        return CalculationResult.error('无效的响应格式');
      }

      // 检查是否是错误响应
      if (firstElement[0] == -2) {
        return _parseSuccessResponse(response);
      }

      return CalculationResult.error('未知的响应类型: ${firstElement[0]}');
    } catch (e) {
      return CalculationResult.error('解析响应失败: $e');
    }
  }

  /// 解析成功响应
  static CalculationResult _parseSuccessResponse(List<dynamic> response) {
    final resultArray = response[0] as List<dynamic>;

    // 解析结果
    final originalExpr = PlaceholderProcessor.process(
      _safeGetString(resultArray, 1),
    );
    final resultLatex = PlaceholderProcessor.process(
      _safeGetString(resultArray, 2),
    );
    final resultText = _safeGetString(resultArray, 3);

    // 解析元数据
    final metadata = _parseMetadata(response);

    // 解析步骤
    final steps = _parseSteps(response);

    return CalculationResult(
      originalExpr: originalExpr,
      resultLatex: resultLatex,
      resultText: resultText,
      steps: steps,
      metadata: metadata,
    );
  }

  /// 解析元数据
  static CalculationMetadata _parseMetadata(List<dynamic> response) {
    if (response.length < 2) {
      return CalculationMetadata(stepCount: 0, complexity: 0, time: 0);
    }

    final metaArray = response[1];
    if (metaArray is! List) {
      return CalculationMetadata(stepCount: 0, complexity: 0, time: 0);
    }

    // 安全解析元数据
    return CalculationMetadata(
      stepCount: _safeGetInt(metaArray, 1, defaultValue: 0),
      complexity: _safeGetInt(metaArray, 2, defaultValue: 0),
      time: _safeGetInt(metaArray, 3, defaultValue: 0),
    );
  }

  /// 解析步骤
  static List<CalculationStep> _parseSteps(List<dynamic> response) {
    final steps = <CalculationStep>[];

    // 从第三个元素开始是步骤
    for (int i = 2; i < response.length; i++) {
      final stepData = response[i];

      // 跳过非列表元素
      if (stepData is! List) continue;

      // 跳过太短的列表
      if (stepData.length < 2) continue;

      final step = CalculationStep.fromApiData(stepData, i - 1);

      // 只添加有内容的步骤
      if (step.latex.isNotEmpty) {
        steps.add(step);
      }
    }

    return steps;
  }

  /// 安全获取字符串
  static String _safeGetString(
    List<dynamic> list,
    int index, {
    String defaultValue = '',
  }) {
    if (index < 0 || index >= list.length) return defaultValue;
    final value = list[index];
    if (value is String) return value;
    if (value is List) return value.map((e) => e.toString()).join('');
    return value.toString();
  }

  /// 安全获取整数
  static int _safeGetInt(
    List<dynamic> list,
    int index, {
    int defaultValue = 0,
  }) {
    if (index < 0 || index >= list.length) return defaultValue;
    final value = list[index];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? defaultValue;
  }
}

/// 计算结果模型
class CalculationResult {
  final String originalExpr; // 原始表达式
  final String resultLatex; // 结果LaTeX
  final String resultText; // 结果文本
  final List<CalculationStep> steps; // 计算步骤
  final CalculationMetadata metadata; // 元数据
  final bool success; // 是否成功
  final String? error; // 错误信息

  CalculationResult({
    required this.originalExpr,
    required this.resultLatex,
    required this.resultText,
    required this.steps,
    required this.metadata,
    this.success = true,
    this.error,
  });

  /// 从API响应解析
  factory CalculationResult.fromApiResponse(List<dynamic> response) {
    return ResponseParser.parse(response);
  }

  /// 创建错误结果
  factory CalculationResult.error(String errorMessage) {
    return CalculationResult(
      originalExpr: '',
      resultLatex: '',
      resultText: '',
      steps: [],
      metadata: CalculationMetadata(stepCount: 0, complexity: 0, time: 0),
      success: false,
      error: errorMessage,
    );
  }

  /// 创建副本
  CalculationResult copyWith({
    String? originalExpr,
    String? resultLatex,
    String? resultText,
    List<CalculationStep>? steps,
    CalculationMetadata? metadata,
    bool? success,
    String? error,
  }) {
    return CalculationResult(
      originalExpr: originalExpr ?? this.originalExpr,
      resultLatex: resultLatex ?? this.resultLatex,
      resultText: resultText ?? this.resultText,
      steps: steps ?? this.steps,
      metadata: metadata ?? this.metadata,
      success: success ?? this.success,
      error: error ?? this.error,
    );
  }

  @override
  String toString() {
    if (!success) {
      return 'CalculationResult(error: $error)';
    }
    return 'CalculationResult(originalExpr: $originalExpr, resultLatex: $resultLatex, steps: ${steps.length})';
  }
}

/// 计算元数据
class CalculationMetadata {
  final int stepCount;
  final int complexity;
  final int time;

  CalculationMetadata({
    required this.stepCount,
    required this.complexity,
    required this.time,
  });

  @override
  String toString() {
    return 'CalculationMetadata(stepCount: $stepCount, complexity: $complexity, time: $time)';
  }
}
