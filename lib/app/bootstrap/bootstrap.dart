import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/app_logger.dart';
import '../../features/reminders/services/notification_service.dart';
import '../app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await NotificationService.instance.init();
  } catch (error, stack) {
    const AppLogger('Bootstrap')
        .error('Notification service failed to initialise', error, stack);
  }
  runApp(const ProviderScope(child: NotesTechApp()));
}
