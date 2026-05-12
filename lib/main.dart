import 'package:flutter/cupertino.dart';
import 'dart:math' as math;

void main() => runApp(const AnimationLabApp());

enum AnimationType { rotate, scale, slide, fade }

enum IconType { rocket, heart, gear, star }

class AnimationLabApp extends StatelessWidget {
  const AnimationLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      theme: CupertinoThemeData(brightness: Brightness.light),
      home: AnimationLabPage(),
    );
  }
}

class AnimationLabPage extends StatefulWidget {
  const AnimationLabPage({super.key});

  @override
  State<AnimationLabPage> createState() => _AnimationLabPageState();
}

class _AnimationLabPageState extends State<AnimationLabPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  AnimationType _selectedType = AnimationType.rotate;
  IconType _selectedIcon = IconType.rocket;
  String _currentStatus = "READY";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _controller.addStatusListener((status) {
      setState(() {
        switch (status) {
          case AnimationStatus.forward:
            _currentStatus = "RUNNING FORWARD";
            break;
          case AnimationStatus.reverse:
            _currentStatus = "RUNNING REVERSE";
            break;
          case AnimationStatus.completed:
            _currentStatus = "COMPLETED";
            break;
          case AnimationStatus.dismissed:
            _currentStatus = "READY";
            break;
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showAnimationSheet(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Select Animation'),
        actions: AnimationType.values.map((type) {
          return CupertinoActionSheetAction(
            onPressed: () {
              setState(() => _selectedType = type);
              _controller.reset();
              Navigator.pop(context);
            },
            child: Text(type.name.toUpperCase()),
          );
        }).toList(),
      ),
    );
  }

  void _showIconSheet(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Select Icon'),
        actions: IconType.values.map((type) {
          return CupertinoActionSheetAction(
            onPressed: () {
              setState(() => _selectedIcon = type);
              Navigator.pop(context);
            },
            child: Text(type.name.toUpperCase()),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Animation Lab'),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoButton(
                  color: CupertinoColors.systemGroupedBackground,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  onPressed: () => _showAnimationSheet(context),
                  child: Text(
                    _selectedType.name.toUpperCase(),
                    style: const TextStyle(
                      color: CupertinoColors.activeBlue,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CupertinoButton(
                  color: CupertinoColors.systemGroupedBackground,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  onPressed: () => _showIconSheet(context),
                  child: Text(
                    _selectedIcon.name.toUpperCase(),
                    style: const TextStyle(
                      color: CupertinoColors.activeOrange,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: CupertinoColors.activeGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "STATUS: $_currentStatus",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.activeGreen,
                  fontSize: 12,
                ),
              ),
            ),
            SizedBox(
              height: 200,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return _buildAnimatedWidget();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CupertinoButton.filled(
                          onPressed: () => _controller.forward(),
                          child: const Text('Start'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CupertinoButton(
                          color: CupertinoColors.systemRed,
                          onPressed: () => _controller.stop(),
                          child: const Text('Stop'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: CupertinoButton(
                          color: CupertinoColors.systemIndigo,
                          onPressed: () => _controller.reverse(),
                          child: const Text('Reverse'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CupertinoButton(
                          color: CupertinoColors.systemGrey,
                          onPressed: () => _controller.reset(),
                          child: const Text('Reset'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getIcon() {
    IconData data;
    Color color;
    switch (_selectedIcon) {
      case IconType.rocket:
        data = CupertinoIcons.rocket_fill;
        color = CupertinoColors.activeBlue;
        break;
      case IconType.heart:
        data = CupertinoIcons.heart_fill;
        color = CupertinoColors.systemRed;
        break;
      case IconType.gear:
        data = CupertinoIcons.settings_solid;
        color = CupertinoColors.systemGrey;
        break;
      case IconType.star:
        data = CupertinoIcons.star_fill;
        color = CupertinoColors.systemYellow;
        break;
    }
    return Icon(data, size: 100, color: color);
  }

  Widget _buildAnimatedWidget() {
    final activeIcon = _getIcon();
    switch (_selectedType) {
      case AnimationType.rotate:
        return Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: activeIcon,
        );
      case AnimationType.scale:
        return Transform.scale(
          scale: 0.5 + (_controller.value * 1.0),
          child: activeIcon,
        );
      case AnimationType.slide:
        return FractionalTranslation(
          translation: Offset(0, -_controller.value),
          child: activeIcon,
        );
      case AnimationType.fade:
        return Opacity(opacity: _controller.value, child: activeIcon);
    }
  }
}
