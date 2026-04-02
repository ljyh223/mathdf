import 'dart:convert';

abstract class ApiRequest {
  Map<String, dynamic> toMap(String token);

  String toJson(String token) {
    final map = toMap(token);
    return jsonEncode(map).replaceAll(' ', '');
  }

  String get endpoint;
}

class IntegralRequest extends ApiRequest {
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

  @override
  Map<String, dynamic> toMap(String token) {
    return {
      'expr': expr,
      'arg': arg,
      'bottom': bottom,
      'top': top,
      'params': params,
      'def': def,
      'token': token,
      'lang': lang,
    };
  }

  @override
  String get endpoint => '/int/calculate.php';
}

class DerivativeRequest extends ApiRequest {
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

  @override
  Map<String, dynamic> toMap(String token) {
    return {
      'expr': expr,
      'arg': arg,
      'params': params,
      'funcs': funcs,
      'token': token,
      'lang': lang,
    };
  }

  @override
  String get endpoint => '/dif/calculate.php';
}

class LimitRequest extends ApiRequest {
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

  @override
  Map<String, dynamic> toMap(String token) {
    return {
      'expr': expr,
      'arg': arg,
      'to': to,
      'params': params,
      'token': token,
      'lang': lang,
    };
  }

  @override
  String get endpoint => '/lim/calculate.php';
}

class EquationRequest extends ApiRequest {
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

  @override
  Map<String, dynamic> toMap(String token) {
    return {
      'expr': expr,
      'arg': arg,
      'set': set,
      'params': params,
      'endtofloat': endtofloat,
      'token': token,
      'lang': lang,
    };
  }

  @override
  String get endpoint => '/equ/calculate.php';
}

class OdeRequest extends ApiRequest {
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

  @override
  Map<String, dynamic> toMap(String token) {
    return {
      'expr': expr,
      'arg': arg,
      'func': func,
      'params': params,
      'cauchy': cauchy,
      'token': token,
      'lang': lang,
    };
  }

  @override
  String get endpoint => '/ode/calculate.php';
}

class ComplexRequest extends ApiRequest {
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

  @override
  Map<String, dynamic> toMap(String token) {
    return {
      'expr': expr,
      'func': func,
      'endtofloat': endtofloat,
      'token': token,
      'lang': lang,
    };
  }

  @override
  String get endpoint => '/com/calculate.php';
}
