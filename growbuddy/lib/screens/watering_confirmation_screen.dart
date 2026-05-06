import 'package:flutter/material.dart';

class WateringConfirmationScreen extends StatelessWidget {
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const WateringConfirmationScreen({
    super.key,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
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
                  _plantHeaderCard(),
                  const SizedBox(height: 16),
                  _metricsGrid(),
                  const SizedBox(height: 16),
                  _missionCard(),
                ],
              ),
            ),
            _topBar(),
            _modal(context),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 12,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _NavItem(icon: Icons.home, label: 'Beranda', active: true),
              _NavItem(icon: Icons.history, label: 'Riwayat'),
              _NavItem(icon: Icons.task, label: 'Misi'),
              _NavItem(icon: Icons.notifications, label: 'Notif', hasDot: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
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
                children: const [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuBOSUdFnE_z8qA0kZwo3EpXCc_TmTjQP9A-6kVxHxZoCnlGyVEpuD7rvvRgiYVJxLW6hSDm-Pb74s4xmHJ4kGRJv11xZF54Mabb5L9G1tAdfh6hCRKTqfB_G2RyuZXdEur4WS8J5Zk0ArQXvZR68NqjFhj7-dDgGf_aQkASKkoi0PKtcwQFt8pVyziMkUWICo3SgYtcDl_dQELAha4R53B6vNVmOr2zt3SzyM7iWTZ_v580P11mKB7T4dvlsvWsLgcCKuReGca3qlM',
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              const Text(
                'Halo, Plant Hero!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF16A34A),
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.sensors, color: Color(0xFF10B981)),
          ),
        ],
      ),
    );
  }

  Widget _plantHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF88C070).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: const [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kaktus Mini',
                style: TextStyle(
                  fontSize: 34,
                  height: 1.05,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF376A25),
                ),
              ),
              SizedBox(height: 6),
              Text(
                '"Wah, segar sekali!"',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF42493D),
                ),
              ),
            ],
          ),
          Positioned(
            right: -10,
            bottom: -18,
            child: Opacity(
              opacity: 0.1,
              child: Icon(Icons.local_florist, size: 120),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricsGrid() {
    return Row(
      children: [
        Expanded(
          child: _metricCard(
            icon: Icons.water_drop,
            iconColor: const Color(0xFF2C6956),
            label: 'Kelembapan',
            value: '42%',
            valueColor: const Color(0xFF2C6956),
            borderColor: const Color(0xFFAEEDD5).withValues(alpha: 0.35),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _metricCard(
            icon: Icons.wb_sunny,
            iconColor: const Color(0xFF735C00),
            label: 'Cahaya',
            value: '850 lux',
            valueColor: const Color(0xFF735C00),
            borderColor: const Color(0xFFD1AE40).withValues(alpha: 0.35),
          ),
        ),
      ],
    );
  }

  Widget _metricCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
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
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(height: 8),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
              color: Color(0xFF72796C),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _missionCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF4DE),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFF88C070).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Misi Hari Ini',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E1C0F),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1AE40),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  '2 MISI LAGI',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF544200),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFF376A25)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Siram kaktus pagi ini',
                    style: TextStyle(fontSize: 16, color: Color(0xFF1E1C0F)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white54,
              borderRadius: BorderRadius.circular(12),
              border: Border.fromBorderSide(
                BorderSide(
                  color: Color(0xFFC2C9B9),
                  style: BorderStyle.solid,
                ),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.radio_button_unchecked, color: Color(0xFF72796C)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Beri pupuk organik',
                    style: TextStyle(fontSize: 16, color: Color(0xFF42493D)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _modal(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: const Color(0xFF1E1C0F).withValues(alpha: 0.4),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Container(
          width: 380,
          constraints: const BoxConstraints(maxWidth: 380),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF376A25).withValues(alpha: 0.2),
                blurRadius: 50,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF88C070),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF88C070).withValues(alpha: 0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.water_drop, size: 40, color: Color(0xFF1C4E0B)),
              ),
              const SizedBox(height: 20),
              const Text(
                'Siram tanaman?',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E1C0F),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pompa akan menyala selama 3 detik untuk memberikan hidrasi optimal.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF42493D),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF88C070),
                    foregroundColor: const Color(0xFF1C4E0B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Ya, Siram',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onCancel ?? () => Navigator.of(context).maybePop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEEE8D3),
                    foregroundColor: const Color(0xFF42493D),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final bool hasDot;

  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
    this.hasDot = false,
  });

  @override
  Widget build(BuildContext context) {
    final fg = active ? const Color(0xFF047857) : const Color(0xFF9CA3AF);
    final bg = active ? const Color(0xFFDDF6E7) : Colors.transparent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: fg),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ],
          ),
          if (hasDot)
            const Positioned(
              right: -2,
              top: 0,
              child: CircleAvatar(radius: 4, backgroundColor: Color(0xFFBA1A1A)),
            ),
        ],
      ),
    );
  }
}
