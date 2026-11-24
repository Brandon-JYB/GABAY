import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_router.dart';
import '../../../core/city_barangays.dart';
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

    final now = DateTime.now();
    final initialDate =
        _selectedBirthDate ?? DateTime(now.year - 20, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
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

    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Sign up to check your eligibility and get application guidance.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      if (auth.errorMessage != null) ...[
                        AuthErrorBanner(message: auth.errorMessage!),
                        const SizedBox(height: 16),
                      ],
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
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
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
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedGender,
                        onChanged: auth.isLoading
                            ? null
                            : (value) {
                          setState(() => _selectedGender = value);
                          auth.clearError();
                        },
                        validator: Validators.genderStatus,
                        decoration: const InputDecoration(
                          labelText: 'Gender',
                          prefixIcon: Icon(Icons.wc_outlined),
                          border: OutlineInputBorder(),
                        ),
                        items: _genderOptions
                            .map(
                              (gender) => DropdownMenuItem<String>(
                            value: gender,
                            child: Text(gender),
                          ),
                        )
                            .toList(),
                      ),
                      const SizedBox(height: 16),
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
                          labelText:
                          'Sitio / House no. / Street / Purok (optional)',
                          prefixIcon: Icon(Icons.home_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
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
                              border: const OutlineInputBorder(),
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
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _cityMunicipalityCtrl,
                        readOnly: true,
                        enabled: !auth.isLoading,
                        decoration: const InputDecoration(
                          labelText: 'City/Municipality',
                          helperText: 'Will be updated in the future',
                          prefixIcon: Icon(Icons.map_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
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
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      PasswordField(
                        controller: _passwordCtrl,
                        label: 'Password',
                        enabled: !auth.isLoading,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.newPassword],
                        validator: Validators.newPassword,
                        onChanged: (_) => auth.clearError(),
                      ),
                      const SizedBox(height: 16),
                      PasswordField(
                        controller: _confirmCtrl,
                        label: 'Confirm password',
                        enabled: !auth.isLoading,
                        textInputAction: TextInputAction.done,
                        validator:
                        Validators.confirmPassword(() => _passwordCtrl.text),
                        onSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: auth.isLoading ? null : _submit,
                        child: auth.isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child:
                          CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Text('Create account'),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
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
    );
  }
}