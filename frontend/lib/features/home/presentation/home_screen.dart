import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/language_toggle.dart';
import '../../faq/presentation/faq_screen.dart';
import '../../profile/domain/user_profile.dart';
import '../../profile/state/profile_controller.dart';

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
    this.onSpotlightTap,
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

  /// Called with the card id: 'free', 'scam', 'privacy' or 'apply'.
  final ValueChanged<String>? onSpotlightTap;

  @override
  Widget build(BuildContext context) {
    final profileCtrl = ProfileScope.of(context);
    final setup = profileCtrl.profile.setupProgress;
    final showSetup = !profileCtrl.isLoading && !setup.isComplete;

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
              if (showSetup) ...[
                _SetupProgressCard(
                  completed: setup.completed,
                  total: SetupProgress.total,
                  nextStep: _setupStepLabel(context, setup.next),
                  onTap: onProfileTap,
                ),
                const SizedBox(height: 24),
              ],
              _SectionTitle(_t(context, 'spotlight', 'Spotlight')),
              const SizedBox(height: 12),
              _SpotlightStack(onTap: onSpotlightTap),
              const SizedBox(height: 28),
              _SectionTitle(context.tr('quickActions')),
              const SizedBox(height: 12),
              _QuickActions(
                onCheckEligibility: onCheckEligibility,
                onAskGabay: onAskGabay,
              ),
              const SizedBox(height: 28),
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                AppAssets.logo,
                height: 52,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
              const SizedBox(width: 10),
              const Flexible(
                child: Text(
                  'GABAY',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 17,
                    height: 1.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    color: AppColors.deepSpace,
                  ),
                ),
              ),
            ],
          ),
        ),
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
    this.onCheckEligibility,
    this.onAskGabay,
  });

  final VoidCallback? onCheckEligibility;
  final VoidCallback? onAskGabay;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _ActionTile(
                  icon: Icons.help_outline_rounded,
                  tint: AppColors.mustard,
                  iconColor: AppColors.mustard,
                  title: _t(context, 'faq', 'FAQ'),
                  subtitle: _t(context, 'faqDesc',
                      'Answers to common questions'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const FaqScreen(standalone: true)),
                  ),
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
            ],
          ),
        ),
        const SizedBox(height: 10),
        _ActionTile(
          horizontal: true,
          icon: Icons.auto_awesome_outlined,
          tint: AppColors.moonstone,
          iconColor: AppColors.deepSpace,
          title: context.tr('askGabay'),
          subtitle: context.tr('askGabayDesc'),
          onTap: onAskGabay,
        ),
      ],
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
    this.horizontal = false,
  });

  final bool horizontal;
  final IconData icon;
  final Color tint;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final iconBadge = Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.22),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 22, color: iconColor),
    );
    final texts = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
    );

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
          child: horizontal
              ? Row(
            children: [
              iconBadge,
              const SizedBox(width: 14),
              Expanded(child: texts),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textMuted),
            ],
          )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [iconBadge, const SizedBox(height: 10), texts],
          ),
        ),
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

// ---------------------------------------------------------------------------
// Spotlight: looping, swipeable card stack
// ---------------------------------------------------------------------------

/// Looks up [key] in app strings; falls back to [fallback] (English) if the
/// key has not been added to app_strings.dart yet.
String _t(BuildContext context, String key, String fallback) {
  try {
    final v = context.tr(key);
    if (v.isNotEmpty && v != key) return v;
  } catch (_) {}
  return fallback;
}

class _Txt {
  const _Txt(this.key, this.fallback);
  final String key;
  final String fallback;
  String of(BuildContext c) => _t(c, key, fallback);
}

class _SpotlightItem {
  const _SpotlightItem({
    required this.id,
    required this.color,
    required this.fg,
    required this.icon,
    required this.badge,
    required this.title,
    this.body,
    this.chips,
  });

  final String id;
  final Color color;
  final Color fg;
  final IconData icon;
  final _Txt badge;
  final _Txt title;
  final _Txt? body;
  final List<_Txt>? chips;
}

const _spotlightItems = <_SpotlightItem>[
  _SpotlightItem(
    id: 'free',
    color: AppColors.mustard,
    fg: Colors.white,
    icon: Icons.verified_user_outlined,
    badge: _Txt('spotlightFreeBadge', 'Good to know'),
    title: _Txt('spotlightFreeTitle', 'Applying is free'),
    body: _Txt('spotlightFreeBody', 'Report anyone asking for payment.'),
  ),
  _SpotlightItem(
    id: 'scam',
    color: AppColors.phthalo,
    fg: Colors.white,
    icon: Icons.warning_amber_rounded,
    badge: _Txt('spotlightScamBadge', 'Scam alert'),
    title: _Txt('spotlightScamTitle', 'Beware of fake assistance texts'),
    body: _Txt('spotlightScamBody',
        'Check the sender first. Verify real offices before you act.'),
  ),
  _SpotlightItem(
    id: 'privacy',
    color: AppColors.deepSpace,
    fg: Colors.white,
    icon: Icons.lock_outline_rounded,
    badge: _Txt('spotlightPrivacyBadge', 'Your privacy'),
    title: _Txt('spotlightPrivacyTitle', 'Your data stays private'),
    body: _Txt('spotlightPrivacyBody',
        'Your personal information is kept private.'),
  ),
  _SpotlightItem(
    id: 'apply',
    color: AppColors.moonstone,
    fg: AppColors.phthalo,
    icon: Icons.stairs_outlined,
    badge: _Txt('spotlightApplyBadge', 'How to apply'),
    title: _Txt('spotlightApplyTitle', 'Apply in 3 steps'),
    chips: [
      _Txt('spotlightStep1', 'Bring your requirements'),
      _Txt('spotlightStep2', 'Visit the office'),
      _Txt('spotlightStep3', 'Submit your application'),
    ],
  ),
];

class _SpotlightStack extends StatefulWidget {
  const _SpotlightStack({this.onTap});
  final ValueChanged<String>? onTap;

  @override
  State<_SpotlightStack> createState() => _SpotlightStackState();
}

class _SpotlightStackState extends State<_SpotlightStack>
    with SingleTickerProviderStateMixin {
  static const double _cardH = 188;

  late final AnimationController _ctrl;
  int _index = 0;
  double _dx = 0;
  double _from = 0;
  double _to = 0;
  double _w = 360;
  VoidCallback? _onDone;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    )
      ..addListener(() {
        setState(() {
          _dx = _from + (_to - _from) * Curves.easeOut.transform(_ctrl.value);
        });
      })
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed && _onDone != null) {
          final cb = _onDone!;
          _onDone = null;
          cb();
        }
      });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _animateTo(double to, {VoidCallback? onDone}) {
    _from = _dx;
    _to = to;
    _onDone = onDone;
    _ctrl.forward(from: 0);
  }

  void _flyOut(double direction) {
    _animateTo(direction * _w * 1.2, onDone: () {
      setState(() {
        _index = (_index + 1) % _spotlightItems.length;
        _dx = 0;
      });
    });
  }

  void _onDragEnd(DragEndDetails d) {
    final v = d.primaryVelocity ?? 0;
    if (_dx.abs() > _w * 0.3 || v.abs() > 700) {
      _flyOut(_dx != 0 ? _dx.sign : -v.sign);
    } else {
      _animateTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = _spotlightItems.length;

    return Column(
      children: [
        LayoutBuilder(builder: (context, c) {
          _w = c.maxWidth;
          final p = (_dx.abs() / _w).clamp(0.0, 1.0);

          Widget layer(int depth) {
            final item = _spotlightItems[(_index + depth) % n];
            if (depth == 0) {
              return Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: _cardH,
                child: Transform.translate(
                  offset: Offset(_dx, 0),
                  child: Transform.rotate(
                    angle: _dx / _w * 0.1,
                    child: _SpotlightCard(
                      item: item,
                      onTap: () => widget.onTap?.call(item.id),
                    ),
                  ),
                ),
              );
            }
            final d = depth - p;
            return Positioned(
              left: 14 * d,
              right: 14 * d,
              top: 16 * d,
              height: _cardH,
              child: IgnorePointer(child: _SpotlightCard(item: item)),
            );
          }

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: (_) {
              _ctrl.stop();
              _onDone = null;
            },
            onHorizontalDragUpdate: (d) => setState(() => _dx += d.delta.dx),
            onHorizontalDragEnd: _onDragEnd,
            onHorizontalDragCancel: () => _animateTo(0),
            child: SizedBox(
              height: _cardH + 32,
              child: Stack(
                clipBehavior: Clip.none,
                children: [layer(2), layer(1), layer(0)],
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < n; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _index ? 22 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _index
                      ? AppColors.deepSpace
                      : AppColors.lightGray,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _SpotlightCard extends StatelessWidget {
  const _SpotlightCard({required this.item, this.onTap});
  final _SpotlightItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fg = item.fg;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: item.color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.phthalo.withValues(alpha: 0.22),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (item.chips == null)
              Positioned(
                right: -22,
                bottom: -26,
                child: Icon(item.icon, size: 130, color: fg.withValues(alpha: 0.16)),
              ),
            Positioned.fill(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: fg.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      item.badge.of(context),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: fg,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 260),
                    child: Text(
                      item.title.of(context),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 20,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        color: fg,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (item.body != null)
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 230),
                      child: Text(
                        item.body!.of(context),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, height: 1.3, color: fg),
                      ),
                    ),
                  if (item.chips != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var i = 0; i < item.chips!.length; i++)
                            Padding(
                              padding: EdgeInsets.only(top: i == 0 ? 0 : 6),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                      color: AppColors.phthalo,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '${i + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      item.chips![i].of(context),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: fg,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ---------------------------------------------------------------------------
// Account setup progress
// ---------------------------------------------------------------------------

String? _setupStepLabel(BuildContext context, SetupStep? step) {
  switch (step) {
    case SetupStep.personal:
      return context.tr('setupStepPersonal');
    case SetupStep.address:
      return context.tr('setupStepAddress');
    case SetupStep.assistance:
      return context.tr('setupStepAssistance');
    case null:
      return null;
  }
}

class _SetupProgressCard extends StatelessWidget {
  const _SetupProgressCard({
    required this.completed,
    required this.total,
    this.nextStep,
    this.onTap,
  });

  final int completed;
  final int total;
  final String? nextStep;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final value = (completed / total).clamp(0.0, 1.0);
    final count = '$completed ${context.tr('setupOf')} $total';

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.lightGray),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.tr('setupTitle'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.phthalo,
                      ),
                    ),
                  ),
                  Text(
                    count,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mustard,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 22,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 8,
                    color: AppColors.mustard,
                    backgroundColor:
                    AppColors.lightGray.withValues(alpha: 0.6),
                    semanticsLabel: context.tr('setupTitle'),
                    semanticsValue: count,
                  ),
                ),
              ),
              if (nextStep != null) ...[
                const SizedBox(height: 8),
                Text(
                  '${context.tr('setupNext')} $nextStep',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}