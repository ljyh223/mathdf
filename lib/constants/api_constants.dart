class ApiConstants {
  static const String baseUrl = 'https://mathdf.com';

  // API端点
  static const String integralEndpoint = '/int/calculate.php';
  static const String equationEndpoint = '/equ/calculate.php';
  static const String limitEndpoint = '/lim/calculate.php';
  static const String derivativeEndpoint = '/dif/calculate.php';
  static const String odeEndpoint = '/der/calculate.php';
  static const String complexEndpoint = '/com/calculate.php';
  static const String calculatorEndpoint = '/calc/calculate.php';
  static const String matrixEndpoint = '/mat/calculate.php';

  // 超时时间
  static const int connectTimeout = 10000; // 10秒
  static const int receiveTimeout = 10000; // 10秒
}
