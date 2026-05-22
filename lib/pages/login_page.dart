import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../services/auth_service.dart';
import '../services/messaging_service.dart';
import '../widgets/auth_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _showError(String message) {
    return showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Sign-in failed'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      await _showError('Please enter your email and password.');
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.instance.signIn(email: email, password: password);
      await MessagingService.instance.upsertCurrentUser();
      if (!mounted) return;
      context.go('/home');
    } catch (e, st) {
      debugPrint('Login error: $e');
      if (e is FirebaseAuthException) {
        debugPrint('FirebaseAuthException code=${e.code} message=${e.message}');
      }
      debugPrint('$st');
      if (!mounted) return;
      await _showError(authErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Login'),
        border: null,
        backgroundColor: CupertinoColors.white,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              AuthField(
                label: 'EMAIL',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 24),
              AuthField(
                label: 'PASSWORD',
                obscure: true,
                controller: _passwordController,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'forgot password?',
                    style: TextStyle(
                      color: CupertinoColors.activeBlue,
                      decoration: TextDecoration.underline,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const SocialAuthRow(),
              const SizedBox(height: 40),
              Center(
                child: _loading
                    ? const CupertinoActivityIndicator()
                    : PrimaryAuthButton(
                        label: 'LOG IN',
                        onPressed: _handleLogin,
                      ),
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () => context.go('/register'),
                  child: const Text(
                    "don't have an account?",
                    style: TextStyle(
                      color: CupertinoColors.activeBlue,
                      decoration: TextDecoration.underline,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
