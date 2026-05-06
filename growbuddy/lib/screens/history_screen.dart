import 'package:flutter/material.dart';

import '../services/firebase_service.dart';

class HistoryEntry {
  const HistoryEntry({
    required this.timeLabel,
    required this.title,
    required this.beforePct,
    required this.afterPct,
    required this.scoreDelta,
    required this.statusLabel,
    required this.reason,
    required this.accentColor,
    required this.badgeColor,
  });

  final String timeLabel;
  final String title;
  final int beforePct;
  final int afterPct;
  final int scoreDelta;
  final String statusLabel;
  final String reason;
  final Color accentColor;
  final Color badgeColor;
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, this.deviceId, this.bottomNavigationBar});

  final String? deviceId;
  final Widget? bottomNavigationBar;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FirebaseService _svc = FirebaseService();

  List<HistoryEntry> _demoEntries() => const [
    HistoryEntry(
      timeLabel: '14:30',
      title: 'Penyiraman sore',
      beforePct: 22,
      afterPct: 65,
      scoreDelta: 14,
      statusLabel: 'Tepat',
      reason: 'Tanah berhasil kembali ke zona ideal.',
      accentColor: Color(0xFF376A25),
      badgeColor: Color(0xFFB1EFD8),
    ),
    HistoryEntry(
      timeLabel: '08:15',
      title: 'Penyiraman pagi',
      beforePct: 74,
      afterPct: 88,
      scoreDelta: -8,
      statusLabel: 'Berlebih',
      reason: 'Penyiraman dilakukan saat tanah masih cukup basah.',
      accentColor: Color(0xFF9B3D2F),
      badgeColor: Color(0xFFF4E4DF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E7),
      appBar: AppBar(
        title: const Text('Riwayat Penyiraman'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF376A25),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Lihat hasil penyiraman terbaru dan dampaknya ke kesehatan tanaman.',
              style: TextStyle(color: Color(0xFF72796C)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: widget.deviceId == null
                  ? _buildHistoryList(_demoEntries())
                  : StreamBuilder<List<Map<Object?, Object?>>>(
                      stream: _svc.watchHistory(widget.deviceId!, limit: 30),
                      builder: (context, snapshot) {
                        final entries = _buildEntries(snapshot.data ?? const []);
                        if (entries.isEmpty) {
                          return _emptyState();
                        }
                        return _buildHistoryList(entries);
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.bottomNavigationBar,
    );
  }

  Widget _buildHistoryList(List<HistoryEntry> entries) {
    return ListView(
      children: entries.map(_buildCard).toList(),
    );
  }

  Widget _buildCard(HistoryEntry e) {
    final progress = (e.afterPct.clamp(0, 100)) / 100.0;
    final positive = e.scoreDelta >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: e.accentColor.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: e.badgeColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.water_drop, color: e.accentColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${e.timeLabel} • ${e.statusLabel}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: e.accentColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: positive
                      ? const Color(0xFFFFE088)
                      : const Color(0xFFF4E4DF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  positive ? '+${e.scoreDelta}' : '${e.scoreDelta}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _moistureBox(
                  label: 'Sebelum',
                  value: '${e.beforePct}%',
                  color: const Color(0xFFF4EED8),
                  textColor: const Color(0xFF1E1C0F),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _moistureBox(
                  label: 'Sesudah',
                  value: '${e.afterPct}%',
                  color: e.badgeColor,
                  textColor: e.accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              color: e.accentColor,
              backgroundColor: const Color(0xFFF4EED8),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            e.reason,
            style: const TextStyle(
              color: Color(0xFF5E6653),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _moistureBox({
    required String label,
    required String value,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Color(0xFF72796C),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
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
              child: Icon(Icons.history_rounded, color: Color(0xFF376A25)),
            ),
            SizedBox(height: 16),
            Text(
              'Belum ada riwayat penyiraman',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8),
            Text(
              'Setelah perangkat menyelesaikan penyiraman, hasilnya akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF5E6653)),
            ),
          ],
        ),
      ),
    );
  }

  List<HistoryEntry> _buildEntries(List<Map<Object?, Object?>> rawEntries) {
    final result = <HistoryEntry>[];
    for (final item in rawEntries) {
      final before = _readInt(item['moisture_before']);
      final after = _readInt(item['moisture_after']);
      final scoreDelta = _readInt(item['score_delta']);
      final reason =
          '${item['score_reason'] ?? item['title'] ?? 'Penyiraman selesai.'}';
      final createdAt = _readTimestamp(item['created_at']);
      final title = '${item['title'] ?? 'Penyiraman'}';

      final statusLabel = _statusLabel(before: before, after: after);
      final accentColor = scoreDelta >= 0
          ? const Color(0xFF376A25)
          : const Color(0xFF9B3D2F);
      final badgeColor = scoreDelta >= 0
          ? const Color(0xFFB1EFD8)
          : const Color(0xFFF4E4DF);

      result.add(
        HistoryEntry(
          timeLabel: createdAt == null ? '-' : _formatTime(createdAt),
          title: title,
          beforePct: before,
          afterPct: after,
          scoreDelta: scoreDelta,
          statusLabel: statusLabel,
          reason: reason,
          accentColor: accentColor,
          badgeColor: badgeColor,
        ),
      );
    }
    return result;
  }

  String _statusLabel({required int before, required int after}) {
    if (after > 85) {
      return 'Berlebih';
    }
    if (before < 25) {
      return 'Terlambat';
    }
    if (after >= 45 && after <= 75) {
      return 'Ideal';
    }
    return 'Selesai';
  }

  int _readInt(Object? value) {
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse('$value') ?? 0;
  }

  DateTime? _readTimestamp(Object? value) {
    final raw = _readInt(value);
    if (raw <= 0) {
      return null;
    }
    if (raw < 1000000000000) {
      return DateTime.fromMillisecondsSinceEpoch(raw * 1000);
    }
    return DateTime.fromMillisecondsSinceEpoch(raw);
  }

  String _formatTime(DateTime value) {
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month • $hour:$minute';
  }
}
