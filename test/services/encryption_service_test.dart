import 'package:flutter_test/flutter_test.dart';
import 'package:mathdf/services/encryption_service.dart';

void main() {
  group('EncryptionService', () {
    test('encrypt should return bytes of same length as input', () {
      const data = 'test data';
      const key = 'key';

      final result = EncryptionService.encrypt(data, key);

      expect(result.length, equals(data.length));
    });

    test('encrypt should handle empty string', () {
      const data = '';
      const key = 'key';

      final result = EncryptionService.encrypt(data, key);

      expect(result.length, equals(0));
    });

    test('encrypt should handle empty key by returning original data', () {
      const data = 'test';
      const key = '';

      final result = EncryptionService.encrypt(data, key);

      expect(result.length, equals(data.length));
    });

    test('encryptAndEncode should return non-empty base64 string', () {
      const data = '{"expr":"sin(x)"}';
      const key = 'token123';

      final result = EncryptionService.encryptAndEncode(data, key);

      expect(result, isNotEmpty);
    });

    test('encrypt and decrypt should be reversible', () {
      const data = '{"expr":"sin(x)","arg":"x","token":"abc123"}';
      const key = '98ae9979efca566da';

      final encrypted = EncryptionService.encryptAndEncode(data, key);
      final decrypted = EncryptionService.decryptFromBase64(encrypted, key);

      expect(decrypted, equals(data));
    });

    test('same input should produce same output', () {
      const data = 'test data';
      const key = 'key123';

      final result1 = EncryptionService.encryptAndEncode(data, key);
      final result2 = EncryptionService.encryptAndEncode(data, key);

      expect(result1, equals(result2));
    });

    test('different keys should produce different outputs', () {
      const data = 'test data';

      final result1 = EncryptionService.encryptAndEncode(data, 'key1');
      final result2 = EncryptionService.encryptAndEncode(data, 'key2');

      expect(result1, isNot(equals(result2)));
    });
  });
}
