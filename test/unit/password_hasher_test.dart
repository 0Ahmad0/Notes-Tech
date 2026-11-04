import 'package:flutter_test/flutter_test.dart';

import 'package:task_ai1/features/auth/data/password_hasher.dart';

void main() {
  final PasswordHasher hasher = PasswordHasher();

  test('hashes and verifies the correct password', () async {
    final PasswordHash result = await hasher.hash('correct horse battery');

    expect(result.hash, isNotEmpty);
    expect(result.salt, isNotEmpty);
    expect(result.params, startsWith('pbkdf2-sha256:'));

    final bool valid = await hasher.verify(
      password: 'correct horse battery',
      hash: result.hash,
      salt: result.salt,
      params: result.params,
    );
    expect(valid, isTrue);
  });

  test('rejects a wrong password', () async {
    final PasswordHash result = await hasher.hash('correct horse battery');

    final bool valid = await hasher.verify(
      password: 'wrong password',
      hash: result.hash,
      salt: result.salt,
      params: result.params,
    );
    expect(valid, isFalse);
  });

  test('uses a unique salt for every hash', () async {
    final PasswordHash first = await hasher.hash('same password');
    final PasswordHash second = await hasher.hash('same password');

    expect(first.salt, isNot(second.salt));
    expect(first.hash, isNot(second.hash));
  });
}
