# LEGO COLLECTION (Aplikasi Katalog Koleksi Set LEGO)

Aplikasi katalog interaktif berbasis **Flutter (Material 3)** yang terhubung dengan **Web Service REST API PHP** untuk menjelajahi 6 tema resmi dan 30 set LEGO pilihan (**Marvel**, **Disney**, **Harry Potter**, **NINJAGO**, **LEGO City**, dan **Star Wars**).

| Informasi | Detail |
|---|---|
| **Nama Pengembang** | Rakha Aljiva Prabaswara |
| **NIM** | 21120124140126 |
| **Versi Aplikasi** | 1.0.0 |
| **Client** | Flutter & Dart (Material 3, package `http`) |
| **Backend API** | PHP REST API (JSON + layanan gambar lokal & CORS) |

---

## Fitur Utama (5 Tab + Halaman Detail)

Navigasi utama berada di `MainNavigation` (`flutter_app/lib/screens/main_navigation.dart`) menggunakan *nested* `Navigator`, sehingga **Bottom Navigation Bar tetap tampil** saat pengguna membuka halaman Detail Set.

1. **Home (`HomeScreen`)**
   - *Hero banner carousel* yang bergeser otomatis setiap 4 detik (juga mendukung geser manual) untuk set unggulan.
   - Daftar horizontal **Shop by Theme** (6 tema koleksi yang langsung memfilter tab Catalog), **Collector Edition**, **New Arrivals**, dan pintasan menuju fitur Compare.
2. **Catalog (`SetsListScreen`)**
   - *Grid* produk gulir vertikal responsif (2 kolom di HP, 3 di tablet, 4 di desktop).
   - Pencarian *real-time* berdasarkan nama atau nomor set (mis. `76269`, `Castle`, `Falcon`).
   - Filter tab tema (`ALL`, `MARVEL`, `DISNEY`, `HARRY POTTER`, `NINJAGO`, `LEGO CITY`, `STAR WARS`) dan kontrol pengurutan (*Default*, *Price: Low to High*, *Price: High to Low*, *Most Pieces*, *Newest*).
   - Kartu preview menampilkan nomor set, *badge* rating usia (`AGE 18+`, `AGE 9+`, dll.), jumlah `pcs`, harga Rupiah, tahun rilis, dan tombol Wishlist cepat.
3. **Compare (`CompareSetsScreen`)**
   - Memilih 2 set (**Set A** dan **Set B**) secara berdampingan untuk membandingkan foto produk, nomor set, tema, harga, jumlah *pieces* (`pcs`), harga rata-rata per *piece* (`BEST VALUE` / `MORE PIECES`), rating usia, dan tahun rilis.
4. **Wishlist (`WishlistScreen`)**
   - Menyimpan set favorit dengan sinkronisasi *badge* angka di Bottom Navigation Bar secara langsung dan menghitung estimasi total harga seluruh koleksi di Wishlist.
5. **Profile (`ProfileAboutScreen`)**
   - Profil anggota **LEGO Insiders** (foto profil, nama lengkap, NIM) beserta ringkasan dan versi aplikasi.
6. **Halaman Detail (`SetDetailScreen`)**
   - Tata letak 2 kolom responsif (informasi di kiri & foto besar rasio 1:1 di kanan pada layar lebar; bertumpuk rapi di HP).
   - Menampilkan spesifikasi lengkap (`TOTAL PIECES`, `AGE RATING`, `RELEASE YEAR`, `DIMENSIONS`), deskripsi produk, tombol `SAVE TO WISHLIST`, serta rekomendasi **Related Sets** dari tema yang sama.

---

## Struktur Proyek

```text
LEGO/
├── api/                                # Backend Web Service REST API (PHP)
│   ├── data/
│   │   ├── themes.php                  # Data 6 tema LEGO
│   │   └── sets.php                    # Data 30 set LEGO (5 set per tema)
│   ├── public/                         # Document root server PHP
│   │   ├── index.php                   # Router API JSON (/api/sets, /api/themes) + CORS + statis gambar
│   │   ├── api/image.php               # Handler cache/fallback gambar
│   │   ├── .htaccess                   # Konfigurasi rewrite untuk Apache
│   │   └── images/                     # Aset gambar produk (.webp / .png)
│   └── tools/                          # Script bantu pengelolaan gambar
├── flutter_app/                        # Aplikasi Client Flutter
│   ├── lib/
│   │   ├── main.dart                   # Entry point & konfigurasi ThemeData global
│   │   ├── config/api_config.dart      # Konfigurasi Base URL API & timeout
│   │   ├── models/                     # Model data (lego_set.dart, lego_theme.dart)
│   │   ├── services/                   # HTTP client (api_service.dart) & state Wishlist (wishlist_store.dart)
│   │   ├── utils/currency_formatter.dart
│   │   ├── widgets/lego_set_card.dart  # Komponen kartu produk, badge, & pembungkus gambar
│   │   └── screens/                    # 5 halaman tab + SetDetailScreen + MainNavigation
│   ├── test/widget_test.dart           # Unit test & widget test (8 skenario)
│   └── web/                            # Asset Web & loading screen (index.html, manifest.json)
├── .gitignore
└── README.md
```

---

## Prasyarat

Pastikan perangkat Anda sudah terpasang:
- **PHP 8.0+** (terdaftar di `PATH`, cek dengan `php -v`)
- **Flutter SDK** (Dart `^3.13.3`, cek dengan `flutter doctor`)
- Browser (Chrome/Edge) untuk menjalankan versi Web, atau Android Emulator / HP Android untuk versi mobile.

---

## Tutorial Menjalankan Aplikasi

> **Penting:** Server backend PHP **harus dijalankan terlebih dahulu** agar aplikasi Flutter dapat memuat daftar tema, set, dan gambar produk.

### Langkah 1: Jalankan Backend REST API PHP

Buka terminal di root folder `LEGO/`, lalu jalankan perintah berikut:

```bash
php -S 0.0.0.0:8000 -t api/public api/public/index.php
```

> Menggunakan router `api/public/index.php` di belakang perintah `php -S` wajib dilakukan agar endpoint JSON dan folder `/images/` sama-sama mengirimkan header CORS untuk Flutter Web.

Verifikasi API berjalan dengan membuka browser atau `curl`:
- http://localhost:8000/api/themes (mengembalikan 6 tema)
- http://localhost:8000/api/sets (mengembalikan 30 set)

---

### Langkah 2: Siapkan Dependensi Flutter

Buka terminal kedua (biarkan terminal API tetap berjalan), lalu masuk ke folder `flutter_app`:

```bash
cd flutter_app
flutter pub get
```

---

### Langkah 3: Jalankan Aplikasi Flutter (Pilih Salah Satu Platform)

#### A. Mode Web via Chrome (Development / Hot Reload)
```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
```

#### B. Mode Web Production (Build Statis Port 8080)
Build aplikasi web terlebih dahulu di folder `flutter_app/`:
```bash
flutter build web --dart-define=API_BASE_URL=http://localhost:8000
```
Lalu jalankan server statis dari folder root `LEGO/` pada terminal baru:
```bash
php -S 127.0.0.1:8080 -t flutter_app/build/web
```
Buka http://127.0.0.1:8080/ di browser.

#### C. Emulator Android
Gunakan `10.0.2.2` sebagai alamat `localhost` komputer host dari dalam Android Emulator:
```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

#### D. HP Fisik Android (Dalam Satu Wi-Fi)
1. Cek alamat IPv4 komputer Anda melalui `ipconfig` (Windows) atau `ifconfig` (macOS/Linux), misalnya `192.168.1.10`.
2. Jalankan aplikasi dengan IP tersebut:
```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000
```

#### E. Windows Desktop
```bash
flutter run -d windows --dart-define=API_BASE_URL=http://localhost:8000
```

---

## Pengujian & Build APK Release

Jalankan seluruh perintah ini dari dalam folder `flutter_app/`:

```bash
# 1. Cek static analysis kode Dart
flutter analyze

# 2. Jalankan 8 unit test & widget test
flutter test

# 3. Build APK Android release (sesuaikan API_BASE_URL dengan IP server / hosting Anda)
flutter build apk --release --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

File APK hasil build akan tersimpan di `flutter_app/build/app/outputs/flutter-apk/app-release.apk`.

---

## Daftar Endpoint API (`GET`)

| Endpoint | Keterangan |
|---|---|
| `/api/sets` | Mengambil seluruh 30 set LEGO (`{"status":"success","data":[...]}`) |
| `/api/sets?theme_id=1` | Memfilter set berdasarkan ID tema (`1` s.d. `6`) |
| `/api/sets/{id}` | Mengambil detail 1 set LEGO, atau HTTP `404` jika ID tidak ditemukan |
| `/api/themes` | Mengambil daftar seluruh 6 tema koleksi LEGO |
| `/api/themes/{id}` | Mengambil detail 1 tema LEGO, atau HTTP `404` jika ID tidak ditemukan |
| `/images/{file}` | Mengambil file foto produk langsung dari `api/public/images/` dengan header CORS |
| `/api/image.php?set={set_number}` | Fallback proxy/cache gambar berdasarkan nomor set |

---
