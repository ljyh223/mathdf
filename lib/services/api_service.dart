import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:mathdf/models/calculation_requests.dart';
import 'package:mathdf/models/calculation_result.dart';
import 'package:mathdf/models/calculation_type.dart';
import 'package:mathdf/services/encryption_service.dart';
import 'package:mathdf/services/dynamic_auth_service.dart';

class ApiService {
  final DynamicAuthService _authService;

  ApiService(this._authService);

  Dio get _dio => _authService.dio;

  Future<CalculationResult> _sendRequest({
    required String jsonData,
    required String endpoint,
  }) async {
    try {
      await _authService.ensureAuthReady();

      final token = _authService.token;
      final jsonDataWithToken = _injectToken(jsonData, token);

      final encrypted = EncryptionService.encryptAndEncode(
        jsonDataWithToken,
        '${token}a',
      );
      print("encrypted: $encrypted");
      print("jsonDataWithToken: $jsonDataWithToken");

      final response = await _dio.post(
        endpoint,
        data: {'p': encrypted, 'f': 'false'},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is String) {
          if (responseData == 'ERROR' || responseData.isEmpty) {
            return CalculationResult.error('API返回错误: $responseData');
          }

          try {
            final jsonData = jsonDecode(responseData);
            if (jsonData is List) {
              return CalculationResult.fromApiResponse(jsonData);
            }
          } catch (e) {
            return CalculationResult.error('解析响应失败: $e');
          }
        } else if (responseData is List) {
          return CalculationResult.fromApiResponse(responseData);
        }

        return CalculationResult.error('响应格式不正确');
      } else {
        return CalculationResult.error('请求失败: ${response.statusCode}');
      }
    } on DioException catch (e) {
      String errorMessage;

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          errorMessage = '连接超时';
          break;
        case DioExceptionType.sendTimeout:
          errorMessage = '发送超时';
          break;
        case DioExceptionType.receiveTimeout:
          errorMessage = '接收超时';
          break;
        case DioExceptionType.badResponse:
          errorMessage = '服务器错误: ${e.response?.statusCode}';
          break;
        case DioExceptionType.cancel:
          errorMessage = '请求已取消';
          break;
        default:
          errorMessage = '网络错误: ${e.message}';
      }

      return CalculationResult.error(errorMessage);
    } catch (e) {
      return CalculationResult.error('未知错误: $e');
    }
  }

  String _injectToken(String jsonData, String token) {
    final map = jsonDecode(jsonData) as Map<String, dynamic>;
    map['token'] = token;
    return jsonEncode(map).replaceAll(' ', '');
  }

  Future<CalculationResult> calculateIntegral({
    required String expression,
    String variable = 'x',
    String? lowerLimit,
    String? upperLimit,
  }) async {
    final request = IntegralRequest(
      expr: expression,
      arg: variable,
      bottom: lowerLimit ?? '',
      top: upperLimit ?? '',
    );
    return _sendRequest(
      jsonData: request.toJson(),
      endpoint: CalculationType.integral.endpoint,
    );
  }

  Future<CalculationResult> calculateDerivative({
    required String expression,
    String variable = 'x',
  }) async {
    final request = DerivativeRequest(expr: expression, arg: variable);
    return _sendRequest(
      jsonData: request.toJson(),
      endpoint: CalculationType.derivative.endpoint,
    );
  }

  Future<CalculationResult> calculateLimit({
    required String expression,
    String variable = 'x',
    required String to,
    bool useHospital = false,
  }) async {
    final request = LimitRequest(
      expr: expression,
      arg: variable,
      to: to,
      params: 'usehopital=$useHospital',
    );
    return _sendRequest(
      jsonData: request.toJson(),
      endpoint: CalculationType.limit.endpoint,
    );
  }

  Future<CalculationResult> calculateEquation({
    required String expression,
    String variable = 'x',
  }) async {
    final request = EquationRequest(expr: expression, arg: variable);
    return _sendRequest(
      jsonData: request.toJson(),
      endpoint: CalculationType.equation.endpoint,
    );
  }

  Future<CalculationResult> calculateODE({
    required String expression,
    String func = 'y',
    String variable = 'x',
  }) async {
    final request = OdeRequest(expr: expression, arg: variable, func: func);
    return _sendRequest(
      jsonData: request.toJson(),
      endpoint: CalculationType.ode.endpoint,
    );
  }

  Future<CalculationResult> calculateComplex({
    required String expression,
  }) async {
    final request = ComplexRequest(expr: expression);
    return _sendRequest(
      jsonData: request.toJson(),
      endpoint: CalculationType.complex.endpoint,
    );
  }

  Future<CalculationResult> calculate({
    required CalculationType type,
    required String expression,
    String variable = 'x',
    String? lowerLimit,
    String? upperLimit,
    String? additionalParam,
    String? to,
  }) async {
    switch (type) {
      case CalculationType.integral:
        return calculateIntegral(
          expression: expression,
          variable: variable,
          lowerLimit: lowerLimit,
          upperLimit: upperLimit,
        );
      case CalculationType.derivative:
        return calculateDerivative(expression: expression, variable: variable);
      case CalculationType.limit:
        return calculateLimit(
          expression: expression,
          variable: variable,
          to: to ?? additionalParam ?? 'inf',
        );
      case CalculationType.equation:
        return calculateEquation(expression: expression, variable: variable);
      case CalculationType.ode:
        return calculateODE(expression: expression, variable: variable);
      case CalculationType.complex:
        return calculateComplex(expression: expression);
      default:
        return calculateIntegral(expression: expression, variable: variable);
    }
  }
}
