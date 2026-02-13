import 'package:flutter/material.dart';
import 'package:multi_lng_bloc/l10n/app_localizations.dart';

class ErrorDialog extends StatelessWidget {
  final String? title;
  final String message;
  final VoidCallback? onRetry;

  const ErrorDialog({
    super.key,
    this.title,
    required this.message,
    this.onRetry,
  });

  static Future<void> show(
    BuildContext context, {
    String? title,
    required String message,
    VoidCallback? onRetry,
  }) {
    return showDialog(
      context: context,
      builder: (_) =>
          ErrorDialog(title: title, message: message, onRetry: onRetry),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(title ?? l10n.error),
      content: Text(message),
      actions: [
        if (onRetry != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry!();
            },
            child: Text(l10n.retry),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.ok),
        ),
      ],
    );
  }
}
