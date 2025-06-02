# Flutter Authentication Implementation Guide

This document provides detailed implementation logic for each authentication feature. Use this as a reference when building similar functionality in future projects.

## 📋 Table of Contents
1. [Firebase Setup](#firebase-setup)
2. [Google Sign-In Implementation](#google-sign-in-implementation)
3. [Email/Password Authentication](#emailpassword-authentication)
4. [User Registration](#user-registration)
5. [Forgot Password](#forgot-password)
6. [Authentication State Management](#authentication-state-management)
7. [UI Components](#ui-components)
8. [Error Handling](#error-handling)
9. [Navigation Flow](#navigation-flow)
10. [Best Practices](#best-practices)

---

## 🔥 Firebase Setup

### Step 1: Firebase Configuration
```yaml
# pubspec.yaml dependencies
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  google_sign_in: ^6.1.6
```

### Step 2: Firebase Initialization
```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kDebugMode) {
      print('Firebase connected!');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Firebase connection failed: $e');
    }
  }
  
  runApp(const MyApp());
}
```

### Step 3: Platform Configuration
```bash
# Android: Add google-services.json to android/app/
# iOS: Add GoogleService-Info.plist to ios/Runner/
# Web: Add Firebase SDK to web/index.html
```

---

## 🔐 Google Sign-In Implementation

### Core Logic Structure
```dart
// services/auth_service.dart
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static Future<AuthResult> signInWithGoogle() async {
    try {
      // Step 1: Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      // Step 2: Handle user cancellation
      if (googleUser == null) {
        return AuthResult(success: false, errorMessage: 'Sign in cancelled');
      }

      // Step 3: Get authentication details
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      // Step 4: Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Step 5: Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      
      return AuthResult(success: true, user: userCredential.user);
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'Google sign in failed: ${e.toString()}',
      );
    }
  }
}
```

### UI Implementation
```dart
// Login button with Google
CustomButton(
  text: 'Continue with Google',
  onPressed: () async {
    setState(() => _isLoading = true);
    
    final result = await AuthService.signInWithGoogle();
    
    setState(() => _isLoading = false);
    
    if (result.success && context.mounted) {
      Utils.showSnackBar(context, 'Login successful!');
      _navigateToHome(context);
    } else if (context.mounted) {
      Utils.showSnackBar(context, result.errorMessage!, isError: true);
    }
  },
  isLoading: _isLoading,
  isOutlined: true,
),
```

### Key Implementation Points:
1. **Always handle user cancellation** (when googleUser is null)
2. **Use proper error handling** with try-catch blocks
3. **Manage loading states** in UI
4. **Check context.mounted** before navigation
5. **Provide user feedback** with success/error messages

---

## 📧 Email/Password Authentication

### Core Logic Structure
```dart
// Sign In Logic
static Future<AuthResult> signInWithEmailPassword({
  required String email,
  required String password,
}) async {
  try {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return AuthResult(success: true, user: credential.user);
  } on FirebaseAuthException catch (e) {
    return AuthResult(
      success: false,
      errorMessage: _getErrorMessage(e.code),
    );
  } catch (e) {
    return AuthResult(
      success: false,
      errorMessage: 'An unexpected error occurred',
    );
  }
}

// Error Message Translation
static String _getErrorMessage(String errorCode) {
  switch (errorCode) {
    case 'user-not-found':
      return 'No user found with this email address.';
    case 'wrong-password':
      return 'Incorrect password.';
    case 'invalid-email':
      return 'Invalid email address.';
    case 'user-disabled':
      return 'This account has been disabled.';
    case 'too-many-requests':
      return 'Too many attempts. Please try again later.';
    default:
      return 'Authentication failed. Please try again.';
  }
}
```

### Form Validation Logic
```dart
// Email Validation
static String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email is required';
  }
  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
    return 'Please enter a valid email address';
  }
  return null;
}

// Password Validation
static String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }
  if (value.length < 6) {
    return 'Password must be at least 6 characters';
  }
  return null;
}
```

### UI Implementation with Form
```dart
Future<void> _signInWithEmail() async {
  // Step 1: Validate form
  if (!_formKey.currentState!.validate()) return;

  // Step 2: Set loading state
  setState(() => _isLoading = true);

  // Step 3: Call authentication service
  final result = await AuthService.signInWithEmailPassword(
    email: _emailController.text.trim(),
    password: _passwordController.text,
  );

  // Step 4: Clear loading state
  setState(() => _isLoading = false);

  // Step 5: Handle result with navigation
  if (result.success && context.mounted) {
    Utils.showSnackBar(context, 'Login successful!');
    _navigateToHome(context);
  } else if (context.mounted) {
    Utils.showSnackBar(context, result.errorMessage!, isError: true);
  }
}
```

---

## 👤 User Registration

### Core Logic Structure
```dart
static Future<AuthResult> signUpWithEmailPassword({
  required String email,
  required String password,
}) async {
  try {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return AuthResult(success: true, user: credential.user);
  } on FirebaseAuthException catch (e) {
    return AuthResult(
      success: false,
      errorMessage: _getErrorMessage(e.code),
    );
  } catch (e) {
    return AuthResult(
      success: false,
      errorMessage: 'An unexpected error occurred',
    );
  }
}
```

### Additional Validation for Registration
```dart
// Confirm Password Validation
String? _validateConfirmPassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please confirm your password';
  }
  if (value != _passwordController.text) {
    return 'Passwords do not match';
  }
  return null;
}

// Name Validation (if collecting user name)
static String? validateName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Name is required';
  }
  if (value.length < 2) {
    return 'Name must be at least 2 characters';
  }
  if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
    return 'Name can only contain letters and spaces';
  }
  return null;
}
```

### Registration Flow Implementation
```dart
Future<void> _signUp() async {
  // Step 1: Validate all fields including password confirmation
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  // Step 2: Create user account
  final result = await AuthService.signUpWithEmailPassword(
    email: _emailController.text.trim(),
    password: _passwordController.text,
  );

  setState(() => _isLoading = false);

  // Step 3: Navigate to login on success
  if (result.success && context.mounted) {
    Utils.showSnackBar(context, 'Account created successfully! Please sign in.');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  } else if (context.mounted) {
    Utils.showSnackBar(context, result.errorMessage!, isError: true);
  }
}
```

---

## 🔄 Forgot Password

### Core Logic Structure
```dart
static Future<AuthResult> sendPasswordResetEmail(String email) async {
  try {
    await _auth.sendPasswordResetEmail(email: email);
    return AuthResult(success: true);
  } on FirebaseAuthException catch (e) {
    return AuthResult(
      success: false,
      errorMessage: _getErrorMessage(e.code),
    );
  } catch (e) {
    return AuthResult(
      success: false,
      errorMessage: 'Failed to send reset email',
    );
  }
}
```

### UI State Management
```dart
class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _emailSent = false; // Track if email was sent

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await AuthService.sendPasswordResetEmail(
      _emailController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result.success && context.mounted) {
      setState(() => _emailSent = true); // Update UI state
      Utils.showSnackBar(
        context,
        'Password reset email sent! Check your inbox.',
      );
    } else if (context.mounted) {
      Utils.showSnackBar(context, result.errorMessage!, isError: true);
    }
  }
}
```

### Dynamic UI Based on State
```dart
// Show different UI based on email sent state
if (!_emailSent) ...[
  // Show email input form
  Form(
    key: _formKey,
    child: CustomTextField(
      controller: _emailController,
      hintText: 'Email',
      prefixIcon: Icons.email,
      keyboardType: TextInputType.emailAddress,
      validator: Utils.validateEmail,
    ),
  ),
  const SizedBox(height: 20),
  CustomButton(
    text: 'Send Reset Email',
    onPressed: _sendResetEmail,
    isLoading: _isLoading,
  ),
] else ...[
  // Show success state with resend option
  CustomButton(
    text: 'Resend Email',
    onPressed: () {
      setState(() => _emailSent = false);
    },
    isOutlined: true,
  ),
],
```

---

## 🔄 Authentication State Management

### Core Auth Wrapper Logic
```dart
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.authStateChanges,
      builder: (context, snapshot) {
        // Step 1: Show loading while determining auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading...'),
                ],
              ),
            ),
          );
        }

        // Step 2: Navigate based on auth state
        if (snapshot.hasData && snapshot.data != null) {
          return const HomePage(); // User is signed in
        }

        return const LoginPage(); // User is not signed in
      },
    );
  }
}
```

### Auth Service Stream Setup
```dart
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Get current user
  static User? get currentUser => _auth.currentUser;
  
  // Auth state stream for real-time updates
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Sign out from all providers
  static Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}
```

---

## 🎨 UI Components

### Reusable Custom Text Field
```dart
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool enabled;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      enabled: enabled,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.deepPurple),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
```

### Custom Button with Loading State
```dart
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isOutlined;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget buttonChild = isLoading
        ? const CircularProgressIndicator(color: Colors.white)
        : Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textColor ?? (isOutlined ? Colors.black87 : Colors.white),
            ),
          );

    return SizedBox(
      height: 48,
      width: double.infinity,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: backgroundColor ?? Colors.deepPurple),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                backgroundColor: Colors.white,
              ),
              child: buttonChild,
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor ?? Colors.deepPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: buttonChild,
            ),
    );
  }
}
```

### Loading Overlay Component
```dart
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black54,
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      if (message != null) ...[
                        const SizedBox(height: 16),
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

## ⚠️ Error Handling

### AuthResult Pattern
```dart
class AuthResult {
  final bool success;
  final User? user;
  final String? errorMessage;

  AuthResult({
    required this.success,
    this.user,
    this.errorMessage,
  });
}
```

### Comprehensive Error Translation
```dart
static String _getErrorMessage(String errorCode) {
  switch (errorCode) {
    // Sign In Errors
    case 'user-not-found':
      return 'No user found with this email address.';
    case 'wrong-password':
      return 'Incorrect password.';
    case 'invalid-email':
      return 'Invalid email address.';
    case 'user-disabled':
      return 'This account has been disabled.';
    case 'too-many-requests':
      return 'Too many attempts. Please try again later.';
    
    // Sign Up Errors
    case 'email-already-in-use':
      return 'An account already exists with this email.';
    case 'weak-password':
      return 'Password is too weak.';
    case 'operation-not-allowed':
      return 'Email/password sign up is not enabled.';
    
    // General Errors
    case 'network-request-failed':
      return 'Network error. Please check your connection.';
    case 'invalid-credential':
      return 'Invalid credentials provided.';
    
    default:
      return 'Authentication failed. Please try again.';
  }
}
```

### User Feedback Utility
```dart
class Utils {
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
```

---

## 🧭 Navigation Flow

### Basic Navigation Pattern
```dart
// Navigate and replace (for login to home)
Navigator.of(context).pushReplacement(
  MaterialPageRoute(builder: (_) => const HomePage()),
);

// Navigate and clear stack (for logout)
Navigator.of(context).pushAndRemoveUntil(
  MaterialPageRoute(builder: (_) => const LoginPage()),
  (route) => false,
);

// Simple navigation (for forgot password)
Navigator.of(context).push(
  MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
);
```

### Named Route System (Advanced)
```dart
class AppRouter {
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String homeRoute = '/home';
  static const String profileRoute = '/profile';
  static const String forgotPasswordRoute = '/forgot-password';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const AuthWrapper());
      case loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case signupRoute:
        return MaterialPageRoute(builder: (_) => const SignUpPage());
      case homeRoute:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case profileRoute:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case forgotPasswordRoute:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());
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

// Usage in MaterialApp
MaterialApp(
  onGenerateRoute: AppRouter.generateRoute,
  home: const AuthWrapper(),
)
```

---

## ✅ Best Practices

### 1. Security Practices
```dart
// Always trim email input
email: _emailController.text.trim(),

// Validate inputs before API calls
if (!_formKey.currentState!.validate()) return;

// Handle all possible Firebase error codes
on FirebaseAuthException catch (e) {
  return AuthResult(
    success: false,
    errorMessage: _getErrorMessage(e.code),
  );
}

// Use secure password requirements
if (value.length < 6) {
  return 'Password must be at least 6 characters';
}
```

### 2. UX Best Practices
```dart
// Always show loading states
setState(() => _isLoading = true);
// ... async operation
setState(() => _isLoading = false);

// Check context.mounted before navigation
if (result.success && context.mounted) {
  _navigateToHome(context);
}

// Provide user feedback for all actions
Utils.showSnackBar(context, 'Login successful!');
Utils.showSnackBar(context, result.errorMessage!, isError: true);

// Disable buttons during loading
CustomButton(
  text: 'Sign In',
  onPressed: _isLoading ? null : _signInWithEmail,
  isLoading: _isLoading,
),
```

### 3. Code Organization
```dart
// Separate service layer for auth logic
class AuthService {
  // All authentication methods here
}

// Separate utils for validation and UI helpers
class Utils {
  static String? validateEmail(String? value) { ... }
  static void showSnackBar(...) { ... }
}

// Use consistent naming conventions
Future<void> _signInWithEmail() async { ... }
Future<void> _signInWithGoogle() async { ... }
Future<void> _signUp() async { ... }
```

### 4. State Management
```dart
// Use proper disposal
@override
void dispose() {
  _emailController.dispose();
  _passwordController.dispose();
  super.dispose();
}

// Use GlobalKey for forms
final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

// Proper loading state management
bool _isLoading = false;
```

### 5. Error Prevention
```dart
// Always handle null cases
if (googleUser == null) {
  return AuthResult(success: false, errorMessage: 'Sign in cancelled');
}

// Use mounted checks for async operations
if (context.mounted) {
  Navigator.of(context).pushReplacement(...);
}

// Provide fallback error messages
default:
  return 'Authentication failed. Please try again.';
```

---

## 🚀 Quick Implementation Checklist

When implementing authentication in a new project:

### Setup Phase:
- [ ] Add Firebase dependencies to pubspec.yaml
- [ ] Configure Firebase project and download config files
- [ ] Initialize Firebase in main.dart
- [ ] Set up Google Sign-In configuration

### Core Implementation:
- [ ] Create AuthService class with all authentication methods
- [ ] Implement AuthResult pattern for consistent return values
- [ ] Create reusable UI components (CustomTextField, CustomButton, LoadingOverlay)
- [ ] Set up form validation with proper error messages
- [ ] Implement AuthWrapper for automatic state management

### UI Implementation:
- [ ] Design login page with email/password and Google options
- [ ] Create signup page with password confirmation
- [ ] Build forgot password page with email input
- [ ] Design user profile/home page
- [ ] Add loading states to all buttons and forms

### Error Handling:
- [ ] Translate all Firebase error codes to user-friendly messages
- [ ] Add proper try-catch blocks around all async operations
- [ ] Implement user feedback with SnackBars or dialogs
- [ ] Handle network errors and edge cases

### Navigation:
- [ ] Set up proper navigation flow between screens
- [ ] Implement context.mounted checks for async navigation
- [ ] Clear authentication state on logout
- [ ] Handle deep linking and route guards if needed

### Testing:
- [ ] Test all authentication flows (login, signup, logout)
- [ ] Test error scenarios (wrong password, network errors)
- [ ] Test Google Sign-In flow
- [ ] Test forgot password functionality
- [ ] Test automatic authentication state management

This guide provides the complete blueprint for implementing authentication in Flutter. Each section contains the core logic patterns and best practices you'll need for a production-ready authentication system.
