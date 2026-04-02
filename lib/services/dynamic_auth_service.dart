import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_js/flutter_js.dart';

class DynamicAuthService {
  static final DynamicAuthService _instance = DynamicAuthService._internal();
  factory DynamicAuthService() => _instance;
  DynamicAuthService._internal();

  late final Dio _dio;
  late final CookieJar _cookieJar;
  bool _initialized = false;
  String _token = '';
  DateTime? _sessionCreatedAt;
  JavascriptRuntime? _jsRuntime;

  static const Duration sessionDuration = Duration(minutes: 24);

  String get token => _token;
  CookieJar get cookieJar => _cookieJar;
  Dio get dio {
    if (!_initialized) {
      throw StateError('DynamicAuthService not initialized, call init() first');
    }
    return _dio;
  }

  bool get isSessionExpired {
    if (_sessionCreatedAt == null || _token.isEmpty) return true;
    return DateTime.now().difference(_sessionCreatedAt!) >= sessionDuration;
  }

  Future<void> init() async {
    if (_initialized) return;

    final dir = await getApplicationDocumentsDirectory();
    final cookieDir = '${dir.path}/.cookies/';

    _cookieJar = PersistCookieJar(storage: FileStorage(cookieDir));

    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://mathdf.com',
        followRedirects: false,
        validateStatus: (status) => status != null && status < 500,
        headers: {
          'User-Agent':
              'Mozilla/5.0 (X11; Linux x86_64; rv:148.0) Gecko/20100101 Firefox/148.0',
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.5',
          'Accept-Encoding': 'gzip, deflate, br',
          'Connection': 'keep-alive',
          'Upgrade-Insecure-Requests': '1',
        },
      ),
    );
    _dio.interceptors.add(CookieManager(_cookieJar));
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('=== REQUEST ===');
          print('URL: ${options.method} ${options.uri}');
          print('Headers: ${options.headers}');
          print('Data: ${options.data}');
          print('=============');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('=== RESPONSE ===');
          print('Status: ${response.statusCode}');
          print('Headers: ${response.headers.map}');
          print('Set-Cookie: ${response.headers['set-cookie']}');
          print('Body: ${response.data}');
          print('==============');
          return handler.next(response);
        },
        onError: (error, handler) {
          print('=== ERROR ===');
          print('URL: ${error.requestOptions.uri}');
          print('Message: ${error.message}');
          if (error.response != null) {
            print('Status: ${error.response!.statusCode}');
            print('Headers: ${error.response!.headers.map}');
          }
          print('===========');
          return handler.next(error);
        },
      ),
    );

    _initialized = true;
  }

  Future<void> ensureAuthReady() async {
    await init();
    await fetchFreshAuth();
  }

  Future<void> fetchFreshAuth() async {
    await init();
    _token = '';
    await _clearCookies();
    await _fetchAuthInfo();
    _sessionCreatedAt = DateTime.now();
    await _saveSessionToPrefs(_token, _sessionCreatedAt!);
    final cookies = await _cookieJar.loadForRequest(
      Uri.parse('https://mathdf.com'),
    );
    print('[Auth] Fresh token: $_token');
    print('[Auth] Fresh cookies: $cookies');
  }

  Future<void> _clearCookies() async {
    final uri = Uri.parse('https://mathdf.com');
    final cookies = await _cookieJar.loadForRequest(uri);
    for (final cookie in cookies) {
      await _cookieJar.saveFromResponse(uri, [
        Cookie(cookie.name, cookie.value)
          ..expires = DateTime.now().subtract(const Duration(days: 1)),
      ]);
    }
  }

  Future<void> refresh() async => fetchFreshAuth();

  Future<void> _fetchAuthInfo() async {
    try {
      final response = await _dio.get(
        '/int/',
        options: Options(
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final html = response.data.toString();
      final RegExp regExp = RegExp(r'rando\s*=\s*`([^`]*)`');
      final Match? match = regExp.firstMatch(html);

      if (match != null && match.groupCount >= 1) {
        String jsfuck = match.group(1)!;
        print('[Auth] JSFuck: $jsfuck');
        _token = _decodeToken(jsfuck);
      } else {
        throw Exception('Failed to extract rando from /int/ HTML');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch auth info: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error during auth fetch: $e');
    }
  }

  String _decodeToken(String jsfuck) {
    var processed = jsfuck.replaceAll('^2', '1');
    processed = processed
        .split('')
        .reversed
        .join('')
        .substring(1, processed.length - 1);
    var js = 'return ""' + processed;
    if (js.substring(js.length - 1, js.length) == '+') {
      js = js.substring(0, js.length - 1);
    }
    print('[Auth] Decoding JS: $js');

    final result = _evaluateJs(js);
    print('[Auth] JS result: $result');

    final token = result.split('.').first;
    if (token.isEmpty || token.length != 16) {
      throw Exception('Invalid token length: $token (from $result)');
    }
    print('[Auth] Token: $token');
    return token;
  }

  String _evaluateJs(String js) {
    _jsRuntime ??= getJavascriptRuntime();
    final escapedJs = js.replaceAll('\\', '\\\\').replaceAll("'", "\\'");
    final result = _jsRuntime!.evaluate("new Function('$escapedJs')()");
    return result.stringResult.trim();
  }

  Future<String> get _sessionFile async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/.mathdf_session';
  }

  Future<void> _loadSessionFromPrefs() async {
    try {
      final file = File(await _sessionFile);
      if (await file.exists()) {
        final content = await file.readAsString();
        final data = jsonDecode(content) as Map<String, dynamic>;
        _token = data['token'] as String;
        _sessionCreatedAt = DateTime.parse(data['createdAt'] as String);
        print('[Auth] Loaded cached session, token: $_token');
      }
    } catch (_) {}
  }

  Future<void> _saveSessionToPrefs(String token, DateTime createdAt) async {
    try {
      final file = File(await _sessionFile);
      final data = jsonEncode({
        'token': token,
        'createdAt': createdAt.toIso8601String(),
      });
      await file.writeAsString(data);
      print('[Auth] Session saved');
    } catch (e) {
      print('[Auth] Failed to save session: $e');
    }
  }
}
