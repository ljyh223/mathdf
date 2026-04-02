import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:mathdf/constants/api_constants.dart';
import 'package:mathdf/models/calculation_request.dart';
import 'package:mathdf/models/calculation_result.dart';
import 'package:mathdf/models/calculation_type.dart';
import 'package:mathdf/services/encryption_service.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(
          milliseconds: ApiConstants.connectTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: ApiConstants.receiveTimeout,
        ),
        headers: ApiConstants.headers,
      ),
    );

    // 添加拦截器
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print(obj),
      ),
    );
  }

  /// 发送计算请求
  Future<CalculationResult> calculate({
    required CalculationType type,
    required String expression,
    String variable = 'x',
    String? lowerLimit,
    String? upperLimit,
    String? additionalParam,
  }) async {
    try {
      // 创建请求对象
      final request = CalculationRequest(
        expr: expression,
        arg: variable,
        def: additionalParam ?? '0',
        bottom: lowerLimit ?? '',
        top: upperLimit ?? '',
      );

      // 加密请求数据
      final requestData = request.toJson();
      final encrypted = EncryptionService.encryptAndEncode(
        requestData,
        '${ApiConstants.token}a',
      );

      // 创建表单数据
      final formData = FormData.fromMap({'p': encrypted, 'f': 'false'});

      // 发送请求
      final response = await _dio.post(type.endpoint, data: formData);

      // 解析响应
      if (response.statusCode == 200) {
        final responseData = response.data;

        // 如果响应是字符串，需要解析为JSON
        if (responseData is String) {
          // 检查是否是错误响应
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

  /// 计算积分
  Future<CalculationResult> calculateIntegral({
    required String expression,
    String variable = 'x',
    String? lowerLimit,
    String? upperLimit,
  }) async {
    return calculate(
      type: CalculationType.integral,
      expression: expression,
      variable: variable,
      lowerLimit: lowerLimit,
      upperLimit: upperLimit,
    );
  }

  /// 计算方程
  Future<CalculationResult> calculateEquation({
    required String expression,
    String variable = 'x',
  }) async {
    return calculate(
      type: CalculationType.equation,
      expression: expression,
      variable: variable,
    );
  }

  /// 计算极限
  Future<CalculationResult> calculateLimit({
    required String expression,
    String variable = 'x',
    String? limitPoint,
  }) async {
    return calculate(
      type: CalculationType.limit,
      expression: expression,
      variable: variable,
      additionalParam: limitPoint,
    );
  }

  /// 计算导数
  Future<CalculationResult> calculateDerivative({
    required String expression,
    String variable = 'x',
  }) async {
    return calculate(
      type: CalculationType.derivative,
      expression: expression,
      variable: variable,
    );
  }

  /// 计算微分方程
  Future<CalculationResult> calculateODE({
    required String expression,
    String variable = 'x',
  }) async {
    return calculate(
      type: CalculationType.ode,
      expression: expression,
      variable: variable,
    );
  }

  /// 计算复数
  Future<CalculationResult> calculateComplex({
    required String expression,
    String variable = 'z',
  }) async {
    return calculate(
      type: CalculationType.complex,
      expression: expression,
      variable: variable,
    );
  }

  /// 基础计算
  Future<CalculationResult> calculateBasic({required String expression}) async {
    return calculate(
      type: CalculationType.calculator,
      expression: expression,
      variable: '',
    );
  }

  /// 矩阵计算
  Future<CalculationResult> calculateMatrix({
    required String expression,
    String variable = 'A',
  }) async {
    return calculate(
      type: CalculationType.matrix,
      expression: expression,
      variable: variable,
    );
  }
}
