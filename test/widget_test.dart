import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartscan_mlkit/core/app_feedback_service.dart';
import 'package:smartscan_mlkit/core/auth_service.dart';
import 'package:smartscan_mlkit/features/auth/auth_screen.dart';

void main() {
  late _FakeAuthService authService;

  setUp(() {
    AppFeedbackService.instance.configure(
      soundEnabled: false,
      vibrationEnabled: false,
    );
    authService = _FakeAuthService();
  });

  Widget buildAuthScreen() {
    return MaterialApp(
      home: AuthScreen(localeCode: 'fr', authService: authService),
    );
  }

  testWidgets('Login screen renders the sign-in form', (tester) async {
    await tester.pumpWidget(buildAuthScreen());

    expect(find.text('DocTranslate'), findsOneWidget);
    expect(find.text('Connexion'), findsOneWidget);
    expect(find.text('Inscription'), findsOneWidget);
    expect(find.text('Adresse e-mail'), findsOneWidget);
    expect(find.text('Mot de passe'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
  });

  testWidgets('Login validates required email and password', (tester) async {
    await tester.pumpWidget(buildAuthScreen());

    await _tapText(tester, 'Se connecter');

    expect(find.text('L email est obligatoire.'), findsOneWidget);
    expect(find.text('Le mot de passe est obligatoire.'), findsOneWidget);
    expect(authService.signInCalls, 0);
  });

  testWidgets('Register mode validates password confirmation', (tester) async {
    await tester.pumpWidget(buildAuthScreen());

    await _tapText(tester, 'Inscription');

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Nour Karray');
    await tester.enterText(fields.at(1), 'nour@example.com');
    await tester.enterText(fields.at(2), 'secret1');
    await tester.enterText(fields.at(3), 'secret2');
    await _tapText(tester, 'Creer le compte');

    expect(
      find.text('Les mots de passe ne correspondent pas.'),
      findsOneWidget,
    );
    expect(authService.registerCalls, 0);
  });

  testWidgets('Login submits email credentials', (tester) async {
    await tester.pumpWidget(buildAuthScreen());

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), ' nour@example.com ');
    await tester.enterText(fields.at(1), 'password123');
    await _tapText(tester, 'Se connecter');

    expect(authService.signInCalls, 1);
    expect(authService.lastEmail, ' nour@example.com ');
    expect(authService.lastPassword, 'password123');
  });
}

Future<void> _tapText(WidgetTester tester, String text) async {
  final finder = find.text(text);
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pump();
}

class _FakeAuthService extends AuthService {
  int signInCalls = 0;
  int registerCalls = 0;
  String? lastEmail;
  String? lastPassword;

  @override
  bool get isBusy => false;

  @override
  String? get errorMessage => null;

  @override
  Future<AuthActionResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    signInCalls += 1;
    lastEmail = email;
    lastPassword = password;
    return AuthActionResult.success();
  }

  @override
  Future<AuthActionResult> registerWithEmail({
    required String fullName,
    required String email,
    required String password,
  }) async {
    registerCalls += 1;
    lastEmail = email;
    lastPassword = password;
    return AuthActionResult.success();
  }

  @override
  Future<AuthActionResult> signInWithGoogle() async {
    return AuthActionResult.success();
  }

  @override
  Future<AuthActionResult> sendPasswordResetEmail({
    required String email,
  }) async {
    lastEmail = email;
    return AuthActionResult.success('Email de reinitialisation envoye.');
  }
}
