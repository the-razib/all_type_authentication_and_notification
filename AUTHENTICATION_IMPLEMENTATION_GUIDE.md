# Flutter Authentication Implementation Guide

This guide provides step-by-step implementation details for building a complete authentication system in Flutter with Firebase. Use this as a reference for future projects.

## Table of Contents

1. [Project Setup & Dependencies](#project-setup--dependencies)
2. [Firebase Configuration](#firebase-configuration)
3. [Google Sign-In Implementation](#google-sign-in-implementation)
4. [Email/Password Authentication](#emailpassword-authentication)
5. [User Registration (Sign Up)](#user-registration-sign-up)
6. [Forgot Password](#forgot-password)
7. [Authentication State Management](#authentication-state-management)
8. [UI Components & Widgets](#ui-components--widgets)
9. [Error Handling](#error-handling)
10. [Navigation & Routing](#navigation--routing)
11. [Theme & Styling](#theme--styling)

---

## Project Setup & Dependencies

### 1. Required Dependencies

Add these to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase Core
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  
  # Google Sign-In
  google_sign_in: ^6.1.6
  
  # UI/UX
  cupertino_icons: ^1.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

### 2. Platform Configuration

#### Android (`android/app/build.gradle.kts`):
```kotlin
android {
    compileSdk 34
    ndkVersion "27.0.12077973"  // Updated NDK version
    
    defaultConfig {
        minSdk 23  // Minimum for Firebase
        targetSdk 34
        multiDexEnabled true
    }
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}
```

#### iOS Configuration:
- No additional configuration needed beyond Firebase setup

---

## Firebase Configuration

### 1. Firebase Project Setup

1. Create project in [Firebase Console](https://console.firebase.google.com/)
2. Enable Authentication with Email/Password and Google providers
3. Download configuration files:
   - `google-services.json` for Android
   - `GoogleService-Info.plist` for iOS

### 2. Firebase Options File

Generate using Firebase CLI:
```bash
flutterfire configure
```

This creates `lib/firebase_options.dart` with platform-specific configurations.

### 3. Main App Initialization

```dart
// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(MyApp());
}
```

---

## Google Sign-In Implementation

### 1. Core Google Sign-In Service

```dart
// lib/services/login_with_google.dart
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GoogleSignInService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled

      // Get authentication details
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Google Sign-In Error: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}
```

### 2. Google Sign-In Button Integration

```dart
// In your login page widget
ElevatedButton.icon(
  onPressed: () async {
    setState(() => _isLoading = true);
    
    final result = await GoogleSignInService.signInWithGoogle();
    
    setState(() => _isLoading = false);
    
    if (result != null && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In failed')),
      );
    }
  },
  icon: Image.asset('assets/google_logo.png', height: 20),
  label: Text('Continue with Google'),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black87,
    side: BorderSide(color: Colors.grey.shade300),
  ),
)
```

---

## Email/Password Authentication

### 1. AuthService Class Structure

```dart
// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthResult {
  final bool success;
  final String? error;
  final User? user;

  AuthResult({required this.success, this.error, this.user});
}

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Auth state stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  static Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      return AuthResult(success: true, user: credential.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false, 
        error: _getErrorMessage(e.code),
      );
    } catch (e) {
      return AuthResult(
        success: false, 
        error: 'An unexpected error occurred',
      );
    }
  }

  // Error message mapping
  static String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email address';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later';
      default:
        return 'Authentication failed. Please try again';
    }
  }
}
```

### 2. Login Page Implementation

```dart
// lib/screens/login_page.dart
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await AuthService.signInWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (result.success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error ?? 'Login failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value!)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: 16),
                
                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword 
                        ? Icons.visibility 
                        : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: 24),
                
                // Login button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleEmailLogin,
                  child: _isLoading 
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Sign In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## User Registration (Sign Up)

### 1. Registration Method in AuthService

```dart
// Add to AuthService class
static Future<AuthResult> createUserWithEmailAndPassword({
  required String email,
  required String password,
  String? displayName,
}) async {
  try {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // Update display name if provided
    if (displayName != null && credential.user != null) {
      await credential.user!.updateDisplayName(displayName);
      await credential.user!.reload();
    }

    return AuthResult(success: true, user: credential.user);
  } on FirebaseAuthException catch (e) {
    return AuthResult(
      success: false,
      error: _getRegistrationErrorMessage(e.code),
    );
  } catch (e) {
    return AuthResult(
      success: false,
      error: 'Registration failed. Please try again',
    );
  }
}

static String _getRegistrationErrorMessage(String code) {
  switch (code) {
    case 'weak-password':
      return 'Password is too weak. Use at least 6 characters';
    case 'email-already-in-use':
      return 'An account already exists with this email';
    case 'invalid-email':
      return 'Invalid email address';
    case 'operation-not-allowed':
      return 'Email/password accounts are not enabled';
    default:
      return 'Registration failed. Please try again';
  }
}
```

### 2. Sign Up Page Implementation

```dart
// lib/screens/signup_page.dart
class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await AuthService.createUserWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
      displayName: _nameController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result.success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error ?? 'Registration failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: 16),
                
                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value!)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: 16),
                
                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter a password';
                    }
                    if (value!.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: 16),
                
                // Confirm password field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: 24),
                
                // Sign up button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignUp,
                  child: _isLoading 
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Create Account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## Forgot Password

### 1. Password Reset Method in AuthService

```dart
// Add to AuthService class
static Future<AuthResult> sendPasswordResetEmail({
  required String email,
}) async {
  try {
    await _auth.sendPasswordResetEmail(email: email.trim());
    return AuthResult(success: true);
  } on FirebaseAuthException catch (e) {
    return AuthResult(
      success: false,
      error: _getPasswordResetErrorMessage(e.code),
    );
  } catch (e) {
    return AuthResult(
      success: false,
      error: 'Failed to send reset email. Please try again',
    );
  }
}

static String _getPasswordResetErrorMessage(String code) {
  switch (code) {
    case 'user-not-found':
      return 'No account found with this email address';
    case 'invalid-email':
      return 'Invalid email address';
    case 'too-many-requests':
      return 'Too many requests. Please try again later';
    default:
      return 'Failed to send reset email. Please try again';
  }
}
```

### 2. Forgot Password Page Implementation

```dart
// lib/screens/forgot_password_page.dart
class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  Future<void> _handlePasswordReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await AuthService.sendPasswordResetEmail(
      email: _emailController.text,
    );

    setState(() => _isLoading = false);

    if (result.success) {
      setState(() => _emailSent = true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error ?? 'Failed to send reset email')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reset Password')),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: _emailSent ? _buildSuccessView() : _buildFormView(),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Enter your email address and we\'ll send you a link to reset your password.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          
          SizedBox(height: 24),
          
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value!)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          
          SizedBox(height: 24),
          
          ElevatedButton(
            onPressed: _isLoading ? null : _handlePasswordReset,
            child: _isLoading 
              ? CircularProgressIndicator(color: Colors.white)
              : Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.mark_email_read,
          size: 80,
          color: Colors.green,
        ),
        
        SizedBox(height: 24),
        
        Text(
          'Reset Link Sent!',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        
        SizedBox(height: 16),
        
        Text(
          'We\'ve sent a password reset link to ${_emailController.text}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        
        SizedBox(height: 32),
        
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Back to Login'),
        ),
      ],
    );
  }
}
```

---

## Authentication State Management

### 1. AuthWrapper Widget

```dart
// lib/widgets/auth_wrapper.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthWrapper extends StatelessWidget {
  final Widget authenticatedWidget;
  final Widget unauthenticatedWidget;

  const AuthWrapper({
    Key? key,
    required this.authenticatedWidget,
    required this.unauthenticatedWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show appropriate widget based on auth state
        if (snapshot.hasData && snapshot.data != null) {
          return authenticatedWidget;
        } else {
          return unauthenticatedWidget;
        }
      },
    );
  }
}
```

### 2. Usage in Main App

```dart
// lib/main.dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: AuthWrapper(
        authenticatedWidget: HomePage(),
        unauthenticatedWidget: LoginPage(),
      ),
    );
  }
}
```

---

## UI Components & Widgets

### 1. Custom TextField Widget

```dart
// lib/widgets/common_widgets.dart
class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.isPassword ? _obscureText : false,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.labelText,
        prefixIcon: Icon(widget.prefixIcon),
        suffixIcon: widget.isPassword
          ? IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() => _obscureText = !_obscureText);
              },
            )
          : null,
      ),
    );
  }
}
```

### 2. Custom Button Widget

```dart
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
      ),
      child: isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                textColor ?? Colors.white,
              ),
            ),
          )
        : Text(text),
    );
  }
}
```

### 3. Loading Overlay Widget

```dart
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      if (message != null) ...[
                        SizedBox(height: 16),
                        Text(message!),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
```

---

## Error Handling

### 1. Centralized Error Handler

```dart
// lib/utils/error_handler.dart
class ErrorHandler {
  static String getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      // Sign-in errors
      case 'user-not-found':
        return 'No account found with this email address';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      
      // Registration errors
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      
      // General errors
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later';
      case 'operation-not-allowed':
        return 'This operation is not allowed';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      
      default:
        return 'An unexpected error occurred. Please try again';
    }
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
```

---

## Navigation & Routing

### 1. Router Configuration

```dart
// lib/config/router.dart
import 'package:flutter/material.dart';

class AppRouter {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => LoginPage());
      
      case signup:
        return MaterialPageRoute(builder: (_) => SignUpPage());
      
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => ForgotPasswordPage());
      
      case home:
        return MaterialPageRoute(builder: (_) => HomePage());
      
      case profile:
        return MaterialPageRoute(builder: (_) => ProfilePage());
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
```

### 2. Navigation Usage

```dart
// Navigate to different screens
Navigator.pushNamed(context, AppRouter.signup);
Navigator.pushReplacementNamed(context, AppRouter.home);
Navigator.pushNamedAndRemoveUntil(
  context, 
  AppRouter.login, 
  (route) => false,
);
```

---

## Theme & Styling

### 1. Theme Configuration

```dart
// lib/config/theme.dart
class AppTheme {
  static const Color primaryColor = Colors.deepPurple;
  static const Color secondaryColor = Color(0xFF9C27B0);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: Color(0xFF121212),
    );
  }
}
```

---

## Implementation Checklist

### Basic Setup
- [ ] Add Firebase dependencies to `pubspec.yaml`
- [ ] Configure Firebase project and download config files
- [ ] Run `flutterfire configure` to generate Firebase options
- [ ] Initialize Firebase in `main.dart`
- [ ] Update Android `build.gradle.kts` with minimum SDK and NDK version

### Authentication Features
- [ ] Create `AuthService` class with email/password methods
- [ ] Implement Google Sign-In service
- [ ] Build login page with form validation
- [ ] Create registration page with password confirmation
- [ ] Add forgot password functionality
- [ ] Implement sign-out functionality

### UI Components
- [ ] Create reusable `CustomTextField` widget
- [ ] Build `CustomButton` with loading state
- [ ] Add `LoadingOverlay` for async operations
- [ ] Implement `AuthWrapper` for state management

### Error Handling
- [ ] Create centralized error handler
- [ ] Map Firebase error codes to user-friendly messages
- [ ] Add SnackBar utilities for user feedback

### Navigation
- [ ] Set up route configuration
- [ ] Implement navigation between auth screens
- [ ] Add authentication-based routing

### Styling
- [ ] Create theme configuration with Material Design 3
- [ ] Define color scheme and component styles
- [ ] Add support for light/dark themes

---

## Best Practices

1. **Security**
   - Never store sensitive data in plain text
   - Use Firebase Security Rules
   - Validate all user inputs
   - Implement proper error handling

2. **Performance**
   - Use StreamBuilder for auth state changes
   - Implement loading states for better UX
   - Dispose controllers and streams properly

3. **Code Organization**
   - Separate business logic from UI
   - Use consistent naming conventions
   - Create reusable widgets
   - Follow Flutter/Dart style guidelines

4. **Testing**
   - Write unit tests for authentication logic
   - Test error scenarios
   - Validate form inputs
   - Test navigation flows

This guide provides a complete foundation for implementing authentication in Flutter apps. Each section can be implemented independently and expanded based on specific requirements.
