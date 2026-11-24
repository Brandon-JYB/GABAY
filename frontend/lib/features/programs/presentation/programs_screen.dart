import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/language_toggle.dart';
import '../../home/presentation/home_screen.dart' show ProgramSummary;

/// Programs tab. Search lives here. It filters the list it is given,
/// so nothing is hard coded. Pass real programs in once the data layer exists.
class ProgramsScreen extends StatefulWidget {
  const ProgramsScreen({
    super.key,
    this.programs = const [],
    this.onProgramTap,
    this.onFilterTap,
  });

  final List<ProgramSummary> programs;
  final ValueChanged<ProgramSummary>? onProgramTap;
  final VoidCallback? onFilterTap;

  @override
  State<ProgramsScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends State<ProgramsScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _query.isEmpty
        ? widget.programs
        : widget.programs
        .where((p) =>
    p.title.toLowerCase().contains(_query) ||
        p.description.toLowerCase().contains(_query))
        .toList();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.tr('programsTitle'),
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.phthalo,
                    ),
                  ),
                ),
                const LanguageToggle(),
              ],
            ),
            const SizedBox(height: 20),
            _SearchField(
              controller: _controller,
              hint: context.tr('searchHint'),
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              onFilterTap: widget.onFilterTap,
            ),
            const SizedBox(height: 20),
            if (results.isEmpty)
              _EmptyState(
                message: widget.programs.isEmpty
                    ? context.tr('noPrograms')
                    : context.tr('noResults'),
              )
            else
              for (final p in results)
                _ProgramTile(
                  program: p,
                  onTap: () => widget.onProgramTap?.call(p),
                ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.onFilterTap,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback? onFilterTap;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(32),
      borderSide: BorderSide(color: color),
    );

    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textMuted),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.phthalo),
        suffixIcon: Padding(
          padding: const EdgeInsets.all(6),
          child: InkWell(
            onTap: onFilterTap,
            customBorder: const CircleBorder(),
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: AppColors.deepSpace,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.tune_rounded,
                  size: 20, color: Colors.white),
            ),
          ),
        ),
        enabledBorder: border(AppColors.lightGray),
        border: border(AppColors.lightGray),
        focusedBorder: border(AppColors.deepSpace),
      ),
    );
  }
}

class _ProgramTile extends StatelessWidget {
  const _ProgramTile({required this.program, this.onTap});
  final ProgramSummary program;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.lightGray),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        program.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.phthalo,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        program.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          color: AppColors.textMuted,
                        ),
                      ),
                      if (program.category != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.moonstone.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            program.category!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.phthalo,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.phthalo),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_off_rounded, color: AppColors.deepSpace),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}