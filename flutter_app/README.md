# LEGO Collection (Flutter Client)

Client Flutter (Material 3) untuk aplikasi **LEGO COLLECTION**.

Untuk panduan instalasi, arsitektur folder, daftar endpoint API PHP, dan tutorial lengkap menjalankan aplikasi (Web, Android Emulator, HP Fisik, Desktop, serta build APK), silakan lihat [README utama](../README.md).

## Perintah Cepat

Pastikan server API PHP sudah berjalan di port `8000`, lalu jalankan dari folder `flutter_app/`:

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
```
