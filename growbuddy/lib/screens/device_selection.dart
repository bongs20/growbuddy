import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/firebase_service.dart';

class DeviceSelection extends StatefulWidget {
  const DeviceSelection({super.key, required this.onSaved});

  final ValueChanged<String> onSaved;

  @override
  State<DeviceSelection> createState() => _DeviceSelectionState();
}

class _DeviceSelectionState extends State<DeviceSelection> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isSaving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveDevice() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login anonim belum siap. Coba lagi.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final deviceId = _controller.text.trim();

    try {
      final exists = await _firebaseService.deviceExists(deviceId);
      
      if (!mounted) return;

      if (!exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ID Perangkat "$deviceId" tidak ditemukan! Silakan hubungi admin atau masukkan ID yang benar.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      await _firebaseService.saveDeviceId(uid: user.uid, deviceId: deviceId);

      if (!mounted) {
        return;
      }

      widget.onSaved(deviceId);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghubungkan device: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _goToAdminLogin() {
    // I'll create this screen next
    Navigator.of(context).pushNamed('/admin-login');
  }

  void _useDemoDevice() {
    _controller.text = FirebaseService.demoDeviceId;
    _saveDevice();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF88C070,
                            ).withValues(alpha: 0.15),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const Column(
                        children: [
                          CircleAvatar(
                            radius: 34,
                            backgroundColor: Color(0xFFEAF7EC),
                            child: Icon(
                              Icons.sensors,
                              size: 34,
                              color: Color(0xFF376A25),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Hubungkan Device GrowBuddy',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Masukkan ID perangkat yang tertera pada modul GrowBuddy kamu untuk mulai memantau tanaman.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF5E6653),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F4E8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tes Tanpa ESP Fisik',
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Gunakan perangkat demo untuk mencoba sensor, skor, dan penyiraman tanpa hardware asli.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF5E6653),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: _isSaving ? null : _useDemoDevice,
                            child: const Text('Pakai Demo'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _controller,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'ID perangkat',
                        hintText: 'contoh: device_001',
                        prefixIcon: Icon(Icons.memory_outlined),
                      ),
                      validator: (value) {
                        final trimmed = value?.trim() ?? '';
                        if (trimmed.isEmpty) {
                          return 'Device ID wajib diisi.';
                        }
                        if (trimmed.contains(' ')) {
                          return 'Device ID tidak boleh mengandung spasi.';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _saveDevice(),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveDevice,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF376A25),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Hubungkan Perangkat',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _goToAdminLogin,
                      child: const Text(
                        'Masuk sebagai Admin',
                        style: TextStyle(
                          color: Color(0xFF5E6653),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
