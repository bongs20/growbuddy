import 'package:flutter/material.dart';

class GrowBottomNavigationBar extends StatelessWidget {
  const GrowBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final items = <({IconData icon, String label})>[
      (icon: Icons.home_rounded, label: 'Beranda'),
      (icon: Icons.history_rounded, label: 'Riwayat'),
      (icon: Icons.task_alt_rounded, label: 'Misi'),
      (icon: Icons.notifications_rounded, label: 'Notif'),
    ];

    return NavigationBarTheme(
      data: NavigationBarThemeData(
        height: 76,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE6F7EE),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: active ? const Color(0xFF376A25) : Colors.grey,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return IconThemeData(
            color: active ? const Color(0xFF376A25) : Colors.grey,
            size: 24,
          );
        }),
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: onTap,
        destinations: items
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.icon),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }
}
