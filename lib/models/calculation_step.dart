/// 步骤分类
enum StepCategory {
  start, // 开始计算
  result, // 最终结果
  integral, // 积分
  expand, // 展开
  extract, // 提取常数
  substitution, // 换元
  transform, // 变换
  equation, // 方程相关
  complex, // 复数相关
  inequality, // 不等式
  other, // 其他
}

/// 占位符处理器
class PlaceholderProcessor {
  static const Map<String, String> placeholders = {
    '\\001': '\\log',
    '\\002': '\\sin',
    '\\003': '\\cos',
    '\\004': '\\tan',
    '\\005': '\\cot',
    '\\006': '\\arctan',
    '\\007': '\\csc',
    '\\010': '\\arcsin',
    '\\011': '\\arccos',
    '\\012': '\\arctan',
    '\\013': '\\sinh',
    '\\014': '\\cosh',
    '\\015': '\\tanh',
    '\\016': '\\ln',
    '\\017': '\\log',
    '\\020': '\\exp',
    '\\021': '\\sqrt',
  };

  /// 处理占位符
  static String process(String input) {
    if (input.isEmpty) return input;

    String result = input;

    // 替换占位符
    placeholders.forEach((key, value) {
      result = result.replaceAll(key, value);
    });

    // 移除HTML class标记但保留内容
    result = result.replaceAll(RegExp(r'\\class\{[^}]*\}\{'), '');
    result = result.replaceAll(RegExp(r'\\htmlClass\{[^}]*\}\{'), '');
    result = result.replaceAll(RegExp(r'\\cssId\{[^}]*\}\{'), '');

    // 移除cancel标记
    result = result.replaceAll(RegExp(r'\\cancel\{[^}]*\}'), '');

    return result;
  }
}

/// 单个计算步骤
class CalculationStep {
  final dynamic typeCode; // 可以是int或String
  final StepCategory category;
  final int stepNumber;
  final String description;
  final String latex;
  final String? method;
  final Map<String, dynamic> rawData;

  CalculationStep({
    required this.typeCode,
    required this.category,
    required this.stepNumber,
    required this.description,
    required this.latex,
    this.method,
    Map<String, dynamic>? rawData,
  }) : rawData = rawData ?? {};

  /// 从API步骤数据解析
  factory CalculationStep.fromApiData(dynamic data, int stepNumber) {
    if (data is! List || data.isEmpty) {
      return CalculationStep(
        typeCode: null,
        category: StepCategory.other,
        stepNumber: stepNumber,
        description: '未知步骤',
        latex: '',
      );
    }

    final typeCode = data[0];
    final category = parseCategory(typeCode);

    String description = '';
    String latex = '';
    String? method;
    Map<String, dynamic> rawData = {'original': data};

    switch (category) {
      case StepCategory.start:
        description = '开始计算';
        latex = _extractLatex(data, preferredIndex: 1);
        break;

      case StepCategory.integral:
        description = '积分';
        latex = _extractLatex(data, preferredIndex: 3);
        break;

      case StepCategory.expand:
        description = '展开';
        latex = _extractLatex(data, preferredIndex: 3);
        break;

      case StepCategory.extract:
        description = '提取';
        latex = _extractLatex(data, preferredIndex: 3);
        break;

      case StepCategory.substitution:
        description = '换元';
        method = _extractMethod(data);
        latex = _extractLatex(data, preferredIndex: 4);
        break;

      case StepCategory.transform:
        description = '变换';
        latex = _extractLatex(data, preferredIndex: 1);
        break;

      case StepCategory.equation:
        description = '方程';
        latex = _extractLatex(data, preferredIndex: 1);
        break;

      case StepCategory.complex:
        description = '复数';
        latex = _extractLatex(data, preferredIndex: 1);
        break;

      case StepCategory.inequality:
        description = '不等式';
        latex = _extractLatex(data, preferredIndex: 1);
        break;

      case StepCategory.result:
        description = '结果';
        latex = _extractLatex(data, preferredIndex: 2);
        break;

      default:
        description = '计算步骤';
        latex = _extractLatex(data, preferredIndex: 1);
    }

    return CalculationStep(
      typeCode: typeCode,
      category: category,
      stepNumber: stepNumber,
      description: description,
      latex: PlaceholderProcessor.process(latex),
      method: method,
      rawData: rawData,
    );
  }

  /// 解析步骤类型
  static StepCategory parseCategory(dynamic typeCode) {
    if (typeCode is int) {
      switch (typeCode) {
        case -2:
          return StepCategory.result;
        case -1:
          return StepCategory.start;
        case 0:
          return StepCategory.integral;
        case 2:
          return StepCategory.expand;
        case 3:
          return StepCategory.extract;
        case 5:
          return StepCategory.substitution;
        case 6:
          return StepCategory.transform;
        case 9:
          return StepCategory.transform;
        case 11:
          return StepCategory.substitution;
        default:
          return StepCategory.other;
      }
    }

    if (typeCode is String) {
      // 处理字符串类型码
      final code = typeCode.replaceAll('-', '');

      if (typeCode.startsWith('-') && typeCode.endsWith('-')) {
        // 如 "-1-", "-2-", "6-"
        switch (code) {
          case '1':
            return StepCategory.start;
          case '2':
            return StepCategory.expand;
          case '3':
            return StepCategory.extract;
          case '5':
            return StepCategory.substitution;
          case '6':
            return StepCategory.transform;
          case '111':
            return StepCategory.inequality;
          case '15':
            return StepCategory.equation;
          case '0':
            return StepCategory.integral;
          case '4':
            return StepCategory.substitution;
          default:
            return StepCategory.other;
        }
      }

      // 数学运算符
      if (['+', '-', '*', '/'].contains(typeCode)) {
        return StepCategory.transform;
      }
    }

    return StepCategory.other;
  }

  /// 提取LaTeX表达式
  static String _extractLatex(List<dynamic> data, {int preferredIndex = 1}) {
    // 尝试从首选索引提取
    if (data.length > preferredIndex) {
      final item = data[preferredIndex];
      if (item is String) {
        return item;
      }
      if (item is List) {
        return item.map((e) => e.toString()).join('');
      }
    }

    // 回退：查找第一个字符串
    for (int i = 1; i < data.length; i++) {
      if (data[i] is String) {
        final str = data[i] as String;
        // 跳过太短的字符串
        if (str.length > 2) {
          return str;
        }
      }
    }

    return '';
  }

  /// 提取方法说明
  static String? _extractMethod(List<dynamic> data) {
    for (int i = 1; i < data.length; i++) {
      if (data[i] is List) {
        final list = data[i] as List;
        for (final item in list) {
          if (item is String && item.contains('=')) {
            return PlaceholderProcessor.process(item);
          }
        }
      }
    }
    return null;
  }

  @override
  String toString() {
    return 'CalculationStep(typeCode: $typeCode, category: $category, latex: $latex)';
  }
}
