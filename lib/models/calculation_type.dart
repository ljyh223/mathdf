enum CalculationType {
  integral, // 积分
  equation, // 方程
  limit, // 极限
  derivative, // 导数
  ode, // 微分方程
  complex, // 复数
  calculator, // 基础计算
  matrix, // 矩阵
}

extension CalculationTypeExtension on CalculationType {
  /// 获取显示名称
  String get displayName {
    switch (this) {
      case CalculationType.integral:
        return '积分';
      case CalculationType.equation:
        return '方程';
      case CalculationType.limit:
        return '极限';
      case CalculationType.derivative:
        return '导数';
      case CalculationType.ode:
        return '微分方程';
      case CalculationType.complex:
        return '复数';
      case CalculationType.calculator:
        return '基础计算';
      case CalculationType.matrix:
        return '矩阵';
    }
  }

  /// 获取英文名称
  String get englishName {
    switch (this) {
      case CalculationType.integral:
        return 'Integrals';
      case CalculationType.equation:
        return 'Equations';
      case CalculationType.limit:
        return 'Limits';
      case CalculationType.derivative:
        return 'Derivatives';
      case CalculationType.ode:
        return 'Differential Equations';
      case CalculationType.complex:
        return 'Complex Numbers';
      case CalculationType.calculator:
        return 'Basic Calculator';
      case CalculationType.matrix:
        return 'Matrices';
    }
  }

  /// 获取API端点
  String get endpoint {
    switch (this) {
      case CalculationType.integral:
        return '/int/calculate.php';
      case CalculationType.equation:
        return '/equ/calculate.php';
      case CalculationType.limit:
        return '/lim/calculate.php';
      case CalculationType.derivative:
        return '/dif/calculate.php';
      case CalculationType.ode:
        return '/ode/calculate.php';
      case CalculationType.complex:
        return '/com/calculate.php';
      case CalculationType.calculator:
        return '/calc/calculate.php';
      case CalculationType.matrix:
        return '/mat/calculate.php';
    }
  }

  /// 获取图标
  String get icon {
    switch (this) {
      case CalculationType.integral:
        return '∫';
      case CalculationType.equation:
        return '=';
      case CalculationType.limit:
        return 'lim';
      case CalculationType.derivative:
        return 'd/dx';
      case CalculationType.ode:
        return "y'";
      case CalculationType.complex:
        return 'i';
      case CalculationType.calculator:
        return '123';
      case CalculationType.matrix:
        return '□';
    }
  }
}
