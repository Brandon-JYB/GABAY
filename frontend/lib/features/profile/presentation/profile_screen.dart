import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
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
  final _formKey = GlobalKey<FormState>();

  late final _name = TextEditingController(text: widget.initial.name);
  late final _sitio = TextEditingController(text: widget.initial.sitio);
  late final _barangay = TextEditingController(text: widget.initial.barangay);
  late final _city = TextEditingController(text: widget.initial.city);
  late final _province = TextEditingController(text: widget.initial.province);

  late DateTime? _birthday = widget.initial.birthday;
  late String? _gender = widget.initial.gender;
  late String? _civil = widget.initial.civilStatus;
  late bool? _philhealth = widget.initial.isPhilhealth;
  late bool? _pwd = widget.initial.isPwd;

  /// What was last saved. Anything different from this counts as unsaved.
  late UserProfile _saved = widget.initial;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_name, _sitio, _barangay, _city, _province]) {
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
    barangay: _barangay.text.trim(),
    city: _city.text.trim(),
    province: _province.text.trim(),
    isPhilhealth: _philhealth,
    isPwd: _pwd,
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

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? context.tr('required') : null;

  String _formatDate(DateTime d) {
    final months = context.tr('months').split(',');
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  Future<void> _pickBirthday(FormFieldState<DateTime> field) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime(now.year - 30, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked == null || !mounted) return;
    field.didChange(picked);
    setState(() => _birthday = picked);
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
    if (_isDirty && !await _confirmDiscard()) return;
    await onLogout();
  }

  InputDecoration _decoration(String label) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color),
    );
    return InputDecoration(
      labelText: label,
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

  Widget _dropdown({
    required String label,
    required String? value,
    required List<String> keys,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: _decoration(label),
      items: [
        for (final k in keys)
          DropdownMenuItem(value: k, child: Text(context.tr(k))),
      ],
      onChanged: onChanged,
      validator: (v) => v == null ? context.tr('chooseOne') : null,
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
                _SectionLabel(context.tr('personalInfo')),
                _textField(context.tr('fullName'), _name),
                gap,
                FormField<DateTime>(
                  initialValue: _birthday,
                  validator: (v) => v == null ? context.tr('required') : null,
                  builder: (field) => InkWell(
                    onTap: () => _pickBirthday(field),
                    borderRadius: BorderRadius.circular(16),
                    child: InputDecorator(
                      decoration: _decoration(context.tr('birthday'))
                          .copyWith(errorText: field.errorText),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _birthday == null
                                  ? context.tr('selectDate')
                                  : _formatDate(_birthday!),
                              style: TextStyle(
                                fontSize: 16,
                                color: _birthday == null
                                    ? AppColors.textMuted
                                    : AppColors.phthalo,
                              ),
                            ),
                          ),
                          const Icon(Icons.calendar_today_outlined,
                              size: 20, color: AppColors.phthalo),
                        ],
                      ),
                    ),
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
                _dropdown(
                  label: context.tr('gender'),
                  value: _gender,
                  keys: const ['male', 'female'],
                  onChanged: (v) => setState(() => _gender = v),
                ),
                gap,
                _dropdown(
                  label: context.tr('civilStatus'),
                  value: _civil,
                  keys: const ['single', 'married', 'widowed', 'separated'],
                  onChanged: (v) => setState(() => _civil = v),
                ),
                const SizedBox(height: 28),
                _SectionLabel(context.tr('address')),
                _textField(context.tr('sitio'), _sitio, required: false),
                gap,
                _textField(context.tr('barangay'), _barangay),
                gap,
                _textField(context.tr('city'), _city),
                gap,
                _textField(context.tr('province'), _province),
                const SizedBox(height: 28),
                _SectionLabel(context.tr('assistanceInfo')),
                _YesNoField(
                  label: context.tr('philhealth'),
                  value: _philhealth,
                  onChanged: (v) => setState(() => _philhealth = v),
                ),
                gap,
                _YesNoField(
                  label: context.tr('pwd'),
                  value: _pwd,
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
                if (widget.onLogout != null) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _saving ? null : _logout,
                    icon: const Icon(Icons.logout_rounded, size: 20),
                    label: Text(context.tr('logout')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.deepSpace,
                      side: const BorderSide(color: AppColors.deepSpace),
                      minimumSize: const Size.fromHeight(52),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.phthalo,
        ),
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

class _YesNoField extends StatelessWidget {
  const _YesNoField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool? value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return FormField<bool>(
      initialValue: value,
      validator: (v) => v == null ? context.tr('chooseOne') : null,
      builder: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.phthalo,
              )),
          const SizedBox(height: 8),
          SegmentedButton<bool>(
            emptySelectionAllowed: true,
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: true, label: Text(context.tr('yes'))),
              ButtonSegment(value: false, label: Text(context.tr('no'))),
            ],
            selected: state.value == null ? <bool>{} : {state.value!},
            onSelectionChanged: (s) {
              final v = s.isEmpty ? null : s.first;
              state.didChange(v);
              onChanged(v);
            },
            style: SegmentedButton.styleFrom(
              backgroundColor: Colors.white,
              selectedBackgroundColor: AppColors.deepSpace,
              selectedForegroundColor: Colors.white,
              foregroundColor: AppColors.phthalo,
            ),
          ),
          if (state.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                state.errorText!,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
}