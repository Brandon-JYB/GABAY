import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/language_toggle.dart';

// Lightweight view models. Move these to features/home/domain once the
// data layer exists, and map your API/Firebase results into them.
class ProgramSummary {
  const ProgramSummary({
    required this.title,
    required this.description,
    this.category,
  });

  final String title;
  final String description;
  final String? category;
}

class UpdateSummary {
  const UpdateSummary({
    required this.title,
    required this.description,
    required this.date,
    this.programName,
  });

  final String title;
  final String description;
  final DateTime date;
  final String? programName;
}

/// The dashboard. It renders whatever it is given, and shows an empty state
/// when a list is empty, so nothing here is dummy data.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.userName,
    this.recommended = const [],
    this.updates = const [],
    this.onProfileTap,
    this.onFindPrograms,
    this.onCheckEligibility,
    this.onAskGabay,
    this.onViewAllPrograms,
    this.onViewAllUpdates,
    this.onProgramTap,
    this.onUpdateTap,
    this.onExploreMap,
  });

  final String? userName;
  final List<ProgramSummary> recommended;
  final List<UpdateSummary> updates;

  final VoidCallback? onProfileTap;
  final VoidCallback? onFindPrograms;
  final VoidCallback? onCheckEligibility;
  final VoidCallback? onAskGabay;
  final VoidCallback? onViewAllPrograms;
  final VoidCallback? onViewAllUpdates;
  final ValueChanged<ProgramSummary>? onProgramTap;
  final ValueChanged<UpdateSummary>? onUpdateTap;
  final VoidCallback? onExploreMap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.center,
            colors: [
              AppColors.moonstone.withValues(alpha: 0.28),
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              _Header(onProfileTap: onProfileTap),
              const SizedBox(height: 28),
              _Greeting(userName: userName),
              const SizedBox(height: 28),
              _SectionTitle(context.tr('quickActions')),
              const SizedBox(height: 12),
              _QuickActions(
                onFindPrograms: onFindPrograms,
                onCheckEligibility: onCheckEligibility,
                onAskGabay: onAskGabay,
              ),
              const SizedBox(height: 28),
              _SectionTitle(context.tr('recommended'), onViewAll: onViewAllPrograms),
              const SizedBox(height: 12),
              if (recommended.isEmpty)
                _EmptyCard(
                  icon: Icons.favorite_border_rounded,
                  message:
                  context.tr('noRecommended'),
                )
              else
                for (final p in recommended)
                  _ProgramCard(program: p, onTap: () => onProgramTap?.call(p)),
              const SizedBox(height: 28),
              _SectionTitle(context.tr('latestUpdates'), onViewAll: onViewAllUpdates),
              const SizedBox(height: 12),
              if (updates.isEmpty)
                _EmptyCard(
                  icon: Icons.campaign_outlined,
                  message: context.tr('noUpdates'),
                )
              else
                for (final u in updates)
                  _UpdateCard(update: u, onTap: () => onUpdateTap?.call(u)),
              const SizedBox(height: 20),
              _NearbyOfficesBanner(onExplore: onExploreMap),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header, greeting, search
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({this.onProfileTap});
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          AppAssets.logo,
          height: 44,
          errorBuilder: (_, __, ___) => const Text(
            'GABAY',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: AppColors.phthalo,
            ),
          ),
        ),
        const Spacer(),
        const LanguageToggle(),
        const SizedBox(width: 10),
        InkWell(
          onTap: onProfileTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.lightGray),
            ),
            child: const Icon(Icons.person_outline_rounded,
                color: AppColors.phthalo),
          ),
        ),
      ],
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({this.userName});
  final String? userName;

  String _salutation(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) return context.tr('goodMorning');
    if (hour < 18) return context.tr('goodAfternoon');
    return context.tr('goodEvening');
  }

  @override
  Widget build(BuildContext context) {
    final name = (userName == null || userName!.trim().isEmpty)
        ? context.tr('welcome')
        : '${userName!.trim()}!';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _salutation(context),
          style: const TextStyle(fontSize: 18, color: AppColors.textMuted),
        ),
        Text(
          name,
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 44,
            height: 1.1,
            fontWeight: FontWeight.w800,
            color: AppColors.phthalo,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.tr('tagline'),
          style: TextStyle(fontSize: 16, height: 1.4, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Sections
// ---------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {this.onViewAll});
  final String title;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.phthalo,
            ),
          ),
        ),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            style: TextButton.styleFrom(foregroundColor: AppColors.deepSpace),
            child: Text(context.tr('viewAll'),
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    this.onFindPrograms,
    this.onCheckEligibility,
    this.onAskGabay,
  });

  final VoidCallback? onFindPrograms;
  final VoidCallback? onCheckEligibility;
  final VoidCallback? onAskGabay;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _ActionTile(
              icon: Icons.search_rounded,
              tint: AppColors.mustard,
              iconColor: AppColors.mustard,
              title: context.tr('findPrograms'),
              subtitle: context.tr('findProgramsDesc'),
              onTap: onFindPrograms,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ActionTile(
              icon: Icons.fact_check_outlined,
              tint: AppColors.deepSpace,
              iconColor: AppColors.deepSpace,
              title: context.tr('checkEligibility'),
              subtitle: context.tr('checkEligibilityDesc'),
              onTap: onCheckEligibility,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ActionTile(
              icon: Icons.auto_awesome_outlined,
              tint: AppColors.moonstone,
              iconColor: AppColors.deepSpace,
              title: context.tr('askGabay'),
              subtitle: context.tr('askGabayDesc'),
              onTap: onAskGabay,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.tint,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final Color tint;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.lightGray),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 22, color: iconColor),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.phthalo,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.3,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({required this.program, this.onTap});
  final ProgramSummary program;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.moonstone.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite_border_rounded,
                      color: AppColors.deepSpace),
                ),
                const SizedBox(width: 14),
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
                        maxLines: 2,
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

class _UpdateCard extends StatelessWidget {
  const _UpdateCard({required this.update, this.onTap});
  final UpdateSummary update;
  final VoidCallback? onTap;

  String _date(BuildContext context) {
    final months = context.tr('months').split(',');
    return '${months[update.date.month - 1]} ${update.date.day}, ${update.date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final meta = update.programName == null
        ? _date(context)
        : '${update.programName} • ${_date(context)}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.lightGray),
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.deepSpace,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.campaign_outlined,
                      size: 32, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        update.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.phthalo,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        meta,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.deepSpace,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        update.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          color: AppColors.textMuted,
                        ),
                      ),
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

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.icon, required this.message});
  final IconData icon;
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
    );
  }
}

class _NearbyOfficesBanner extends StatelessWidget {
  const _NearbyOfficesBanner({this.onExplore});
  final VoidCallback? onExplore;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.deepSpace, AppColors.moonstone],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -14,
            bottom: -18,
            child: Icon(
              Icons.map_outlined,
              size: 130,
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('nearbyTitle'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 230,
                  child: Text(
                    context.tr('nearbyBody'),
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.35,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: onExplore,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.phthalo,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.location_on_outlined, size: 18),
                  label: Text(context.tr('openMap')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}