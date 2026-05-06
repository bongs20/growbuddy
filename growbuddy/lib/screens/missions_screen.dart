import 'package:flutter/material.dart';

import '../services/firebase_service.dart';

class MissionsScreen extends StatelessWidget {
  MissionsScreen({
    super.key,
    required this.deviceId,
    this.bottomNavigationBar,
  });

  final String deviceId;
  final Widget? bottomNavigationBar;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<Object?, Object?>>(
      stream: _firebaseService.watchDevice(deviceId),
      builder: (context, deviceSnapshot) {
        final deviceData = deviceSnapshot.data ?? const <Object?, Object?>{};
        final moisture = _readInt(deviceData['moisture']);
        final game = _readMap(deviceData['game']);
        final score = _readInt(game['score']);
        final levelProgress = _firebaseService.levelProgressForScore(score);
        final level = levelProgress['level'] ?? 1;
        final xpInLevel = levelProgress['xp_in_level'] ?? 0;
        final xpNeeded = levelProgress['xp_needed'] ?? 1;
        final xpRemaining = levelProgress['xp_remaining'] ?? 0;
        final scoreReason =
            '${game['last_score_reason'] ?? 'Belum ada evaluasi skor terbaru.'}';

        return StreamBuilder<List<Map<Object?, Object?>>>(
          stream: _firebaseService.watchHistory(deviceId, limit: 50),
          builder: (context, historySnapshot) {
            final history = historySnapshot.data ?? const [];
            final wateringToday = _countTodayWatering(history);
            final wateringProgress = (wateringToday / 3).clamp(0.0, 1.0);
            final moistureProgress = _idealMoistureProgress(moisture);
            final stableHours = _estimateStableHours(moisture);

            return Scaffold(
              backgroundColor: const Color(0xFFFFF9E7),
              body: SafeArea(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 84, 20, 126),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _levelSection(
                            level: level,
                            score: score,
                            xpInLevel: xpInLevel,
                            xpNeeded: xpNeeded,
                            xpRemaining: xpRemaining,
                            progress: xpNeeded == 0 ? 0 : xpInLevel / xpNeeded,
                            scoreReason: scoreReason,
                          ),
                          const SizedBox(height: 24),
                          _missionSection(
                            wateringToday: wateringToday,
                            wateringProgress: wateringProgress,
                            moistureProgress: moistureProgress,
                            stableHours: stableHours,
                          ),
                          const SizedBox(height: 24),
                          _badgeSection(
                            level: level,
                            wateringToday: wateringToday,
                            moisture: moisture,
                          ),
                          const SizedBox(height: 24),
                          _bentoStatsSection(
                            score: score,
                            wateringToday: wateringToday,
                          ),
                        ],
                      ),
                    ),
                    _topBar(level: level, moisture: moisture),
                  ],
                ),
              ),
              bottomNavigationBar: bottomNavigationBar,
            );
          },
        );
      },
    );
  }

  Widget _topBar({required int level, required int moisture}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF88C070).withValues(alpha: 0.08),
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
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFFAEEDD5),
                    child: Icon(Icons.eco, color: Color(0xFF1C4E0B)),
                  ),
                  Positioned(
                    right: -3,
                    bottom: -3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE088),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white),
                      ),
                      child: Text(
                        'LV.$level',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              const Text(
                'Progress Tanaman',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF16A34A),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFDFF4E2),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Moisture $moisture%',
              style: const TextStyle(
                color: Color(0xFF376A25),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _levelSection({
    required int level,
    required int score,
    required int xpInLevel,
    required int xpNeeded,
    required int xpRemaining,
    required double progress,
    required String scoreReason,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF4DE),
        borderRadius: BorderRadius.circular(32),
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
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'STATUS PAHLAWAN',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 0.9,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF376A25),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Level $level',
                    style: const TextStyle(
                      fontSize: 38,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF376A25),
                    ),
                  ),
                ],
              ),
              Text(
                '$xpInLevel / $xpNeeded XP',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF42493D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 16,
              color: const Color(0xFF376A25),
              backgroundColor: const Color(0xFFE8E3CD),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            xpRemaining == 0
                ? 'Level berikutnya sudah terbuka. Saatnya lanjut rawat tanaman.'
                : '$xpRemaining XP lagi untuk naik level. Total skor saat ini $score.',
            style: const TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Color(0xFF42493D),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            scoreReason,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF5E6653),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _missionSection({
    required int wateringToday,
    required double wateringProgress,
    required double moistureProgress,
    required int stableHours,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Misi Hari Ini',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E1C0F),
              ),
            ),
            Row(
              children: [
                Icon(Icons.stars, color: Color(0xFF376A25)),
                SizedBox(width: 4),
                Text(
                  '+150 XP',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF376A25),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        _missionCard(
          icon: Icons.water_drop,
          iconBg: const Color(0xFFAEEDD5),
          iconColor: const Color(0xFF316D5B),
          title: 'Siram dengan ritme sehat 3x',
          reward: '+50 XP',
          rewardColor: const Color(0xFF2C6956),
          progressLabelLeft: 'Progres',
          progressLabelRight: '$wateringToday / 3',
          progress: wateringProgress,
          progressColor: const Color(0xFF2C6956),
          completed: wateringToday >= 3,
        ),
        const SizedBox(height: 12),
        _missionCard(
          icon: Icons.thermostat,
          iconBg: const Color(0xFF88C070),
          iconColor: const Color(0xFF1C4E0B),
          title: 'Jaga kelembapan di zona aman',
          reward: '+100 XP',
          rewardColor: const Color(0xFF376A25),
          progressLabelLeft: 'Estimasi stabil',
          progressLabelRight: '$stableHours jam',
          progress: moistureProgress,
          progressColor: const Color(0xFF376A25),
          completed: moistureProgress >= 1,
        ),
      ],
    );
  }

  Widget _badgeSection({
    required int level,
    required int wateringToday,
    required int moisture,
  }) {
    final plantHeroUnlocked = level >= 3;
    final waterMasterUnlocked =
        wateringToday >= 3 &&
        moisture >= FirebaseService.idealMoistureMin &&
        moisture <= FirebaseService.idealMoistureMax;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lencana Koleksi',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E1C0F),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _badgeCard(
                title: 'Plant Hero',
                subtitle: plantHeroUnlocked ? 'TERBUKA' : 'LEVEL 3',
                icon: Icons.park,
                bgColor: const Color(0xFFD1AE40).withValues(alpha: 0.1),
                borderColor: const Color(0xFFD1AE40).withValues(alpha: 0.3),
                iconBg: const Color(0xFFFFE088),
                iconColor: const Color(0xFF241A00),
                subtitleColor: const Color(0xFF544200),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _badgeCard(
                title: 'Water Master',
                subtitle: waterMasterUnlocked ? 'AKTIF' : 'JAGA RITME',
                icon: Icons.opacity,
                bgColor: const Color(0xFFAEEDD5).withValues(alpha: 0.12),
                borderColor: const Color(0xFFAEEDD5).withValues(alpha: 0.4),
                iconBg: const Color(0xFFB1EFD8),
                iconColor: const Color(0xFF002118),
                subtitleColor: const Color(0xFF0D503F),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _bentoStatsSection({
    required int score,
    required int wateringToday,
  }) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 170,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF376A25),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.stars, size: 32, color: Colors.white),
                const Spacer(),
                Text(
                  '$score',
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'TOTAL SKOR',
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 0.9,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFEAF7E5),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 170,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFC2C9B9)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.history, size: 32, color: Color(0xFF376A25)),
                const Spacer(),
                Text(
                  '$wateringToday',
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E1C0F),
                  ),
                ),
                const Text(
                  'SIRAM HARI INI',
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 0.9,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF42493D),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _missionCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String reward,
    required Color rewardColor,
    required String progressLabelLeft,
    required String progressLabelRight,
    required double progress,
    required Color progressColor,
    required bool completed,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFAEEDD5), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF88C070).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E1C0F),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      reward,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: rewardColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (completed)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE088),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 20,
                    color: Color(0xFF241A00),
                  ),
                )
              else
                const Icon(Icons.pending, color: Color(0xFFC2C9B9)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                progressLabelLeft,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF42493D),
                ),
              ),
              Text(
                progressLabelRight,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF42493D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 12,
              color: progressColor,
              backgroundColor: const Color(0xFFE8E3CD),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badgeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color bgColor,
    required Color borderColor,
    required Color iconBg,
    required Color iconColor,
    required Color subtitleColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, size: 46, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E1C0F),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 0.9,
              fontWeight: FontWeight.w800,
              color: subtitleColor,
            ),
          ),
        ],
      ),
    );
  }

  int _countTodayWatering(List<Map<Object?, Object?>> history) {
    final now = DateTime.now();
    return history.where((item) {
      final createdAt = _readTimestamp(item['created_at']);
      if (createdAt == null) {
        return false;
      }
      return createdAt.year == now.year &&
          createdAt.month == now.month &&
          createdAt.day == now.day &&
          '${item['action'] ?? ''}' == 'manual_water';
    }).length;
  }

  double _idealMoistureProgress(int moisture) {
    if (moisture >= FirebaseService.idealMoistureMin &&
        moisture <= FirebaseService.idealMoistureMax) {
      return 1;
    }
    if (moisture < FirebaseService.idealMoistureMin) {
      return (moisture / FirebaseService.idealMoistureMin).clamp(0.0, 1.0);
    }
    return ((100 - moisture) / (100 - FirebaseService.idealMoistureMax))
        .clamp(0.0, 1.0);
  }

  int _estimateStableHours(int moisture) {
    if (moisture >= FirebaseService.idealMoistureMin &&
        moisture <= FirebaseService.idealMoistureMax) {
      return 24;
    }
    return (_idealMoistureProgress(moisture) * 24).round();
  }
}

Map<Object?, Object?> _readMap(Object? value) {
  if (value is Map) {
    return Map<Object?, Object?>.from(value);
  }
  return <Object?, Object?>{};
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
