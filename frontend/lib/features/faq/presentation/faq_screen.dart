import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/language_toggle.dart';
import '../domain/faq_content.dart';

/// Frequently asked questions, with a search box and a "Terms explained"
/// section. Used as the Ask GABAY tab, and (with [standalone]) as a page you
/// open from Profile.
class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key, this.standalone = false});

  /// true: shows a back arrow (opened from Profile). false: the tab version.
  final bool standalone;

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final _search = TextEditingController();
  String _query = '';

  /// 0 = FAQ, 1 = Terms explained.
  int _tab = 0;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTl = context.language.language == AppLanguage.tl;
    String pick(String en, String tl) => isTl ? tl : en;
    final showingTerms = _tab == 1;

    // Keep only the entries that match the search, in the chosen tab.
    final visible = <({FaqSection section, List<FaqItem> items})>[];
    for (final section in showingTerms ? termSections : faqSections) {
      final items = section.items.where((item) {
        if (_query.isEmpty) return true;
        final text = '${pick(item.questionEn, item.questionTl)} '
            '${pick(item.answerEn, item.answerTl)}'
            .toLowerCase();
        return text.contains(_query);
      }).toList();
      if (items.isNotEmpty) visible.add((section: section, items: items));
    }

    final body = ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        if (!widget.standalone) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  context.tr('askGabay'),
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
          const SizedBox(height: 6),
        ],
        Text(
          showingTerms
              ? pick(
            'Plain meanings of the words you will see in the programs.',
            'Simpleng paliwanag sa mga salitang makikita mo sa mga programa.',
          )
              : pick(
            'Common questions about GABAY and its programs.',
            'Mga karaniwang tanong tungkol sa GABAY at sa mga programa.',
          ),
          style: const TextStyle(
              fontSize: 15, height: 1.4, color: AppColors.textMuted),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<int>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: 0,
                icon: const Icon(Icons.help_outline_rounded, size: 18),
                label: const Text('FAQ'),
              ),
              ButtonSegment(
                value: 1,
                icon: const Icon(Icons.menu_book_outlined, size: 18),
                label: Text(pick('Terms', 'Mga Termino')),
              ),
            ],
            selected: {_tab},
            onSelectionChanged: (s) => setState(() => _tab = s.first),
            style: SegmentedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.phthalo,
              selectedBackgroundColor: AppColors.deepSpace,
              selectedForegroundColor: Colors.white,
              side: const BorderSide(color: AppColors.lightGray),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _SearchBox(
          controller: _search,
          hint: showingTerms
              ? pick('Search terms', 'Maghanap ng termino')
              : pick('Search questions', 'Maghanap ng tanong'),
          onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
        ),
        const SizedBox(height: 8),
        if (visible.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Text(
              showingTerms
                  ? pick('No terms match your search.',
                  'Walang terminong tumutugma sa hinahanap mo.')
                  : pick('No questions match your search.',
                  'Walang tanong na tumutugma sa hinahanap mo.'),
              style: const TextStyle(color: AppColors.textMuted),
            ),
          )
        else
          for (final entry in visible)
            _SectionGroup(
              // New key when searching or switching tabs so groups reset.
              key: ValueKey(
                  'group-$_tab-${entry.section.titleEn}-${_query.isNotEmpty}-$isTl'),
              icon: entry.section.icon,
              title: pick(entry.section.titleEn, entry.section.titleTl),
              // Closed by default; opened while searching so matches show.
              expanded: _query.isNotEmpty,
              children: [
                for (var i = 0; i < entry.items.length; i++)
                  _FaqTile(
                    key: ValueKey(
                        '$_tab-${entry.section.titleEn}-$i-${_query.isNotEmpty}-$isTl'),
                    question: pick(
                        entry.items[i].questionEn, entry.items[i].questionTl),
                    answer: pick(
                        entry.items[i].answerEn, entry.items[i].answerTl),
                    expanded: _query.isNotEmpty,
                  ),
              ],
            ),
      ],
    );

    if (!widget.standalone) {
      return Scaffold(body: SafeArea(child: body));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(pick('Help & FAQ', 'Tulong at FAQ')),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.phthalo,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(child: LanguageToggle()),
          ),
        ],
      ),
      body: SafeArea(child: body),
    );
  }
}

/// A button that opens the FAQ page. Drop it into the Profile screen.
class FaqLinkButton extends StatelessWidget {
  const FaqLinkButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isTl = context.language.language == AppLanguage.tl;
    return OutlinedButton.icon(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const FaqScreen(standalone: true)),
      ),
      icon: const Icon(Icons.help_outline_rounded, size: 20),
      label: Text(isTl ? 'Tulong at FAQ' : 'Help & FAQ'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.deepSpace,
        side: const BorderSide(color: AppColors.lightGray),
        backgroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

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
        enabledBorder: border(AppColors.lightGray),
        border: border(AppColors.lightGray),
        focusedBorder: border(AppColors.deepSpace),
      ),
    );
  }
}

/// A category that opens and closes. Holds the questions of one section.
class _SectionGroup extends StatelessWidget {
  const _SectionGroup({
    super.key,
    required this.icon,
    required this.title,
    required this.expanded,
    required this.children,
  });

  final IconData icon;
  final String title;
  final bool expanded;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: expanded,
          shape: const Border(),
          collapsedShape: const Border(),
          iconColor: AppColors.deepSpace,
          collapsedIconColor: AppColors.deepSpace,
          tilePadding: const EdgeInsets.symmetric(horizontal: 4),
          childrenPadding: const EdgeInsets.only(top: 6),
          title: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.moonstone.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: AppColors.deepSpace),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.phthalo,
                  ),
                ),
              ),
            ],
          ),
          children: children,
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({
    super.key,
    required this.question,
    required this.answer,
    required this.expanded,
  });

  final String question;
  final String answer;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: expanded,
          shape: const Border(),
          collapsedShape: const Border(),
          iconColor: AppColors.deepSpace,
          collapsedIconColor: AppColors.deepSpace,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedAlignment: Alignment.centerLeft,
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.phthalo,
            ),
          ),
          children: [
            Text(
              answer,
              style: const TextStyle(
                  fontSize: 14, height: 1.5, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}