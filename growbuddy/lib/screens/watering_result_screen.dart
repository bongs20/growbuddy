import 'package:flutter/material.dart';

class WateringResultScreen extends StatelessWidget {
  const WateringResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E7),
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.8),
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFB8F29D),
          ),
          child: Center(
            child: Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuAWKw9W6iI8tYXhCTxyllffk_TH-OxDTHuUNArjpZiboAGZh0dCMCUU9JZJkOElZjhQ06EVwWQ1F0PmbnkjubFlOiPQdz2vBzxj3UyrgUY_2E3Su8BuvBgJWmiT3cYM9CotmZS-_FPJDNNUSP4fERuEwN8YVGRiAD_P6Ba1tg0K6Hip70zcXw0OPGJfH1ynwFJrigKoDssEEmd_Whbrg10HZlCLCOjwgxuwFOH69JMNio3Fr0jZn_Za0RM0kdca7KgOEI3cY0EHr5M',
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.person);
              },
            ),
          ),
        ),
        title: const Text(
          'Level 12',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF376A25),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.close, color: Color(0xFF376A25)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Success Section
              Column(
                children: [
                  const SizedBox(height: 24),
                  // Plant Character
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glow backdrop
                      Container(
                        width: 256,
                        height: 256,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF88C070).withValues(alpha: 0.2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF88C070).withValues(alpha: 0.15),
                              blurRadius: 48,
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                      ),
                      // Plant image
                      Image.network(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuAWi7FllaNmbrdUWLDsolbaDQ1aWd8d9ocMYmlNyuUq3Vkr00HcJKkhvnArqCKx-gPO-u1RBRfsXVb9L8BswVuy3XNW8Ofe1lLE1rQI9Mp63wCEMyENhtVSfC3oN41DowXswc5nFmnHO4T0kmRyjmIWDTSL_L9wcMEEkyR8HHKjUuMzXz4QJsK3dgBsmi9KeziztL7X9LacV6s2iWioRjjyMEQVW42pNF4wObc4Ili75wjq8U2b7O9FvYUGlDB0VpKRWQtJaQOwLes',
                        width: 192,
                        height: 192,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 192,
                            height: 192,
                            color: const Color(0xFFF0F0F0),
                            child: const Icon(Icons.eco, size: 96),
                          );
                        },
                      ),
                      // Points badge
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Transform.rotate(
                          angle: 0.2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE088),
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.star,
                                  color: Color(0xFF241A00),
                                  size: 18,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '+10 poin',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF241A00),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Success text
                  const Text(
                    'Berhasil!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF376A25),
                      letterSpacing: -0.02,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Penyiraman tepat waktu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C6956),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Moisture comparison grid
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Before
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: const Color(0xFFF4EED8),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'SEBELUM',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.05,
                              color: Color(0xFF72796C),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '32%',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF735C00).withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Kelembaban',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF72796C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // After
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: const Color(0xFFB1EFD8),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'SESUDAH',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.05,
                              color: Color(0xFF72796C),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '78%',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C6956),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Kelembaban',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF72796C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
