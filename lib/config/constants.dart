class AppConstants {
  // App Information
  static const String appName = 'Authentication & Notification';
  static const String appVersion = '1.0.0';

  // Routes
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String homeRoute = '/home';
  static const String profileRoute = '/profile';
  static const String forgotPasswordRoute = '/forgot-password';

  // Messages
  static const String loginSuccessMessage = 'Login successful!';
  static const String signupSuccessMessage =
      'Account created successfully! Please sign in.';
  static const String signoutSuccessMessage = 'Signed out successfully';
  static const String signoutFailMessage = 'Sign out failed';
  static const String passwordResetEmailSent =
      'Password reset email sent! Check your inbox.';

  // Validation Messages
  static const String emailRequiredMessage = 'Email is required';
  static const String emailInvalidMessage =
      'Please enter a valid email address';
  static const String passwordRequiredMessage = 'Password is required';
  static const String passwordMinLengthMessage =
      'Password must be at least 6 characters';
  static const String passwordsDoNotMatchMessage = 'Passwords do not match';
  static const String nameRequiredMessage = 'Name is required';
  static const String nameMinLengthMessage =
      'Name must be at least 2 characters';
  static const String nameInvalidMessage =
      'Name can only contain letters and spaces';

  // Loading Messages
  static const String signingInMessage = 'Signing in...';
  static const String creatingAccountMessage = 'Creating account...';
  static const String signingOutMessage = 'Signing out...';
  static const String sendingResetEmailMessage = 'Sending reset email...';
  static const String loadingMessage = 'Loading...';

  // UI Text
  static const String welcomeBack = 'Welcome Back';
  static const String signInToContinue = 'Sign in to continue';
  static const String createAccount = 'Create Account';
  static const String signUpToGetStarted = 'Sign up to get started';
  static const String resetPassword = 'Reset Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String dontHaveAccount = "Don't have an account?";
  static const String alreadyHaveAccount = "Already have an account?";
  static const String signIn = 'Sign In';
  static const String signUp = 'Sign Up';
  static const String signOut = 'Sign Out';
  static const String continueWithGoogle = 'Continue with Google';
  static const String sendResetEmail = 'Send Reset Email';
  static const String resendEmail = 'Resend Email';
  static const String backToSignIn = 'Back to Sign In';
  static const String checkYourEmail = 'Check Your Email';
  static const String home = 'Home';
  static const String profile = 'Profile';

  // Form Fields
  static const String emailHint = 'Email';
  static const String passwordHint = 'Password';
  static const String confirmPasswordHint = 'Confirm Password';
  static const String nameHint = 'Name';

  // Profile
  static const String verified = 'Verified';
  static const String unverified = 'Unverified';
  static const String notProvided = 'Not provided';
  static const String anonymousUser = 'Anonymous User';
  static const String noUserInfo = 'No user information available';
  static const String youAreAuthenticated =
      'You are successfully authenticated!';

  // Info Card Titles
  static const String emailTitle = 'Email';
  static const String phoneTitle = 'Phone';
  static const String userIdTitle = 'User ID';
  static const String accountCreatedTitle = 'Account Created';
  static const String lastSignInTitle = 'Last Sign In';
}
