import 'package:flutter/cupertino.dart';
import 'dart:math' as math;

void main() => runApp(const AnimationLabApp());

enum AnimationType { rotate, scale, slide, fade }

enum IconType { rocket, heart, gear, star }

enum CurveType { linear, easeIn, easeOut, bounce, elastic }

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
  CurveType _selectedCurve = CurveType.linear; // Default curve
  String _currentStatus = "READY";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _controller.addStatusListener((status) {
      setState(() {
        _currentStatus = status.name.toUpperCase();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Curve _getActualCurve() {
    switch (_selectedCurve) {
      case CurveType.linear:
        return Curves.linear;
      case CurveType.easeIn:
        return Curves.easeIn;
      case CurveType.easeOut:
        return Curves.easeOut;
      case CurveType.bounce:
        return Curves.bounceOut;
      case CurveType.elastic:
        return Curves.elasticOut;
    }
  }

  void _showSheet<T>(String title, List<T> values, Function(T) onSelect) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(title),
        actions: values.map((value) {
          final String name = value.toString().split('.').last.toUpperCase();
          return CupertinoActionSheetAction(
            onPressed: () {
              onSelect(value);
              Navigator.pop(context);
            },
            child: Text(name),
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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildPickerButton(
                  _selectedType.name,
                  CupertinoColors.activeBlue,
                  () => _showSheet(
                    "Animation",
                    AnimationType.values,
                    (v) => setState(() => _selectedType = v),
                  ),
                ),
                _buildPickerButton(
                  _selectedIcon.name,
                  CupertinoColors.activeOrange,
                  () => _showSheet(
                    "Icon",
                    IconType.values,
                    (v) => setState(() => _selectedIcon = v),
                  ),
                ),
                _buildPickerButton(
                  _selectedCurve.name,
                  CupertinoColors.systemPurple,
                  () => _showSheet(
                    "Curve",
                    CurveType.values,
                    (v) => setState(() => _selectedCurve = v),
                  ),
                ),
              ],
            ),

            _buildStatusIndicator(),

            SizedBox(
              height: 200,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return _buildAnimatedWidget(
                    _getActualCurve().transform(_controller.value),
                  );
                },
              ),
            ),

            _buildPlaybackControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerButton(String label, Color color, VoidCallback onPressed) {
    return CupertinoButton(
      color: CupertinoColors.systemGroupedBackground,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      onPressed: onPressed,
      child: Text(
        label.toUpperCase(),
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
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
    );
  }

  Widget _buildAnimatedWidget(double animValue) {
    final activeIcon = _getIcon();
    switch (_selectedType) {
      case AnimationType.rotate:
        return Transform.rotate(
          angle: animValue * 2 * math.pi,
          child: activeIcon,
        );
      case AnimationType.scale:
        return Transform.scale(
          scale: 0.5 + (animValue * 1.0),
          child: activeIcon,
        );
      case AnimationType.slide:
        return FractionalTranslation(
          translation: Offset(0, -animValue),
          child: activeIcon,
        );
      case AnimationType.fade:
        return Opacity(opacity: animValue.clamp(0.0, 1.0), child: activeIcon);
    }
  }

  Widget _getIcon() {
    final Map<IconType, (IconData, Color)> iconMap = {
      IconType.rocket: (CupertinoIcons.rocket_fill, CupertinoColors.activeBlue),
      IconType.heart: (CupertinoIcons.heart_fill, CupertinoColors.systemRed),
      IconType.gear: (
        CupertinoIcons.settings_solid,
        CupertinoColors.systemGrey,
      ),
      IconType.star: (CupertinoIcons.star_fill, CupertinoColors.systemYellow),
    };
    final config = iconMap[_selectedIcon]!;
    return Icon(config.$1, size: 100, color: config.$2);
  }

  Widget _buildPlaybackControls() {
    return Padding(
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
    );
  }
}
