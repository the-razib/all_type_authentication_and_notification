# Widgets Documentation

This document describes the organization and usage of custom widgets in the authentication app.

## Folder Structure

```
lib/widgets/
├── common_widgets.dart          # Main export file (backward compatibility)
├── auth_wrapper.dart           # Authentication state wrapper
└── common/                     # Common reusable widgets
    ├── index.dart              # Export file for all common widgets
    ├── loading_overlay.dart    # Loading overlay widget
    ├── custom_text_field.dart  # Custom text input field
    ├── custom_button.dart      # Custom button widget
    └── utils.dart              # UI utility functions
```

## Widget Descriptions

### LoadingOverlay
A widget that displays a loading indicator over existing content.

**Usage:**
```dart
LoadingOverlay(
  isLoading: _isLoading,
  message: "Signing in...",
  child: YourWidget(),
)
```

**Properties:**
- `isLoading`: Controls whether loading overlay is shown
- `child`: The widget to display behind the overlay
- `message`: Optional loading message

### CustomTextField
A styled text input field with consistent design.

**Usage:**
```dart
CustomTextField(
  controller: _emailController,
  hintText: "Enter your email",
  prefixIcon: Icons.email,
  keyboardType: TextInputType.emailAddress,
  validator: FormValidators.validateEmail,
)
```

**Properties:**
- `controller`: TextEditingController for the field
- `hintText`: Placeholder text
- `prefixIcon`: Icon to show at the start of field
- `obscureText`: Whether to hide text (for passwords)
- `keyboardType`: Type of keyboard to show
- `validator`: Function to validate input
- `enabled`: Whether the field is editable

### CustomButton
A styled button with loading state support.

**Usage:**
```dart
CustomButton(
  text: "Sign In",
  onPressed: _handleSignIn,
  isLoading: _isLoading,
  backgroundColor: Colors.blue,
)
```

**Properties:**
- `text`: Button label
- `onPressed`: Function to call when tapped
- `isLoading`: Shows loading indicator when true
- `backgroundColor`: Custom background color
- `textColor`: Custom text color
- `isOutlined`: Whether to show as outlined button

### Utils
Utility functions for common UI operations.

**Methods:**
- `showSnackBar()`: Display a snackbar message
- `showSuccessSnackBar()`: Display success message
- `showErrorSnackBar()`: Display error message
- `showLoadingDialog()`: Show loading dialog
- `hideLoadingDialog()`: Hide loading dialog
- `showConfirmDialog()`: Show confirmation dialog

**Usage:**
```dart
Utils.showSuccessSnackBar(context, "Login successful!");
Utils.showErrorSnackBar(context, "Login failed");
Utils.showLoadingDialog(context, message: "Processing...");
```

## Form Validators

Located in `lib/utils/validators/form_validators.dart`

### FormValidators
Contains validation functions for form fields.

**Methods:**
- `validateEmail()`: Email format validation
- `validatePassword()`: Password requirements validation
- `validateName()`: Name format validation
- `validateRequired()`: Required field validation
- `validatePhoneNumber()`: Phone number format validation
- `validateConfirmPassword()`: Password confirmation validation

**Usage:**
```dart
TextFormField(
  validator: FormValidators.validateEmail,
  // other properties...
)
```

## Import Usage

### Option 1: Import main file (recommended for backward compatibility)
```dart
import 'package:authentication_and_notification/widgets/common_widgets.dart';
```

### Option 2: Import specific widgets
```dart
import 'package:authentication_and_notification/widgets/common/custom_button.dart';
import 'package:authentication_and_notification/widgets/common/utils.dart';
```

### Option 3: Import all common widgets
```dart
import 'package:authentication_and_notification/widgets/common/index.dart';
```

## Best Practices

1. **Consistent Styling**: All widgets follow the app's design system
2. **Validation**: Use FormValidators for consistent validation logic
3. **Loading States**: Show loading indicators for async operations
4. **Error Handling**: Use Utils.showErrorSnackBar for error messages
5. **Accessibility**: All widgets support accessibility features

## Future Enhancements

- Add more validation types (URL, date, etc.)
- Create specialized widgets (SearchField, DatePicker, etc.)
- Add animation support to loading states
- Implement theme-aware styling
