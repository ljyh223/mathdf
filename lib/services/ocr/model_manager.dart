import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';

/// 模型配置参数
class ModelConfig {
  static const int bosToken = 1;
  static const int eosToken = 2;
  static const int maxSeqLen = 512;
  static const double temperature = 0.00001;
  static const int maxWidth = 672;
  static const int maxHeight = 192;
  static const int minWidth = 32;
  static const int minHeight = 32;
}

/// 模型加载和管理
class ModelManager {
  static final ModelManager _instance = ModelManager._internal();
  factory ModelManager() => _instance;
  ModelManager._internal();

  final OnnxRuntime _ort = OnnxRuntime();

  OrtSession? _encoderSession;
  OrtSession? _decoderSession;
  OrtSession? _imageResizerSession;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// 初始化加载所有模型
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // 加载Encoder模型
      _encoderSession = await _ort.createSessionFromAsset(
        'assets/models/encoder.onnx',
      );

      // 加载Decoder模型
      _decoderSession = await _ort.createSessionFromAsset(
        'assets/models/decoder.onnx',
      );

      // 加载Image Resizer模型
      _imageResizerSession = await _ort.createSessionFromAsset(
        'assets/models/image_resizer.onnx',
      );

      _isInitialized = true;
      print('Models loaded successfully');

      // 打印模型信息
      _printModelInfo();
    } catch (e) {
      print('Failed to load models: $e');
      rethrow;
    }
  }

  /// 打印模型输入输出信息
  void _printModelInfo() {
    if (_encoderSession != null) {
      print('Encoder inputs: ${_encoderSession!.inputNames}');
      print('Encoder outputs: ${_encoderSession!.outputNames}');
    }
    if (_decoderSession != null) {
      print('Decoder inputs: ${_decoderSession!.inputNames}');
      print('Decoder outputs: ${_decoderSession!.outputNames}');
    }
    if (_imageResizerSession != null) {
      print('Image Resizer inputs: ${_imageResizerSession!.inputNames}');
      print('Image Resizer outputs: ${_imageResizerSession!.outputNames}');
    }
  }

  /// 运行Image Resizer
  Future<OrtValue?> runImageResizer(OrtValue input) async {
    if (_imageResizerSession == null) {
      throw StateError('Image Resizer not initialized');
    }

    final inputs = {_imageResizerSession!.inputNames[0]: input};
    final outputs = await _imageResizerSession!.run(inputs);
    return outputs.values.first;
  }

  /// 运行Encoder
  Future<OrtValue?> runEncoder(OrtValue input) async {
    if (_encoderSession == null) {
      throw StateError('Encoder not initialized');
    }

    final inputs = {_encoderSession!.inputNames[0]: input};
    final outputs = await _encoderSession!.run(inputs);
    return outputs.values.first;
  }

  /// 运行Decoder
  Future<OrtValue?> runDecoder({
    required OrtValue tokens,
    required OrtValue mask,
    required OrtValue context,
  }) async {
    if (_decoderSession == null) {
      throw StateError('Decoder not initialized');
    }

    final inputNames = _decoderSession!.inputNames;
    final inputs = {
      inputNames[0]: tokens,
      inputNames[1]: mask,
      inputNames[2]: context,
    };

    final outputs = await _decoderSession!.run(inputs);
    return outputs.values.first;
  }

  /// 释放资源
  Future<void> dispose() async {
    await _encoderSession?.close();
    await _decoderSession?.close();
    await _imageResizerSession?.close();
    _isInitialized = false;
  }
}
