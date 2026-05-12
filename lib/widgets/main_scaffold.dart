import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  final String location;

  const MainScaffold({
    super.key,
    required this.child,
    required this.location,
  });

  static const _tabs = [
    ('/home', CupertinoIcons.house),
    ('/calendar', CupertinoIcons.calendar),
    ('/inventory', CupertinoIcons.shopping_cart),
    ('/settings', CupertinoIcons.settings),
  ];

  int get _currentIndex {
    for (var i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].$1)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Column(
        children: [
          Expanded(child: child),
          Container(
            decoration: const BoxDecoration(
              color: CupertinoColors.white,
              border: Border(
                top: BorderSide(color: CupertinoColors.separator, width: 0.5),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 52,
                child: Row(
                  children: [
                    for (var i = 0; i < _tabs.length; i++)
                      Expanded(
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => context.go(_tabs[i].$1),
                          child: Icon(
                            _tabs[i].$2,
                            size: 26,
                            color: _currentIndex == i
                                ? CupertinoColors.black
                                : CupertinoColors.inactiveGray,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
