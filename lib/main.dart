import 'package:authentication_and_notification/config/constants.dart';
import 'package:authentication_and_notification/config/router.dart';
import 'package:authentication_and_notification/config/theme.dart';
import 'package:authentication_and_notification/firebase_options.dart';
import 'package:authentication_and_notification/services/notification_service.dart';
import 'package:authentication_and_notification/widgets/auth_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kDebugMode) {
      print('Firebase connected!');
    }

    // Initialize notification service
    await NotificationService().initialize();
    if (kDebugMode) {
      print('Notification service initialized!');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Firebase connection failed: $e');
    }
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      onGenerateRoute: AppRouter.generateRoute,
      home: const AuthWrapper(),
    );
  }
}
