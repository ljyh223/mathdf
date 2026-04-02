import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:image/image.dart' as img;
import 'model_manager.dart';
import 'image_processor.dart';
import 'tokenizer.dart';

/// LaTeX OCR 服务
class LatexOcrService {
  static final LatexOcrService _instance = LatexOcrService._internal();
  factory LatexOcrService() => _instance;
  LatexOcrService._internal();

  final ModelManager _modelManager = ModelManager();
  final Tokenizer _tokenizer = Tokenizer();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// 初始化服务
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // 加载模型
      await _modelManager.init();

      // 加载tokenizer
      await _tokenizer.loadFromAsset('assets/models/tokenizer.json');

      _isInitialized = true;
      print('LatexOcrService initialized successfully');
    } catch (e) {
      print('Failed to initialize LatexOcrService: $e');
      rethrow;
    }
  }

  /// 识别图片中的LaTeX公式
  /// [imageBytes] 图片字节数组
  /// 返回LaTeX字符串
  Future<String> recognize(Uint8List imageBytes) async {
    if (!_isInitialized) {
      throw StateError('LatexOcrService not initialized. Call init() first.');
    }

    final stopwatch = Stopwatch()..start();

    try {
      // 1. 解码图片
      final image = ImageProcessor.decodeImage(imageBytes);
      if (image == null) {
        throw ArgumentError('Failed to decode image');
      }

      // 2. 预处理图片
      final processed = ImageProcessor.preprocess(image);
      final (width, height) = ImageProcessor.getProcessedSize(image);

      // 3. 运行Image Resizer调整尺寸
      final resized = await _runImageResizer(processed, width, height);

      // 4. 运行Encoder提取特征
      final context = await _runEncoder(resized);

      // 5. 运行Decoder生成token序列
      final tokens = await _runDecoder(context);

      // 6. 解码token为字符串
      final results = _tokenizer.tokensToStrings(tokens);
      final latex = results.isNotEmpty ? results[0] : '';

      // 7. 后处理
      final result = _postProcess(latex);

      // 清理context
      context.dispose();

      stopwatch.stop();
      print('OCR completed in ${stopwatch.elapsedMilliseconds}ms');

      return result;
    } catch (e) {
      print('OCR failed: $e');
      rethrow;
    }
  }

  /// 运行Image Resizer
  Future<Float32List> _runImageResizer(
    Float32List imageData,
    int width,
    int height,
  ) async {
    // Image Resizer循环
    int w = width;
    int h = height;
    double r = 1.0;
    Float32List finalImage = imageData;

    for (int i = 0; i < 10; i++) {
      h = (h * r).toInt();

      // 确保尺寸有效
      if (h < 1 || w < 1) break;

      // 创建ONNX输入
      final inputShape = [1, 1, h, w];
      final input = await OrtValue.fromList(finalImage, inputShape);

      // 运行resizer
      final output = await _modelManager.runImageResizer(input);

      // 清理
      await input.dispose();

      if (output == null) break;

      // 获取输出并计算新宽度
      final outputList = await output.asFlattenedList();
      await output.dispose();

      // 找到最大概率的索引
      int maxIdx = 0;
      double maxVal = outputList[0].toDouble();
      for (int j = 1; j < outputList.length; j++) {
        final val = outputList[j].toDouble();
        if (val > maxVal) {
          maxVal = val;
          maxIdx = j;
        }
      }

      final newW = (maxIdx + 1) * 32;
      if (newW == w) break;

      r = newW / w;
      w = newW;
    }

    return finalImage;
  }

  /// 运行Encoder
  Future<OrtValue> _runEncoder(Float32List imageData) async {
    // 获取图片尺寸
    final length = imageData.length;
    final h = (length / 672).ceil();

    // 创建ONNX输入
    final inputShape = [1, 1, h, 672];
    final input = await OrtValue.fromList(imageData, inputShape);

    // 运行encoder
    final output = await _modelManager.runEncoder(input);

    // 清理输入
    await input.dispose();

    if (output == null) {
      throw StateError('Encoder returned null');
    }

    return output;
  }

  /// 运行Decoder
  Future<List<int>> _runDecoder(OrtValue context) async {
    final tokens = <int>[ModelConfig.bosToken];
    final mask = <bool>[true];

    for (int step = 0; step < ModelConfig.maxSeqLen; step++) {
      // 取最近512个token
      final startIdx = tokens.length > 512 ? tokens.length - 512 : 0;
      final currentTokens = tokens.sublist(startIdx);
      final currentMask = mask.sublist(startIdx);

      // 创建ONNX输入
      final tokensInput = await OrtValue.fromList(
        Int64List.fromList(currentTokens),
        [1, currentTokens.length],
      );
      final maskInput = await OrtValue.fromList(
        Uint8List.fromList(currentMask.map((e) => e ? 1 : 0).toList()),
        [1, currentMask.length],
      );

      // 运行decoder
      final output = await _modelManager.runDecoder(
        tokens: tokensInput,
        mask: maskInput,
        context: context,
      );

      // 清理输入
      await tokensInput.dispose();
      await maskInput.dispose();

      if (output == null) break;

      // 获取logits
      final logitsList = await output.asFlattenedList();
      await output.dispose();

      final logits = logitsList
          .map<double>((e) => (e as num).toDouble())
          .toList();

      // 获取最后一个位置的logits
      final vocabSize = logits.length ~/ currentTokens.length;
      final lastLogits = logits.sublist(
        (currentTokens.length - 1) * vocabSize,
        currentTokens.length * vocabSize,
      );

      // Top-k filtering
      final filtered = _topK(lastLogits, threshold: 0.9);

      // Softmax with temperature
      final probs = _softmax(filtered, ModelConfig.temperature);

      // 采样
      final sample = _multinomial(probs);

      // 追加
      tokens.add(sample);
      mask.add(true);

      // 检查EOS
      if (sample == ModelConfig.eosToken) {
        break;
      }
    }

    // 移除BOS token
    return tokens.sublist(1);
  }

  /// Top-k filtering
  List<double> _topK(List<double> logits, {double threshold = 0.9}) {
    final k = ((1 - threshold) * logits.length).toInt();

    // 创建副本
    final result = List<double>.from(logits);

    // 找到第k大的值
    final sorted = List<double>.from(logits)..sort((a, b) => b.compareTo(a));
    final cutoff = sorted[k.clamp(0, sorted.length - 1)];

    // 将小于cutoff的值设为负无穷
    for (int i = 0; i < result.length; i++) {
      if (result[i] < cutoff) {
        result[i] = double.negativeInfinity;
      }
    }

    return result;
  }

  /// Softmax with temperature
  List<double> _softmax(List<double> logits, double temperature) {
    // 除以temperature
    final scaled = logits.map((x) => x / temperature).toList();

    // 找最大值（数值稳定性）
    double maxVal = scaled[0];
    for (final val in scaled) {
      if (val > maxVal) maxVal = val;
    }

    // 计算exp
    double sum = 0;
    final exp = List<double>.filled(scaled.length, 0);
    for (int i = 0; i < scaled.length; i++) {
      if (scaled[i] != double.negativeInfinity) {
        exp[i] = scaled[i] - maxVal;
        exp[i] = exp[i] > -700 ? math.exp(exp[i]) : 0; // 防止下溢
      }
      sum += exp[i];
    }

    // 归一化
    if (sum > 0) {
      for (int i = 0; i < exp.length; i++) {
        exp[i] /= sum;
      }
    }

    return exp;
  }

  /// Multinomial sampling
  int _multinomial(List<double> probs) {
    final random = math.Random();
    final r = random.nextDouble();

    double cumSum = 0;
    for (int i = 0; i < probs.length; i++) {
      cumSum += probs[i];
      if (r <= cumSum) {
        return i;
      }
    }

    return probs.length - 1;
  }

  /// 后处理：移除多余空格
  String _postProcess(String latex) {
    // 参考Python实现的后处理
    final textReg = RegExp(
      r'(\\(operatorname|mathrm|text|mathbf)\s?\*? {.*?})',
    );

    var result = latex;

    // 移除多余空格
    result = result.replaceAll(RegExp(r'\s+'), ' ').trim();

    return result;
  }

  /// 释放资源
  Future<void> dispose() async {
    await _modelManager.dispose();
    _isInitialized = false;
  }
}
