# AUCTOBID - Flutter Mobile App

![AUCTOBID Logo](assets/images/AUCTOBID-Logo.png)

**Aplikasi Mobile AUCTOBID - Sistem Pelelangan Online.**

---

## 🏰 Tentang Aplikasi

AUCTOBID Mobile adalah aplikasi Flutter untuk pengguna masyarakat yang ingin mengikuti lelang online. Aplikasi ini terhubung dengan backend Laravel melalui REST API dan WebSocket untuk real-time bidding.

### 🎨 Tema Desain

Medieval Fantasy dengan palet warna:

- **Primary**: `#8B4513` (Saddle Brown).
- **Secondary**: `#D4AF37` (Gold).
- **Background**: `#FFF8DC` (Cornsilk/Parchment).
- **Text**: `#2F4F4F` (Dark Slate).
- **Font**: Google Fonts - Cinzel (heading), Merriweather (body).

---

## 🛠️ Tech Stack

- **Framework**: Flutter 3.x.
- **State Management**: Provider.
- **HTTP Client**: Dio.
- **WebSocket**: web_socket_channel.
- **Secure Storage**: flutter_secure_storage.
- **Image Picker**: image_picker.
- **Fonts**: google_fonts

---

## 👥 Pengguna

Aplikasi ini digunakan oleh **Masyarakat** untuk:

- Mendaftar dan login
- Melihat lelang yang tersedia
- Memasang bid pada lelang
- Submit barang untuk dilelang
- Melihat riwayat bid
- Melakukan pembayaran (simulasi)
- Menerima notifikasi

---

## 📋 Fitur Utama

- ✔️ Splash screen dengan animasi logo.
- ✔️ Login & registrasi.
- ✔️ Home dengan bottom navigation.
- ✔️ Galeri gambar lelang.
- ✔️ Real-time bidding via WebSocket.
- ✔️ Submit barang dengan multi-image picker.
- ✔️ Riwayat bid (semua/aktif/menang).
- ✔️ Pembayaran simulasi.
- ✔️ Notifikasi push.
- ✔️ Pengaturan profil.
- ✔️ Edit profil dengan upload foto.

---

## ⚙️ Instalasi

### Prasyarat

- Flutter SDK >= 3.0
- Chrome browser (untuk web mode)
- Backend Laravel sudah berjalan di localhost:8000

### Langkah Instalasi

```bash
# 1. Get dependencies
flutter pub get

# 2. Pastikan backend Laravel sudah berjalan
# Backend: http://localhost:8000

# 3. Jalankan aplikasi di Chrome (Web Mode)
flutter run -d chrome
```

---

## 🚀 Menjalankan Aplikasi

### Web Mode (Recommended)

```bash
flutter run -d chrome
```

### Cek Devices

```bash
flutter devices
```

---

## 🔑 Login Default

| Email            | Password    |
| ---------------- | ----------- |
| john@example.com | password123 |

---

## 📡 Konfigurasi API

Edit file `lib/config/api_config.dart`:

```dart
class ApiConfig {
  // Backend URL
  static const String baseUrl = 'http://localhost:8000';

  // WebSocket
  static const String wsHost = 'localhost';
  static const int wsPort = 8080;
}
```

---

## 📁 Struktur Folder

```
auctobid_mobile/
├── lib/
│   ├── config/           # Konfigurasi tema, routes, API
│   ├── models/           # Data models (User, Auction, Item, dll)
│   ├── providers/        # State management (5 providers)
│   ├── screens/          # UI screens (14 screens)
│   ├── services/         # API & WebSocket services
│   └── widgets/          # Reusable widgets (AuctionCard)
├── assets/
│   └── images/           # Logo assets
├── pubspec.yaml          # Dependencies
└── README.md             # Dokumentasi ini
```

---

## 📱 Screens

| Screen              | Deskripsi                              |
| ------------------- | -------------------------------------- |
| SplashScreen        | Animasi logo saat loading              |
| LoginScreen         | Form login pengguna                    |
| RegisterScreen      | Form registrasi lengkap                |
| HomeScreen          | Dashboard dengan 4 tab                 |
| AuctionDetailScreen | Detail lelang dengan galeri            |
| BidHistoryScreen    | Riwayat bid (tabs: Semua/Aktif/Menang) |
| SubmitItemScreen    | Form submit barang dengan image picker |
| PaymentScreen       | Simulasi pembayaran                    |
| NotificationsScreen | Daftar notifikasi                      |
| SettingsScreen      | Pengaturan aplikasi                    |
| EditProfileScreen   | Edit profil dengan foto                |

---

## 🔧 Providers

| Provider             | Fungsi                          |
| -------------------- | ------------------------------- |
| AuthProvider         | Login, register, logout, profil |
| AuctionProvider      | List lelang, detail, bid        |
| ItemProvider         | Submit item, kategori, kondisi  |
| NotificationProvider | Notifikasi pengguna             |
| BidProvider          | Riwayat bid, kemenangan         |

---

## 📝 Logo Assets

Assets logo di folder `assets/images/`:

- `AUCTOBID-Logo.png` - Logo utama.
- `AUCTOBID-Favicon.png` - Icon aplikasi.

---

## ⚠️ Catatan Penting

1. **Web Mode Only** - Aplikasi dijalankan di Chrome untuk development.
2. **Backend Required** - Pastikan Laravel backend sudah running.
3. **WebSocket** - Untuk real-time bidding, jalankan Reverb di backend.

---

## 🌐 Koneksi Backend

Pastikan backend Laravel berjalan:

```bash
# Di folder AUCTOBID-Website
php artisan serve --port=8000
php artisan reverb:start --port=8080
```

---

## 📄 Lisensi

**© 2025 AUCTOBID - All rights reserved | Developed by StegoYas**

---

![AUCTOBID Favicon](assets/images/AUCTOBID-Favicon.png)
