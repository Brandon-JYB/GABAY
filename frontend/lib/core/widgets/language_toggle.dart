import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';

/// Small EN | TL switch. Tap anywhere on it to change language.
class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.language;
    final isEnglish = controller.language == AppLanguage.en;

    return Semantics(
      button: true,
      label: 'Switch language between English and Tagalog',
      child: InkWell(
        onTap: controller.toggle,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 46,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.lightGray),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Segment(label: 'EN', selected: isEnglish),
              _Segment(label: 'TL', selected: !isEnglish),
            ],
          ),
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.label, required this.selected});
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? AppColors.deepSpace : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: selected ? Colors.white : AppColors.textMuted,
        ),
      ),
    );
  }
}