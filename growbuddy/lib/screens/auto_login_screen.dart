import 'package:flutter/material.dart';

class AutoLoginScreen extends StatefulWidget {
  const AutoLoginScreen({super.key});

  @override
  State<AutoLoginScreen> createState() => _AutoLoginScreenState();
}

class _AutoLoginScreenState extends State<AutoLoginScreen> with SingleTickerProviderStateMixin {
  late AnimationController _dotController;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E7),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Illustration Section
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(decoration: BoxDecoration(color: const Color(0xFF88C070).withValues(alpha: 0.14), shape: BoxShape.circle)),
                        Container(
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.green.withValues(alpha: 0.06), blurRadius: 18)]),
                          padding: const EdgeInsets.all(12),
                          child: Image.network('https://lh3.googleusercontent.com/aida-public/AB6AXuB3QgBAztqnGhjp1MSmf5SwZBYam4SYreh43yi2Gj0OU0gwRRmyUHpSlr5KwRdy7e0TBIoROO5rvMcUhUIl5OzJiA9azpY42DrlXUblEeKfVkY3v-UbE1o1ARm8yjDtqnpRTPrBjrrj3B7D7NIGu4pHmQgsa0-EaghcPH9e-6g4zhwxcMIXmb6wExDuvk0uI4eNXzVP7TaU-50E8S-bksdcNQUBC7_Dbl7BSqkh0ROQaC9i_aRVR5jvivgnF6rsqffndRWTMwGzyfg', fit: BoxFit.contain),
                        ),
                        Positioned(top: -8, right: -6, child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: const Color(0xFFFFE088), borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8)]), child: const Icon(Icons.color_lens_outlined, color: Color(0xFF241A00)))),
                        Positioned(bottom: -8, left: -10, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFAEEDD5), borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)]), child: const Icon(Icons.water_drop, color: Color(0xFF002118))))
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Text Guidance
                  Column(
                    children: [
                      const Text('Halo, Plant Hero!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF376A25))),
                      const SizedBox(height: 8),
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        const Text('Menghubungkan aplikasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E1C0F))),
                        const SizedBox(width: 12),
                        // animated dots
                        SizedBox(
                          width: 36,
                          child: AnimatedBuilder(
                            animation: _dotController,
                            builder: (context, child) {
                              final t = _dotController.value;
                              return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: List.generate(3, (i) {
                                final phase = (t + i * 0.2) % 1.0;
                                final opacity = 0.4 + (phase > 0.5 ? (phase - 0.5) * 1.2 : phase * 0.8);
                                return Container(width: 6, height: 6, decoration: BoxDecoration(color: const Color(0xFF88C070).withValues(alpha: opacity), borderRadius: BorderRadius.circular(4)));
                              }));
                            },
                          ),
                        )
                      ]),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Status Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: const Color(0xFFF4EED8), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12)], border: Border.all(color: Colors.white.withValues(alpha: 0.6))),
                    child: Row(children: [
                      Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFFB8F29D), borderRadius: BorderRadius.circular(12)), child: const Center(child: Icon(Icons.sensors, color: Color(0xFF376A25)))),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('Status Koneksi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: Color(0xFF72796C))), SizedBox(height: 4), Text('Sinkronisasi Data IoT...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF376A25))) ])),
                      const SizedBox(width: 8),
                      Container(width: 12, height: 12, decoration: BoxDecoration(color: const Color(0xFFD1AE40), shape: BoxShape.circle))
                    ]),
                  ),
                  const SizedBox(height: 18),
                  const Text('"Hampir sampai! Tanamanmu merindukanmu."', style: TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF72796C))),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 18.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: const [
          Icon(Icons.eco, color: Color(0xFF376A25)),
          SizedBox(height: 6),
          Text('HaloPlant', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF376A25))),
          SizedBox(height: 4),
          Text('v2.4.0 Stable Connection', style: TextStyle(fontSize: 10, letterSpacing: 2.0, color: Color(0xFF72796C)))
        ]),
      ),
    );
  }
}
