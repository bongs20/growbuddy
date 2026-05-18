# GrowBuddy Technical Guide

Panduan teknis ini berisi petunjuk untuk melakukan modifikasi pada aplikasi GrowBuddy, mulai dari tampilan (warna/layout), logika sistem, hingga penjelasan konsep OOP yang diterapkan.

---

## 🏛️ 0. Konsep OOP (Object-Oriented Programming)

Aplikasi ini dibangun menggunakan prinsip OOP untuk memastikan kode mudah dikelola:

- **Encapsulation (Enkapsulasi)**: Terlihat pada `FirebaseService` di `lib/services/firebase_service.dart`. Data sensitif seperti `_auth` dan `_database` dibuat private (`_`), dan hanya bisa diakses melalui metode publik yang terkontrol.
- **Abstraction (Abstraksi)**: UI tidak perlu tahu cara kerja Firebase secara detail. UI hanya memanggil fungsi seperti `triggerWaterNow()` atau `watchDevice()`, sementara detail teknis pengiriman data disembunyikan di dalam Service.
- **Inheritance (Pewarisan)**: Setiap halaman di `lib/screens/` mewarisi sifat dari `StatelessWidget` atau `StatefulWidget` milik Flutter.
- **Polymorphism (Polimorfisme)**: Penggunaan metode `build(BuildContext context)` di setiap widget adalah contoh polimorfisme, di mana setiap widget mendefinisikan ulang (override) cara mereka merender diri sendiri.
- **Data Modeling**: Penggunaan class internal seperti `_GameResult` (di dalam `firebase_service.dart`) untuk membungkus hasil kalkulasi skor dan riwayat ke dalam satu objek yang terstruktur.

---


## 🎨 1. Merubah Warna & Tampilan (Theming)

Seluruh tema dasar aplikasi didefinisikan di file utama:
📍 **`lib/main.dart`**

Cari bagian `ThemeData` di dalam class `GrowBuddyApp` (baris 27-57):

- **Warna Background**: Ubah `scaffoldBackgroundColor` (default: `#FFF9E7`).
- **Warna Utama (Primary)**: Ubah `seedColor` atau `primary` di `ColorScheme`. Ini akan merubah warna tombol dan elemen aktif lainnya.
- **Warna AppBar**: Ubah `appBarTheme` untuk mengganti warna header aplikasi.
- **Font**: Aplikasi menggunakan Google Fonts `Plus Jakarta Sans`. Anda bisa menggantinya di bagian `textTheme`.

---

## 🏗️ 2. Merubah Layout & Halaman

Semua halaman aplikasi berada di folder:
📍 **`lib/screens/`**

### Struktur Halaman Utama:
1. **`home_dashboard.dart`**: Halaman utama yang menampilkan sensor (Kelembaban Tanah, Suhu, Kelembaban Udara) dan tombol siram.
2. **`history_screen.dart`**: Grafik riwayat data sensor.
3. **`settings_screen.dart`**: Pengaturan profil dan perangkat.
4. **`device_selection.dart`**: Halaman awal untuk memilih/menghubungkan perangkat baru.

### Navigasi:
📍 **`lib/screens/device_shell_screen.dart`**
File ini adalah pembungkus (shell) yang menangani perpindahan halaman melalui **Bottom Navigation Bar**. Jika ingin menambah menu baru, edit file ini dan `lib/widgets/grow_bottom_navigation_bar.dart`.

---

## ⚙️ 3. Merubah Logika Aplikasi (Flutter)

Logika komunikasi data dengan Firebase dipusatkan di satu tempat:
📍 **`lib/services/firebase_service.dart`**

- **Ambil Data Sensor**: Cari fungsi yang melakukan `stream` atau `listen` ke path `devices/{deviceId}/status`.
- **Kontrol Pompa**: Cari fungsi yang mengupdate nilai `pump_status` di Firebase.
- **Simpan Device ID**: Logika penyimpanan ID perangkat ke profil pengguna ada di fungsi `saveDeviceId`.

---

## 🔌 4. Merubah Logika Perangkat (ESP32)

Jika ingin merubah perilaku hardware, edit file firmware:
📍 **`esp32/SmartPlant_ESP32_REST/SmartPlant_ESP32_REST.ino`**

- **PIN Hardware**: Ubah `#define SOIL_PIN` atau `PUMP_PIN` jika menggunakan pin berbeda (baris 9-10).
- **Interval Update**: Ubah `SAMPLE_INTERVAL_MS` (default 10 detik) untuk merubah seberapa sering data dikirim ke Firebase (baris 23).
- **Threshold Penyiraman**: Logika otomatisasi (jika ada) biasanya diletakkan di dalam fungsi `loop()`.

---

## 🔐 5. Konfigurasi Firebase (PENTING)

Aplikasi ini menggunakan sistem pengamanan API Key melalui environment variables. Jangan merubah `lib/firebase_options.dart` secara manual.
📍 **`.env`** (di folder root utama)

Edit file `.env` jika ingin mengganti project Firebase yang digunakan (API Key, Project ID, App ID, dll).

---

## 🚀 Ringkasan Lokasi Edit:
- **Warna/Tema**: `lib/main.dart`
- **Dashboard**: `lib/screens/home_dashboard.dart`
- **Database/Logic**: `lib/services/firebase_service.dart`
- **Hardware/Pin**: `esp32/.../*.ino`
