import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../widgets/auth_field.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
              const AuthField(label: 'USERNAME'),
              const SizedBox(height: 24),
              const AuthField(label: 'PASSWORD', obscure: true),
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
                child: PrimaryAuthButton(
                  label: 'LOG IN',
                  onPressed: () => context.go('/home'),
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
