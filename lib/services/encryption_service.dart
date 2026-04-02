import 'dart:convert';
import 'dart:typed_data';

class EncryptionService {
  /// XOR加密函数
  /// [data] 要加密的数据
  /// [key] 加密密钥
  /// 返回加密后的字节数组
  static Uint8List encrypt(String data, String key) {
    if (key.isEmpty) {
      return Uint8List.fromList(utf8.encode(data));
    }

    final dataBytes = utf8.encode(data);
    final keyBytes = utf8.encode(key);
    final result = Uint8List(dataBytes.length);

    for (int i = 0; i < dataBytes.length; i++) {
      result[i] = dataBytes[i] ^ keyBytes[i % keyBytes.length];
    }

    return result;
  }

  /// 加密并编码为Base64
  /// [data] 要加密的数据
  /// [key] 加密密钥
  /// 返回Base64编码的加密字符串
  static String encryptAndEncode(String data, String key) {
    final encrypted = encrypt(data, key);
    return base64.encode(encrypted);
  }

  /// 解密Base64编码的数据
  /// [encodedData] Base64编码的加密数据
  /// [key] 解密密钥
  /// 返回解密后的字符串
  static String decryptFromBase64(String encodedData, String key) {
    final encrypted = base64.decode(encodedData);
    final keyBytes = utf8.encode(key);
    final result = Uint8List(encrypted.length);

    for (int i = 0; i < encrypted.length; i++) {
      result[i] = encrypted[i] ^ keyBytes[i % keyBytes.length];
    }

    return utf8.decode(result);
  }
}
