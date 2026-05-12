import 'package:flutter/cupertino.dart';

import '../widgets/meal_section.dart';
import 'home_page.dart' show Divider;

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  int _selectedDay = 18;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCalendar(),
            const SizedBox(height: 24),
            const MealSection(
              label: 'Breakfast',
              title: 'Frozen Eggo waffles\nand fruit',
              details: ['1 Eggo waffle box', '1 Apple', '1 Pineapple'],
            ),
            const Divider(),
            const MealSection(
              label: 'Lunch',
              title: 'Leftovers from\nChipotle',
              subtitle: 'No Prep Required!',
            ),
            const Divider(),
            const MealSection(
              label: 'Next Meal',
              title: 'Salmon Nigiri with Gyoza\nand Ika Geso',
              details: [
                '1 1/2 cups (320 g) Calrose rice (sushi rice)',
                '3/4 cups (430 ml) water',
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    const daysHeader = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    // Rough May 2023 layout starting Monday May 1
    final weeks = <List<int?>>[
      [1, 2, 3, 4, 5, 6, 7],
      [8, 9, 10, 11, 12, 13, 14],
      [15, 16, 17, 18, 19, 20, 21],
      [22, 23, 24, 25, 26, 27, 28],
      [29, 30, 31, null, null, null, null],
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: CupertinoColors.separator),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'May 2023',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Icon(CupertinoIcons.chevron_left, size: 18),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {},
                child: const Icon(CupertinoIcons.chevron_right, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: daysHeader
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: const TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 4),
          for (final week in weeks)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: week.map((day) {
                  if (day == null) return const Expanded(child: SizedBox());
                  final isSelected = day == _selectedDay;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedDay = day),
                      child: Container(
                        height: 32,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? CupertinoColors.activeBlue
                              : null,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected
                                  ? CupertinoColors.white
                                  : CupertinoColors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
