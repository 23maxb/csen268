import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../services/auth_service.dart';
import '../services/settings_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<void>? _loadFuture;
  int _meals = SettingsService.defaultMeals;
  int _calories = SettingsService.defaultCalories;
  Map<String, bool> _restrictions = Map<String, bool>.from(
    SettingsService.defaultRestrictions,
  );
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFuture = _load();
  }

  Future<void> _load() async {
    try {
      final settings = await SettingsService.instance.fetchOrCreate();
      if (!mounted) return;
      setState(() {
        _meals = settings.meals;
        _calories = settings.calories;
        _restrictions = settings.restrictions;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await SettingsService.instance.save(
        UserSettings(
          meals: _meals,
          calories: _calories,
          restrictions: _restrictions,
        ),
      );
      if (!mounted) return;
      setState(() => _saving = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showError('Failed to save: $e');
    }
  }

  void _showError(String msg) {
    showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(msg),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<void>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          }
          if (_error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Failed to load settings.\n$_error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    CupertinoButton(
                      onPressed: () {
                        setState(() => _loadFuture = _load());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          return _buildContent(context);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_saving)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    CupertinoActivityIndicator(radius: 8),
                    SizedBox(width: 8),
                    Text(
                      'Saving...',
                      style: TextStyle(
                        fontSize: 13,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              ),
            _Stepper(
              label: 'Meals Per Day',
              value: _meals,
              onChanged: (v) {
                setState(() => _meals = v);
                _save();
              },
            ),
            const SizedBox(height: 16),
            _Stepper(
              label: 'Calorie Target',
              value: _calories,
              step: 100,
              onChanged: (v) {
                setState(() => _calories = v);
                _save();
              },
            ),
            const SizedBox(height: 24),
            // Header with the info button next to it
            Row(
              children: [
                const Text(
                  'Dietary Restrictions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => context.push('/diet-info'),
                  // Adjust path as needed for your router config
                  child: const Icon(
                    CupertinoIcons.info_circle,
                    size: 18,
                    color: CupertinoColors.activeBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final key in _restrictions.keys)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: Text(key)),
                    GestureDetector(
                      onTap: () {
                        setState(
                          () => _restrictions[key] = !_restrictions[key]!,
                        );
                        _save();
                      },
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          border: Border.all(color: CupertinoColors.systemGrey),
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
