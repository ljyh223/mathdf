enum CalculationType {
  integral,
  equation,
  limit,
  derivative,
  ode,
  complex,
  calculator,
  matrix,
}

extension CalculationTypeExtension on CalculationType {
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
