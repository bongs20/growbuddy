import 'package:flutter/material.dart';

class WateringProgressScreen extends StatefulWidget {
  const WateringProgressScreen({super.key, this.durationSeconds = 3});

  final int durationSeconds;

  @override
  State<WateringProgressScreen> createState() => _WateringProgressScreenState();
}

class _WateringProgressScreenState extends State<WateringProgressScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _waterController;
  late Animation<double> _waterAnimation;

  @override
  void initState() {
    super.initState();
    _waterController = AnimationController(
      duration: Duration(seconds: widget.durationSeconds),
      vsync: this,
    );

    _waterAnimation = Tween<double>(begin: 0.0, end: 0.45).animate(
      CurvedAnimation(parent: _waterController, curve: Curves.easeInOutCubic),
    );

    _waterController.forward();
  }

  @override
  void dispose() {
    _waterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E7),
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.8),
        elevation: 0,
        leading: const SizedBox.shrink(),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF88C070), width: 2),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuCcsl2JTSgI94foFyPoSrWZh_Wf47yIvMe_crTz3bw0GKiwKqMj0D7z8Iqd7EcaNf_Zrl51DpxCQxuJ4b8sAlm1yYnbiiUhdhp-PTFrxsOkPgNsWn9eEGGOjSgnqwwp1FFvz0kA_W536j4cu7f6x3FXwxMtKXnnXWrOFtJVJZ6wdGODSlMb1E8uJYWQ2YcUCE7FVSa-7iRipZRm0Zp67YvZzRRQhs10RNkbo5fJLcg1gQXniHRV5YUjM2CvXDFtUgzqf1zg1cggAPE',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Halo, Plant Hero!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C6956),
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Icon(Icons.sensors, color: Color(0xFF2C6956), size: 24),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Plant with Water
                SizedBox(
                  width: 288,
                  height: 288,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background halo
                      Container(
                        width: 288,
                        height: 288,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF88C070).withValues(alpha: 0.2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF88C070).withValues(alpha: 0.15),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      // Main container
                      Container(
                        width: 256,
                        height: 256,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: const Color(0xFFFAF4DE),
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF88C070).withValues(alpha: 0.15),
                              blurRadius: 20,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Plant image
                            Center(
                              child: Image.network(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuAYEE3ulkTjwzIitTuSANU9HWo3YHRtEkGhbtii1VXJf_PGXNQmb_FoT5rAxZYCqiNqzQKb-y5ofCg42vSQR05Dvy0uf0u6da0JvtMz80X1HfFqVMSVEmQHTp1DcwqklDfntNJzJTxoMvNQp8jCvVu6a0lhCfxn5d6BCpnW_X5mHj2knU12OmNObuZcdhaWqTgjtn-5sTbFiD7c4MzZLGUlmGkk4wYH7nR7teKjSSNEzkBG9SudRPKrBrfkaPFiqdiibddxH8ccub4',
                                width: 192,
                                height: 192,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 192,
                                    height: 192,
                                    color: const Color(0xFFF0F0F0),
                                    child: const Icon(Icons.eco),
                                  );
                                },
                              ),
                            ),
                            // Water fill animation
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: AnimatedBuilder(
                                animation: _waterAnimation,
                                builder: (context, child) {
                                  return ClipOval(
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      heightFactor: _waterAnimation.value,
                                      child: Container(
                                        height: 256,
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFAEEDD5,
                                          ).withValues(alpha: 0.4),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Text content
                Column(
                  children: [
                    const Text(
                      'Sedang menyiram...',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF376A25),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFAEEDD5),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.opacity,
                            color: Color(0xFF316D5B),
                            size: 18,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Pompa aktif ${widget.durationSeconds} detik',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF316D5B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
