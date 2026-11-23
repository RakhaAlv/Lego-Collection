# LETS — Aplikasi Katalog Koleksi Set LEGO

Tugas Akhir Praktikum PPB 2026

| | |
|---|---|
| **Pengembang** | Rakha Aljiva Prabaswara |
| **NIM** | 21120124140126 |
| **Kelompok / Shift** | Kelompok 9 / Shift 02 |
| **Client** | Flutter (Dart, Material 3, package `http`) |
| **Web Service** | PHP REST API (JSON + proxy/cache gambar `api/image.php`) |

```text
LEGO/
├── api/                         # Web Service REST API (PHP)
│   ├── data/
│   │   ├── themes.php           # seed 6 tema (Marvel, Disney, Harry Potter, NINJAGO, City, Star Wars)
│   │   └── sets.php             # seed 30 set (5 set per tema)
│   ├── public/                  # document root
│   │   ├── index.php            # router JSON + header CORS
│   │   ├── api/image.php        # proxy/cache gambar (cURL og:image + fallback GD PNG + CORS)
│   │   ├── .htaccess            # rewrite untuk hosting Apache
│   │   └── images/              # cache gambar PNG lokal (36 gambar)
│   └── tools/generate_images.php
└── flutter_app/                 # Aplikasi Flutter (5 tab + 2 halaman detail)
```

---

## 1. Menjalankan API PHP (Backend)

Dari root folder `LEGO/`:

```bash
php -S 0.0.0.0:8000 -t api/public
```

Untuk Flutter Web (Chrome), jalankan dengan `index.php` sebagai router agar semua endpoint
dan `/api/image.php` melayani CORS dengan konsisten:

```bash
php -S 0.0.0.0:8000 -t api/public api/public/index.php
```

### Endpoint (`GET`)

| Endpoint | Respons |
|---|---|
| `/api/sets` | `{"status":"success","data":[...]}` (30 set) |
| `/api/sets?theme_id=1` | daftar 5 set pada tema tertentu |
| `/api/sets/{id}` | `{"status":"success","data":{...}}` atau **404** `{"status":"error","message":"Set LEGO tidak ditemukan"}` |
| `/api/themes` | `{"status":"success","data":[...]}` (6 tema) |
| `/api/themes/{id}` | `{"status":"success","data":{...}}` atau **404** `{"status":"error","message":"Tema LEGO tidak ditemukan"}` |
| `/api/image.php?set={set_number}` | cek cache `api/public/images/`; bila belum ada ambil `og:image` produk `lego.com` via cURL & simpan ke cache, dengan fallback PNG lokal + header CORS |
| `/api/image.php?theme={theme_id}` | gambar banner tema dari cache lokal dengan header CORS |

### Catatan URL per perangkat

| Perangkat | Base URL |
|---|---|
| Emulator Android | `http://10.0.2.2:8000` (default di `lib/config/api_config.dart`) |
| HP fisik (Wi-Fi sama) | `http://<IP-LAN-laptop>:8000` — cek dengan `ipconfig` (IPv4) |
| Flutter Web / Windows | `http://localhost:8000` |
| Hosting HTTPS | `https://domain-anda.com` (arahkan document root ke `api/public`) |

---

## 2. Menjalankan Aplikasi Flutter & Build APK Release

```bash
cd flutter_app
flutter pub get
flutter analyze
flutter test
flutter run                                                     # emulator (default http://10.0.2.2:8000)
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000 # HP fisik
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
```

Build APK release:

```bash
flutter build apk --release
# atau dengan IP LAN / hosting custom:
flutter build apk --release --dart-define=API_BASE_URL=http://192.168.1.10:8000
```

### Fitur Utama

- **AppBar ala katalog `lego.com`** dengan logo resmi LEGO di sisi kiri (`Image.network` + fallback) dan tema terang (`#F7F7F7`, kartu putih berborder, aksen kuning `#F6C90E` & merah `#D01012`).
- **5 Tab `NavigationBar` (`IndexedStack`):**
  1. **Sets (`SetsListScreen`)** — 30 set, pencarian, filter 6 tema, opsi *sort* (harga, pieces, tahun), tombol wishlist cepat, & pull-to-refresh → `SetDetailScreen`.
  2. **Themes (`ThemesListScreen`)** — 6 tema LEGO → `ThemeDetailScreen` lengkap dengan daftar set pada tema tersebut.
  3. **Featured (`FeaturedSetsScreen`)** — kurasi set unggulan (`Semua Unggulan`, `Edisi 18+`, `Pieces Terbanyak`, `Rilis Terbaru`) → `SetDetailScreen`.
  4. **Wishlist (`WishlistScreen`)** — koleksi favorit pengguna beserta estimasi total harga Rupiah & badge jumlah tab → `SetDetailScreen`.
  5. **Profile (`ProfileAboutScreen`)** — profil pengembang (**Rakha Aljiva Prabaswara**, NIM **21120124140126**, **Kelompok 9 / Shift 02**), statistik katalog & wishlist, info API, dan versi **1.0.0**.
