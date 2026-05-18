# 🌱 GrowBuddy: Smart Plant Watering Game

GrowBuddy adalah ekosistem monitoring dan penyiraman tanaman pintar berbasis Internet of Things (IoT) yang digabungkan dengan mekanisme gamifikasi (Game Level & Score). Sistem ini dirancang multi-platform untuk mempermudah pemantauan tanaman Anda di mana saja dan kapan saja.

---

## 🚀 Fitur Utama
* **Real-time Monitoring**: Pemantauan kelembaban tanah, status perangkat, dan indikator online secara instan.
* **Smart Manual Watering**: Pemicuan pompa air fisik dengan konfirmasi aman dan penghitung waktu mundur non-blocking.
* **Gamifikasi Interaktif**: Naikkan level dan kumpulkan skor setiap kali Anda merawat tanaman Anda dengan kelembaban optimal!
* **Offline Simulator Engine**: Simulator internal untuk menguji seluruh fitur aplikasi desktop tanpa memerlukan perangkat keras ESP32.
* **Multi-Platform UI**: Tersedia untuk **Mobile (Flutter)** dan **Desktop (JavaFX)** dengan integrasi data yang tersinkronisasi.
* **Sistem Notifikasi Native**: Notifikasi otomatis langsung ke desktop OS saat status tanah kritis atau alat terputus.

---

## 📐 Arsitektur Sistem & Alur Kerja

```text
  [ ESP32 IoT Device ]  <--- REST API --->  [ Firebase Realtime Database ]  <--- Watcher Stream --->  [ Flutter Mobile App ]
           or                                                                                         [ JavaFX Desktop App ]
  [ Demo Simulator Engine ]
```
Untuk penjelasan mendalam mengenai arsitektur sistem, prinsip pemrograman berorientasi objek (OOP), skema database, detail fungsional seluruh file kode, silakan merujuk ke **[PANDUAN TEKNIS & DOKUMENTASI LENGKAP](file:///home/syaiful/Kuliah/GrowBuddy/DOCUMENTATION.md)**.

---

## 🛠️ Panduan Persiapan & Instalasi

### 1. Konfigurasi Backend Firebase
1. Buat proyek baru di [Firebase Console](https://console.firebase.google.com/).
2. Aktifkan **Anonymous Sign-In** pada menu **Authentication > Sign-in method**.
3. Buat database baru di **Realtime Database** (pilih lokasi Asia Tenggara jika tersedia).
4. Salin aturan keamanan dari file `database.rules.json` di proyek ini ke Console Firebase > Realtime Database > Rules.

---

### 📱 2. Menjalankan Aplikasi Mobile (Flutter)
Aplikasi mobile terletak di folder `/growbuddy`.

#### Prasyarat:
* Flutter SDK (Versi >= 3.0.0)
* Android Studio / Xcode (untuk Emulator)

#### Langkah Menjalankan:
1. Unduh konfigurasi aplikasi Firebase Anda:
   - Tambahkan aplikasi Android ke proyek Firebase, lalu unduh `google-services.json` dan letakkan di `/growbuddy/android/app/`.
   - Tambahkan aplikasi iOS ke proyek Firebase, lalu unduh `GoogleService-Info.plist` dan letakkan di `/growbuddy/ios/Runner/`.
2. Edit file `.env` di folder root utama untuk menyesuaikan konfigurasi API Key dan Database URL Anda.
3. Jalankan perintah berikut di terminal:
```bash
cd growbuddy
flutter pub get
flutter run
```

---

### 💻 3. Menjalankan Aplikasi Desktop (JavaFX)
Aplikasi desktop terletak di folder `/growbuddy_desktop`.

#### Prasyarat:
* Java Development Kit (JDK 17 atau lebih baru)
* Gradle (telah disertakan dalam pembungkus Gradle)

#### Langkah Menjalankan:
1. Buat **Service Account Key** (Kunci Akun Layanan) di Firebase Console Anda:
   - Masuk ke **Project Settings > Service accounts**.
   - Klik **Generate new private key**, lalu simpan file JSON tersebut dengan nama `serviceAccountKey.json`.
   - Pindahkan file tersebut ke folder `/growbuddy_desktop/src/main/resources/serviceAccountKey.json`.
2. Buka terminal Anda, lalu jalankan:
```bash
cd growbuddy_desktop
./gradlew run
```
*Tip: Untuk mencoba aplikasi tanpa hardware, sambungkan perangkat menggunakan awalan nama `demo_` (misalnya: `demo_perangkat_1`). Aplikasi akan mengaktifkan **Demo Simulator Engine** secara otomatis untuk mensimulasikan pergerakan sensor dan pompa air secara lokal!*

---

### 🔌 4. Mengunggah Firmware Perangkat IoT (ESP32)
Firmware mikroprosesor terletak di folder `/esp32/SmartPlant_ESP32_REST`.

#### Prasyarat:
* Arduino IDE atau VSCode PlatformIO
* Board ESP32 (misal: ESP32 Dev Module)
* Sensor Kelembaban Tanah Analog (Pin 34) & Modul Relai Pompa Air (Pin 26)

#### Langkah Upload:
1. Buka file `SmartPlant_ESP32_REST.ino` menggunakan editor pilihan Anda.
2. Sesuaikan konstanta di baris 15-18:
   - `WIFI_SSID`: Nama jaringan WiFi Anda.
   - `WIFI_PASSWORD`: Sandi jaringan WiFi Anda.
   - `DB_URL`: URL Realtime Database Firebase Anda (misal: `https://grow-buddy-34262-default-rtdb.asia-southeast1.firebasedatabase.app`).
   - `DEVICE_ID`: ID Perangkat yang unik (misal: `device_001`).
3. Sambungkan board ESP32 ke komputer Anda, pilih tipe board dan port yang sesuai, lalu klik **Upload**.
4. Buka Serial Monitor (baud rate 115200) untuk melihat aktivitas koneksi WiFi, kalibrasi NTP, dan transmisi data sensor secara langsung.

---

## 📂 Struktur Repositori Utama
* `growbuddy/`: Source code aplikasi mobile (Flutter).
* `growbuddy_desktop/`: Source code aplikasi desktop (JavaFX + Gradle).
* `esp32/`: Firmware C++ untuk papan kontrol IoT ESP32.
* `database.rules.json`: Aturan keamanan Firebase Realtime Database.
* `DOCUMENTATION.md`: Penjelasan rinci fungsi kode, relasi database, dan prinsip pemrograman OOP.
