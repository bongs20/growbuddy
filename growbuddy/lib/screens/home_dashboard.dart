import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/firebase_service.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({
    super.key,
    required this.deviceId,
    required this.onDeviceUnlinked,
    this.bottomNavigationBar,
  });

  final String deviceId;
  final VoidCallback onDeviceUnlinked;
  final Widget? bottomNavigationBar;

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isSubmitting = false;
  bool? _effectiveOnline;
  Timer? _staleCheckTimer;
  static const int _staleThresholdMs = 30000; // 30 seconds

  Future<void> _triggerWater(int moisture) async {
    if (_isSubmitting) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User anonim belum tersedia.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _firebaseService.triggerWaterNow(
        uid: user.uid,
        deviceId: widget.deviceId,
        moistureBefore: moisture,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perintah siram berhasil dikirim.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim perintah: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<Object?, Object?>>(
      stream: _firebaseService.watchDevice(widget.deviceId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('GrowBuddy Dashboard')),
            body: Center(
              child: Text('Gagal membaca device: ${snapshot.error}'),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final deviceData = snapshot.data ?? <Object?, Object?>{};

        final moisture = _readInt(deviceData['moisture']);
        final status = '${deviceData['status'] ?? 'unknown'}';
        final online = _readBool(deviceData['online']);
        final lastUpdate = _readTimestamp(deviceData['last_update']);

        // Determine staleness: if last_update is too old, consider device offline
        final now = DateTime.now();
        final isStale = lastUpdate == null
            ? true
            : now.difference(lastUpdate).inMilliseconds > _staleThresholdMs;
        final currentEffectiveOnline = online && !isStale;

        // If effective online status changed, notify user briefly
        if (_effectiveOnline != null && _effectiveOnline != currentEffectiveOnline) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            final messenger = ScaffoldMessenger.of(context);
            if (currentEffectiveOnline) {
              messenger.showSnackBar(
                const SnackBar(content: Text('Perangkat kembali terhubung'), duration: Duration(seconds: 2)),
              );
            } else {
              messenger.showSnackBar(
                const SnackBar(content: Text('Perangkat terputus / tidak merespon'), duration: Duration(seconds: 2)),
              );
            }
          });
        }
        
        if (_effectiveOnline != currentEffectiveOnline) {
           _effectiveOnline = currentEffectiveOnline;
        }

        // Periodic stale check: ensure we keep evaluating staleness even when
        // no DB events arrive (in case of long silence)
        _staleCheckTimer?.cancel();
        _staleCheckTimer = Timer(const Duration(seconds: 15), () {
          if (!mounted) return;
          setState(() {
            // This force-rebuilds to re-calculate 'isStale' based on current time
          });
        });

        final control = _readMap(deviceData['control']);
        final game = _readMap(deviceData['game']);

        final siramRequested = _readBool(control['siram']);
        final durationSeconds = _firebaseService.readPumpDurationSeconds(
          deviceData,
        );
        final score = _readInt(game['score']);
        final level = _readInt(game['level']);
        final lastScoreDelta = _readInt(game['last_score_delta']);
        final lastScoreReason =
            '${game['last_score_reason'] ?? 'Belum ada evaluasi skor.'}';

        return Scaffold(
          appBar: AppBar(
            title: const Text('GrowBuddy Dashboard'),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => HistoryScreen(deviceId: widget.deviceId),
                    ),
                  );
                },
                icon: const Icon(Icons.history),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SettingsScreen(
                        deviceId: widget.deviceId,
                        onDeviceUnlinked: widget.onDeviceUnlinked,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.settings),
              ),
            ],
          ),
          bottomNavigationBar: widget.bottomNavigationBar,
          body: RefreshIndicator(
            onRefresh: () async {
              await _firebaseService.fetchDevice(widget.deviceId);
            },
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _DeviceSummaryCard(
                  deviceId: widget.deviceId,
                  status: status,
                  online: currentEffectiveOnline,
                  moisture: moisture,
                  lastUpdate: lastUpdate,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        label: 'Score',
                        value: '$score',
                        icon: Icons.stars_rounded,
                        color: const Color(0xFFFFD34D),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MetricCard(
                        label: 'Level',
                        value: '$level',
                        icon: Icons.terrain_rounded,
                        color: const Color(0xFF88C070),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Ringkasan Perawatan',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FriendlyInfoLine(
                        label: 'Status tanaman',
                        value: _friendlyStatus(status),
                      ),
                      _FriendlyInfoLine(
                        label: 'Kondisi perangkat',
                        value: currentEffectiveOnline ? 'Terhubung dan aktif' : 'Sedang offline',
                      ),
                      _FriendlyInfoLine(
                        label: 'Durasi penyiraman',
                        value: '$durationSeconds detik per siklus',
                      ),
                      _FriendlyInfoLine(
                        label: 'Permintaan siram',
                        value: siramRequested
                            ? 'Sedang diproses oleh perangkat'
                            : 'Siap menerima perintah',
                      ),
                      _FriendlyInfoLine(
                        label: 'Pembaruan terakhir',
                        value: lastUpdate == null
                            ? 'Belum ada data terbaru'
                            : _formatDateTime(lastUpdate),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Evaluasi Skor Terakhir',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lastScoreDelta >= 0
                            ? '+$lastScoreDelta poin'
                            : '$lastScoreDelta poin',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: lastScoreDelta >= 0
                              ? const Color(0xFF376A25)
                              : const Color(0xFF9B3D2F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        lastScoreReason,
                        style: const TextStyle(
                          color: Color(0xFF5E6653),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Kontrol',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        siramRequested
                            ? 'Perintah siram masih aktif di device.'
                            : 'Tekan tombol untuk meminta perangkat menyiram tanaman sesuai durasi pompa yang tersimpan.',
                        style: const TextStyle(color: Color(0xFF5E6653)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Durasi pompa saat ini: $durationSeconds detik',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF376A25),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _isSubmitting || !currentEffectiveOnline
                            ? null
                            : () => _triggerWater(moisture),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF376A25),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.water_drop_rounded),
                        label: Text(
                          _isSubmitting ? 'Mengirim...' : 'Siram Sekarang',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _HistorySection(
                  firebaseService: _firebaseService,
                  deviceId: widget.deviceId,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _staleCheckTimer?.cancel();
    super.dispose();
  }
}

class _DeviceSummaryCard extends StatelessWidget {
  const _DeviceSummaryCard({
    required this.deviceId,
    required this.status,
    required this.online,
    required this.moisture,
    required this.lastUpdate,
  });

  final String deviceId;
  final String status;
  final bool online;
  final int moisture;
  final DateTime? lastUpdate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFFEDF7E8), Color(0xFFFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF88C070).withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFF376A25),
                child: Icon(Icons.eco, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deviceId,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      status,
                      style: const TextStyle(color: Color(0xFF5E6653)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: online
                      ? const Color(0xFFDFF4E2)
                      : const Color(0xFFF4E4DF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  online ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: online
                        ? const Color(0xFF376A25)
                        : const Color(0xFF9B3D2F),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Kelembapan Tanah',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: (moisture.clamp(0, 100)) / 100,
              minHeight: 14,
              backgroundColor: const Color(0xFFF0ECD9),
              color: const Color(0xFF88C070),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$moisture%',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF376A25),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            lastUpdate == null
                ? 'Belum ada last_update'
                : 'Update terakhir: ${_formatDateTime(lastUpdate!)}',
            style: const TextStyle(color: Color(0xFF5E6653)),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.2),
            foregroundColor: const Color(0xFF1E1C0F),
            child: Icon(icon),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Color(0xFF5E6653))),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _FriendlyInfoLine extends StatelessWidget {
  const _FriendlyInfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF5E6653),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({
    required this.firebaseService,
    required this.deviceId,
  });

  final FirebaseService firebaseService;
  final String deviceId;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'History Penyiraman',
      child: StreamBuilder<List<Map<Object?, Object?>>>(
        stream: firebaseService.watchHistory(deviceId),
        builder: (context, snapshot) {
          final historyEntries = snapshot.data ?? const [];
          if (historyEntries.isEmpty) {
            return const Text(
              'Belum ada history pada device ini.',
              style: TextStyle(color: Color(0xFF5E6653)),
            );
          }

          return Column(
            children: historyEntries.map((item) {
              final title = '${item['title'] ?? 'History'}';
              final moistureBefore = _readInt(item['moisture_before']);
              final moistureAfter = _readInt(item['moisture_after']);
              final durationSeconds = _readInt(item['duration_seconds']);
              final createdAt = _readTimestamp(item['created_at']);
              final triggeredBy = '${item['triggered_by'] ?? '-'}';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F6EC),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFFDFF4E2),
                      child: Icon(
                        Icons.water_drop_rounded,
                        color: Color(0xFF376A25),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Moisture sebelum siram: $moistureBefore%',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF5E6653),
                            ),
                          ),
                          Text(
                            'Moisture sesudah siram: $moistureAfter%',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF5E6653),
                            ),
                          ),
                          Text(
                            'Durasi pompa: $durationSeconds detik',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF5E6653),
                            ),
                          ),
                          Text(
                            'UID: $triggeredBy',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF5E6653),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      createdAt == null ? '-' : _formatShortDateTime(createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

Map<Object?, Object?> _readMap(Object? value) {
  if (value is Map) {
    return Map<Object?, Object?>.from(value);
  }
  return <Object?, Object?>{};
}

bool _readBool(Object? value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  return '$value'.toLowerCase() == 'true';
}

int _readInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is double) {
    return value.round();
  }
  return int.tryParse('$value') ?? 0;
}

DateTime? _readTimestamp(Object? value) {
  final timestamp = _readInt(value);
  if (timestamp <= 0) {
    return null;
  }

  if (timestamp < 1000000000000) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  }
  return DateTime.fromMillisecondsSinceEpoch(timestamp);
}

String _formatDateTime(DateTime value) {
  final local = value.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final year = local.year;
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  final second = local.second.toString().padLeft(2, '0');
  return '$day/$month/$year $hour:$minute:$second';
}

String _formatShortDateTime(DateTime value) {
  final local = value.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day/$month $hour:$minute';
}

String _friendlyStatus(String status) {
  switch (status) {
    case 'critical_dry':
      return 'Sangat kering';
    case 'dry':
      return 'Perlu disiram';
    case 'healthy':
      return 'Sehat';
    case 'wet':
      return 'Cukup basah';
    case 'overwatered':
      return 'Terlalu basah';
    case 'watering':
      return 'Sedang disiram';
    case 'offline':
      return 'Perangkat offline';
    case 'sensor_error':
      return 'Sensor bermasalah/terlepas';
    default:
      return status;
  }
}
