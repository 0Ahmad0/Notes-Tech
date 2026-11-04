import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database/app_database.dart';

final Provider<AppDatabase> appDatabaseProvider = Provider<AppDatabase>((
  Ref ref,
) {
  final AppDatabase database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final Provider<SharedPreferencesAsync> sharedPreferencesProvider =
    Provider<SharedPreferencesAsync>((Ref ref) => SharedPreferencesAsync());
