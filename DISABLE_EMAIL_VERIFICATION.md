# Cara Menonaktifkan Verifikasi Email di Supabase

Untuk menggunakan email dummy tanpa verifikasi, ikuti langkah-langkah berikut:

## 1. Masuk ke Dashboard Supabase
- Buka https://supabase.com/dashboard
- Login ke akun Anda
- Pilih project `uas_c14220080`

## 2. Nonaktifkan Email Verification
1. Di sidebar kiri, klik **Authentication**
2. Klik tab **Settings**
3. Scroll ke bagian **User Signups**
4. **MATIKAN** toggle **Enable email confirmations**
5. Klik **Save**

## 3. Atur Email Templates (Opsional)
1. Masih di halaman Authentication > Settings
2. Scroll ke bagian **Email Templates**
3. Untuk **Confirm signup**, Anda bisa mengosongkan template atau mengubahnya
4. Klik **Save**

## 4. Pastikan RLS (Row Level Security) Sudah Diatur
1. Klik **Table Editor** di sidebar
2. Pilih table `recipes`
3. Klik **Authentication** > **RLS disabled** jika RLS masih aktif
4. Atau pastikan policy RLS sudah benar untuk user yang tidak terverifikasi

## 5. Test dengan Email Dummy
Setelah pengaturan di atas, Anda bisa menggunakan email seperti:
- `test@dummy.com`
- `user123@fake.email`
- `demo@notreal.xyz`

Password tetap harus minimal 6 karakter.

## Troubleshooting
Jika masih ada masalah:
1. Coba logout dari semua device dan clear browser cache
2. Restart aplikasi Flutter
3. Pastikan semua pengaturan sudah disave di dashboard Supabase
