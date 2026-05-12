import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prev() {
    if (_page > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: const [
                  _OnboardSlide(
                    icon: CupertinoIcons.cart,
                    title: 'Get recipes for the\nfood you have',
                  ),
                  _OnboardSlide(
                    icon: CupertinoIcons.globe,
                    title: 'Save the world by\nsaving food',
                  ),
                  _OnboardSlide(
                    icon: CupertinoIcons.person_2,
                    title: 'Organize meals with\nyour household',
                    isLast: true,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _page == 0 ? null : _prev,
                    child: Icon(
                      CupertinoIcons.chevron_left,
                      color: _page == 0
                          ? CupertinoColors.systemGrey3
                          : CupertinoColors.black,
                    ),
                  ),
                  Row(
                    children: List.generate(
                      3,
                      (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _page == i
                              ? CupertinoColors.black
                              : CupertinoColors.systemGrey3,
                        ),
                      ),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _page == 2 ? null : _next,
                    child: Icon(
                      CupertinoIcons.chevron_right,
                      color: _page == 2
                          ? CupertinoColors.systemGrey3
                          : CupertinoColors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardSlide extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isLast;

  const _OnboardSlide({
    required this.icon,
    required this.title,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 140, color: CupertinoColors.black),
          const SizedBox(height: 64),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.black,
            ),
          ),
          if (isLast) ...[
            const SizedBox(height: 40),
            _ActionButton(
              label: 'REGISTER',
              onPressed: () => context.go('/register'),
            ),
            const SizedBox(height: 12),
            _ActionButton(
              label: 'SIGN IN',
              onPressed: () => context.go('/login'),
            ),
            const SizedBox(height: 12),
            _ActionButton(
              label: 'GUEST',
              onPressed: () => context.go('/home'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 10),
        color: CupertinoColors.black,
        borderRadius: BorderRadius.circular(4),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
