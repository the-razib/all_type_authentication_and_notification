import 'package:authentication_and_notification/config/constants.dart';
import 'package:authentication_and_notification/screens/forgot_password_page.dart';
import 'package:authentication_and_notification/screens/home_page.dart';
import 'package:authentication_and_notification/screens/login_page.dart';
import 'package:authentication_and_notification/screens/profile_page.dart';
import 'package:authentication_and_notification/screens/signup_page.dart';
import 'package:authentication_and_notification/widgets/auth_wrapper.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const AuthWrapper());
      case AppConstants.loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case AppConstants.signupRoute:
        return MaterialPageRoute(builder: (_) => const SignUpPage());
      case AppConstants.homeRoute:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case AppConstants.profileRoute:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case AppConstants.forgotPasswordRoute:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
