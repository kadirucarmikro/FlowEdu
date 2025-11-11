# FlowEdu Veritabanı Seed İşlemi - Adım Adım Rehber

Bu rehber, veritabanını yapılandırmak ve test verileri eklemek için izlemeniz gereken adımları açıklar.

> ⚠️ **Not**: Development/test SQL script'leri (delete-all-data.sql, seed-sample-data.sql, seed-auth-users.sql) production için gerekli olmadığından kaldırılmıştır. Production için gerekli SQL dosyaları `docs/` klasöründe bulunmaktadır.

## 📋 Veritabanı Kurulumu

### Adım 1: Production SQL Script'lerini Çalıştır

Supabase SQL Editor'da aşağıdaki dosyaları sırayla çalıştırın:

1. **`docs/create-basic-tables.sql`** - Temel tablolar, RLS politikaları ve fonksiyonlar
2. **`docs/about-rls-policies.sql`** - About modülü RLS politikaları
3. **`docs/lesson-schedules-rls-policies.sql`** - Lesson schedules RLS politikaları
4. **`docs/payments-rls-policies.sql`** - Payments modülü RLS politikaları

### Adım 2: Test Verileri Ekle (Opsiyonel)

Test verileri eklemek için Flutter script'ini kullanabilirsiniz:

#### 2.1. .env Dosyasını Kontrol Et

Proje kök dizininde `.env` dosyası olmalı. Eğer yoksa oluşturun:

```bash
# Proje kök dizininde
touch .env
```

`.env` dosyasına şu bilgileri ekleyin:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

**Supabase bilgilerini nereden bulabilirim?**
1. Supabase Dashboard'a giriş yapın
2. Project Settings → API sekmesine gidin
3. `Project URL` → `SUPABASE_URL` olarak kullanın
4. `anon public` key → `SUPABASE_ANON_KEY` olarak kullanın

#### 2.2. Flutter Script ile Test Verileri Ekle

Terminal'de proje kök dizininde şu komutu çalıştırın:

```bash
dart run lib/scripts/seed_database.dart
```

**Beklenen Çıktı:**
```
🚀 Tango Dans Okulu veritabanı seed işlemi başlatılıyor...

📝 Admin kullanıcıları oluşturuluyor...
  ✅ Ahmet Yönetim eklendi
  ✅ Ayşe Yönetici eklendi

👥 Örnek üyeler oluşturuluyor...
  ✅ Mehmet Kaya eklendi
  ✅ Zeynep Demir eklendi
  ...

🎓 Örnek eğitmenler oluşturuluyor...
  ✅ Carlos Rodriguez eklendi
  ...

🎉 Örnek etkinlikler oluşturuluyor...
  ✅ Milonga Gecesi - Aylık Tango Buluşması eklendi
  ...

📢 Örnek bildirimler oluşturuluyor...
  ✅ Hoş Geldiniz - FlowEdu Tango Dans Okulu eklendi
  ...

💳 Örnek ödemeler oluşturuluyor...
  ✅ 8 Derslik Başlangıç Paketi için ödeme eklendi (paid)
  ...

📅 Örnek ders programları oluşturuluyor...
  ✅ 8 Derslik Başlangıç Paketi - Ders 1/8 eklendi
  ...

✅ Tüm örnek veriler başarıyla eklendi!
```

## 🔍 Sorun Giderme

### "FileSystemException: Cannot open file" hatası
- `.env` dosyasının proje kök dizininde olduğundan emin olun
- Dosya adının tam olarak `.env` olduğundan emin olun (`.env.txt` değil)

### "SUPABASE_URL not found" hatası
- `.env` dosyasında `SUPABASE_URL` ve `SUPABASE_ANON_KEY` tanımlı olduğundan emin olun
- Dosyada boşluk veya tırnak işareti olmamalı:
  ```env
  # ✅ Doğru
  SUPABASE_URL=https://xxx.supabase.co
  
  # ❌ Yanlış
  SUPABASE_URL = "https://xxx.supabase.co"
  ```

### "User already exists" uyarıları
- Bu normaldir, script mevcut kullanıcıları atlar ve devam eder
- Hata değildir, sadece bilgilendirme

### "Role not found" hatası
- `docs/create-basic-tables.sql` scriptinin çalıştırıldığından emin olun
- Supabase'de `roles` tablosunda rollerin olduğunu kontrol edin

### "Group not found" hatası
- `docs/create-basic-tables.sql` scriptinin çalıştırıldığından emin olun
- Supabase'de `groups` tablosunda grupların olduğunu kontrol edin

## ✅ Başarılı Tamamlandıktan Sonra

Script başarıyla tamamlandığında:

1. **Supabase Dashboard'da kontrol edin:**
   - `members` tablosunda 23 kullanıcı olmalı (2 admin + 15 öğrenci + 6 eğitmen)
   - `events` tablosunda 5 etkinlik olmalı
   - `notifications` tablosunda 4 bildirim olmalı
   - `payments` tablosunda 15 ödeme olmalı
   - `lesson_schedules` tablosunda ders programları olmalı

2. **Flutter uygulamasını test edin:**
   ```bash
   flutter run -d chrome
   ```

3. **Giriş yapın:**

   **Admin Kullanıcıları:**
   - **SuperAdmin**: `admin@flowedu.com` / `admin123456` (Ahmet Yönetim)
   - **Admin**: `yonetim@flowedu.com` / `yonetim123` (Ayşe Yönetici)

   **Öğrenci Kullanıcıları:**
   - **Email**: `ogrenci1@flowedu.com` - `ogrenci15@flowedu.com`
   - **Şifre**: `ogrenci123` (hepsi için aynı)
   - **Örnek**: `ogrenci1@flowedu.com` / `ogrenci123` (Mehmet Kaya)

   **Eğitmen Kullanıcıları:**
   - **Email**: `egitmen1@flowedu.com` - `egitmen6@flowedu.com`
   - **Şifre**: `egitmen123` (hepsi için aynı)
   - **Örnek**: `egitmen1@flowedu.com` / `egitmen123` (Carlos Rodriguez)

## 📊 Oluşturulan Veriler Özeti

- **2 Admin** kullanıcısı
- **15 Öğrenci** (farklı seviyelerde)
- **6 Eğitmen** (farklı uzmanlık alanları)
- **5 Etkinlik** (Milonga, Workshop, Seminer, vb.)
- **4 Bildirim** (Hoş geldiniz, Ders programı, vb.)
- **15 Ödeme** kaydı
- **30-40 Ders Programı** (paketlere göre)

## 🎉 Tamamlandı!

Tüm adımlar tamamlandığında, FlowEdu Tango Dans Okulu uygulamanız örnek verilerle dolu olacak ve test edilmeye hazır olacak!

