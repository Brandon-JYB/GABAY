import 'package:flutter/material.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/language_toggle.dart';
import '../../profile/state/profile_controller.dart';
import '../domain/program.dart';
import '../domain/program_matcher.dart';
import '../state/programs_controller.dart';
import '../state/saved_programs_controller.dart';
import 'program_detail_screen.dart';
import '../../../core/city_barangays.dart';

/// Programs tab: search, filter by level, and open a program's details.
class ProgramsScreen extends StatefulWidget {
  const ProgramsScreen({super.key, this.matchProfileRequest = 0});

  /// Increase this number to open the list with "Match my profile" switched
  /// on, e.g. when the user taps "Check eligibility" on Home.
  final int matchProfileRequest;

  @override
  State<ProgramsScreen> createState() => _ProgramsScreenState();
}

enum _ProgramView { all, saved, recent }

class _ProgramsScreenState extends State<ProgramsScreen> {
  final _search = TextEditingController();
  String _query = '';
  final Set<LevelGroup> _levels = {};
  bool _matchProfile = false;
  _ProgramView _view = _ProgramView.all;
  bool _selecting = false;
  final Set<String> _picked = {};

  @override
  void initState() {
    super.initState();
    _matchProfile = widget.matchProfileRequest > 0;
  }

  @override
  void didUpdateWidget(ProgramsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.matchProfileRequest != oldWidget.matchProfileRequest) {
      setState(() {
        _matchProfile = true;
        _view = _ProgramView.all;
        _selecting = false;
        _picked.clear();
        _levels.clear();
        _search.clear();
        _query = '';
      });
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// The list for the selected view: everything, saved (newest first) or
  /// recently viewed (newest first).
  List<Program> _baseList(List<Program> all, SavedProgramsController saved) {
    if (_view == _ProgramView.all) return all;
    final keys =
    _view == _ProgramView.saved ? saved.savedKeys : saved.recentKeys;
    final byKey = {for (final p in all) programKey(p): p};
    return [
      for (final k in keys)
        if (byKey[k] != null) byKey[k]!,
    ];
  }

  void _toggleSave(Program p, SavedProgramsController saved) {
    final wasSaved = saved.isSaved(p);
    saved.toggleSaved(p);
    if (!wasSaved) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(context.tr('removedFromSaved')),
        // Newer Flutter keeps snackbars with an action on screen until
        // dismissed, so turn that off and set a timeout.
        persist: false,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: context.tr('undo'),
          onPressed: () => saved.toggleSaved(p),
        ),
      ));
  }

  Future<void> _confirmRemove(SavedProgramsController saved) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          ctx.tr('removeRecentTitle'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.phthalo,
          ),
        ),
        content: Text(
          ctx.tr('removeRecentBody'),
          style: const TextStyle(
              fontSize: 14.5, height: 1.4, color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: TextButton.styleFrom(foregroundColor: AppColors.textMuted),
            child: Text(ctx.tr('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.phthalo,
              foregroundColor: Colors.white,
            ),
            child: Text(ctx.tr('removeSelected')),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    saved.removeRecent(_picked.toList());
    _exitSelect();
  }

  void _exitSelect() => setState(() {
    _selecting = false;
    _picked.clear();
  });

  void _togglePick(Program p) => setState(() {
    final k = programKey(p);
    if (!_picked.remove(k)) _picked.add(k);
  });

  Widget _selectionBar(BuildContext context, SavedProgramsController saved,
      List<Program> results) {
    if (!_selecting) {
      return Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed:
          results.isEmpty ? null : () => setState(() => _selecting = true),
          style: TextButton.styleFrom(foregroundColor: AppColors.deepSpace),
          child: Text(context.tr('select')),
        ),
      );
    }
    final visible = [for (final p in results) programKey(p)];
    final allPicked = visible.isNotEmpty && visible.every(_picked.contains);
    return Row(
      children: [
        TextButton(
          onPressed: _exitSelect,
          style: TextButton.styleFrom(foregroundColor: AppColors.textMuted),
          child: Text(context.tr('cancel')),
        ),
        const Spacer(),
        TextButton(
          onPressed: () => setState(() {
            if (allPicked) {
              _picked.removeAll(visible);
            } else {
              _picked.addAll(visible);
            }
          }),
          style: TextButton.styleFrom(foregroundColor: AppColors.deepSpace),
          child: Text(context.tr(allPicked ? 'deselectAll' : 'selectAll')),
        ),
        const SizedBox(width: 4),
        FilledButton(
          onPressed: _picked.isEmpty ? null : () => _confirmRemove(saved),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.phthalo,
            foregroundColor: Colors.white,
          ),
          child: Text('${context.tr('removeSelected')} (${_picked.length})'),
        ),
      ],
    );
  }

  Widget _viewChips(BuildContext context, SavedProgramsController saved) {
    Widget chip(_ProgramView v, String label) {
      final sel = _view == v;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: sel,
          showCheckmark: false,
          onSelected: (_) => setState(() {
            _view = v;
            _selecting = false;
            _picked.clear();
          }),
          selectedColor: AppColors.deepSpace,
          backgroundColor: Colors.white,
          side: BorderSide(
              color: sel ? AppColors.deepSpace : AppColors.lightGray),
          labelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            color: sel ? Colors.white : AppColors.phthalo,
          ),
        ),
      );
    }

    final n = saved.savedKeys.length;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          chip(_ProgramView.all, context.tr('allPrograms')),
          chip(_ProgramView.saved,
              '${context.tr('savedTab')}${n == 0 ? '' : ' ($n)'}'),
          chip(_ProgramView.recent, context.tr('recentTab')),
        ],
      ),
    );
  }

  List<Program> _filtered(List<Program> all, ProgramMatcher matcher) {
    return all.where((p) {
      if (_levels.isNotEmpty && !_levels.contains(levelGroupOf(p.level))) {
        return false;
      }
      if (_matchProfile && !matcher.matches(p)) return false;
      if (_query.isEmpty) return true;
      return [p.name, p.description, p.office, p.level]
          .any((text) => text.toLowerCase().contains(_query));
    }).toList();
  }

  Future<void> _openFilter() async {
    // Drafts live here so they survive sheet rebuilds; applied only on Apply.
    final draftLevels = <LevelGroup>{..._levels};
    var draftMatch = _matchProfile;

    final applied = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheet) => StatefulBuilder(
        builder: (ctx, setSheet) => SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            children: [
              Text(
                ctx.tr('filters'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.phthalo,
                ),
              ),
              const SizedBox(height: 4),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: draftMatch,
                onChanged: (v) => setSheet(() => draftMatch = v),
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.deepSpace,
                title: Text(
                  ctx.tr('matchMyProfile'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.phthalo,
                  ),
                ),
                subtitle: Text(
                  ctx.tr('matchMyProfileDesc'),
                  style: const TextStyle(
                      fontSize: 12.5, color: AppColors.textMuted),
                ),
              ),
              const Divider(height: 1, color: AppColors.lightGray),
              Theme(
                data: Theme.of(ctx).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: EdgeInsets.zero,
                  initiallyExpanded: draftLevels.isNotEmpty,
                  iconColor: AppColors.phthalo,
                  collapsedIconColor: AppColors.phthalo,
                  title: Text(
                    ctx.tr('filterByLevel'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.phthalo,
                    ),
                  ),
                  subtitle: draftLevels.isEmpty
                      ? null
                      : Text(
                    '${draftLevels.length} ${ctx.tr('selected')}',
                    style: const TextStyle(
                        fontSize: 12.5, color: AppColors.textMuted),
                  ),
                  children: [
                    for (final level in LevelGroup.values)
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: AppColors.deepSpace,
                        value: draftLevels.contains(level),
                        onChanged: (checked) => setSheet(() {
                          if (checked == true) {
                            draftLevels.add(level);
                          } else {
                            draftLevels.remove(level);
                          }
                        }),
                        title: Text(
                          ctx.tr(level.labelKey),
                          style: const TextStyle(color: AppColors.phthalo),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setSheet(() {
                        draftLevels.clear();
                        draftMatch = false;
                      }),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.deepSpace,
                        side: const BorderSide(color: AppColors.deepSpace),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: Text(ctx.tr('clearAll')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(sheet, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.phthalo,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: Text(ctx.tr('apply')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (applied != true || !mounted) return;
    setState(() {
      _levels
        ..clear()
        ..addAll(draftLevels);
      _matchProfile = draftMatch;
    });
  }

  List<Widget> _body(
      BuildContext context,
      ProgramsController c,
      List<Program> results,
      SavedProgramsController saved) {
    if (c.isLoading && c.programs.isEmpty) {
      return const [
        _ProgramTileSkeleton(),
        _ProgramTileSkeleton(),
        _ProgramTileSkeleton(),
        _ProgramTileSkeleton(),
        _ProgramTileSkeleton(),
      ];
    }
    if (c.hasError && c.programs.isEmpty) {
      return [
        _EmptyState(
          icon: Icons.cloud_off_rounded,
          message: context.tr(
            c.isOfflineError ? 'programsOffline' : 'programsLoadFailed',
          ),
          actionLabel: context.tr('retry'),
          onAction: c.load,
        ),
      ];
    }
    if (results.isEmpty) {
      return [
        _EmptyState(
          icon: Icons.search_off_rounded,
          message: c.programs.isEmpty
              ? context.tr('noPrograms')
              : (_view == _ProgramView.saved && saved.savedKeys.isEmpty)
              ? context.tr('noSaved')
              : (_view == _ProgramView.recent && saved.recentKeys.isEmpty)
              ? context.tr('noRecent')
              : context.tr('noResults'),
        ),
      ];
    }
    return [
      for (final p in results)
        _ProgramTile(
          program: p,
          saved: saved.isSaved(p),
          onToggleSave: () => _toggleSave(p, saved),
          selectMode: _selecting && _view == _ProgramView.recent,
          selected: _picked.contains(programKey(p)),
          onTap: (_selecting && _view == _ProgramView.recent)
              ? () => _togglePick(p)
              : () => Navigator.of(context).push(
            MaterialPageRoute(
                builder: (_) => ProgramDetailScreen(program: p)),
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final c = ProgramsScope.of(context);
    final matcher = ProgramMatcher(ProfileScope.of(context).profile);
    final saved = SavedProgramsScope.of(context);
    final results = _filtered(_baseList(c.programs, saved), matcher);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: c.load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                controller: _search,
                hint: context.tr('searchHint'),
                onChanged: (v) =>
                    setState(() => _query = v.trim().toLowerCase()),
                onFilterTap: _openFilter,
              ),
              const SizedBox(height: 12),
              _viewChips(context, saved),
              if (_view == _ProgramView.recent && saved.recentKeys.isNotEmpty)
                _selectionBar(context, saved, results),
              if (_matchProfile)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    context.tr('profileIncompleteHint'),
                    style: const TextStyle(
                        fontSize: 12.5, color: AppColors.textMuted),
                  ),
                ),
              const SizedBox(height: 20),
              ..._body(context, c, results, saved),
            ],
          ),
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
    required this.onFilterTap,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;

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
              child:
              const Icon(Icons.tune_rounded, size: 20, color: Colors.white),
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
  const _ProgramTile({
    required this.program,
    required this.onTap,
    required this.saved,
    required this.onToggleSave,
    this.selectMode = false,
    this.selected = false,
  });
  final Program program;
  final VoidCallback onTap;
  final bool saved;
  final VoidCallback onToggleSave;
  final bool selectMode;
  final bool selected;

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
                      LevelChip(program.level),
                      const SizedBox(height: 8),
                      Text(
                        program.name,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                          color: AppColors.phthalo,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 1),
                            child: Icon(Icons.apartment_rounded,
                                size: 15, color: AppColors.deepSpace),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              program.office,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12.5,
                                height: 1.3,
                                color: AppColors.deepSpace,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (selectMode)
                  Checkbox(
                    value: selected,
                    onChanged: (_) => onTap(),
                    activeColor: AppColors.deepSpace,
                  )
                else ...[
                  IconButton(
                    onPressed: onToggleSave,
                    tooltip: context.tr(saved ? 'removeSaved' : 'saveProgram'),
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      saved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: saved ? AppColors.mustard : AppColors.textMuted,
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.phthalo),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Placeholder shown while programs load. Same shape as [_ProgramTile].
class _ProgramTileSkeleton extends StatelessWidget {
  const _ProgramTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.lightGray),
        ),
        child: const SkeletonShimmer(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 120, height: 22, radius: 11),
                    SizedBox(height: 12),
                    SkeletonBox(height: 16),
                    SizedBox(height: 8),
                    FractionallySizedBox(
                      widthFactor: 0.7,
                      child: SkeletonBox(height: 16),
                    ),
                    SizedBox(height: 12),
                    FractionallySizedBox(
                      widthFactor: 0.5,
                      child: SkeletonBox(height: 12),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              SkeletonBox(width: 20, height: 20, radius: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.deepSpace),
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
          if (actionLabel != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: onAction,
              style:
              TextButton.styleFrom(foregroundColor: AppColors.deepSpace),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

/// Small label showing a program's governance level.
class LevelChip extends StatelessWidget {
  const LevelChip(this.label, {super.key});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.moonstone.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.phthalo,
        ),
      ),
    );
  }
}