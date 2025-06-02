import 'package:flutter/material.dart';

class ErrorHandler {
  static void handleAsyncError(VoidCallback callback, BuildContext? context) {
    try {
      if (context != null && context.mounted) {
        callback();
      }
    } catch (e) {
      // Log error in production or handle as needed
      debugPrint('Error in async callback: $e');
    }
  }

  static void showErrorDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static void showConfirmationDialog(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
