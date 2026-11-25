import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/program.dart';
import '../state/saved_programs_controller.dart';
import 'programs_screen.dart' show LevelChip;

/// Everything about one program, with a requirements checklist.
class ProgramDetailScreen extends StatefulWidget {
  const ProgramDetailScreen({super.key, required this.program});

  final Program program;

  @override
  State<ProgramDetailScreen> createState() => _ProgramDetailScreenState();
}

class _ProgramDetailScreenState extends State<ProgramDetailScreen> {
  // Ticks are only a reminder for the person. They are not saved.
  final Set<int> _have = {};

  @override
  void initState() {
    super.initState();
    // Remember that this program was opened (shown under "Recently viewed").
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      SavedProgramsScope.of(context).markViewed(widget.program);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.program;
    final saved = SavedProgramsScope.of(context);
    final isSaved = saved.isSaved(p);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.phthalo,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            tooltip: context.tr(isSaved ? 'removeSaved' : 'saveProgram'),
            onPressed: () => saved.toggleSaved(p),
            icon: Icon(
              isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: isSaved ? AppColors.mustard : AppColors.phthalo,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          children: [
            Align(alignment: Alignment.centerLeft, child: LevelChip(p.level)),
            const SizedBox(height: 12),
            Text(
              p.name,
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 26,
                height: 1.2,
                fontWeight: FontWeight.w800,
                color: AppColors.phthalo,
              ),
            ),
            const SizedBox(height: 14),
            _OfficeCard(label: context.tr('implementingOffice'), office: p.office),
            const SizedBox(height: 24),
            _Section(title: context.tr('whatItCovers'), body: p.description),
            const SizedBox(height: 20),
            _Section(title: context.tr('whoCanAvail'), body: p.whoCanAvail),
            if (p.requirements.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                context.tr('requirementsList'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.phthalo,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.tr('checklistNote'),
                style: const TextStyle(
                    fontSize: 12.5, height: 1.4, color: AppColors.textMuted),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.lightGray),
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < p.requirements.length; i++)
                      CheckboxListTile(
                        value: _have.contains(i),
                        onChanged: (checked) => setState(() {
                          if (checked == true) {
                            _have.add(i);
                          } else {
                            _have.remove(i);
                          }
                        }),
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: AppColors.deepSpace,
                        title: Text(
                          p.requirements[i],
                          style: const TextStyle(
                              fontSize: 14,
                              height: 1.35,
                              color: AppColors.phthalo),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.phthalo,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          body,
          style: const TextStyle(
              fontSize: 15, height: 1.45, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _OfficeCard extends StatelessWidget {
  const _OfficeCard({required this.label, required this.office});
  final String label;
  final String office;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.moonstone.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.apartment_rounded, color: AppColors.deepSpace),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: 2),
                Text(
                  office,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                    color: AppColors.phthalo,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}