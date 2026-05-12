import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class MealSection extends StatelessWidget {
  final String label;
  final String title;
  final List<String> details;
  final String? subtitle;

  const MealSection({
    super.key,
    required this.label,
    required this.title,
    this.details = const [],
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/recipe'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14),
                  ),
                  if (details.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    for (final d in details)
                      Text(
                        d,
                        style: const TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                  ],
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const _IconBtn(icon: CupertinoIcons.check_mark),
          const SizedBox(width: 12),
          const _IconBtn(icon: CupertinoIcons.xmark),
          const SizedBox(width: 12),
          const _IconBtn(icon: CupertinoIcons.eye),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  const _IconBtn({required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Icon(icon, size: 18, color: CupertinoColors.black),
    );
  }
}
