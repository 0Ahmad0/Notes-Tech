import 'dart:convert';

import 'package:cryptography/cryptography.dart';

final class PasswordHash {
  const PasswordHash({
    required this.hash,
    required this.salt,
    required this.params,
  });

  final String hash;
  final String salt;
  final String params;
}

final class PasswordHasher {
  static const int _iterations = 120000;
  static const int _bits = 256;
  static const String _algorithmName = 'pbkdf2-sha256';

  final Pbkdf2 _defaultAlgorithm = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: _iterations,
    bits: _bits,
  );

  Future<PasswordHash> hash(String password) async {
    final SecretKeyData salt = SecretKeyData.random(length: 16);
    final SecretKey key = await _defaultAlgorithm.deriveKeyFromPassword(
      password: password,
      nonce: salt.bytes,
    );
    final List<int> bytes = await key.extractBytes();
    return PasswordHash(
      hash: base64Encode(bytes),
      salt: base64Encode(salt.bytes),
      params: '$_algorithmName:$_iterations:$_bits',
    );
  }

  Future<bool> verify({
    required String password,
    required String hash,
    required String salt,
    required String params,
  }) async {
    final List<String> parts = params.split(':');
    final int iterations = parts.length > 1
        ? int.tryParse(parts[1]) ?? _iterations
        : _iterations;
    final int bits = parts.length > 2 ? int.tryParse(parts[2]) ?? _bits : _bits;
    final Pbkdf2 algorithm = iterations == _iterations && bits == _bits
        ? _defaultAlgorithm
        : Pbkdf2(
            macAlgorithm: Hmac.sha256(),
            iterations: iterations,
            bits: bits,
          );
    final SecretKey key = await algorithm.deriveKeyFromPassword(
      password: password,
      nonce: base64Decode(salt),
    );
    final List<int> bytes = await key.extractBytes();
    return _constantTimeEquals(bytes, base64Decode(hash));
  }

  bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) {
      return false;
    }
    int difference = 0;
    for (int i = 0; i < a.length; i++) {
      difference |= a[i] ^ b[i];
    }
    return difference == 0;
  }
}
