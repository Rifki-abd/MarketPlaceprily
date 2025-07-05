# Panduan Onboarding Pengembang

Selamat datang di tim proyek Marketplace App! Dokumen ini akan memandu Anda melalui arsitektur, alur kerja, dan praktik terbaik yang kita gunakan.

## 1. Memahami Arsitektur

Hal pertama yang harus dipahami adalah arsitektur **Feature-First + Clean Architecture** kita.

- **Feature-First**: Semua kode untuk satu fitur (misalnya, `product`) berada di dalam satu folder: `lib/features/product/`. Ini membuat kode lebih mudah ditemukan dan dikelola.
- **Clean Architecture**: Di dalam setiap fitur, kode dibagi menjadi tiga lapisan:
    1.  **`domain`**: Ini adalah jantungnya. Berisi *model* (contoh: `ProductModel`). Lapisan ini tidak boleh tahu tentang Flutter atau Supabase. Hanya kode Dart murni.
    2.  **`data`**: Di sinilah *repository* berada. Tugasnya adalah mengambil data dari internet (Supabase). Ini adalah satu-satunya tempat yang "berbicara" dengan Supabase.
    3.  **`presentation`**: Ini adalah lapisan UI. Berisi *screens*, *widgets*, dan *providers* (state management). UI hanya boleh bergantung pada provider, bukan repository secara langsung.

**Alur Data:**
`Screen` → `Provider` (Riverpod) → `Repository` → `Supabase`

## 2. Alur Kerja Menambah Fitur Baru

Misalkan Anda ingin menambahkan fitur **"Keranjang Belanja" (`cart`)**:

1.  **Buat Folder Fitur**:
    Buat folder baru di `lib/features/cart`.

2.  **Buat Struktur Internal**:
    Di dalam `lib/features/cart/`, buat tiga folder: `data`, `domain`, dan `presentation`.

3.  **Definisikan Domain**:
    Buat model `CartItem` di dalam `lib/features/cart/domain/cart_model.dart`.

4.  **Buat Repository**:
    Buat `CartRepository` di `lib/features/cart/data/cart_repository.dart`. Tambahkan metode seperti `getCartItems()`, `addToCart()`, dll.

5.  **Buat Provider**:
    Di `lib/features/cart/presentation/providers/cart_provider.dart`, buat `StateNotifier` atau `FutureProvider` yang menggunakan `CartRepository` untuk mengelola state keranjang belanja.

6.  **Buat UI**:
    Buat `CartScreen` di `lib/features/cart/presentation/screens/cart_screen.dart`. Gunakan `ref.watch` untuk mendengarkan perubahan dari provider Anda.

7.  **Tambahkan Rute**:
    Buka `lib/core/routing/app_router.dart` dan tambahkan rute baru untuk `/cart` yang menunjuk ke `CartScreen`.

## 3. Aturan Emas (Golden Rules)

- **UI adalah "Dumb"**: Jangan letakkan logika bisnis (memanggil API, memformat data kompleks) di dalam widget. Widget hanya bertugas menampilkan apa yang diberikan oleh provider.
- **Repository untuk Data**: Semua query ke Supabase harus berada di dalam sebuah Repository.
- **Provider untuk State**: Gunakan Riverpod untuk mengelola state. Jangan gunakan `setState` untuk state yang kompleks atau yang dibagikan.
- **Impor Berdasarkan Layer**:
    - `presentation` boleh mengimpor dari `domain`.
    - `data` boleh mengimpor dari `domain`.
    - `domain` **TIDAK BOLEH** mengimpor dari layer lain.
- **Gunakan `.autoDispose`**: Untuk provider yang datanya tidak perlu disimpan selamanya (misalnya, data untuk satu halaman spesifik), gunakan modifier `.autoDispose` untuk membersihkan memori secara otomatis.

Dengan mengikuti panduan ini, kita dapat memastikan proyek ini tetap bersih, terstruktur, dan menyenangkan untuk dikembangkan bersama. Selamat bekerja!
