import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_router.dart';
import '../../../core/city_barangays.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/validators.dart';
import '../state/auth_scope.dart';
import 'widgets/auth_error_banner.dart';
import 'widgets/password_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const List<String> _genderOptions = [
    'Male',
    'Female',
  ];

  static const String _cityValue = 'Batangas City';

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _birthDateCtrl = TextEditingController();
  final _streetDetailCtrl = TextEditingController();
  final _cityMunicipalityCtrl = TextEditingController(text: _cityValue);
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  TextEditingController? _barangayAutocompleteCtrl;
  DateTime? _selectedBirthDate;
  String? _selectedGender;
  String _barangayValue = '';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _birthDateCtrl.dispose();
    _streetDetailCtrl.dispose();
    _cityMunicipalityCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _attachBarangayController(TextEditingController controller) {
    if (_barangayAutocompleteCtrl == controller) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _barangayAutocompleteCtrl = controller;
      }
    });
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _pickBirthDate() async {
    final auth = AuthScope.read(context);
    if (auth.isLoading) return;

    const english = [
      'January', 'February', 'March', 'April', 'May', 'June', 'July',
      'August', 'September', 'October', 'November', 'December',
    ];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var initialDate =
        _selectedBirthDate ?? DateTime(now.year - 20, now.month, now.day);
    if (initialDate.isAfter(today)) initialDate = today;

    var months = context.tr('months').split(',').map((m) => m.trim()).toList();
    if (months.length != 12) months = english;

    // Same calendar as the profile: month and year picked from dropdowns.
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (_) => _BirthdayDialog(
        initial: initialDate,
        today: today,
        months: months,
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
        _birthDateCtrl.text = _formatDate(picked);
      });
      auth.clearError();
    }
  }

  void _openBarangayDropdown() {
    final auth = AuthScope.read(context);
    final ctrl = _barangayAutocompleteCtrl;
    if (auth.isLoading || ctrl == null) return;

    ctrl.value = const TextEditingValue(text: '');
    setState(() => _barangayValue = '');
  }

  String _buildAddress() {
    final normalizedBrgy =
    BatangasCityBarangays.normalizeBarangay(_barangayValue);
    final street = _streetDetailCtrl.text.trim();
    final parts = <String>[
      if (street.isNotEmpty) street,
      if (normalizedBrgy.isNotEmpty) 'Brgy. $normalizedBrgy',
      _cityValue,
    ];
    return parts.join(', ');
  }

  Future<void> _submit() async {
    final auth = AuthScope.read(context);
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final ok = await auth.register(
      fullName: _nameCtrl.text.trim(),
      birthDate: _selectedBirthDate!,
      genderStatus: _selectedGender!,
      address: _buildAddress(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
    if (!mounted || !ok) return;
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    final theme = Theme.of(context);
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color),
    );
    final styled = theme.copyWith(
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: Colors.white,
        border: border(AppColors.lightGray),
        enabledBorder: border(AppColors.lightGray),
        disabledBorder: border(AppColors.lightGray),
        focusedBorder: border(AppColors.deepSpace),
        errorBorder: border(theme.colorScheme.error),
        focusedErrorBorder: border(theme.colorScheme.error),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create account'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.phthalo,
        elevation: 0,
      ),
      body: Theme(
        data: styled,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: _formKey,
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (auth.errorMessage != null) ...[
                          AuthErrorBanner(message: auth.errorMessage!),
                          const SizedBox(height: 14),
                        ],
                        const _SectionHeader('Personal information'),
                        TextFormField(
                          controller: _nameCtrl,
                          enabled: !auth.isLoading,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.name],
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r"[A-Za-z\s.'-]"),
                            ),
                          ],
                          validator: Validators.fullName,
                          onChanged: (_) => auth.clearError(),
                          decoration: const InputDecoration(
                            labelText: 'Full name',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _birthDateCtrl,
                          readOnly: true,
                          enabled: !auth.isLoading,
                          onTap: _pickBirthDate,
                          validator: (_) =>
                              Validators.birthDate(_selectedBirthDate),
                          decoration: const InputDecoration(
                            labelText: 'Birthdate',
                            hintText: 'YYYY-MM-DD',
                            prefixIcon: Icon(Icons.cake_outlined),
                            suffixIcon: Icon(Icons.calendar_today_outlined),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) =>
                          _genderOptions,
                          onSelected: (String selection) {
                            setState(() => _selectedGender = selection);
                            auth.clearError();
                            FocusScope.of(context).unfocus();
                          },
                          fieldViewBuilder: (
                              BuildContext context,
                              TextEditingController textEditingController,
                              FocusNode focusNode,
                              VoidCallback onFieldSubmitted,
                              ) {
                            return TextFormField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              readOnly: true,
                              enabled: !auth.isLoading,
                              validator: (_) =>
                                  Validators.genderStatus(_selectedGender),
                              decoration: InputDecoration(
                                labelText: 'Gender',
                                hintText: 'Select from list',
                                prefixIcon: const Icon(Icons.wc_outlined),
                                suffixIcon: IconButton(
                                  tooltip: 'Show gender options',
                                  icon: const Icon(Icons.arrow_drop_down),
                                  onPressed: auth.isLoading
                                      ? null
                                      : () => focusNode.requestFocus(),
                                ),
                              ),
                            );
                          },
                          optionsViewBuilder: (
                              BuildContext context,
                              AutocompleteOnSelected<String> onSelected,
                              Iterable<String> options,
                              ) {
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
                                    shrinkWrap: true,
                                    itemCount: list.length,
                                    itemBuilder: (context, index) {
                                      final gender = list[index];
                                      return ListTile(
                                        dense: true,
                                        title: Text(gender),
                                        onTap: () => onSelected(gender),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 28),
                        const _SectionHeader('Address'),
                        TextFormField(
                          controller: _streetDetailCtrl,
                          enabled: !auth.isLoading,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.streetAddressLine1],
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[A-Za-z0-9\s#.,/-]'),
                            ),
                          ],
                          // Optional: skip validation when empty, validate only if filled in
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return null;
                            }
                            return Validators.streetDetail(value);
                          },
                          onChanged: (_) => auth.clearError(),
                          decoration: const InputDecoration(
                            labelText: 'Street / Sitio / Purok',
                            helperText: 'House no., street, sitio or purok (optional)',
                            prefixIcon: Icon(Icons.home_outlined),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            final query =
                            textEditingValue.text.trim().toLowerCase();
                            if (query.isEmpty) {
                              return BatangasCityBarangays.all;
                            }
                            return BatangasCityBarangays.all.where(
                                  (brgy) => brgy.toLowerCase().contains(query),
                            );
                          },
                          onSelected: (String selection) {
                            setState(() => _barangayValue = selection);
                            auth.clearError();
                          },
                          fieldViewBuilder: (
                              BuildContext context,
                              TextEditingController textEditingController,
                              FocusNode focusNode,
                              VoidCallback onFieldSubmitted,
                              ) {
                            _attachBarangayController(textEditingController);
                            return TextFormField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              enabled: !auth.isLoading,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[A-Za-z0-9\s.()-]'),
                                ),
                              ],
                              validator: Validators.barangay,
                              onChanged: (value) {
                                setState(() => _barangayValue = value);
                                auth.clearError();
                              },
                              onFieldSubmitted: (_) => onFieldSubmitted(),
                              decoration: InputDecoration(
                                labelText: 'Barangay',
                                hintText: 'Select from list or type',
                                prefixIcon:
                                const Icon(Icons.location_city_outlined),
                                suffixIcon: IconButton(
                                  tooltip: 'Show all barangays',
                                  icon: const Icon(Icons.arrow_drop_down),
                                  onPressed: auth.isLoading
                                      ? null
                                      : () {
                                    focusNode.requestFocus();
                                    _openBarangayDropdown();
                                  },
                                ),
                              ),
                            );
                          },
                          optionsViewBuilder: (
                              BuildContext context,
                              AutocompleteOnSelected<String> onSelected,
                              Iterable<String> options,
                              ) {
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
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _cityMunicipalityCtrl,
                          readOnly: true,
                          enabled: !auth.isLoading,
                          decoration: const InputDecoration(
                            labelText: 'City/Municipality',
                            helperText: 'Will be updated in the future',
                            prefixIcon: Icon(Icons.map_outlined),
                          ),
                        ),
                        const SizedBox(height: 28),
                        const _SectionHeader('Account'),
                        TextFormField(
                          controller: _emailCtrl,
                          enabled: !auth.isLoading,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[A-Za-z0-9@._%+-]'),
                            ),
                          ],
                          validator: Validators.email,
                          onChanged: (_) => auth.clearError(),
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.mail_outline),
                          ),
                        ),
                        const SizedBox(height: 14),
                        PasswordField(
                          controller: _passwordCtrl,
                          label: 'Password',
                          enabled: !auth.isLoading,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.newPassword],
                          validator: Validators.newPassword,
                          onChanged: (_) => auth.clearError(),
                        ),
                        const SizedBox(height: 14),
                        PasswordField(
                          controller: _confirmCtrl,
                          label: 'Confirm password',
                          enabled: !auth.isLoading,
                          textInputAction: TextInputAction.done,
                          validator:
                          Validators.confirmPassword(() => _passwordCtrl.text),
                          onSubmitted: (_) => _submit(),
                        ),
                        const SizedBox(height: 28),
                        FilledButton(
                          onPressed: auth.isLoading ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.mustard,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(52),
                          ),
                          child: auth.isLoading
                              ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: Colors.white),
                          )
                              : const Text('Create account',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          style: TextButton.styleFrom(
                              foregroundColor: AppColors.deepSpace),
                          onPressed: auth.isLoading
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: const Text('Already have an account? Log in'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
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