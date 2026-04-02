import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'model_manager.dart';

class ImageProcessor {
  static const List<double> _mean = [0.7931, 0.7931, 0.7931];
  static const List<double> _std = [0.1738, 0.1738, 0.1738];

  static img.Image pad(img.Image image, {int divable = 32}) {
    final data = img.grayscale(image);

    // Find text bounding box
    int minX = data.width, minY = data.height;
    int maxX = 0, maxY = 0;
    const threshold = 128;

    for (int y = 0; y < data.height; y++) {
      for (int x = 0; x < data.width; x++) {
        final pixel = data.getPixel(x, y);
        final luminance = pixel.r.toInt();
        if (luminance < threshold) {
          if (x < minX) minX = x;
          if (y < minY) minY = y;
          if (x > maxX) maxX = x;
          if (y > maxY) maxY = y;
        }
      }
    }

    if (maxX <= minX || maxY <= minY) {
      return image;
    }

    final w = maxX - minX + 1;
    final h = maxY - minY + 1;
    final cropped = img.copyCrop(image, x: minX, y: minY, width: w, height: h);

    final padW = ((w + divable - 1) ~/ divable) * divable;
    final padH = ((h + divable - 1) ~/ divable) * divable;

    final padded = img.Image(width: padW, height: padH, numChannels: 3);
    img.fill(padded, color: img.ColorRgb8(255, 255, 255));
    img.compositeImage(padded, cropped);

    return padded;
  }

  static img.Image minmaxSize(img.Image image) {
    int w = image.width;
    int h = image.height;

    final maxRatioW = w / ModelConfig.maxWidth;
    final maxRatioH = h / ModelConfig.maxHeight;
    if (maxRatioW > 1 || maxRatioH > 1) {
      final ratio = maxRatioW > maxRatioH ? maxRatioW : maxRatioH;
      w = (w / ratio).floor();
      h = (h / ratio).floor();
      w = w < 1 ? 1 : w;
      h = h < 1 ? 1 : h;
    }

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

  static img.Image ensureRgb(img.Image image) {
    if (image.numChannels >= 3) return image;
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

  static img.Image toGray(img.Image image) {
    final gray = img.grayscale(image);
    return ensureRgb(gray);
  }

  static Float32List normalize(img.Image image) {
    final width = image.width;
    final height = image.height;
    final result = Float32List(width * height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final pixel = image.getPixel(x, y);
        final idx = y * width + x;
        result[idx] = (pixel.r.toInt() / 255.0 - _mean[0]) / _std[0];
      }
    }

    return result;
  }

  static (Float32List, img.Image) preProcess(
    img.Image inputImage,
    double r,
    int w,
    int h,
  ) {
    final resizeFunc = r > 1
        ? img.Interpolation.linear
        : img.Interpolation.cubic;

    final resizeImg = img.copyResize(
      inputImage,
      width: w,
      height: h,
      interpolation: resizeFunc,
    );

    final padImg = pad(minmaxSize(resizeImg));
    final cvtImg = ensureRgb(padImg);
    final grayImg = toGray(cvtImg);
    final normalImg = normalize(grayImg);

    return (normalImg, padImg);
  }

  static img.Image? decodeImage(Uint8List bytes) {
    return img.decodeImage(bytes);
  }

  static (int, int) getProcessedSize(img.Image image) {
    final padded = pad(image);
    final resized = minmaxSize(padded);
    return (resized.width, resized.height);
  }
}
