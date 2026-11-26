import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';
import 'language_toggle.dart';

/// Quick "how to get around" guide shown once to each new user.
class AppTutorial {
  AppTutorial._();

  static String get _key {
    final uid = Supabase.instance.client.auth.currentUser?.id ?? 'guest';
    return 'tutorial_seen_$uid';
  }

  /// Shows the guide only if this user has not seen it on this device.
  static Future<void> showIfFirstTime(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_key) ?? false) return;
    if (!context.mounted) return;
    await show(context);
    await prefs.setBool(_key, true);
  }

  /// Opens the guide on demand (e.g. from a "How to use GABAY" button).
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _TutorialDialog(),
    );
  }
}

enum _Preview { language, programsTab, profile, askTab }

class _Slide {
  const _Slide(this.titleKey, this.bodyKey, this.preview);
  final String titleKey;
  final String bodyKey;
  final _Preview preview;
}

const _slides = <_Slide>[
  _Slide('tutorial1Title', 'tutorial1Body', _Preview.language),
  _Slide('tutorial2Title', 'tutorial2Body', _Preview.programsTab),
  _Slide('tutorial3Title', 'tutorial3Body', _Preview.profile),
  _Slide('tutorial4Title', 'tutorial4Body', _Preview.askTab),
];

class _TutorialDialog extends StatefulWidget {
  const _TutorialDialog();

  @override
  State<_TutorialDialog> createState() => _TutorialDialogState();
}

class _TutorialDialogState extends State<_TutorialDialog> {
  final _pages = PageController();
  int _page = 0;

  bool get _isLast => _page == _slides.length - 1;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _next() {
    if (_isLast) {
      Navigator.of(context).pop();
    } else {
      _pages.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Lets a new user pick English or Tagalog right here, since the
            // toggle on Home is hidden behind this dialog.
            const Align(
              alignment: Alignment.centerRight,
              child: LanguageToggle(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 360,
              child: PageView.builder(
                controller: _pages,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => _SlidePage(slide: _slides[i]),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _slides.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _page ? 22 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _page
                          ? AppColors.deepSpace
                          : AppColors.lightGray,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Visibility(
                  visible: !_isLast,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textMuted,
                    ),
                    child: Text(context.tr('tutorialSkip')),
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _next,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.phthalo,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 46),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    textStyle: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  child: Text(
                    context.tr(_isLast ? 'tutorialStart' : 'tutorialNext'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SlidePage extends StatelessWidget {
  const _SlidePage({required this.slide});
  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.moonstone.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(20),
            ),
            child: _PreviewFor(slide.preview),
          ),
          const SizedBox(height: 20),
          Text(
            context.tr(slide.titleKey),
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 22,
              height: 1.2,
              fontWeight: FontWeight.w800,
              color: AppColors.phthalo,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr(slide.bodyKey),
            style: const TextStyle(
              fontSize: 14.5,
              height: 1.45,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small drawings of the real header / bottom bar, with a ring around the
/// part the slide is talking about.
class _PreviewFor extends StatelessWidget {
  const _PreviewFor(this.kind);
  final _Preview kind;

  @override
  Widget build(BuildContext context) {
    switch (kind) {
      case _Preview.language:
        return const _HeaderPreview(highlightLanguage: true);
      case _Preview.profile:
        return const _HeaderPreview(highlightProfile: true);
      case _Preview.programsTab:
        return const _NavPreview(selected: 1);
      case _Preview.askTab:
        return const _NavPreview(selected: 2);
    }
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.on, required this.child, this.circle = false});
  final bool on;
  final bool circle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(26),
        border: Border.all(
          color: on ? AppColors.mustard : Colors.transparent,
          width: 2.5,
        ),
      ),
      child: child,
    );
  }
}

class _HeaderPreview extends StatelessWidget {
  const _HeaderPreview({
    this.highlightLanguage = false,
    this.highlightProfile = false,
  });
  final bool highlightLanguage;
  final bool highlightProfile;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Ring(
          on: highlightLanguage,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.deepSpace,
                    shape: BoxShape.circle,
                  ),
                  child: const Text('EN',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 10),
                const Text('TL',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.phthalo)),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        _Ring(
          on: highlightProfile,
          circle: true,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.lightGray),
            ),
            child: const Icon(Icons.person_outline_rounded,
                size: 22, color: AppColors.phthalo),
          ),
        ),
      ],
    );
  }
}

class _NavPreview extends StatelessWidget {
  const _NavPreview({required this.selected});
  final int selected;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_outlined, context.tr('navHome')),
      (Icons.description_outlined, context.tr('navPrograms')),
      (Icons.auto_awesome_outlined, context.tr('navAsk')),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < items.length; i++)
            _Ring(
              on: i == selected,
              child: SizedBox(
                width: 76,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(items[i].$1,
                        size: 22,
                        color: i == selected
                            ? AppColors.deepSpace
                            : AppColors.textMuted),
                    const SizedBox(height: 2),
                    Text(
                      items[i].$2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight:
                        i == selected ? FontWeight.w700 : FontWeight.w500,
                        color: i == selected
                            ? AppColors.deepSpace
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}