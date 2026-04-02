/// 积分计算请求模型
class IntegralRequest {
  final String expr;
  final String arg;
  final String bottom;
  final String top;
  final String params;
  final String def;
  final String lang;

  IntegralRequest({
    required this.expr,
    this.arg = 'x',
    this.bottom = '',
    this.top = '',
    this.params = 'expandtable=false',
    this.def = '0',
    this.lang = 'en',
  });

  Map<String, dynamic> toMap() {
    return {
      'expr': expr,
      'arg': arg,
      'bottom': bottom,
      'top': top,
      'params': params,
      'def': def,
      'lang': lang,
    };
  }

  String toJson() {
    final map = toMap();
    final entries = map.entries.map((e) => '"${e.key}":"${e.value}"').join(',');
    return '{$entries}';
  }
}

/// 导数计算请求模型
class DerivativeRequest {
  final String expr;
  final String arg;
  final String params;
  final String funcs;
  final String lang;

  DerivativeRequest({
    required this.expr,
    this.arg = 'x',
    this.params = 'simplifyresult=true,implicitresult=false',
    this.funcs = '',
    this.lang = 'en',
  });

  Map<String, dynamic> toMap() {
    return {
      'expr': expr,
      'arg': arg,
      'params': params,
      'funcs': funcs,
      'lang': lang,
    };
  }

  String toJson() {
    final map = toMap();
    final entries = map.entries.map((e) => '"${e.key}":"${e.value}"').join(',');
    return '{$entries}';
  }
}

/// 极限计算请求模型
class LimitRequest {
  final String expr;
  final String arg;
  final String to;
  final String params;
  final String lang;

  LimitRequest({
    required this.expr,
    this.arg = 'x',
    required this.to,
    this.params = 'usehopital=false',
    this.lang = 'en',
  });

  Map<String, dynamic> toMap() {
    return {'expr': expr, 'arg': arg, 'to': to, 'params': params, 'lang': lang};
  }

  String toJson() {
    final map = toMap();
    final entries = map.entries.map((e) => '"${e.key}":"${e.value}"').join(',');
    return '{$entries}';
  }
}

/// 方程/不等式计算请求模型
class EquationRequest {
  final String expr;
  final String arg;
  final String set;
  final String params;
  final String endtofloat;
  final String lang;

  EquationRequest({
    required this.expr,
    this.arg = 'x',
    this.set = '0',
    this.params = 'usefactor=false',
    this.endtofloat = 'false',
    this.lang = 'en',
  });

  Map<String, dynamic> toMap() {
    return {
      'expr': expr,
      'arg': arg,
      'set': set,
      'params': params,
      'endtofloat': endtofloat,
      'lang': lang,
    };
  }

  String toJson() {
    final map = toMap();
    final entries = map.entries.map((e) => '"${e.key}":"${e.value}"').join(',');
    return '{$entries}';
  }
}

/// 微分方程计算请求模型
class OdeRequest {
  final String expr;
  final String arg;
  final String func;
  final String params;
  final String cauchy;
  final String lang;

  OdeRequest({
    required this.expr,
    this.arg = 'x',
    this.func = 'y',
    this.params = 'linlagrange=false,elimmethod=false',
    this.cauchy = '',
    this.lang = 'en',
  });

  Map<String, dynamic> toMap() {
    return {
      'expr': expr,
      'arg': arg,
      'func': func,
      'params': params,
      'cauchy': cauchy,
      'lang': lang,
    };
  }

  String toJson() {
    final map = toMap();
    final entries = map.entries.map((e) => '"${e.key}":"${e.value}"').join(',');
    return '{$entries}';
  }
}

/// 复数计算请求模型
class ComplexRequest {
  final String expr;
  final String func;
  final String endtofloat;
  final String lang;

  ComplexRequest({
    required this.expr,
    this.func = 'z=x+i*y',
    this.endtofloat = 'false',
    this.lang = 'en',
  });

  Map<String, dynamic> toMap() {
    return {'expr': expr, 'func': func, 'endtofloat': endtofloat, 'lang': lang};
  }

  String toJson() {
    final map = toMap();
    final entries = map.entries.map((e) => '"${e.key}":"${e.value}"').join(',');
    return '{$entries}';
  }
}
