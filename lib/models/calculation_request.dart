class CalculationRequest {
  final String expr;
  final String arg;
  final String params;
  final String def;
  final String bottom;
  final String top;
  final String token;
  final String lang;

  CalculationRequest({
    required this.expr,
    required this.arg,
    this.params = 'expandtable=false',
    this.def = '0',
    this.bottom = '',
    this.top = '',
    this.token = '98ae9979efca566d',
    this.lang = 'en',
  });

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'expr': expr,
      'arg': arg,
      'params': params,
      'def': def,
      'bottom': bottom,
      'top': top,
      'token': token,
      'lang': lang,
    };
  }

  /// 转换为JSON字符串
  String toJson() {
    final map = toMap();
    final entries = map.entries.map((e) => '"${e.key}":"${e.value}"').join(',');
    return '{$entries}';
  }

  /// 创建副本
  CalculationRequest copyWith({
    String? expr,
    String? arg,
    String? params,
    String? def,
    String? bottom,
    String? top,
    String? token,
    String? lang,
  }) {
    return CalculationRequest(
      expr: expr ?? this.expr,
      arg: arg ?? this.arg,
      params: params ?? this.params,
      def: def ?? this.def,
      bottom: bottom ?? this.bottom,
      top: top ?? this.top,
      token: token ?? this.token,
      lang: lang ?? this.lang,
    );
  }

  @override
  String toString() {
    return 'CalculationRequest(expr: $expr, arg: $arg, params: $params, def: $def, bottom: $bottom, top: $top, token: $token, lang: $lang)';
  }
}
