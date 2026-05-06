import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'device_shell_screen.dart';
import 'calibration_screen.dart';
import '../services/firebase_service.dart';
import '../widgets/grow_bottom_navigation_bar.dart';

class SettingsScreen extends StatefulWidget {
  final String deviceId;
  final VoidCallback onDeviceUnlinked;
  final Widget? bottomNavigationBar;

  const SettingsScreen({
    super.key,
    required this.deviceId,
    required this.onDeviceUnlinked,
    this.bottomNavigationBar,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseService _svc = FirebaseService();
  bool _smartNotif = true;
  bool _autoWater = false;
  String _displayName = 'Plant Hero';
  String _plantFocus = 'Monstera Deliciosa';
  String _location = 'Rumah Kaca';

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
    _loadUserProfile();
  }

  Future<void> _loadUserSettings() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final settings = await _svc.loadUserSettings(uid);
    if (!mounted) return;

    setState(() {
      _smartNotif = settings['smart_notifications'] ?? true;
      _autoWater = settings['auto_water'] ?? false;
    });
  }

  Future<void> _loadUserProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final profile = await _svc.loadUserProfile(uid);
    if (!mounted) return;

    setState(() {
      _displayName = profile['display_name'] ?? 'Plant Hero';
      _plantFocus = profile['plant_focus'] ?? 'Monstera Deliciosa';
      _location = profile['location'] ?? 'Rumah Kaca';
    });
  }

  Future<void> _saveToggle({bool? smartNotif, bool? autoWater}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await _svc.saveUserSettings(
      uid: uid,
      smartNotif: smartNotif,
      autoWater: autoWater,
    );
  }

  Future<void> _editProfile() async {
    final nameController = TextEditingController(text: _displayName);
    final plantController = TextEditingController(text: _plantFocus);
    final locationController = TextEditingController(text: _location);

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profil'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama panggilan'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: plantController,
                decoration: const InputDecoration(labelText: 'Tanaman fokus'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Lokasi tanaman'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (shouldSave != true) {
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await _svc.saveUserProfile(
      uid: uid,
      displayName: nameController.text.trim().isEmpty
          ? _displayName
          : nameController.text.trim(),
      plantFocus: plantController.text.trim().isEmpty
          ? _plantFocus
          : plantController.text.trim(),
      location: locationController.text.trim().isEmpty
          ? _location
          : locationController.text.trim(),
    );

    await _loadUserProfile();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profil berhasil diperbarui')));
  }

  Future<void> _copyDeviceId() async {
    await Clipboard.setData(ClipboardData(text: widget.deviceId));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Device ID disalin')));
  }

  Future<void> _unlinkDevice() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    await _svc.clearDeviceId(uid);

    if (!mounted) {
      return;
    }

    widget.onDeviceUnlinked();
    messenger.showSnackBar(
      const SnackBar(content: Text('Hubungan perangkat dihapus')),
    );

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _editPumpDuration(int currentSeconds) async {
    final controller = TextEditingController(text: '$currentSeconds');

    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Durasi Pompa'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Detik',
              hintText: '1 - 60',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                final seconds = int.tryParse(controller.text.trim());
                if (seconds == null) {
                  return;
                }
                Navigator.of(context).pop(seconds);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (result == null) {
      return;
    }

    try {
      await _svc.setPumpDurationSeconds(
        deviceId: widget.deviceId,
        seconds: result,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Durasi pompa diubah menjadi $result detik')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan durasi: $error')));
    }
  }

  Widget _buildStandaloneBottomNavigationBar() {
    return GrowBottomNavigationBar(
      currentIndex: 0,
      onTap: (index) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => DeviceShellScreen(
              deviceId: widget.deviceId,
              onDeviceUnlinked: widget.onDeviceUnlinked,
              initialIndex: index,
            ),
          ),
          (route) => route.isFirst,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<Object?, Object?>>(
      stream: _svc.watchDevice(widget.deviceId),
      builder: (context, snapshot) {
        final data = snapshot.data ?? <Object?, Object?>{};

        final bool online = data['online'] == true;
        final String version =
            (data['fw_version'] ?? data['version'] ?? 'V.2.0.4-Alpha')
                .toString();
        final String wifiSsid =
            (data['wifi_ssid'] ?? data['wifi'] ?? 'IndoHome_5G').toString();
        final int pumpDurationSeconds = _svc.readPumpDurationSeconds(data);
        final initials = _displayName.trim().isEmpty
            ? 'P'
            : _displayName
                  .trim()
                  .split(RegExp(r'\s+'))
                  .take(2)
                  .map((part) => part[0].toUpperCase())
                  .join();

        return Scaffold(
          backgroundColor: const Color(0xFFFFF9E7),
          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 84, 20, 128),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _profileCard(
                        initials: initials,
                        displayName: _displayName,
                        plantFocus: _plantFocus,
                        location: _location,
                        deviceId: widget.deviceId,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Pengaturan',
                        style: TextStyle(
                          fontSize: 28,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E1C0F),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Kelola profil, perangkat, dan preferensi perawatan tanamanmu.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF42493D),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _squareStatusCard(
                              icon: Icons.wifi,
                              iconBg: const Color(0xFFAEEDD5),
                              iconColor: const Color(0xFF316D5B),
                              badgeText: 'Kuat',
                              badgeBg: const Color(0xFFB1EFD8),
                              badgeTextColor: const Color(0xFF2C6956),
                              title: 'WiFi Status',
                              value: wifiSsid,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _squareStatusCard(
                              icon: Icons.memory,
                              iconBg: const Color(
                                0xFFB8F29D,
                              ).withValues(alpha: 0.25),
                              iconColor: const Color(0xFF376A25),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: online
                                          ? const Color(0xFF376A25)
                                          : const Color(0xFF72796C),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    online ? 'Online' : 'Offline',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: online
                                          ? const Color(0xFF376A25)
                                          : const Color(0xFF72796C),
                                    ),
                                  ),
                                ],
                              ),
                              title: 'Status ESP32',
                              value: version,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _settingRow(
                        icon: Icons.fingerprint,
                        iconColor: const Color(0xFF72796C),
                        iconBg: const Color(0xFFF4EED8),
                        label: 'Perangkat terhubung',
                        value: widget.deviceId,
                        action: IconButton(
                          onPressed: _copyDeviceId,
                          icon: const Icon(
                            Icons.content_copy,
                            color: Color(0xFF72796C),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _settingRow(
                        icon: Icons.water_drop,
                        iconColor: const Color(0xFF2C6956),
                        iconBg: const Color(0xFFAEEDD5).withValues(alpha: 0.35),
                        label: 'Durasi pompa',
                        value: '$pumpDurationSeconds detik',
                        action: TextButton.icon(
                          onPressed: () =>
                              _editPumpDuration(pumpDurationSeconds),
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFEEE8D3),
                            foregroundColor: const Color(0xFF1E1C0F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                          ),
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text(
                            'Ubah',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _settingRow(
                        icon: Icons.person_outline,
                        iconColor: const Color(0xFF376A25),
                        iconBg: const Color(0xFFEAF7EC),
                        label: 'Profil',
                        value: 'Atur identitas dan preferensi tanaman',
                        action: TextButton.icon(
                          onPressed: _editProfile,
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFEEE8D3),
                            foregroundColor: const Color(0xFF1E1C0F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                          ),
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text(
                            'Edit',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _settingRow(
                        icon: Icons.tune,
                        iconColor: const Color(0xFF735C00),
                        iconBg: const Color(0xFFD1AE40).withValues(alpha: 0.2),
                        label: 'Kalibrasi sensor',
                        value: 'Sesuaikan sensor saat pembacaan kelembapan terasa kurang akurat',
                        action: IconButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CalibrationScreen(deviceId: widget.deviceId),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.info_outline,
                            color: Color(0xFF72796C),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF4DE),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Column(
                          children: [
                            _toggleRow(
                              icon: Icons.notifications_active,
                              iconColor: const Color(0xFF376A25),
                              label: 'Notifikasi pintar',
                              value: _smartNotif,
                              onChanged: (value) async {
                                setState(() => _smartNotif = value);
                                await _saveToggle(smartNotif: value);
                              },
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              height: 1,
                              color: const Color(
                                0xFFC2C9B9,
                              ).withValues(alpha: 0.4),
                            ),
                            _toggleRow(
                              icon: Icons.auto_mode,
                              iconColor: const Color(0xFF2C6956),
                              label: 'Siram otomatis',
                              value: _autoWater,
                              onChanged: (value) async {
                                setState(() => _autoWater = value);
                                await _saveToggle(autoWater: value);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _unlinkDevice,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          foregroundColor: const Color(0xFFBA1A1A),
                          side: BorderSide(
                            color: const Color(
                              0xFFBA1A1A,
                            ).withValues(alpha: 0.2),
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        icon: const Icon(Icons.delete),
                        label: const Text(
                          'Hapus Hubungan Perangkat',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Versi Aplikasi 1.4.2',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF72796C),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.86),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF88C070,
                          ).withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: const Color(0xFF88C070),
                                  backgroundImage: const NetworkImage(
                                    'https://lh3.googleusercontent.com/aida-public/AB6AXuB2LXToYIgThKkKP4L7_Q83pV5rhicOJJW39SbgS7LbFhY9VcBS8ZObYQLzelxZGXR5liNZGYs0_mviPzmT8Y-tDM4HSO8Yen0jK9wJLo8ZcOoxCgqzDX0ePxi6kkO-A_BO5cT9sa47rOAZaJIo1c0-0YEYjURwDwfVofk-lBjrG_Wb_2q2bgV6fcfIQtwcEb15azPrlfsEtsBXa5cVWDsKk_rtOLEb_-pbjPPB4ufdkrA8An9jzMRbuuCmCFNdJ1oc_IXlkbCV3Ns',
                                  ),
                                ),
                                Positioned(
                                  right: -2,
                                  bottom: -2,
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFE088),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.star,
                                      size: 10,
                                      color: Color(0xFF241A00),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _displayName,
                              style: const TextStyle(
                                color: Color(0xFF16A34A),
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.sensors,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar:
              widget.bottomNavigationBar ??
              _buildStandaloneBottomNavigationBar(),
        );
      },
    );
  }

  Widget _squareStatusCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String value,
    Widget? trailing,
    String? badgeText,
    Color? badgeBg,
    Color? badgeTextColor,
  }) {
    return Container(
      height: 168,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF88C070).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor),
              ),
              if (trailing != null)
                trailing
              else if (badgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg ?? const Color(0xFFB1EFD8),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: badgeTextColor ?? const Color(0xFF2C6956),
                    ),
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: Color(0xFF42493D),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E1C0F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileCard({
    required String initials,
    required String displayName,
    required String plantFocus,
    required String location,
    required String deviceId,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF376A25), Color(0xFF88C070)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF376A25).withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withValues(alpha: 0.16),
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$plantFocus • $location',
                  style: const TextStyle(
                    color: Color(0xFFF4FBEF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Perangkat aktif: $deviceId',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
    required Widget action,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF88C070).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF42493D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E1C0F),
                  ),
                ),
              ],
            ),
          ),
          action,
        ],
      ),
    );
  }

  Widget _toggleRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        GestureDetector(
          onTap: () => onChanged(!value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 56,
            height: 32,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: value ? const Color(0xFF376A25) : const Color(0xFFC2C9B9),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Align(
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
