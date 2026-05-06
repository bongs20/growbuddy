import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/firebase_service.dart';

class CalibrationScreen extends StatefulWidget {
  final String deviceId;
  const CalibrationScreen({super.key, required this.deviceId});

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  final FirebaseService _svc = FirebaseService();
  String _plantType = '';
  int _offset = 0;
  bool _loading = true;
  int _currentMoisture = 0;

  @override
  void initState() {
    super.initState();
    _loadCalibration();
  }

  Future<void> _loadCalibration() async {
    setState(() => _loading = true);
    try {
      final device = await _svc.fetchDevice(widget.deviceId);
      final cal = await _svc.fetchDeviceCalibration(widget.deviceId);
      setState(() {
        _currentMoisture = _readInt(device['moisture']);
        _plantType = (cal['plant_type'] ?? '').toString();
        _offset = _readInt(cal['offset_percent']);
      });
    } catch (e) {
      // ignore
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  int _readInt(Object? v) {
    if (v is int) return v;
    if (v is double) return v.round();
    return int.tryParse('$v') ?? 0;
  }

  Future<void> _save() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await _svc.saveDeviceCalibration(
        deviceId: widget.deviceId,
        plantType: _plantType.trim().isEmpty ? 'Custom' : _plantType.trim(),
        offsetPercent: _offset,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kalibrasi tersimpan')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _useCurrentReadingAsBaseline() {
    // Set offset so that current reading maps to 50% (midpoint)
    final desired = 50;
    final computed = desired - _currentMoisture;
    setState(() {
      _offset = computed.clamp(-100, 100);
    });
  }

  @override
  Widget build(BuildContext context) {
    final calibrated = (_currentMoisture + _offset).clamp(0, 100);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalibrasi Sensor'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Perangkat: ${widget.deviceId}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Text('Bacaan saat ini: $_currentMoisture%'),
                  const SizedBox(height: 8),
                  Text('Kalibrasi saat ini: $_offset% offset'),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Tipe tanaman'),
                    controller: TextEditingController(text: _plantType),
                    onChanged: (v) => _plantType = v,
                  ),
                  const SizedBox(height: 12),
                  Text('Sesuaikan offset kelembapan (–100 → +100)'),
                  Slider(
                    min: -100,
                    max: 100,
                    divisions: 200,
                    value: _offset.toDouble(),
                    label: '$_offset%',
                    onChanged: (v) => setState(() => _offset = v.round()),
                  ),
                  const SizedBox(height: 8),
                  Text('Preview kelembapan setelah kalibrasi: ${calibrated}%'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _useCurrentReadingAsBaseline,
                          child: const Text('Gunakan bacaan saat ini sebagai 50%'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _loadCalibration,
                          child: const Text('Refresh bacaan'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _save,
                    child: const Text('Simpan Kalibrasi'),
                  ),
                ],
              ),
            ),
    );
  }
}
