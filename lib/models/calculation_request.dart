/// 计算请求模型 - 统一支持所有计算类型
class CalculationRequest {
  // 核心参数
  final String expr;
  final String arg;
  final String token;
  final String lang;

  // 可选参数（使用Map存储所有额外参数）
  final Map<String, dynamic> _params;

  CalculationRequest({
    required this.expr,
    required this.arg,
    this.token = '98ae9979efca566d',
    this.lang = 'en',
    Map<String, dynamic>? params,
  }) : _params = params ?? {};

  // ==================== 工厂方法 ====================

  /// 创建积分计算请求
  factory CalculationRequest.integral({
    required String expr,
    String arg = 'x',
    String? lowerLimit,
    String? upperLimit,
  }) {
    final params = <String, dynamic>{
      'params': 'expandtable=false',
      'def': '0',
      'bottom': lowerLimit ?? '',
      'top': upperLimit ?? '',
    };
    return CalculationRequest(expr: expr, arg: arg, params: params);
  }

  /// 创建导数计算请求
  factory CalculationRequest.derivative({
    required String expr,
    String arg = 'x',
    List<String>? params,
  }) {
    final paramsMap = <String, dynamic>{
      'params': params ?? ['simplifyresult=true', 'implicitresult=false'],
      'funcs': '',
    };
    return CalculationRequest(expr: expr, arg: arg, params: paramsMap);
  }

  /// 创建极限计算请求
  factory CalculationRequest.limit({
    required String expr,
    String arg = 'x',
    required String to,
    bool useHospital = false,
  }) {
    final params = <String, dynamic>{
      'to': to,
      'params': 'usehopital=$useHospital',
    };
    return CalculationRequest(expr: expr, arg: arg, params: params);
  }

  /// 创建方程/不等式计算请求
  factory CalculationRequest.equation({
    required String expr,
    String arg = 'x',
    String set = '0',
    bool useFactor = false,
    bool endToFloat = false,
  }) {
    final params = <String, dynamic>{
      'set': set,
      'params': 'usefactor=$useFactor',
      'endtofloat': endToFloat.toString(),
    };
    return CalculationRequest(expr: expr, arg: arg, params: params);
  }

  /// 创建微分方程计算请求
  factory CalculationRequest.ode({
    required String expr,
    String func = 'y',
    String arg = 'x',
    String cauchy = '',
    bool linLagrange = false,
    bool elimMethod = false,
  }) {
    final params = <String, dynamic>{
      'func': func,
      'params': 'linlagrange=$linLagrange,elimmethod=$elimMethod',
      'cauchy': cauchy,
    };
    return CalculationRequest(expr: expr, arg: arg, params: params);
  }

  /// 创建复数计算请求
  factory CalculationRequest.complex({
    required String expr,
    String func = 'z=x+i*y',
    bool endToFloat = false,
  }) {
    final params = <String, dynamic>{
      'func': func,
      'endtofloat': endToFloat.toString(),
    };
    // 复数计算不需要arg参数
    return CalculationRequest(expr: expr, arg: '', params: params);
  }

  // ==================== 访问器 ====================

  /// 获取to参数（极限趋向值）
  String? get to => _params['to'] as String?;

  /// 获取func参数（函数名，用于微分方程和复数）
  String? get func => _params['func'] as String?;

  /// 获取set参数（用于方程/不等式）
  String? get set => _params['set'] as String?;

  /// 获取cauchy参数（用于微分方程）
  String? get cauchy => _params['cauchy'] as String?;

  /// 获取bottom参数（积分下限）
  String? get bottom => _params['bottom'] as String?;

  /// 获取top参数（积分上限）
  String? get top => _params['top'] as String?;

  // ==================== 序列化 ====================

  /// 转换为Map
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{'expr': expr, 'token': token, 'lang': lang};

    // 只有非空的arg才添加
    if (arg.isNotEmpty) {
      map['arg'] = arg;
    }

    // 添加所有额外参数（包括空字符串，因为API可能需要）
    _params.forEach((key, value) {
      if (value != null) {
        map[key] = value;
      }
    });

    return map;
  }

  /// 转换为JSON字符串
  String toJson() {
    final map = toMap();
    final entries = map.entries
        .map((e) {
          final value = e.value is List
              ? (e.value as List).map((v) => '"$v"').toList().toString()
              : '"${e.value}"';
          return '"${e.key}":$value';
        })
        .join(',');
    return '{$entries}';
  }

  /// 创建副本
  CalculationRequest copyWith({
    String? expr,
    String? arg,
    String? token,
    String? lang,
    Map<String, dynamic>? params,
  }) {
    return CalculationRequest(
      expr: expr ?? this.expr,
      arg: arg ?? this.arg,
      token: token ?? this.token,
      lang: lang ?? this.lang,
      params: params ?? _params,
    );
  }

  @override
  String toString() {
    return 'CalculationRequest(expr: $expr, arg: $arg, params: $_params)';
  }
}
