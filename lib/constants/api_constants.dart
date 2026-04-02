class ApiConstants {
  static const String baseUrl = 'https://mathdf.com';

  // API端点
  static const String integralEndpoint = '/int/calculate.php';
  static const String equationEndpoint = '/equ/calculate.php';
  static const String limitEndpoint = '/lim/calculate.php';
  static const String derivativeEndpoint = '/dif/calculate.php';
  static const String odeEndpoint = '/ode/calculate.php';
  static const String complexEndpoint = '/com/calculate.php';
  static const String calculatorEndpoint = '/calc/calculate.php';
  static const String matrixEndpoint = '/mat/calculate.php';

  // Token
  static const String token = '98ae9979efca566d';

  // 请求头
  static Map<String, String> get headers => {
    'Content-Type': 'application/x-www-form-urlencoded',
    'User-Agent':
        'Mozilla/5.0 (X11; Linux x86_64; rv:148.0) Gecko/20100101 Firefox/148.0',
    'Cookie':
        '_ga_TMLP1D3BYZ=GS2.1.s1775056456\$o20\$g1\$t1775056462\$j54\$l0\$h0; _ga=GA1.1.243734629.1771126008; __gads=ID=dc0a8d6ba5b7a067:T=1771126014:RT=1775056474:S=ALNI_MZ9D-r0nf3oEOtckmIxN1CnapS9dg; __gpi=UID=00001385d66ab352:T=1771126014:RT=1775056474:S=ALNI_MbBhH5ZJEsnLySTzu23vMajiXgDOA; __eoi=ID=9a01fec717daa912:T=1771126014:RT=1775056474:S=AA-AfjZSi0zNjrdSfRpTv0sDDvj8; FCCDCF=%5Bnull%2Cnull%2Cnull%2Cnull%2Cnull%2Cnull%2C%5B%5B32%2C%22%5B%5C%2263d17e43-187a-44bd-bdf1-f4f4c94747b0%5C%22%2C%5B1771126016%2C188000000%5D%5D%22%5D%5D%5D; FCNEC=%5B%5B%22AKsRol9rn-_umHincbm6774vDKdfvKErjQ8cGGBcoQsqAoX3zYFOB9hcMX44Muo1YBKnczWNJcneqmL90UUzx-laL53Ekkzs4bJ0wZHz8x0tHwCJQ2zhcK01t5vfN6utJ4Rg6kDBLNQeQzZ5UKv9AyCEraWkgxvhzQ%3D%3D%22%5D%5D; PHPSESSID=jbqf5fgvs0hjektsbg81igi0d2; theme=0; last-lang=en',
  };

  // 超时时间
  static const int connectTimeout = 10000; // 10秒
  static const int receiveTimeout = 10000; // 10秒
}
