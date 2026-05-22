import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../services/auth_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _meals = 3;
  int _calories = 2000;
  final Map<String, bool> _restrictions = {
    'Vegetarian': false,
    'Vegan': false,
    'Kosher': false,
    'Halal': true,
    'Custom': false,
  };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Stepper(
              label: 'Meals Per Day',
              value: _meals,
              onChanged: (v) => setState(() => _meals = v),
            ),
            const SizedBox(height: 16),
            _Stepper(
              label: 'Calorie Target',
              value: _calories,
              step: 100,
              onChanged: (v) => setState(() => _calories = v),
            ),
            const SizedBox(height: 24),
            const Text(
              'Dietary Restrictions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            for (final key in _restrictions.keys)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: Text(key)),
                    GestureDetector(
                      onTap: () => setState(
                          () => _restrictions[key] = !_restrictions[key]!),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: CupertinoColors.systemGrey),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: _restrictions[key]!
                            ? const Icon(
                                CupertinoIcons.check_mark,
                                size: 16,
                                color: CupertinoColors.black,
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                color: CupertinoColors.destructiveRed,
                onPressed: () async {
                  await AuthService.instance.signOut();
                  if (context.mounted) context.go('/login');
                },
                child: const Text('Log Out'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final String label;
  final int value;
  final int step;
  final ValueChanged<int> onChanged;

  const _Stepper({
    required this.label,
    required this.value,
    required this.onChanged,
    this.step = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
        GestureDetector(
          onTap: () => onChanged((value - step).clamp(0, 99999)),
          child: const Icon(CupertinoIcons.minus_circle, size: 22),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('$value', style: const TextStyle(fontSize: 15)),
        ),
        GestureDetector(
          onTap: () => onChanged(value + step),
          child: const Icon(CupertinoIcons.plus_circle, size: 22),
        ),
      ],
    );
  }
}
