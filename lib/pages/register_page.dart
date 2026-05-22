import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../services/auth_service.dart';
import '../services/messaging_service.dart';
import '../widgets/auth_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _showError(String message) {
    return showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Registration failed'),
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

  Future<void> _handleRegister() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (email.isEmpty || password.isEmpty) {
      await _showError('Please enter your email and password.');
      return;
    }
    if (password != confirm) {
      await _showError('Passwords do not match.');
      return;
    }

    setState(() => _loading = true);
    try {
      await AuthService.instance.register(email: email, password: password);
      await MessagingService.instance.upsertCurrentUser();
      if (!mounted) return;
      context.go('/home');
    } catch (e, st) {
      debugPrint('Register error: $e');
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
        middle: Text('Register'),
        border: null,
        backgroundColor: CupertinoColors.white,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
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
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 24),
              AuthField(
                label: 'CONFIRM PASSWORD',
                obscure: true,
                controller: _confirmController,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 40),
              const SocialAuthRow(),
              const SizedBox(height: 40),
              Center(
                child: _loading
                    ? const CupertinoActivityIndicator()
                    : PrimaryAuthButton(
                        label: 'SIGN UP',
                        onPressed: _handleRegister,
                      ),
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () => context.go('/login'),
                  child: const Text(
                    'already have an account?',
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
