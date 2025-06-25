# Test Credentials untuk Demo

Untuk memudahkan testing aplikasi Recipe Keeper, berikut adalah contoh credentials yang bisa digunakan:

## Email Dummy untuk Testing
Gunakan email format yang valid tapi tidak perlu email asli:

### Contoh Email Testing:
- `test@example.com` 
- `demo@dummy.com`
- `user123@fake.email`
- `admin@notreal.xyz`
- `student@testing.com`
- `recipe@lover.com`

## Password untuk Testing
Password minimal 6 karakter:

### Contoh Password:
- `password123`
- `testing456`
- `demo2024`
- `recipe123`
- `user456789`

## Skenario Testing

### 1. Sign Up Berhasil
- Email: `test@example.com`
- Password: `password123`
- Confirm Password: `password123`

### 2. Sign In dengan Email/Password Salah
- Email: `wrong@email.com` (tidak terdaftar)
- Password: `wrongpass`
- **Expected:** Error "❌ Invalid email or password. Please check your credentials."

### 3. Sign In dengan Password Salah
- Email: `test@example.com` (sudah terdaftar)
- Password: `wrongpassword`
- **Expected:** Error "❌ Invalid email or password. Please check your credentials."

### 4. Sign Up dengan Email yang Sudah Ada
- Email: `test@example.com` (sudah digunakan)
- Password: `newpassword`
- **Expected:** Error "📧 Email already exists. Please use a different email or sign in."

### 5. Password Terlalu Pendek
- Email: `new@test.com`
- Password: `123` (kurang dari 6 karakter)
- **Expected:** Error "🔒 Password must be at least 6 characters long."

## Pesan Error yang Ditampilkan

### Login Errors:
- ❌ Invalid email or password. Please check your credentials.
- ⏰ Too many login attempts. Please try again later.
- 📧 Email not found. Please check your email or sign up.
- 🌐 Network error. Please check your internet connection.

### Sign Up Errors:
- 📧 Email already exists. Please use a different email or sign in.
- 🔒 Password must be at least 6 characters long.
- 📧 Please enter a valid email format (e.g., test@example.com).
- ⏰ Too many attempts. Please try again later.
- 🌐 Network error. Please check your internet connection.

### Success Messages:
- ✅ Welcome back, [email]! (Login)
- 🎉 Welcome, [email]! (Sign Up)

## Catatan
- Semua notifikasi ditampilkan dengan icon dan warna yang sesuai
- Error notifications berwarna merah dengan durasi 4 detik
- Success notifications berwarna hijau dengan durasi 2 detik
- Notifications menggunakan floating snackbar dengan border radius
