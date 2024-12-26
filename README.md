# advanced_inventory_management

A11.2021.13937 - Bengkel Koding Tugas 2

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Tahap 2: Advanced Inventory Management

## Fitur-Fitur Lanjutan

- **Fitur Login**:
  - Sistem otentikasi pengguna menggunakan Firebase Authentication (email/password).
  
- **Manajemen Data Supplier**:
  - Input data pemasok, termasuk nama, alamat, dan informasi kontak.
  - **Location-Based Service**: Lokasi kantor pemasok disimpan sebagai titik koordinat menggunakan GPS perangkat.
  
- **Relasi Data Barang-Supplier**:
  - Barang dihubungkan dengan pemasok untuk mencatat sumber barang.
  
- **Penyimpanan Cloud**:
  - Semua data, termasuk gambar barang, riwayat transaksi, dan informasi pemasok, diunggah ke Firebase **(Supabase)**.
  - Penyimpanan data yang pada tahap 1 disimpan di local dengan SQLite, pada tahap ini diubah agar tersimpan ke Firestore dan Firebase Storage **(Supabase)**.

## Tampilan yang Diperlukan

### 1. Halaman Login

- **Fungsi**: Mengelola autentikasi pengguna.
- **Konten**:
  - Form input (email, password).
  - Tombol untuk login.
  - Tautan ke halaman registrasi.
- **Aksi**:
  - Autentikasi pengguna dengan Firebase Authentication **(Supabase Auth)**.
  - Navigasi ke halaman dashboard setelah login berhasil.

### 2. Halaman Registrasi

- **Fungsi**: Membuat akun baru.
- **Konten**:
  - Form input (email, password, konfirmasi password).
- **Aksi**:
  - Registrasi pengguna ke Firebase Authentication.
  - Navigasi ke halaman dashboard setelah registrasi berhasil.

### 3. Halaman Dashboard

- **Fungsi**: Menampilkan ringkasan data inventaris dan supplier.
- **Konten**:
  - Total barang: jika diklik navigasi ke halaman daftar barang.
  - Jumlah Supplier: jika diklik navigasi ke halaman daftar supplier.
- **Aksi**:
  - Navigasi ke halaman daftar barang.
  - Navigasi ke halaman daftar supplier.

### 4. Halaman Tambah Supplier

- **Fungsi**: Input data supplier baru.
- **Konten**:
  - Form input (nama supplier, alamat, kontak).
  - Tombol untuk mengambil lokasi supplier dengan GPS.
- **Aksi**:
  - Menyimpan data supplier ke Firebase Firestore **(Supabase)**.
  - Menampilkan koordinat lokasi dengan location-based services.

### 5. Halaman Daftar Supplier

- **Fungsi**: Menampilkan semua supplier yang telah ditambahkan.
- **Konten**:
  - Daftar nama supplier, alamat, dan kontak.
- **Aksi**:
  - Navigasi ke halaman detail supplier.
  - Menghapus atau memperbarui data supplier.

### 6. Halaman Detail Supplier

- **Fungsi**: Menampilkan detail supplier, termasuk lokasi.
- **Konten**:
  - Nama supplier, alamat, kontak, koordinat lokasi.
  - Tombol untuk membuat google map ke koordinat lokasi.
- **Aksi**:
  - Menampilkan peta lokasi supplier menggunakan koordinat.
