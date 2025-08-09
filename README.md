# 🍵 Cafe Management App

Aplikasi manajemen kafe modern yang dibangun dengan Flutter. Aplikasi ini menyediakan sistem Point of Sale (POS) lengkap untuk mengelola menu, transaksi, inventori, dan laporan kafe.

## ✨ Fitur Utama

- 📊 **Dashboard Interaktif** - Overview bisnis dengan statistik real-time
- 🍽️ **Manajemen Menu** - Kelola makanan dan minuman dengan mudah
- 🛒 **Sistem POS** - Point of Sale dengan berbagai metode pembayaran
- 👥 **Manajemen Member** - Sistem keanggotaan pelanggan
- 📈 **Laporan Lengkap** - Laporan keuangan dan analisis bisnis
- 📦 **Manajemen Inventori** - Pantau stok dan bahan baku
- 🧾 **Invoice Digital** - Struk digital yang dapat dicetak

## 🚀 Quick Start

### Prasyarat
Pastikan Anda sudah menginstall:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versi 3.0 atau lebih baru)
- Android Studio atau VS Code
- Git

### Instalasi Cepat (Windows)

1. **Clone Repository**
   ```bash
   git clone <repository-url>
   cd cafe_app
   ```

2. **Jalankan Installer Otomatis**
   ```bash
   install.bat
   ```

3. **Jalankan Aplikasi**
   ```bash
   run.bat
   ```

### Instalasi Manual

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Jalankan Aplikasi**
   ```bash
   flutter run
   ```

3. **Build APK (Opsional)**
   ```bash
   build.bat
   # atau manual:
   flutter build apk --release
   ```

## 📱 Cara Penggunaan

### File Batch Commands

- **`install.bat`** - Setup otomatis dan install dependencies
- **`run.bat`** - Jalankan aplikasi dalam mode debug
- **`build.bat`** - Build APK release untuk produksi

### Command Manual

```bash
# Development
flutter run                    # Run debug mode
flutter run --release         # Run release mode
flutter run -d chrome         # Run di web browser

# Build
flutter build apk             # Build APK debug
flutter build apk --release   # Build APK release
flutter build web             # Build untuk web

# Maintenance
flutter clean                 # Bersihkan cache build
flutter pub get              # Update dependencies
flutter upgrade              # Update Flutter SDK
```

## 🏗️ Struktur Aplikasi

```
lib/
├── main.dart                 # Entry point aplikasi
├── database/
│   └── database_helper.dart  # SQLite database handler
├── models/                   # Data models
│   ├── food.dart
│   ├── drink.dart
│   ├── transaction.dart
│   └── member.dart
├── providers/                # State management
│   ├── product_provider.dart
│   ├── cart_provider.dart
│   └── transaction_provider.dart
├── screens/                  # UI Screens
│   ├── dashboard_screen.dart
│   ├── food_management_screen.dart
│   ├── cart_screen.dart
│   └── reports_screen.dart
├── widgets/                  # Reusable widgets
└── services/                 # Helper services
```

## 💾 Database

Aplikasi menggunakan SQLite untuk penyimpanan lokal dengan tabel:
- **foods** - Data menu makanan
- **drinks** - Data menu minuman  
- **transactions** - Riwayat transaksi
- **transaction_items** - Detail item transaksi
- **members** - Data member/pelanggan
- **ingredients** - Data bahan baku
- **stock_movements** - Pergerakan stok

## 🎨 UI/UX Features

- **Modern Design** - Interface yang clean dan intuitif
- **Responsive Layout** - Mendukung berbagai ukuran layar
- **Dark/Light Theme** - Tema yang dapat disesuaikan
- **Smooth Animations** - Transisi yang halus
- **Icon Integration** - FontAwesome icons

## 🔧 Pengembangan

### Hot Reload
```bash
flutter run
# Tekan 'r' untuk hot reload
# Tekan 'R' untuk hot restart
```

### Debug
```bash
flutter run --debug           # Mode debug dengan debugging info
flutter run --profile         # Mode profiling untuk performance testing
```

### Testing
```bash
flutter test                  # Jalankan unit tests
flutter drive                 # Jalankan integration tests
```

## 📦 Dependencies

Aplikasi ini menggunakan package-package berikut:
- `provider` - State management
- `sqflite` - SQLite database
- `google_fonts` - Custom fonts
- `font_awesome_flutter` - Icons
- `image_picker` - Image selection
- `pdf` & `printing` - PDF generation
- `intl` - Internationalization

## 🐛 Troubleshooting

### Error: Flutter not found
```bash
# Pastikan Flutter sudah ditambahkan ke PATH
# Atau jalankan:
where flutter
```

### Error: Pub get failed
```bash
flutter clean
flutter pub get
```

### Error: Build failed
```bash
flutter clean
flutter pub get
flutter build apk --verbose
```

## 📞 Support

Jika mengalami masalah atau butuh bantuan:
1. Periksa [Flutter Documentation](https://docs.flutter.dev/)
2. Cek [Common Issues](https://docs.flutter.dev/development/tools/android-studio#troubleshooting)
3. Buat issue di repository ini
4. Hubungi developer: raydenfly84@gmail.com

## 👨‍💻 Credits

**Developer:** RAYDENFLY / Azis Maulana  
**Email:** raydenfly84@gmail.com  
**Portfolio:** [raydenfly.github.io](https://raydenfly.github.io)

Aplikasi Cafe Management ini dikembangkan dengan ❤️ menggunakan Flutter.

## 📄 License

Project ini menggunakan [MIT License](LICENSE).

---

**Happy Coding! ☕**
