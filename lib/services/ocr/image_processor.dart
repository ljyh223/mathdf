import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'model_manager.dart';

/// 图片预处理
class ImageProcessor {
  // 标准化参数
  static const List<double> _mean = [0.7931, 0.7931, 0.7931];
  static const List<double> _std = [0.1738, 0.1738, 0.1738];

  /// 完整的图片预处理流程
  /// 返回 (1, 1, H, W) 格式的 Float32List
  static Float32List preprocess(img.Image image) {
    // 1. Padding - 裁剪空白区域并padding到32的倍数
    final padded = _pad(image);

    // 2. 限制尺寸
    final resized = _minmaxSize(padded);

    // 3. 转换为RGB
    final rgb = _ensureRgb(resized);

    // 4. 转为灰度再转回RGB (与Python实现一致)
    final gray = _toGray(rgb);

    // 5. 标准化
    final normalized = _normalize(gray);

    // 6. 转置为 (1, 1, H, W)
    final transposed = _transpose(normalized);

    return transposed;
  }

  /// Padding - 裁剪文字区域并padding到32的倍数
  static img.Image _pad(img.Image image, {int divable = 32}) {
    // 转换为灰度
    final gray = img.grayscale(image);

    // 找到文字区域的边界框
    int minX = gray.width, minY = gray.height;
    int maxX = 0, maxY = 0;
    const threshold = 128;

    for (int y = 0; y < gray.height; y++) {
      for (int x = 0; x < gray.width; x++) {
        final pixel = gray.getPixel(x, y);
        final luminance = pixel.r.toInt();
        if (luminance < threshold) {
          minX = minX < x ? minX : x;
          minY = minY < y ? minY : y;
          maxX = maxX > x ? maxX : x;
          maxY = maxY > y ? maxY : y;
        }
      }
    }

    // 如果没有找到文字，返回原图
    if (maxX <= minX || maxY <= minY) {
      return image;
    }

    // 裁剪
    final w = maxX - minX + 1;
    final h = maxY - minY + 1;
    final cropped = img.copyCrop(image, x: minX, y: minY, width: w, height: h);

    // 计算padding后的尺寸 (32的倍数)
    final padW = ((w + divable - 1) ~/ divable) * divable;
    final padH = ((h + divable - 1) ~/ divable) * divable;

    // 创建白色背景的padding图像
    final padded = img.Image(width: padW, height: padH);
    img.fill(padded, color: img.ColorRgb8(255, 255, 255));
    img.compositeImage(padded, cropped);

    return padded;
  }

  /// 限制尺寸在min和max之间
  static img.Image _minmaxSize(img.Image image) {
    int w = image.width;
    int h = image.height;

    // 检查最大尺寸
    final maxRatioW = w / ModelConfig.maxWidth;
    final maxRatioH = h / ModelConfig.maxHeight;
    if (maxRatioW > 1 || maxRatioH > 1) {
      final ratio = maxRatioW > maxRatioH ? maxRatioW : maxRatioH;
      w = (w / ratio).floor();
      h = (h / ratio).floor();
    }

    // 检查最小尺寸
    w = w < ModelConfig.minWidth ? ModelConfig.minWidth : w;
    h = h < ModelConfig.minHeight ? ModelConfig.minHeight : h;

    if (w != image.width || h != image.height) {
      return img.copyResize(
        image,
        width: w,
        height: h,
        interpolation: img.Interpolation.linear,
      );
    }

    return image;
  }

  /// 确保图片是RGB格式
  static img.Image _ensureRgb(img.Image image) {
    if (image.numChannels == 1) {
      // 灰度转RGB
      final rgb = img.Image(
        width: image.width,
        height: image.height,
        numChannels: 3,
      );
      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);
          final gray = pixel.r.toInt();
          rgb.setPixelRgba(x, y, gray, gray, gray, 255);
        }
      }
      return rgb;
    }
    return image;
  }

  /// 转为灰度再转回RGB
  static img.Image _toGray(img.Image image) {
    final gray = img.grayscale(image);
    return _ensureRgb(gray);
  }

  /// 标准化
  static Float32List _normalize(img.Image image) {
    final width = image.width;
    final height = image.height;
    final result = Float32List(width * height * 3);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final pixel = image.getPixel(x, y);
        final idx = (y * width + x) * 3;

        // 标准化: (pixel - mean * 255) / (std * 255)
        result[idx] = (pixel.r.toInt() - _mean[0] * 255) / (_std[0] * 255);
        result[idx + 1] = (pixel.g.toInt() - _mean[1] * 255) / (_std[1] * 255);
        result[idx + 2] = (pixel.b.toInt() - _mean[2] * 255) / (_std[2] * 255);
      }
    }

    return result;
  }

  /// 转置为 (1, 1, H, W) 格式
  /// 实际上只需要第一个通道，然后变成 (1, 1, H, W)
  static Float32List _transpose(Float32List normalized) {
    // normalized 是 (H, W, 3) 格式
    // 需要转为 (1, 1, H, W) 格式，只取第一个通道
    final length = normalized.length ~/ 3;
    final result = Float32List(length);

    for (int i = 0; i < length; i++) {
      result[i] = normalized[i * 3]; // 取第一个通道
    }

    return result;
  }

  /// 从字节数组解码图片
  static img.Image? decodeImage(Uint8List bytes) {
    return img.decodeImage(bytes);
  }

  /// 获取预处理后的图片尺寸
  static (int, int) getProcessedSize(img.Image image) {
    final padded = _pad(image);
    final resized = _minmaxSize(padded);
    return (resized.width, resized.height);
  }
}
