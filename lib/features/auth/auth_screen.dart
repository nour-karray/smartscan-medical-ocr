import 'package:flutter/material.dart';

import '../../core/app_feedback_service.dart';
import '../../core/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_surfaces.dart';

enum _AuthMode { signIn, register }

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    required this.localeCode,
    required this.authService,
    super.key,
  });

  final String localeCode;
  final AuthService authService;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  _AuthMode _mode = _AuthMode.signIn;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String get _lc => widget.localeCode;

  bool get _isFrench => _lc == 'fr';
  bool get _isArabic => _lc == 'ar';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: AppBackdrop(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppPanel(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                      child: Column(
                        children: [
                          Container(
                            width: 86,
                            height: 86,
                            decoration: BoxDecoration(
                              gradient: AppThemePalette.heroGradient(
                                theme.brightness == Brightness.dark,
                              ),
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: const Icon(
                              Icons.translate_rounded,
                              color: Colors.white,
                              size: 42,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'DocTranslate',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _heroSubtitle(),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    AppPanel(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                      child: AnimatedBuilder(
                        animation: widget.authService,
                        builder: (context, _) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _AuthModeSwitch(
                                mode: _mode,
                                localeCode: _lc,
                                onChanged: (mode) {
                                  AppFeedbackService.instance.tap();
                                  setState(() {
                                    _mode = mode;
                                  });
                                },
                              ),
                              const SizedBox(height: 18),
                              Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    if (_mode == _AuthMode.register) ...[
                                      TextFormField(
                                        controller: _nameController,
                                        textInputAction: TextInputAction.next,
                                        autofillHints: const [
                                          AutofillHints.name,
                                        ],
                                        decoration: InputDecoration(
                                          labelText: _labelFullName(),
                                          prefixIcon: const Icon(
                                            Icons.person_outline_rounded,
                                          ),
                                        ),
                                        validator: (value) {
                                          if (_mode != _AuthMode.register) {
                                            return null;
                                          }
                                          if ((value ?? '').trim().length < 2) {
                                            return _fullNameError();
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                    TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      autofillHints: const [
                                        AutofillHints.email,
                                      ],
                                      decoration: InputDecoration(
                                        labelText: _labelEmail(),
                                        prefixIcon: const Icon(
                                          Icons.mail_outline_rounded,
                                        ),
                                      ),
                                      validator: (value) {
                                        final email = (value ?? '').trim();
                                        if (email.isEmpty) {
                                          return _emailRequiredError();
                                        }
                                        if (!email.contains('@') ||
                                            !email.contains('.')) {
                                          return _emailFormatError();
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      textInputAction:
                                          _mode == _AuthMode.register
                                          ? TextInputAction.next
                                          : TextInputAction.done,
                                      autofillHints: _mode == _AuthMode.register
                                          ? const [AutofillHints.newPassword]
                                          : const [AutofillHints.password],
                                      onFieldSubmitted: (_) {
                                        if (_mode == _AuthMode.signIn) {
                                          _submit();
                                        }
                                      },
                                      decoration: InputDecoration(
                                        labelText: _labelPassword(),
                                        prefixIcon: const Icon(
                                          Icons.lock_outline_rounded,
                                        ),
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            AppFeedbackService.instance.tap();
                                            setState(() {
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_rounded
                                                : Icons.visibility_off_rounded,
                                          ),
                                        ),
                                      ),
                                      validator: (value) {
                                        final password = value ?? '';
                                        if (password.isEmpty) {
                                          return _passwordRequiredError();
                                        }
                                        if (_mode == _AuthMode.register &&
                                            password.length < 6) {
                                          return _passwordLengthError();
                                        }
                                        return null;
                                      },
                                    ),
                                    if (_mode == _AuthMode.register) ...[
                                      const SizedBox(height: 12),
                                      TextFormField(
                                        controller: _confirmPasswordController,
                                        obscureText: _obscureConfirmPassword,
                                        textInputAction: TextInputAction.done,
                                        autofillHints: const [
                                          AutofillHints.newPassword,
                                        ],
                                        onFieldSubmitted: (_) => _submit(),
                                        decoration: InputDecoration(
                                          labelText: _labelConfirmPassword(),
                                          prefixIcon: const Icon(
                                            Icons.verified_user_outlined,
                                          ),
                                          suffixIcon: IconButton(
                                            onPressed: () {
                                              AppFeedbackService.instance.tap();
                                              setState(() {
                                                _obscureConfirmPassword =
                                                    !_obscureConfirmPassword;
                                              });
                                            },
                                            icon: Icon(
                                              _obscureConfirmPassword
                                                  ? Icons.visibility_rounded
                                                  : Icons
                                                        .visibility_off_rounded,
                                            ),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (_mode != _AuthMode.register) {
                                            return null;
                                          }
                                          if ((value ?? '').isEmpty) {
                                            return _confirmPasswordError();
                                          }
                                          if (value !=
                                              _passwordController.text) {
                                            return _passwordMismatchError();
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (_mode == _AuthMode.signIn) ...[
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: widget.authService.isBusy
                                        ? null
                                        : () {
                                            AppFeedbackService.instance.tap();
                                            _sendResetPassword();
                                          },
                                    child: Text(_forgotPasswordLabel()),
                                  ),
                                ),
                              ] else ...[
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppThemePalette.primary.withValues(
                                      alpha: 0.08,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _registerHint(),
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 14),
                              FilledButton.icon(
                                onPressed: widget.authService.isBusy
                                    ? null
                                    : _submit,
                                icon: widget.authService.isBusy
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Icon(
                                        _mode == _AuthMode.signIn
                                            ? Icons.login_rounded
                                            : Icons.person_add_alt_1_rounded,
                                      ),
                                label: Text(
                                  _mode == _AuthMode.signIn
                                      ? _signInLabel()
                                      : _registerLabel(),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: theme.colorScheme.outlineVariant,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(
                                      _separatorLabel(),
                                      style: theme.textTheme.labelMedium,
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: theme.colorScheme.outlineVariant,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              OutlinedButton.icon(
                                onPressed: widget.authService.isBusy
                                    ? null
                                    : _handleGoogleSignIn,
                                icon: const _GoogleMark(),
                                label: Text(_googleButtonLabel()),
                              ),
                              const SizedBox(height: 12),
                              if (widget.authService.errorMessage != null)
                                Text(
                                  widget.authService.errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: widget.authService.isBusy
                                    ? null
                                    : () {
                                        AppFeedbackService.instance.tap();
                                        setState(() {
                                          _mode = _mode == _AuthMode.signIn
                                              ? _AuthMode.register
                                              : _AuthMode.signIn;
                                        });
                                      },
                                child: Text(
                                  _mode == _AuthMode.signIn
                                      ? _registerCtaLabel()
                                      : _signInCtaLabel(),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    AppPanel(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppThemePalette.primary.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.shield_outlined),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              _securityNote(),
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await AppFeedbackService.instance.tap();

    late final AuthActionResult result;
    if (_mode == _AuthMode.signIn) {
      result = await widget.authService.signInWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } else {
      result = await widget.authService.registerWithEmail(
        fullName: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
    }

    await (result.success
        ? AppFeedbackService.instance.success()
        : AppFeedbackService.instance.error());
    if (!mounted || result.message == null) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message!)));
  }

  Future<void> _sendResetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_resetRequiresEmail())));
      return;
    }

    final result = await widget.authService.sendPasswordResetEmail(
      email: email,
    );
    await (result.success
        ? AppFeedbackService.instance.success()
        : AppFeedbackService.instance.error());
    if (!mounted || result.message == null) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message!)));
  }

  Future<void> _handleGoogleSignIn() async {
    await AppFeedbackService.instance.tap();
    final result = await widget.authService.signInWithGoogle();
    await (result.success
        ? AppFeedbackService.instance.success()
        : AppFeedbackService.instance.error());
    if (!mounted || result.message == null) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(_googleInfoMessage(result.message))));
  }

  String _heroSubtitle() {
    if (_isArabic) {
      return 'سجل الدخول أو أنشئ حسابا آمنا للوصول إلى كل المستندات ومسار الترجمة والتحليلات.';
    }
    if (!_isFrench) {
      return 'Sign in or create a secure account to access your document workspace, OCR pipeline and analytics.';
    }
    return 'Connectez-vous ou creez un compte securise pour acceder a votre espace documents, OCR et tableau de bord.';
  }

  String _labelFullName() =>
      _isArabic ? 'الاسم الكامل' : (!_isFrench ? 'Full name' : 'Nom complet');

  String _labelEmail() => _isArabic
      ? 'Adresse e-mail'
      : (!_isFrench ? 'Email address' : 'Adresse e-mail');

  String _labelPassword() =>
      _isArabic ? 'Mot de passe' : (!_isFrench ? 'Password' : 'Mot de passe');

  String _labelConfirmPassword() => _isArabic
      ? 'Confirmer le mot de passe'
      : (!_isFrench ? 'Confirm password' : 'Confirmer le mot de passe');

  String _forgotPasswordLabel() => _isArabic
      ? 'Mot de passe oublie ?'
      : (!_isFrench ? 'Forgot password?' : 'Mot de passe oublie ?');

  String _signInLabel() =>
      _isArabic ? 'Se connecter' : (!_isFrench ? 'Sign in' : 'Se connecter');

  String _registerLabel() => _isArabic
      ? 'Creer le compte'
      : (!_isFrench ? 'Create account' : 'Creer le compte');

  String _separatorLabel() => _isArabic ? 'OU' : 'OU';

  String _googleButtonLabel() => _isArabic
      ? 'Continuer avec Google'
      : (!_isFrench ? 'Continue with Google' : 'Continuer avec Google');

  String _registerCtaLabel() => _isArabic
      ? 'Pas encore de compte ? S inscrire'
      : (!_isFrench
            ? 'No account yet? Sign up'
            : 'Pas encore de compte ? S inscrire');

  String _signInCtaLabel() => _isArabic
      ? 'Vous avez deja un compte ? Se connecter'
      : (!_isFrench
            ? 'Already have an account? Sign in'
            : 'Vous avez deja un compte ? Se connecter');

  String _registerHint() => _isArabic
      ? 'Un email de verification sera envoye apres la creation du compte.'
      : (!_isFrench
            ? 'A verification email will be sent after account creation.'
            : 'Un email de verification sera envoye apres la creation du compte.');

  String _securityNote() => _isArabic
      ? 'Vos donnees sont protegees. L application utilise Firebase Authentication pour securiser votre acces.'
      : (!_isFrench
            ? 'Your data stays protected. The app uses Firebase Authentication to secure access.'
            : 'Vos donnees sont protegees. L application utilise Firebase Authentication pour securiser l acces.');

  String _googleInfoMessage([String? fallback]) => fallback ??
      (_isArabic
          ? 'Activez Google Sign-In dans Firebase Console puis regenerez google-services.json.'
          : (!_isFrench
                ? 'Enable Google Sign-In in Firebase Console, then regenerate google-services.json.'
                : 'Activez Google Sign-In dans Firebase Console puis regenerez google-services.json.'));

  String _resetRequiresEmail() => _isArabic
      ? 'Saisissez votre adresse email avant de demander la reinitialisation.'
      : (!_isFrench
            ? 'Enter your email before requesting a password reset.'
            : 'Saisissez votre adresse email avant de demander la reinitialisation.');

  String _fullNameError() => _isArabic
      ? 'Entrez un nom complet valide.'
      : (!_isFrench
            ? 'Enter a valid full name.'
            : 'Entrez un nom complet valide.');

  String _emailRequiredError() => _isArabic
      ? 'L email est obligatoire.'
      : (!_isFrench ? 'Email is required.' : 'L email est obligatoire.');

  String _emailFormatError() => _isArabic
      ? 'Format d email invalide.'
      : (!_isFrench ? 'Invalid email format.' : 'Format d email invalide.');

  String _passwordRequiredError() => _isArabic
      ? 'Le mot de passe est obligatoire.'
      : (!_isFrench
            ? 'Password is required.'
            : 'Le mot de passe est obligatoire.');

  String _passwordLengthError() => _isArabic
      ? 'Le mot de passe doit contenir au moins 6 caracteres.'
      : (!_isFrench
            ? 'Password must be at least 6 characters.'
            : 'Le mot de passe doit contenir au moins 6 caracteres.');

  String _confirmPasswordError() => _isArabic
      ? 'Confirmez votre mot de passe.'
      : (!_isFrench
            ? 'Confirm your password.'
            : 'Confirmez votre mot de passe.');

  String _passwordMismatchError() => _isArabic
      ? 'Les mots de passe ne correspondent pas.'
      : (!_isFrench
            ? 'Passwords do not match.'
            : 'Les mots de passe ne correspondent pas.');
}

class _AuthModeSwitch extends StatelessWidget {
  const _AuthModeSwitch({
    required this.mode,
    required this.localeCode,
    required this.onChanged,
  });

  final _AuthMode mode;
  final String localeCode;
  final ValueChanged<_AuthMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeButton(
              label: localeCode == 'en' ? 'Sign in' : 'Connexion',
              selected: mode == _AuthMode.signIn,
              onTap: () => onChanged(_AuthMode.signIn),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ModeButton(
              label: localeCode == 'en' ? 'Register' : 'Inscription',
              selected: mode == _AuthMode.register,
              onTap: () => onChanged(_AuthMode.register),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        gradient: selected
            ? AppThemePalette.heroGradient(theme.brightness == Brightness.dark)
            : null,
        color: selected ? null : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelLarge?.copyWith(
                color: selected ? Colors.white : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE4E8F0)),
      ),
      child: const Text(
        'G',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1A6BFF),
        ),
      ),
    );
  }
}
