import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const SplashScreen({super.key, required this.onFinish});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      widget.onFinish();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E7),
      body: Stack(
        children: [
          // decorative blobs
          Positioned(top: -60, right: -60, child: _blob(300, const Color(0xFF88C070).withValues(alpha: 0.2))),
          Positioned(bottom: -40, left: -40, child: _blob(250, const Color(0xFFB1EFD8).withValues(alpha: 0.25))),

          // main content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // logo
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.green.withValues(alpha: 0.08), blurRadius: 20)]),
                  child: const Center(child: Icon(Icons.local_florist, size: 48, color: Color(0xFF376A25))),
                ),
                const SizedBox(height: 16),
                const Text('GrowBuddy', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF376A25))),
                const SizedBox(height: 24),
                // illustration card
                Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(48), color: Colors.white.withValues(alpha: 0.4), boxShadow: [BoxShadow(color: Colors.green.withValues(alpha: 0.06), blurRadius: 18)]),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Image.network(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuA-qY1pE16lHOE022doGMNPg1ogNwjYGAEuJhZ3ynVdkhVj0YRjuvujBD2subBtfED4phfPDklgjugtGKmxclSlPzYhKMezEZwBP3Gk3lE07_-8JCNm7r-lmd9vWJqleYqGAEenubFHk6hmKn3tnnGkJL9ClfdxG1VuJ1cgDPjkp8ngnOgn7gEBdKQTMavuUwKhgRN_gRCVnx721sEYSP2Cpgmpymv91C6gBwOoy0Iuad48Vb4zssc2I2qGggEU8JCrB_hnyjoIKJs',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.local_florist,
                              size: 120,
                              color: Color(0xFF88C070),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Smart Plant Watering Game', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E1C0F))),
                const SizedBox(height: 12),
                // indicator (simple)
                Container(width: 200, height: 8, decoration: BoxDecoration(color: const Color(0xFFF4EED8), borderRadius: BorderRadius.circular(999)), child: FractionallySizedBox(widthFactor: 0.33, alignment: Alignment.centerLeft, child: Container(decoration: BoxDecoration(color: const Color(0xFF88C070), borderRadius: BorderRadius.circular(999))))),
                const SizedBox(height: 12),
                const Text('Menyiapkan Kebunmu...', style: TextStyle(letterSpacing: 1.5, fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF72796C))),
              ],
            ),
          ),

          // floating icons
          Positioned(top: 40, right: 40, child: _floatIcon(Icons.water_drop, const Color(0xFFFFE088))),
          Positioned(bottom: 80, left: 16, child: _floatIcon(Icons.eco, const Color(0xFF88C070))),

          // footer
          Positioned(bottom: 20, left: 0, right: 0, child: Center(child: Opacity(opacity: 0.5, child: const Text('Version 1.0.2 • Powered by GrowSens™', style: TextStyle(fontSize: 10))))),
        ],
      ),
    );
  }

  Widget _floatIcon(IconData icon, Color bg) => Container(width: 48, height: 48, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)]), child: Center(child: Icon(icon, color: Colors.white)));

  Widget _blob(double size, Color color) => Container(width: size, height: size, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(size / 2), boxShadow: [BoxShadow(color: color, blurRadius: 80, spreadRadius: 20)]));
}
