# Marketplace App - Flutter

Aplikasi marketplace modern yang dibangun dengan Flutter, Supabase, dan Riverpod. Proyek ini mengikuti arsitektur **Feature-First** yang dikombinasikan dengan prinsip **Clean Architecture** untuk memastikan skalabilitas, keterbacaan, dan kemudahan pemeliharaan.

## ✨ Fitur Utama

- **Autentikasi Pengguna**: Login & Register menggunakan Supabase Auth.
- **Manajemen Produk**: Pengguna dengan role `penjual` dapat melakukan operasi CRUD (Create, Read, Update, Delete) pada produk mereka.
- **Tampilan Produk**: Pengguna dapat melihat daftar produk yang tersedia.
- **Manajemen Profil**: Pengguna dapat melihat dan mengedit profil mereka.
- **Navigasi Modern**: Menggunakan `GoRouter` untuk routing yang kuat dan berbasis state.
- **State Management**: Menggunakan `Riverpod` untuk manajemen state yang reaktif dan efisien.

## 🏗️ Arsitektur Proyek

Proyek ini mengadopsi struktur **Feature-First**, di mana setiap fitur utama (seperti `auth`, `product`) diisolasi dalam modulnya sendiri.

Struktur Direktori:
```
lib/
├── core/          # Kode inti (routing, theme, providers global)
├── features/      # Semua fitur aplikasi
│   └── [nama_fitur]/
│       ├── data/
│       ├── domain/
│       └── presentation/
├── shared/        # Widget yang dapat digunakan kembali di banyak fitur
└── main.dart
```

Setiap fitur dibagi menjadi tiga layer utama sesuai dengan Clean Architecture:
- **`domain`**: Berisi model (entitas) dan logika bisnis murni (plain Dart objects).
- **`data`**: Berisi *repository* yang bertanggung jawab untuk mengambil dan memanipulasi data dari sumber eksternal (Supabase).
- **`presentation`**: Berisi UI (`screens`, `widgets`) dan state management (`providers` Riverpod).

## 🚀 Memulai

Pastikan Anda memiliki [Flutter SDK](https://flutter.dev/docs/get-started/install) terinstal.

1.  **Clone repositori:**
    ```bash
    git clone https://github.com/Rifki-abd/MarketPlaceprily.git
    cd MarketPlaceprily
    ```

2.  **Buat file `.env`:**
    Buat file bernama `.env` di root proyek dan isikan dengan kredensial Supabase Anda:
    ```
    SUPABASE_URL=https://your-supabase-url.supabase.co
    SUPABASE_ANON_KEY=your-supabase-anon-key
    ```
    *Pastikan file `.env` sudah ditambahkan ke `.gitignore`.*

3.  **Install dependensi:**
    ```bash
    flutter pub get
    ```

4.  **Jalankan aplikasi:**
    ```bash
    flutter run
    ```

## ✅ Linting

Proyek ini menggunakan [`very_good_analysis`](https://pub.dev/packages/very_good_analysis) untuk menjaga kualitas kode. Jalankan perintah berikut untuk menganalisis kode:
```bash
flutter analyze
```

---
Dibuat dengan ❤️ dan kode yang rapi.
