import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _newDeviceIdController = TextEditingController();
  final TextEditingController _pumpDurationController = TextEditingController(text: '3');

  void _showAddDeviceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Perangkat Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _newDeviceIdController,
              decoration: const InputDecoration(
                labelText: 'ID Perangkat',
                hintText: 'contoh: device_002',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pumpDurationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Durasi Pompa (Detik)',
                hintText: '3',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final id = _newDeviceIdController.text.trim();
              final duration = int.tryParse(_pumpDurationController.text) ?? 3;
              if (id.isEmpty) return;
              
              try {
                // Modified addNewDevice to take duration
                await _firebaseService.addNewDevice(id, pumpDuration: duration);
                if (mounted) {
                  Navigator.pop(context);
                  _newDeviceIdController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Perangkat $id berhasil ditambahkan')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.redAccent),
                  );
                }
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: StreamBuilder<Map<String, Map<Object?, Object?>>>(
        stream: _firebaseService.watchAllDevices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final devices = snapshot.data ?? {};
          if (devices.isEmpty) {
            return const Center(child: Text('Belum ada perangkat terdaftar.'));
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Device ID')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Koneksi')),
                DataColumn(label: Text('Moisture')),
                DataColumn(label: Text('Update Terakhir')),
              ],
              rows: devices.entries.map((entry) {
                final id = entry.key;
                final data = entry.value;
                final online = data['online'] == true;
                final moisture = data['moisture'] ?? 0;
                final status = data['status'] ?? 'unknown';
                final lastUpdate = data['last_update'];

                return DataRow(cells: [
                  DataCell(Text(id, style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text('$status')),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: online ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        online ? 'ONLINE' : 'OFFLINE',
                        style: TextStyle(color: online ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  DataCell(Text('$moisture%')),
                  DataCell(Text(lastUpdate != null ? _formatTimestamp(lastUpdate) : '-')),
                ]);
              }).toList(),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDeviceDialog,
        label: const Text('Tambah Device'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  String _formatTimestamp(Object value) {
    try {
      final ts = int.parse(value.toString());
      final dt = DateTime.fromMillisecondsSinceEpoch(ts < 1000000000000 ? ts * 1000 : ts);
      return '${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return value.toString();
    }
  }
}
