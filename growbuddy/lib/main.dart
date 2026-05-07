import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import 'screens/device_selection.dart';
import 'screens/device_shell_screen.dart';
import 'screens/admin_login_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'services/firebase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const GrowBuddyApp());
}

class GrowBuddyApp extends StatelessWidget {
  const GrowBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GrowBuddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFF9E7),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF88C070),
          primary: const Color(0xFF376A25),
          secondary: const Color(0xFFFFE088),
          surface: Colors.white,
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1E1C0F),
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFE6E1C9)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFF376A25), width: 1.5),
          ),
        ),
      ),
      home: const AppRoot(),
      routes: {
        '/admin-login': (context) => const AdminLoginScreen(),
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
      },
    );
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  final FirebaseService _firebaseService = FirebaseService();
  late final Future<void> _bootstrapFuture = _bootstrap();

  String? _deviceId;

  Future<void> _bootstrap() async {
    final user = await _firebaseService.ensureAnonymousSignIn();
    _deviceId = await _firebaseService.fetchSavedDeviceId(user.uid);
  }

  void _handleDeviceSaved(String deviceId) {
    setState(() {
      _deviceId = deviceId;
    });
  }

  void _handleDeviceUnlinked() {
    setState(() {
      _deviceId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _bootstrapFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _LoadingScreen(
            message: 'Menghubungkan GrowBuddy ke Firebase...',
          );
        }

        if (snapshot.hasError) {
          return _ErrorScreen(error: snapshot.error.toString());
        }

        if (_deviceId == null) {
          return DeviceSelection(onSaved: _handleDeviceSaved);
        }

        return DeviceShellScreen(
          deviceId: _deviceId!,
          onDeviceUnlinked: _handleDeviceUnlinked,
        );
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 12),
              const Text(
                'Firebase gagal diinisialisasi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
