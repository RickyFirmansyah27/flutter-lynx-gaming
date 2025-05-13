import 'package:flutter/material.dart';

class SnackBarHelper {
  static Future<void> showMessage(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) async {
    if (!context.mounted) return;
    await ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: Text(message),
            duration: duration,
            action: action,
          ),
        )
        .closed;
  }
}