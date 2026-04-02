/// 计算步骤类型
enum StepType {
  start, // -1: 开始计算
  basicIntegral, // 0: 使用积分公式
  expand, // 2: 展开/因式分解
  extractConstant, // 3: 提取常数
  substitution, // 5: 换元法 (u-substitution)
  trigIdentity, // 9: 三角恒等式
  backSubstitute, // 11: 回代
  result, // -2: 最终结果
  other,
}

/// 单个计算步骤
class CalculationStep {
  final StepType type;
  final int stepNumber;
  final String description; // 步骤描述
  final String latex; // 该步骤的LaTeX表达式
  final String? method; // 使用的方法说明

  CalculationStep({
    required this.type,
    required this.stepNumber,
    required this.description,
    required this.latex,
    this.method,
  });

  /// 从API步骤数据解析
  factory CalculationStep.fromApiData(List<dynamic> data, int stepNumber) {
    final typeCode = data[0] as int;
    final type = _parseStepType(typeCode);

    String description = '';
    String latex = '';
    String? method;

    switch (type) {
      case StepType.start:
        // [-1, [表达式], 起始行, 结束行]
        description = '计算积分';
        if (data[1] is List) {
          latex = (data[1] as List).map((e) => _process(e.toString())).join('');
        } else {
          latex = _process(data[1].toString());
        }
        break;

      case StepType.trigIdentity:
        // [9, [公式类型, 变量, 参数], 系数, 结果]
        description = '应用三角恒等式';
        latex = _process(data[3].toString());
        method = 'sin²(x) = (1-cos(2x))/2';
        break;

      case StepType.expand:
        // [2, [...], 系数, 展开结果, [分支信息]]
        description = '展开';
        latex = _process(data[3].toString());
        break;

      case StepType.extractConstant:
        // [3, 行号, 常数, 剩余积分]
        description = '提取常数';
        latex = _process(data[3].toString());
        break;

      case StepType.substitution:
        // [5, [...], [u=..., x=..., dx=...], 系数, 新积分, ...]
        description = '换元积分';
        if (data[2] is List && (data[2] as List).isNotEmpty) {
          method = _process((data[2] as List)[0].toString());
        }
        if (data.length > 4) {
          latex = _process(data[4].toString());
        }
        break;

      case StepType.basicIntegral:
        // [0, [公式类型], 系数, 被积函数, 结果]
        description = '积分';
        if (data.length > 4 && data[4].toString().isNotEmpty) {
          latex = _process(data[4].toString());
        } else if (data.length > 3) {
          latex = _process(data[3].toString());
        }
        break;

      case StepType.backSubstitute:
        // [11, [u=..., 关系], 结果, ...]
        description = '回代';
        if (data[1] is List && (data[1] as List).isNotEmpty) {
          method = _process((data[1] as List)[0].toString());
        }
        latex = _process(data[2].toString());
        break;

      default:
        // 其他类型，尝试获取输出
        description = '计算';
        if (data.length > 3) {
          latex = _process(data[3].toString());
        } else if (data.length > 2) {
          latex = _process(data[2].toString());
        }
    }

    return CalculationStep(
      type: type,
      stepNumber: stepNumber,
      description: description,
      latex: latex,
      method: method,
    );
  }

  static StepType _parseStepType(int code) {
    switch (code) {
      case -2:
        return StepType.result;
      case -1:
        return StepType.start;
      case 0:
        return StepType.basicIntegral;
      case 2:
        return StepType.expand;
      case 3:
        return StepType.extractConstant;
      case 5:
        return StepType.substitution;
      case 9:
        return StepType.trigIdentity;
      case 11:
        return StepType.backSubstitute;
      default:
        return StepType.other;
    }
  }

  static String _process(String input) {
    if (input.isEmpty) return input;

    String result = input;

    // 替换占位符为实际函数名
    result = result
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

    // 移除HTML class标记但保留内容
    result = result.replaceAll(RegExp(r'\\class\{[^}]*\}\{'), '');

    return result;
  }
}
