import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/task_provider.dart';
import 'services/notification_service.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'utils/app_snackbar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  final taskProvider = TaskProvider();
  await taskProvider.load();
  await NotificationService.instance.rescheduleAll(taskProvider.allTasks);
  runApp(
    ChangeNotifierProvider.value(
      value: taskProvider,
      child: MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        title: 'TaskFlow',
        theme: appTheme,
        themeMode: ThemeMode.dark,
        home: const SplashScreen(),
      ),
    ),
  );
}
