import 'package:flutter/material.dart';

import '../../core/app_feedback_service.dart';
import '../../core/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_surfaces.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({
    required this.localeCode,
    required this.authService,
    super.key,
  });

  final String localeCode;
  final AuthService authService;

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with WidgetsBindingObserver {
  bool _reloading = false;

  String get _lc => widget.localeCode;

  bool get _isFrench => _lc == 'fr';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_reloading) {
      _checkVerification(showFeedback: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final email = widget.authService.email ?? '-';

    return Scaffold(
      body: AppBackdrop(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppPanel(
                      gradient: AppThemePalette.heroGradient(
                        theme.brightness == Brightness.dark,
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: const Icon(
                              Icons.mark_email_read_rounded,
                              color: Colors.white,
                              size: 42,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            _title(),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _subtitle(),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.88),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    AppPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _emailLabel(),
                            style: theme.textTheme.labelLarge,
                          ),
                          const SizedBox(height: 6),
                          Text(email, style: theme.textTheme.titleMedium),
                          const SizedBox(height: 16),
                          ..._steps().map(
                            (step) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: AppThemePalette.primary.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.check_rounded,
                                      color: theme.colorScheme.primary,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      step,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          FilledButton.icon(
                            onPressed: widget.authService.isBusy
                                ? null
                                : () {
                                    AppFeedbackService.instance.tap();
                                    _resendVerification();
                                  },
                            icon: const Icon(Icons.send_rounded),
                            label: Text(_resendLabel()),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _reloading
                                ? null
                                : () {
                                    AppFeedbackService.instance.tap();
                                    _checkVerification();
                                  },
                            icon: _reloading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                    ),
                                  )
                                : const Icon(Icons.refresh_rounded),
                            label: Text(_checkLabel()),
                          ),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: widget.authService.isBusy
                                ? null
                                : () async {
                                    await AppFeedbackService.instance.tap();
                                    await widget.authService.signOut();
                                  },
                            icon: const Icon(Icons.logout_rounded),
                            label: Text(_logoutLabel()),
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

  Future<void> _resendVerification() async {
    final result = await widget.authService.sendEmailVerification();
    await (result.success
        ? AppFeedbackService.instance.success()
        : AppFeedbackService.instance.error());
    if (!mounted || result.message == null) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message!)));
  }

  Future<void> _checkVerification({bool showFeedback = true}) async {
    setState(() {
      _reloading = true;
    });
    final result = await widget.authService.reloadCurrentUser();
    if (!mounted) return;
    setState(() {
      _reloading = false;
    });
    if (showFeedback) {
      await (result.success && widget.authService.isEmailVerified
          ? AppFeedbackService.instance.success()
          : AppFeedbackService.instance.tap());
    }
    final message = result.message;
    if (!mounted || message == null) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _title() => !_isFrench ? 'Verify your email' : 'Verifiez votre email';

  String _subtitle() => !_isFrench
      ? 'We sent a verification link to continue securely into your document workspace.'
      : 'Nous avons envoye un lien de verification pour acceder en toute securite a votre espace documents.';

  String _emailLabel() => !_isFrench ? 'Email address' : 'Adresse email';

  String _resendLabel() => !_isFrench
      ? 'Resend verification email'
      : 'Renvoyer l email de verification';

  String _checkLabel() =>
      !_isFrench ? 'I verified my email' : 'J ai verifie mon email';

  String _logoutLabel() => !_isFrench ? 'Sign out' : 'Se deconnecter';

  List<String> _steps() {
    if (!_isFrench) {
      return const <String>[
        'Open your mailbox and click the verification link.',
        'Check the spam folder if you do not see the email right away.',
        'Come back here and confirm once verification is complete.',
      ];
    }
    return const <String>[
      'Ouvrez votre boite mail puis cliquez sur le lien de verification.',
      'Verifiez les spams si vous ne voyez pas le message tout de suite.',
      'Revenez ensuite ici pour confirmer la verification.',
    ];
  }
}
