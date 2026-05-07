import 'package:flutter/material.dart';

import '../widgets/grow_bottom_navigation_bar.dart';
import 'history_screen.dart';
import 'home_dashboard.dart';
import 'missions_screen.dart';
import 'notifications_screen.dart';

class DeviceShellScreen extends StatefulWidget {
  const DeviceShellScreen({
    super.key,
    required this.deviceId,
    required this.onDeviceUnlinked,
    this.initialIndex = 0,
  });

  final String deviceId;
  final VoidCallback onDeviceUnlinked;
  final int initialIndex;

  @override
  State<DeviceShellScreen> createState() => _DeviceShellScreenState();
}

class _DeviceShellScreenState extends State<DeviceShellScreen> {
  late int _currentIndex = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > 900;

        final bottomNavigationBar = isDesktop
            ? null
            : GrowBottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  if (_currentIndex == index) return;
                  setState(() => _currentIndex = index);
                },
              );

        final screens = [
          HomeDashboardScreen(
            deviceId: widget.deviceId,
            onDeviceUnlinked: widget.onDeviceUnlinked,
            bottomNavigationBar: bottomNavigationBar,
          ),
          HistoryScreen(
            deviceId: widget.deviceId,
            bottomNavigationBar: bottomNavigationBar,
          ),
          MissionsScreen(
            deviceId: widget.deviceId,
            bottomNavigationBar: bottomNavigationBar,
          ),
          NotificationsScreen(
            deviceId: widget.deviceId,
            bottomNavigationBar: bottomNavigationBar,
          ),
        ];

        if (isDesktop) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) {
                    setState(() => _currentIndex = index);
                  },
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: Colors.white,
                  indicatorColor: const Color(0xFFE6F7EE),
                  selectedIconTheme: const IconThemeData(color: Color(0xFF376A25)),
                  unselectedIconTheme: const IconThemeData(color: Colors.grey),
                  selectedLabelTextStyle: const TextStyle(
                    color: Color(0xFF376A25),
                    fontWeight: FontWeight.bold,
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_rounded),
                      label: Text('Beranda'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.history_rounded),
                      label: Text('Riwayat'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.task_alt_rounded),
                      label: Text('Misi'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.notifications_rounded),
                      label: Text('Notif'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: screens[_currentIndex]),
              ],
            ),
          );
        }

        return IndexedStack(index: _currentIndex, children: screens);
      },
    );
  }
}
