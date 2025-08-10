import 'package:authentication_and_notification/screens/forgot_password_page.dart';
import 'package:authentication_and_notification/screens/home_page.dart';
import 'package:authentication_and_notification/screens/signup_page.dart';
import 'package:authentication_and_notification/services/auth_service.dart';
import 'package:authentication_and_notification/services/notification_service.dart';
import 'package:authentication_and_notification/widgets/common_widgets.dart';
import 'package:authentication_and_notification/widgets/common/facebook_login_button.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _navigateToHome(BuildContext context) {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
  }

  // Sign in with email and password
  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await AuthService.signInWithEmailPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (result.success && context.mounted) {
      Utils.showSnackBar(context, 'Login successful!');
      _navigateToHome(context);
    } else if (context.mounted) {
      Utils.showSnackBar(context, result.errorMessage!, isError: true);
    }
  }

  // Sign in with Google
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    final result = await AuthService.signInWithGoogle();

    setState(() => _isLoading = false);

    if (result.success && context.mounted) {
      Utils.showSnackBar(context, 'Login successful!');
      _navigateToHome(context);
    } else if (context.mounted) {
      Utils.showSnackBar(context, result.errorMessage!, isError: true);
    }
  }

  // Sign in with Facebook
  Future<void> _signInWithFacebook() async {
    setState(() => _isLoading = true);

    final result = await AuthService.signInWithFacebook();

    setState(() => _isLoading = false);

    if (result.success && context.mounted) {
      Utils.showSnackBar(context, 'Login successful!');
      _navigateToHome(context);
    } else if (context.mounted) {
      Utils.showSnackBar(context, result.errorMessage!, isError: true);
    }
  }

  // Demo notification method
  Future<void> _sendTestNotification() async {
    try {
      await NotificationService().sendTestNotification();
      if (mounted) {
        Utils.showSnackBar(context, 'Test notification sent!');
      }
    } catch (e) {
      if (mounted) {
        Utils.showSnackBar(
          context,
          'Failed to send notification: $e',
          isError: true,
        );
      }
    }
  }

  // Demo notification with image method
  Future<void> _sendTestNotificationWithImage() async {
    try {
      await NotificationService().sendTestNotificationWithImage();
      if (mounted) {
        Utils.showSnackBar(context, 'Test notification with image sent!');
      }
    } catch (e) {
      if (mounted) {
        Utils.showSnackBar(
          context,
          'Failed to send notification: $e',
          isError: true,
        );
      }
    }
  }

  // Get FCM token for demo
  Future<void> _showFCMToken() async {
    try {
      final token = await NotificationService().getToken();
      if (mounted && token != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('FCM Token'),
            content: SelectableText(token),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Utils.showSnackBar(context, 'Failed to get token: $e', isError: true);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Signing in...',
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurple[700],
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  CustomTextField(
                    controller: _emailController,
                    hintText: 'Email',
                    prefixIcon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: FormValidators.validateEmail,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    prefixIcon: Icons.lock,
                    obscureText: true,
                    validator: FormValidators.validatePassword,
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Sign In',
                    onPressed: _signInWithEmail,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: const [
                      Expanded(child: Divider(thickness: 1)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('or'),
                      ),
                      Expanded(child: Divider(thickness: 1)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  CustomButton(
                    text: 'Continue with Google',
                    onPressed: _signInWithGoogle,
                    isLoading: _isLoading,
                    isOutlined: true,
                  ),
                  const SizedBox(height: 12),
                  FacebookLoginButton(
                    onPressed: _signInWithFacebook,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 28),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(color: Colors.deepPurple),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account?",
                        style: TextStyle(fontSize: 14),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SignUpPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Sign up',
                          style: TextStyle(color: Colors.deepPurple),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Demo notification section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Push Notification Demo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _sendTestNotification,
                                icon: const Icon(Icons.notifications, size: 18),
                                label: const Text('Test Notification'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _showFCMToken,
                                icon: const Icon(Icons.token, size: 18),
                                label: const Text('Show Token'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _sendTestNotificationWithImage,
                            icon: const Icon(Icons.image, size: 18),
                            label: const Text('Test with Image'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
