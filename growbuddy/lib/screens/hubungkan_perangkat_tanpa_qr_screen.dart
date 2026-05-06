import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';

class HubungkanPerangkatTanpaQrScreen extends StatefulWidget {
  const HubungkanPerangkatTanpaQrScreen({super.key});

  @override
  State<HubungkanPerangkatTanpaQrScreen> createState() =>
      _HubungkanPerangkatTanpaQrScreenState();
}

class _HubungkanPerangkatTanpaQrScreenState
    extends State<HubungkanPerangkatTanpaQrScreen> {
  final TextEditingController _deviceIdController = TextEditingController();
  bool _isLoading = false;
  late final FirebaseService _firebaseService;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _firebaseService = FirebaseService();
  }

  @override
  void dispose() {
    _deviceIdController.dispose();
    super.dispose();
  }

  void _handleConnect() async {
    final deviceId = _deviceIdController.text.trim();
    
    if (deviceId.isEmpty) {
      _showErrorMessage('Masukkan Device ID terlebih dahulu');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Validate if device exists in Firebase
      final exists = await _firebaseService.deviceExists(deviceId);
      
      if (!exists) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Device ID "$deviceId" tidak terdaftar.\n\nHarap periksa kembali label di bawah pot Anda.';
        });
        _showErrorNotification(
          'Device Tidak Ditemukan',
          'Device ID yang Anda masukkan tidak terdaftar di sistem.\n\nSilakan periksa kembali ID pada label perangkat.',
        );
        return;
      }

      // Save device ID to Firebase
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Silakan login terlebih dahulu';
        });
        return;
      }

      await _firebaseService.saveDeviceId(
        uid: currentUser.uid,
        deviceId: deviceId,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).pop(deviceId);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Kesalahan autentikasi: ${e.message}';
      });
      _showErrorNotification(
        'Kesalahan Autentikasi',
        e.message ?? 'Terjadi kesalahan saat memverifikasi akun Anda',
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Kesalahan koneksi: ${e.toString()}';
      });
      _showErrorNotification(
        'Kesalahan Koneksi',
        'Terjadi kesalahan saat menghubungkan perangkat. Silakan coba lagi.',
      );
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[400],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorNotification(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF376A25),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(message),
        backgroundColor: const Color(0xFFFFF9E7),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF88C070)),
            ),
          ),
        ],
      ),
    );
  }

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
            color: const Color(0xFFF4EED8),
          ),
          child: Center(
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Color(0xFF1E1C0F),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: const Text(
          'Hubungkan Perangkat',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF376A25),
          ),
        ),
        centerTitle: true,
        actions: [
          const SizedBox(width: 48),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero illustration
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFF88C070).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF88C070).withValues(alpha: 0.1),
                      blurRadius: 50,
                      spreadRadius: 20,
                    ),
                  ],
                ),
                child: Center(
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuC0VkRCuRHTlGqt_P1VVWQotYfS91GIOTRlpimJWD5NW0YoMW63lwD8zlj1VK_RCN4B2tIAIIswiIfkPAs8oXDu_C-1-ghytD8TSitRWhcYsP6NDwHGRVmICYER5AmEsA_3ztnRoMc2D8wI2hjT6tATOs-_YZlGmjJBjPFHGY0Mo2Ba0DcFuRyD4nKP4GcHKMh4xS7z7RpLSzr87cwb7-kddiarQmqF6yDaDisdPkRtOJVwsbow0uZgzBw661m6EObG-1b8WX9BnqQ',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFF0F0F0),
                        child: const Icon(Icons.sensors, size: 80),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Form section
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'MASUKKAN DEVICE ID',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.05,
                      color: Color(0xFF72796C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFEEE8D3),
                        width: 2,
                      ),
                    ),
                    child: TextField(
                      controller: _deviceIdController,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1E1C0F),
                      ),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        hintText: 'device_001',
                        hintStyle: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFFC2C9B9),
                        ),
                        border: InputBorder.none,
                        suffixIcon: Container(
                          padding: const EdgeInsets.all(12),
                          child: const Icon(
                            Icons.qr_code_scanner,
                            color: Color(0xFF88C070),
                            size: 24,
                          ),
                        ),
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'Contoh: device_001 (Lihat label di bawah pot Anda)',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF42493D),
                      ),
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.red[300]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red[400],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.red[700],
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              // Primary button
              SizedBox(
                height: 64,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleConnect,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF88C070),
                    disabledBackgroundColor: const Color(0xFF88C070)
                        .withValues(alpha: 0.5),
                    shadowColor: const Color(0xFF88C070),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: _isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF1C4E0B),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Memverifikasi...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1C4E0B),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'Hubungkan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1C4E0B),
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.sensors,
                              color: Color(0xFF1C4E0B),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              // Secondary button - Scan QR
              SizedBox(
                height: 64,
                child: OutlinedButton(
                  onPressed: () {
                    // Scan QR action
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fitur scan QR akan hadir segera'),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFF88C070),
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Scan QR',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF88C070),
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.qr_code_2,
                        color: Color(0xFF88C070),
                      ),
                    ],
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
