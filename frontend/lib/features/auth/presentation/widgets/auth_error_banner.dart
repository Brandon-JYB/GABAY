import 'package:flutter/material.dart';

class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({
    super.key,
    required this.message,
  });

  final String message;

  // Light moonstone-blue banner with phthalo text
  static const _mustardBg = Color(0xFFB9D8E2); // lightened moonstone
  static const _mustardBorder = Color(0xFF6FA9BB); // moonstone
  static const _onMustard = Color(0xFF19350C); // phthalo

  bool get _isConfirmEmailNotice =>
      message.startsWith('Please confirm your email') ||
          message.startsWith('Account created.');

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final bgColor =
    _isConfirmEmailNotice ? _mustardBg : colorScheme.errorContainer;
    final borderColor =
    _isConfirmEmailNotice ? _mustardBorder : colorScheme.error;
    final fgColor =
    _isConfirmEmailNotice ? _onMustard : colorScheme.onErrorContainer;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: fgColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: fgColor),
            ),
          ),
        ],
      ),
    );
  }
}