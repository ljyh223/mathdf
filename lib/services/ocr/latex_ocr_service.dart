import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:image/image.dart' as img;
import 'model_manager.dart';
import 'image_processor.dart';
import 'tokenizer.dart';

class LatexOcrService {
  static final LatexOcrService _instance = LatexOcrService._internal();
  factory LatexOcrService() => _instance;
  LatexOcrService._internal();

  final ModelManager _modelManager = ModelManager();
  final Tokenizer _tokenizer = Tokenizer();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      await _modelManager.init();
      await _tokenizer.loadFromAsset('assets/models/tokenizer.json');
      _isInitialized = true;
      print('LatexOcrService initialized successfully');
    } catch (e) {
      print('Failed to initialize LatexOcrService: $e');
      rethrow;
    }
  }

  Future<String> recognize(Uint8List imageBytes) async {
    if (!_isInitialized) {
      throw StateError('LatexOcrService not initialized. Call init() first.');
    }

    final stopwatch = Stopwatch()..start();

    try {
      final image = ImageProcessor.decodeImage(imageBytes);
      if (image == null) {
        throw ArgumentError('Failed to decode image');
      }

      final padded = ImageProcessor.pad(image);
      final inputImage = ImageProcessor.minmaxSize(padded);
      print(
        '[OCR] Original: ${image.width}x${image.height}, Padded: ${padded.width}x${padded.height}, InputImage: ${inputImage.width}x${inputImage.height}',
      );

      double r = 1.0;
      int w = inputImage.width;
      int h = inputImage.height;
      Float32List? finalImg;
      img.Image? finalPadded;

      for (int i = 0; i < 10; i++) {
        h = (h * r).round();
        if (h < 1) h = 1;

        print('[OCR] Iteration $i: r=$r, w=$w, h=$h');

        final (processed, paddedImg) = ImageProcessor.preProcess(
          inputImage,
          r,
          w,
          h,
        );

        print(
          '[OCR] Iteration $i: r=$r, w=$w, h=$h, processed.length=${processed.length}, paddedImg=${paddedImg.width}x${paddedImg.height}',
        );

        final inputShape = [1, 1, h, w];
        final input = await OrtValue.fromList(processed, inputShape);
        final output = await _modelManager.runImageResizer(input);
        await input.dispose();

        if (output == null) {
          finalImg = processed;
          finalPadded = paddedImg;
          break;
        }

        final outputList = await output.asFlattenedList();
        await output.dispose();

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
        finalImg = processed;
        finalPadded = paddedImg;

        print(
          '[OCR] maxIdx=$maxIdx, newW=$newW, paddedImg.width=${paddedImg.width}',
        );

        if (newW == paddedImg.width) break;

        r = newW / paddedImg.width;
        w = newW;
      }

      if (finalImg == null || finalPadded == null) {
        final (processed, paddedImg) = ImageProcessor.preProcess(
          inputImage,
          1.0,
          inputImage.width,
          inputImage.height,
        );
        finalImg = processed;
        finalPadded = paddedImg;
        w = finalPadded.width;
        h = finalPadded.height;
      }

      final context = await _runEncoder(finalImg!, w, h);
      final tokens = await _runDecoder(context);
      final results = _tokenizer.tokensToStrings(tokens);
      final latex = results.isNotEmpty ? results[0] : '';
      final result = _postProcess(latex);

      context.dispose();

      stopwatch.stop();
      print('OCR completed in ${stopwatch.elapsedMilliseconds}ms');

      return result;
    } catch (e) {
      print('OCR failed: $e');
      rethrow;
    }
  }

  Future<OrtValue> _runEncoder(Float32List imageData, int w, int h) async {
    final inputShape = [1, 1, h, w];
    final input = await OrtValue.fromList(imageData, inputShape);

    final output = await _modelManager.runEncoder(input);
    await input.dispose();

    if (output == null) {
      throw StateError('Encoder returned null');
    }

    return output;
  }

  Future<List<int>> _runDecoder(OrtValue context) async {
    final tokens = <int>[ModelConfig.bosToken];
    final mask = <bool>[true];

    for (int step = 0; step < ModelConfig.maxSeqLen; step++) {
      final startIdx = tokens.length > 512 ? tokens.length - 512 : 0;
      final currentTokens = tokens.sublist(startIdx);
      final currentMask = mask.sublist(startIdx);

      final tokensInput = await OrtValue.fromList(
        Int64List.fromList(currentTokens),
        [1, currentTokens.length],
      );
      final maskInput = await OrtValue.fromList(List<bool>.from(currentMask), [
        1,
        currentMask.length,
      ]);

      final output = await _modelManager.runDecoder(
        tokens: tokensInput,
        mask: maskInput,
        context: context,
      );

      await tokensInput.dispose();
      await maskInput.dispose();

      if (output == null) break;

      final logitsList = await output.asFlattenedList();
      await output.dispose();

      final logits = logitsList
          .map<double>((e) => (e as num).toDouble())
          .toList();

      final vocabSize = logits.length ~/ currentTokens.length;
      final lastLogits = logits.sublist(
        (currentTokens.length - 1) * vocabSize,
        currentTokens.length * vocabSize,
      );

      final filtered = _topK(lastLogits, threshold: 0.9);
      final probs = _softmax(filtered, ModelConfig.temperature);
      final sample = _multinomial(probs);

      tokens.add(sample);
      mask.add(true);

      if (sample == ModelConfig.eosToken) {
        break;
      }
    }

    return tokens.sublist(1);
  }

  List<double> _topK(List<double> logits, {double threshold = 0.9}) {
    final k = ((1 - threshold) * logits.length).toInt().clamp(1, logits.length);
    final result = List<double>.from(logits);
    final sorted = List<double>.from(logits)..sort((a, b) => b.compareTo(a));
    final cutoff = sorted[k - 1];

    for (int i = 0; i < result.length; i++) {
      if (result[i] < cutoff) {
        result[i] = double.negativeInfinity;
      }
    }

    return result;
  }

  List<double> _softmax(List<double> logits, double temperature) {
    final scaled = logits.map((x) => x / temperature).toList();

    double maxVal = scaled[0];
    for (final val in scaled) {
      if (val > maxVal) maxVal = val;
    }

    double sum = 0;
    final exp = List<double>.filled(scaled.length, 0);
    for (int i = 0; i < scaled.length; i++) {
      if (scaled[i] != double.negativeInfinity) {
        exp[i] = scaled[i] - maxVal;
        exp[i] = exp[i] > -700 ? math.exp(exp[i]) : 0;
      }
      sum += exp[i];
    }

    if (sum > 0) {
      for (int i = 0; i < exp.length; i++) {
        exp[i] /= sum;
      }
    }

    return exp;
  }

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

  String _postProcess(String latex) {
    var result = latex.replaceAll(RegExp(r'\s+'), ' ').trim();
    return result;
  }

  Future<void> dispose() async {
    await _modelManager.dispose();
    _isInitialized = false;
  }
}
