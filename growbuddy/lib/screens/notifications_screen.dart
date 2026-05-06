import 'package:flutter/material.dart';

import '../services/firebase_service.dart';

class NotificationsScreen extends StatelessWidget {
  NotificationsScreen({
    super.key,
    required this.deviceId,
    this.bottomNavigationBar,
  });

  final String deviceId;
  final Widget? bottomNavigationBar;
  final FirebaseService _service = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<Object?, Object?>>(
      stream: _service.watchDevice(deviceId),
      builder: (context, deviceSnapshot) {
        final deviceData = deviceSnapshot.data ?? const <Object?, Object?>{};
        final control = _readMap(deviceData['control']);
        final moisture = _readInt(deviceData['moisture']);
        final online = _readBool(deviceData['online']);
        final status = '${deviceData['status'] ?? 'unknown'}';
        final executionStatus = '${control['execution_status'] ?? ''}';
        final executionReason = '${control['execution_reason'] ?? ''}';
        final updatedAt = _readTimestamp(deviceData['last_update']);

        return StreamBuilder<List<Map<Object?, Object?>>>(
          stream: _service.watchHistory(deviceId, limit: 8),
          builder: (context, historySnapshot) {
            final notifications = _buildNotifications(
              moisture: moisture,
              online: online,
              status: status,
              executionStatus: executionStatus,
              executionReason: executionReason,
              updatedAt: updatedAt,
              history: historySnapshot.data ?? const [],
            );

            return Scaffold(
              backgroundColor: const Color(0xFFFFF9E7),
              appBar: AppBar(title: const Text('Notifikasi')),
              body: notifications.isEmpty
                  ? _emptyState()
                  : ListView(
                      padding: const EdgeInsets.all(20),
                      children: notifications,
                    ),
              bottomNavigationBar: bottomNavigationBar,
            );
          },
        );
      },
    );
  }

  List<Widget> _buildNotifications({
    required int moisture,
    required bool online,
    required String status,
    required String executionStatus,
    required String executionReason,
    required DateTime? updatedAt,
    required List<Map<Object?, Object?>> history,
  }) {
    final cards = <Widget>[];

    if (!online) {
      cards.add(
        _notificationCard(
          icon: Icons.wifi_off_rounded,
          iconBg: const Color(0xFFF4E4DF),
          iconColor: const Color(0xFF9B3D2F),
          title: 'Perangkat sedang offline',
          message: updatedAt == null
              ? 'GrowBuddy belum mengirim data terbaru.'
              : 'Terakhir aktif pada ${_formatTime(updatedAt)}.',
        ),
      );
    }

    if (moisture < FirebaseService.dryMoistureThreshold) {
      cards.add(
        _notificationCard(
          icon: Icons.local_drink_outlined,
          iconBg: const Color(0xFFFEE4BF),
          iconColor: const Color(0xFF8A4B00),
          title: 'Tanah mulai kering',
          message:
              'Kelembapan saat ini $moisture%. Pertimbangkan penyiraman agar tanaman tidak stres.',
        ),
      );
    } else if (status == 'overwatered') {
      cards.add(
        _notificationCard(
          icon: Icons.water_damage_outlined,
          iconBg: const Color(0xFFE3F1FF),
          iconColor: const Color(0xFF245B90),
          title: 'Tanah terlalu basah',
          message:
              'Kelembapan saat ini $moisture%. Tunda penyiraman berikutnya sampai tanah lebih stabil.',
        ),
      );
    }

    if (executionStatus == 'completed' || executionStatus == 'skipped') {
      cards.add(
        _notificationCard(
          icon: executionStatus == 'completed'
              ? Icons.check_circle_outline
              : Icons.info_outline,
          iconBg: executionStatus == 'completed'
              ? const Color(0xFFEAF7EC)
              : const Color(0xFFF4EED8),
          iconColor: executionStatus == 'completed'
              ? const Color(0xFF376A25)
              : const Color(0xFF735C00),
          title: executionStatus == 'completed'
              ? 'Penyiraman selesai'
              : 'Penyiraman dilewati',
          message: _humanizeExecutionReason(executionReason),
        ),
      );
    }

    if (history.isNotEmpty) {
      final latest = history.first;
      final scoreDelta = _readInt(latest['score_delta']);
      final scoreReason = '${latest['score_reason'] ?? 'Skor diperbarui.'}';
      cards.add(
        _notificationCard(
          icon: scoreDelta >= 0 ? Icons.stars_rounded : Icons.trending_down,
          iconBg: scoreDelta >= 0
              ? const Color(0xFFFFE088)
              : const Color(0xFFF4E4DF),
          iconColor: scoreDelta >= 0
              ? const Color(0xFF735C00)
              : const Color(0xFF9B3D2F),
          title: scoreDelta >= 0
              ? 'Skor bertambah ${scoreDelta.abs()} poin'
              : 'Skor berkurang ${scoreDelta.abs()} poin',
          message: scoreReason,
        ),
      );
    }

    return cards;
  }

  Widget _notificationCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String message,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFF5E6653),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Color(0xFFEAF7EC),
                child: Icon(
                  Icons.notifications_active_outlined,
                  color: Color(0xFF376A25),
                  size: 28,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Belum ada notifikasi penting',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 8),
              Text(
                'Saat kondisi tanah berubah atau perangkat menyelesaikan penyiraman, pemberitahuan akan muncul di sini.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF5E6653)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _humanizeExecutionReason(String reason) {
    switch (reason) {
      case 'watering_completed':
        return 'Perangkat berhasil menyelesaikan penyiraman sesuai durasi pompa.';
      case 'moisture_above_threshold':
        return 'Penyiraman dibatalkan karena tanah masih terlalu basah.';
      case 'cooldown_active':
        return 'Penyiraman ditunda karena perangkat masih dalam masa jeda aman.';
      case 'pump_running':
        return 'Pompa sedang berjalan.';
      default:
        return 'Status perangkat telah diperbarui.';
    }
  }

  static Map<Object?, Object?> _readMap(Object? value) {
    if (value is Map) {
      return Map<Object?, Object?>.from(value);
    }
    return <Object?, Object?>{};
  }

  static int _readInt(Object? value) {
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse('$value') ?? 0;
  }

  static bool _readBool(Object? value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    return '$value'.toLowerCase() == 'true';
  }

  static DateTime? _readTimestamp(Object? value) {
    final raw = _readInt(value);
    if (raw <= 0) {
      return null;
    }
    if (raw < 1000000000000) {
      return DateTime.fromMillisecondsSinceEpoch(raw * 1000);
    }
    return DateTime.fromMillisecondsSinceEpoch(raw);
  }

  static String _formatTime(DateTime value) {
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month $hour:$minute';
  }
}
