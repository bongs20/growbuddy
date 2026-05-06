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
    final bottomNavigationBar = GrowBottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        if (_currentIndex == index) {
          return;
        }
        setState(() {
          _currentIndex = index;
        });
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

    return IndexedStack(index: _currentIndex, children: screens);
  }
}
