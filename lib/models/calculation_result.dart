import 'calculation_step.dart';

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
    try {
      // 解析最终结果（第一个数组）
      final resultArray = response[0] as List<dynamic>;
      final originalExpr = _processPlaceholders(resultArray[1] as String);
      final resultLatex = _processPlaceholders(resultArray[2] as String);
      final resultText = resultArray[3] as String;

      // 解析元数据（第二个数组）
      final metadataArray = response[1] as List<dynamic>;
      final metadata = CalculationMetadata(
        stepCount: metadataArray.length > 1
            ? (metadataArray[1] as int? ?? 0)
            : 0,
        complexity: metadataArray.length > 2
            ? (metadataArray[2] as int? ?? 0)
            : 0,
        time: metadataArray.length > 3 ? (metadataArray[3] as int? ?? 0) : 0,
      );

      // 解析计算步骤
      final steps = <CalculationStep>[];
      for (int i = 2; i < response.length; i++) {
        final stepArray = response[i] as List<dynamic>;
        if (stepArray.length >= 2) {
          final step = CalculationStep.fromApiData(stepArray, i - 1);
          // 过滤掉空步骤
          if (step.latex.isNotEmpty) {
            steps.add(step);
          }
        }
      }

      return CalculationResult(
        originalExpr: originalExpr,
        resultLatex: resultLatex,
        resultText: resultText,
        steps: steps,
        metadata: metadata,
      );
    } catch (e) {
      return CalculationResult.error('解析响应失败: $e');
    }
  }

  static String _processPlaceholders(String input) {
    if (input.isEmpty) return input;
    return input
        .replaceAll('\\002', '\\sin')
        .replaceAll('\\003', '\\cos')
        .replaceAll('\\004', '\\tan')
        .replaceAll('\\005', '\\cot')
        .replaceAll('\\006', '\\sec')
        .replaceAll('\\007', '\\csc')
        .replaceAll('\\010', '\\arcsin')
        .replaceAll('\\011', '\\arccos')
        .replaceAll('\\012', '\\arctan')
        .replaceAll('\\013', '\\sinh')
        .replaceAll('\\014', '\\cosh')
        .replaceAll('\\015', '\\tanh')
        .replaceAll('\\016', '\\ln')
        .replaceAll('\\017', '\\log')
        .replaceAll('\\020', '\\exp')
        .replaceAll('\\021', '\\sqrt');
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
    return 'CalculationResult(success: $success, originalExpr: $originalExpr, resultLatex: $resultLatex, resultText: $resultText, steps: ${steps.length}, error: $error)';
  }
}

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
