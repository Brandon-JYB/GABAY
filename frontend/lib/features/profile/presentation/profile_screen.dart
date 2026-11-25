import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/city_barangays.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/validators.dart';
import '../../auth/state/auth_scope.dart';
import '../domain/user_profile.dart';
import '../state/profile_controller.dart';

/// Opens from the button at the top right of Home. Loads the saved profile,
/// saves to Supabase, and handles logout.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profiles = ProfileScope.of(context);
    final auth = AuthScope.of(context);

    if (profiles.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('profile'))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return ProfileForm(
      initial: profiles.profile,
      onSave: profiles.save,
      onLogout: () async {
        final navigator = Navigator.of(context);
        await auth.logout();
        profiles.clear();
        navigator.pushNamedAndRemoveUntil('/login', (_) => false);
      },
    );
  }
}

/// The form itself. Pass [initial] to prefill it, [onSave] to store the result.
class ProfileForm extends StatefulWidget {
  const ProfileForm({
    super.key,
    this.initial = const UserProfile(),
    this.onSave,
    this.onLogout,
  });

  final UserProfile initial;
  final Future<void> Function(UserProfile profile)? onSave;
  final Future<void> Function()? onLogout;

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  static const List<String> _genderOptions = ['Male', 'Female'];
  static const String _cityValue = 'Batangas City';
  static const String _provinceValue = 'Batangas';

  /// Matches a saved gender to the dropdown options, ignoring letter case.
  static String? _matchGender(String? g) {
    if (g == null) return null;
    for (final o in _genderOptions) {
      if (o.toLowerCase() == g.trim().toLowerCase()) return o;
    }
    return null;
  }

  final _formKey = GlobalKey<FormState>();

  late final _name = TextEditingController(text: widget.initial.name);
  late final _sitio = TextEditingController(text: widget.initial.sitio);
  late final _barangay = TextEditingController(text: widget.initial.barangay);
  late final _city = TextEditingController(
      text: widget.initial.city.isEmpty ? _cityValue : widget.initial.city);
  late final _province = TextEditingController(
      text: widget.initial.province.isEmpty
          ? _provinceValue
          : widget.initial.province);

  late DateTime? _birthday = widget.initial.birthday;
  late final _birthdayCtrl = TextEditingController(
      text: widget.initial.birthday == null
          ? ''
          : _formatDate(widget.initial.birthday!));
  late String? _gender = _matchGender(widget.initial.gender);
  late String? _civil = widget.initial.civilStatus;
  // Not shown on screen anymore; kept so saving doesn't erase the stored value.
  late final bool? _philhealth = widget.initial.isPhilhealth;
  late bool? _pwd = widget.initial.isPwd;

  /// What was last saved. Anything different from this counts as unsaved.
  late UserProfile _saved = _current;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_name, _sitio, _barangay, _city, _province, _birthdayCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  UserProfile get _current => UserProfile(
    name: _name.text.trim(),
    birthday: _birthday,
    gender: _gender,
    civilStatus: _civil,
    sitio: _sitio.text.trim(),
    barangay: BatangasCityBarangays.normalizeBarangay(_barangay.text.trim()),
    city: _city.text.trim(),
    province: _province.text.trim(),
    isPhilhealth: _philhealth,
    isPwd: _pwd ?? false,
  );

  bool get _isDirty => !_current.isSameAs(_saved);

  Future<bool> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          dialogContext.tr('discardTitle'),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.phthalo,
          ),
        ),
        content: Text(
          dialogContext.tr('discardBody'),
          style: const TextStyle(color: AppColors.textMuted, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            style: TextButton.styleFrom(foregroundColor: AppColors.deepSpace),
            child: Text(dialogContext.tr('keepEditing')),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: Text(dialogContext.tr('discard')),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  Future<bool> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          dialogContext.tr('logoutConfirmTitle'),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.phthalo,
          ),
        ),
        content: Text(
          _isDirty
              ? dialogContext.tr('discardBody')
              : dialogContext.tr('logoutConfirmBody'),
          style: const TextStyle(color: AppColors.textMuted, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            style: TextButton.styleFrom(foregroundColor: AppColors.deepSpace),
            child: Text(dialogContext.tr('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: Text(dialogContext.tr('logout')),
          ),
        ],
      ),
    );
    return confirm ?? false;
  }
  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? context.tr('required') : null;

  String _formatDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  /// Calendar with month and year dropdowns, so both can be picked directly.
  Future<void> _pickBirthday() async {
    const english = [
      'January', 'February', 'March', 'April', 'May', 'June', 'July',
      'August', 'September', 'October', 'November', 'December',
    ];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var initial = _birthday ?? DateTime(now.year - 30, now.month, now.day);
    if (initial.isAfter(today)) initial = today;

    var months = context.tr('months').split(',').map((m) => m.trim()).toList();
    if (months.length != 12) months = english;

    final picked = await showDialog<DateTime>(
      context: context,
      builder: (_) => _BirthdayDialog(
        initial: initial,
        today: today,
        months: months,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _birthday = picked;
      _birthdayCtrl.text = _formatDate(picked);
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final onSave = widget.onSave;
    if (onSave == null) return;

    final messenger = ScaffoldMessenger.of(context);
    final savedText = context.tr('profileSaved');
    final failedText = context.tr('saveFailed');
    final profile = _current;

    setState(() => _saving = true);
    try {
      await onSave(profile);
      if (!mounted) return;
      setState(() => _saved = profile);
      messenger.showSnackBar(SnackBar(content: Text(savedText)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(failedText)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _logout() async {
    final onLogout = widget.onLogout;
    if (onLogout == null) return;
    if (!await _confirmLogout()) return;
    if (!mounted) return;
    await onLogout();
  }

  InputDecoration _decoration(String label,
      {IconData? icon, String? hint, Widget? suffix}) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color),
    );
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      enabledBorder: border(AppColors.lightGray),
      border: border(AppColors.lightGray),
      focusedBorder: border(AppColors.deepSpace),
    );
  }

  Widget _textField(String label, TextEditingController controller,
      {bool required = true, TextCapitalization caps = TextCapitalization.words}) {
    return TextFormField(
      controller: controller,
      textCapitalization: caps,
      decoration: _decoration(label),
      validator: required ? _required : null,
    );
  }

  /// Same look as the barangay field: type to filter or tap the arrow to see
  /// every option. Only the listed options are accepted.
  Widget _choiceField({
    required String label,
    required IconData icon,
    required List<({String value, String label})> options,
    required String? value,
    required ValueChanged<String?> onChanged,
    required String? Function(String?) validator,
  }) {
    String? match(String text) {
      final t = text.trim().toLowerCase();
      for (final o in options) {
        if (o.label.toLowerCase() == t) return o.value;
      }
      return null;
    }

    String labelOf(String? v) {
      for (final o in options) {
        if (o.value == v) return o.label;
      }
      return '';
    }

    return Autocomplete<String>(
      initialValue: TextEditingValue(text: labelOf(value)),
      optionsBuilder: (TextEditingValue input) {
        final all = [for (final o in options) o.label];
        final q = input.text.trim().toLowerCase();
        // Show everything when empty or when a full option is already chosen.
        if (q.isEmpty || match(input.text) != null) return all;
        return all.where((l) => l.toLowerCase().contains(q));
      },
      onSelected: (String selection) => onChanged(match(selection)),
      fieldViewBuilder: (context, controller, focusNode, onSubmit) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          textInputAction: TextInputAction.next,
          validator: (text) => validator(match(text ?? '')),
          onChanged: (t) => onChanged(match(t)),
          onFieldSubmitted: (_) => onSubmit(),
          decoration: _decoration(
            label,
            icon: icon,
            suffix: IconButton(
              tooltip: 'Show all options',
              icon: const Icon(Icons.arrow_drop_down),
              onPressed: () {
                focusNode.requestFocus();
                controller.value = const TextEditingValue(text: '');
                onChanged(null);
              },
            ),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, opts) {
        final list = opts.toList();
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260, maxWidth: 420),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: list.length,
                itemBuilder: (context, index) => ListTile(
                  dense: true,
                  title: Text(list[index]),
                  onTap: () => onSelected(list[index]),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final preview = UserProfile(birthday: _birthday);
    final age = preview.age;

    const gap = SizedBox(height: 14);

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await _confirmDiscard();
        if (leave && mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr('profile')),
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.phthalo,
          elevation: 0,
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            onChanged: () => setState(() {}),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                // Top right, inside the list, so it scrolls away with the page.
                if (widget.onLogout != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: _saving ? null : _logout,
                      icon: const Icon(Icons.logout_rounded, size: 20),
                      label: Text(context.tr('logout')),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.deepSpace,
                        foregroundColor: AppColors.background,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                _SectionLabel(context.tr('personalInfo')),
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r"[A-Za-z\s.'-]")),
                  ],
                  validator: Validators.fullName,
                  decoration: _decoration(context.tr('fullName'),
                      icon: Icons.person_outline),
                ),
                gap,
                TextFormField(
                  controller: _birthdayCtrl,
                  readOnly: true,
                  onTap: _pickBirthday,
                  validator: (_) => Validators.birthDate(_birthday),
                  decoration: _decoration(
                    context.tr('birthday'),
                    icon: Icons.cake_outlined,
                    hint: 'YYYY-MM-DD',
                    suffix: const Icon(Icons.calendar_today_outlined),
                  ),
                ),
                gap,
                _AutoInfo(
                  ageLabel: context.tr('age'),
                  ageValue: age == null ? '—' : '$age',
                  seniorLabel: context.tr('senior'),
                  seniorValue: age == null
                      ? '—'
                      : context.tr(preview.isSenior ? 'yes' : 'no'),
                  caption: context.tr('seniorAuto'),
                ),
                gap,
                _choiceField(
                  label: context.tr('gender'),
                  icon: Icons.wc_outlined,
                  options: [
                    for (final g in _genderOptions) (value: g, label: g),
                  ],
                  value: _gender,
                  onChanged: (v) => setState(() => _gender = v),
                  validator: Validators.genderStatus,
                ),
                gap,
                _choiceField(
                  label: context.tr('civilStatus'),
                  icon: Icons.favorite_border_rounded,
                  options: [
                    for (final k in const [
                      'single',
                      'married',
                      'widowed',
                      'separated',
                    ])
                      (value: k, label: context.tr(k)),
                  ],
                  value: _civil,
                  onChanged: (v) => setState(() => _civil = v),
                  validator: (v) => v == null ? context.tr('chooseOne') : null,
                ),
                const SizedBox(height: 28),
                _SectionLabel(context.tr('address')),
                TextFormField(
                  controller: _sitio,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'[A-Za-z0-9\s#.,/-]')),
                  ],
                  // Optional: validate only if filled in.
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    return Validators.streetDetail(value);
                  },
                  decoration: _decoration(context.tr('sitio'),
                      icon: Icons.home_outlined),
                ),
                gap,
                Autocomplete<String>(
                  initialValue: TextEditingValue(text: _barangay.text),
                  optionsBuilder: (TextEditingValue value) {
                    final query = value.text.trim().toLowerCase();
                    if (query.isEmpty) return BatangasCityBarangays.all;
                    return BatangasCityBarangays.all
                        .where((b) => b.toLowerCase().contains(query));
                  },
                  onSelected: (String selection) =>
                      setState(() => _barangay.text = selection),
                  fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[A-Za-z0-9\s.()-]')),
                      ],
                      validator: Validators.barangay,
                      onChanged: (v) => _barangay.text = v,
                      onFieldSubmitted: (_) => onSubmit(),
                      decoration: _decoration(
                        context.tr('barangay'),
                        hint: context.tr('barangayHint'),
                        icon: Icons.location_city_outlined,
                        suffix: IconButton(
                          tooltip: 'Show all barangays',
                          icon: const Icon(Icons.arrow_drop_down),
                          onPressed: () {
                            focusNode.requestFocus();
                            controller.value = const TextEditingValue(text: '');
                            setState(() => _barangay.text = '');
                          },
                        ),
                      ),
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    final list = options.toList();
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(8),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 260,
                            maxWidth: 420,
                          ),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              final brgy = list[index];
                              return ListTile(
                                dense: true,
                                title: Text(brgy),
                                subtitle: const Text(
                                  'Batangas City',
                                  style: TextStyle(fontSize: 11),
                                ),
                                onTap: () => onSelected(brgy),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
                gap,
                TextFormField(
                  controller: _city,
                  readOnly: true,
                  decoration: _decoration(context.tr('city'),
                      icon: Icons.map_outlined)
                      .copyWith(helperText: context.tr('addressFixedNote')),
                ),
                const SizedBox(height: 28),
                _SectionLabel(
                  context.tr('assistanceInfo'),
                  icon: Icons.volunteer_activism_outlined,
                ),
                _SwitchCard(
                  icon: Icons.accessible_outlined,
                  title: context.tr('pwd'),
                  subtitle:
                  'Turn on if you need priority or accessible assistance.',
                  value: _pwd ?? false,
                  onChanged: (v) => setState(() => _pwd = v),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.phthalo,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: _saving
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                      : Text(context.tr('save'),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, {this.icon});
  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 22, color: AppColors.phthalo),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.phthalo,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Read-only card: age and senior status come from the birthday.
class _AutoInfo extends StatelessWidget {
  const _AutoInfo({
    required this.ageLabel,
    required this.ageValue,
    required this.seniorLabel,
    required this.seniorValue,
    required this.caption,
  });

  final String ageLabel;
  final String ageValue;
  final String seniorLabel;
  final String seniorValue;
  final String caption;

  @override
  Widget build(BuildContext context) {
    Widget stat(String label, String value) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.phthalo,
              )),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.moonstone.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            stat(ageLabel, ageValue),
            stat(seniorLabel, seniorValue),
          ]),
          const SizedBox(height: 8),
          Text(caption,
              style:
              const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

/// A tappable card with an icon, a title, a short hint and an on/off switch.
class _SwitchCard extends StatelessWidget {
  const _SwitchCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.lightGray),
      ),
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: value
                      ? AppColors.deepSpace
                      : AppColors.lightGray.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: value ? Colors.white : AppColors.textMuted,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.phthalo,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: value,
                onChanged: onChanged,
                activeTrackColor: AppColors.deepSpace,
                activeThumbColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A calendar where the month and the year are chosen from dropdowns.
class _BirthdayDialog extends StatefulWidget {
  const _BirthdayDialog({
    required this.initial,
    required this.today,
    required this.months,
  });

  final DateTime initial;
  final DateTime today;
  final List<String> months;

  @override
  State<_BirthdayDialog> createState() => _BirthdayDialogState();
}

class _BirthdayDialogState extends State<_BirthdayDialog> {
  static const int _firstYear = 1900;

  late int _year = widget.initial.year;
  late int _month = widget.initial.month;
  late int _day = widget.initial.day;

  int get _daysInMonth => DateUtils.getDaysInMonth(_year, _month);

  /// Empty cells before the 1st, with weeks starting on Sunday.
  int get _leadingBlanks => DateTime(_year, _month, 1).weekday % 7;

  bool _isFuture(int day) =>
      DateTime(_year, _month, day).isAfter(widget.today);

  /// Keeps month and day valid after the year or month changes.
  void _fix() {
    if (_year == widget.today.year && _month > widget.today.month) {
      _month = widget.today.month;
    }
    if (_day > _daysInMonth) _day = _daysInMonth;
    if (_isFuture(_day)) _day = widget.today.day;
  }

  @override
  Widget build(BuildContext context) {
    final lastMonth =
    _year == widget.today.year ? widget.today.month : 12;
    final years = [
      for (var y = widget.today.year; y >= _firstYear; y--) y,
    ];
    final weekdays = MaterialLocalizations.of(context).narrowWeekdays;
    final l10n = MaterialLocalizations.of(context);

    Widget dropdown<T>({
      required T value,
      required List<DropdownMenuItem<T>> items,
      required ValueChanged<T?> onChanged,
    }) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lightGray),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            menuMaxHeight: 320,
            borderRadius: BorderRadius.circular(12),
            dropdownColor: Colors.white,
            iconEnabledColor: AppColors.deepSpace,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.phthalo,
            ),
            items: items,
            onChanged: onChanged,
          ),
        ),
      );
    }

    final cells = <Widget>[
      for (var i = 0; i < _leadingBlanks; i++) const SizedBox.shrink(),
      for (var d = 1; d <= _daysInMonth; d++)
        _dayCell(d, selected: d == _day, enabled: !_isFuture(d)),
    ];

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: dropdown<int>(
                      value: _month,
                      items: [
                        for (var m = 1; m <= lastMonth; m++)
                          DropdownMenuItem(
                              value: m, child: Text(widget.months[m - 1])),
                      ],
                      onChanged: (m) {
                        if (m == null) return;
                        setState(() {
                          _month = m;
                          _fix();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: dropdown<int>(
                      value: _year,
                      items: [
                        for (final y in years)
                          DropdownMenuItem(value: y, child: Text('$y')),
                      ],
                      onChanged: (y) {
                        if (y == null) return;
                        setState(() {
                          _year = y;
                          _fix();
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  for (final w in weekdays)
                    Expanded(
                      child: Center(
                        child: Text(
                          w,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              GridView.count(
                crossAxisCount: 7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: cells,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.textMuted),
                    child: Text(l10n.cancelButtonLabel),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context)
                        .pop(DateTime(_year, _month, _day)),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.deepSpace),
                    child: Text(
                      l10n.okButtonLabel,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dayCell(int day, {required bool selected, required bool enabled}) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: enabled ? () => setState(() => _day = day) : null,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.deepSpace : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? Colors.white
                  : enabled
                  ? AppColors.phthalo
                  : AppColors.lightGray,
            ),
          ),
        ),
      ),
    );
  }
}