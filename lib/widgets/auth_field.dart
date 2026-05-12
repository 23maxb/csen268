import 'package:flutter/cupertino.dart';

class AuthField extends StatelessWidget {
  final String label;
  final bool obscure;
  final TextEditingController? controller;

  const AuthField({
    super.key,
    required this.label,
    this.obscure = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            letterSpacing: 1.2,
            color: CupertinoColors.systemGrey,
          ),
        ),
        const SizedBox(height: 4),
        CupertinoTextField(
          controller: controller,
          obscureText: obscure,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: CupertinoColors.systemGrey3),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          style: const TextStyle(fontSize: 15),
        ),
      ],
    );
  }
}

class SocialAuthRow extends StatelessWidget {
  const SocialAuthRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialButton(
          onPressed: () {},
          child: const Text(
            'G',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 36),
        _SocialButton(
          onPressed: () {},
          child: const Icon(
            CupertinoIcons.app,
            size: 28,
            color: CupertinoColors.black,
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;

  const _SocialButton({required this.child, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(width: 48, height: 48, child: Center(child: child)),
    );
  }
}

class PrimaryAuthButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const PrimaryAuthButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 12),
        color: CupertinoColors.black,
        borderRadius: BorderRadius.circular(4),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
