import 'package:flutter/material.dart';

import '../../../core/app_router.dart';
import '../../../core/validators.dart';
import '../state/auth_scope.dart';
import 'widgets/auth_error_banner.dart';
import 'widgets/password_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = AuthScope.read(context);
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final ok = await auth.login(
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
                      Icon(Icons.volunteer_activism_outlined,
                          size: 56, color: theme.colorScheme.primary),
                      const SizedBox(height: 16),
                      Text('Welcome to GABAY',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text(
                        'Log in to find medical assistance programs.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 32),
                      if (auth.errorMessage != null) ...[
                        AuthErrorBanner(message: auth.errorMessage!),
                        const SizedBox(height: 16),
                      ],
                      TextFormField(
                        controller: _emailCtrl,
                        enabled: !auth.isLoading,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
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
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        validator: (v) =>
                            Validators.requiredField(v, label: 'Password'),
                        onChanged: (_) => auth.clearError(),
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
                            : const Text('Log in'),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: auth.isLoading
                            ? null
                            : () => Navigator.of(context)
                            .pushNamed(AppRoutes.register),
                        child: const Text('Create an account'),
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