import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';

/// BPE Tokenizer
class Tokenizer {
  late Map<int, String> _vocab;
  late List<String> _merges;
  bool _isLoaded = false;

  /// 从assets加载tokenizer
  Future<void> loadFromAsset(String assetPath) async {
    if (_isLoaded) return;

    final jsonString = await rootBundle.loadString(assetPath);
    final json = jsonDecode(jsonString);

    // 解析vocab (token -> id)
    final vocabMap = json['model']['vocab'] as Map<String, dynamic>;

    // 反转为 id -> token
    _vocab = {};
    vocabMap.forEach((token, id) {
      _vocab[id as int] = token;
    });

    // 解析merges
    final mergesList = json['model']['merges'] as List<dynamic>;
    _merges = mergesList.cast<String>();

    _isLoaded = true;
  }

  /// 将token ids转换为字符串
  List<String> tokensToStrings(List<int> tokens) {
    if (!_isLoaded) {
      throw StateError('Tokenizer not loaded');
    }

    // 将token ids转换为token strings
    final tokenStrings = <String>[];
    for (final id in tokens) {
      final token = _vocab[id];
      if (token != null) {
        tokenStrings.add(token);
      }
    }

    // 合并BPE tokens
    String result = _mergeBpe(tokenStrings);

    // 后处理
    result = _postProcess(result);

    return [result];
  }

  /// 合并BPE tokens
  String _mergeBpe(List<String> tokens) {
    // 简单的BPE合并：直接连接
    // 对于ByteLevel BPE，需要处理Ġ前缀
    final buffer = StringBuffer();

    for (final token in tokens) {
      if (token.startsWith('Ġ')) {
        // Ġ表示新词开始，需要加空格
        buffer.write(' ');
        buffer.write(token.substring(1));
      } else if (token == 'Ċ') {
        // 换行
        buffer.write('\n');
      } else {
        buffer.write(token);
      }
    }

    return buffer.toString();
  }

  /// 后处理：移除特殊tokens和多余空格
  String _postProcess(String text) {
    return text
        .replaceAll('[EOS]', '')
        .replaceAll('[BOS]', '')
        .replaceAll('[PAD]', '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// 解码单个token id
  String? decodeToken(int id) {
    return _vocab[id];
  }

  /// 检查是否是特殊token
  bool isSpecialToken(int id) {
    final token = _vocab[id];
    if (token == null) return false;
    return token == '[PAD]' || token == '[BOS]' || token == '[EOS]';
  }

  /// 获取BOS token id
  int get bosToken => 1;

  /// 获取EOS token id
  int get eosToken => 2;

  /// 获取PAD token id
  int get padToken => 0;

  /// 获取词汇表大小
  int get vocabSize => _vocab.length;
}
