# FlowEdu Tango Dans Okulu - Veritabanı Seed Scriptleri

Bu klasör, FlowEdu Tango Dans Okulu projesi için veritabanı yönetim scriptlerini içerir.

> 📝 **Detaylı Kullanıcı Bilgileri**: Tüm test kullanıcılarının email, şifre ve detaylı bilgileri için `KULLANICI_BILGILERI.md` dosyasına bakın.

> ⚠️ **Not**: Development/test SQL script'leri (delete-all-data.sql, seed-sample-data.sql, seed-auth-users.sql, fix-instructor-roles.sql) production için gerekli olmadığından kaldırılmıştır. Production için gerekli SQL dosyaları `docs/` klasöründe bulunmaktadır.

## Scriptler

### `lib/scripts/seed_database.dart`
Flutter tarafında çalışan seed scripti. Auth.users gerektiren verileri ekler.

**Kullanım:**
```bash
# .env dosyasının yüklü olduğundan emin olun
dart run lib/scripts/seed_database.dart
```

**Gereksinimler:**
- `.env` dosyasında `SUPABASE_URL` ve `SUPABASE_ANON_KEY` tanımlı olmalı
- Önce SQL scriptleri çalıştırılmış olmalı

**Eklenen Veriler:**
- **Admin Kullanıcıları:** 2 admin (1 superadmin, 1 normal admin)
- **Üyeler:** 15 tango öğrencisi (farklı seviyelerde, farklı gruplarda)
- **Eğitmenler:** 6 tango eğitmeni (farklı uzmanlık alanları)
- **Etkinlikler:** 5 tango etkinliği (Milonga, Workshop, Seminer, vb.)
- **Bildirimler:** 4 bildirim (hoş geldiniz, ders programı, etkinlik, ödeme)
- **Ödemeler:** 15 ödeme kaydı (farklı paketler, farklı durumlar)
- **Ders Programları:** Her paket için 4-6 ders programı

## Veritabanı Kurulumu

### Production SQL Script'leri

Production için gerekli SQL dosyaları `docs/` klasöründe bulunmaktadır:

1. **`docs/create-basic-tables.sql`** - Temel tablolar, RLS politikaları ve fonksiyonlar
2. **`docs/about-rls-policies.sql`** - About modülü RLS politikaları
3. **`docs/lesson-schedules-rls-policies.sql`** - Lesson schedules RLS politikaları
4. **`docs/payments-rls-policies.sql`** - Payments modülü RLS politikaları

Bu dosyaları Supabase SQL Editor'da sırayla çalıştırarak veritabanını yapılandırabilirsiniz.

### Test Verileri Ekleme

Test verileri eklemek için Flutter script'ini kullanabilirsiniz:

```bash
# Terminal'de çalıştır
dart run lib/scripts/seed_database.dart
```

## Oluşturulan Örnek Veriler

### Roller
- **Admin:** Sistem yöneticisi
- **SuperAdmin:** Süper yönetici
- **Member:** Tango öğrencisi
- **Instructor:** Tango eğitmeni

### Gruplar (10 Grup)
1. Başlangıç Seviyesi Tango
2. Orta Seviye Tango
3. İleri Seviye Tango
4. Milonga (Hızlı Tango)
5. Tango Vals
6. Pratik Seansları
7. Yarışma Hazırlık Grubu
8. Yetişkin Başlangıç
9. Çift Dans Grubu
10. Bireysel Dersler

### Ekranlar (16 Ekran)
Tüm proje ekranları route, icon ve açıklamalarla:
- Üyelik, Admin Üyeler, Roller, Gruplar, Ekranlar
- Ders Programları, Ders Detayı, Yeni Ders Ekle, Ders Düzenle
- Bildirimler, Etkinlikler
- Ödemeler, Ders Paketleri
- Hakkımızda, Odalar

### Odalar (8 Salon)
1. Ana Tango Salonu (40 kişi)
2. Milonga Salonu (30 kişi)
3. Pratik Salonu 1 (20 kişi)
4. Pratik Salonu 2 (20 kişi)
5. Bireysel Ders Odası (4 kişi)
6. Yarışma Hazırlık Salonu (25 kişi)
7. Workshop Salonu (50 kişi)
8. Bekleme Alanı (15 kişi)

### Ders Paketleri (10 Paket)
1. 4 Derslik Deneme Paketi
2. 8 Derslik Başlangıç Paketi
3. 12 Derslik Standart Paket
4. 16 Derslik Yoğun Paket
5. Aylık Sınırsız Paket (20 ders)
6. Yarışma Hazırlık Paketi (24 ders)
7. Bireysel Ders Paketi (5 Ders)
8. Bireysel Ders Paketi (10 Ders)
9. Haftalık Pratik Paketi (4 ders)
10. Workshop Paketi (6 ders)

### Kullanıcılar (SQL veya Flutter script ile)

**Admin Kullanıcıları:**
- **SuperAdmin**: 
  - Email: `admin@flowedu.com`
  - Şifre: `admin123456`
  - Ad Soyad: Ahmet Yönetim
  
- **Admin**: 
  - Email: `yonetim@flowedu.com`
  - Şifre: `yonetim123`
  - Ad Soyad: Ayşe Yönetici

**Öğrenci Kullanıcıları (15 adet):**
- Email formatı: `ogrenci1@flowedu.com` - `ogrenci15@flowedu.com`
- Şifre: `ogrenci123` (hepsi için aynı)
- Örnekler:
  - `ogrenci1@flowedu.com` / `ogrenci123` - Mehmet Kaya
  - `ogrenci2@flowedu.com` / `ogrenci123` - Zeynep Demir
  - `ogrenci3@flowedu.com` / `ogrenci123` - Can Yılmaz
  - ... (15 öğrenci)

**Eğitmen Kullanıcıları (6 adet):**
- Email formatı: `egitmen1@flowedu.com` - `egitmen6@flowedu.com`
- Şifre: `egitmen123` (hepsi için aynı)
- Örnekler:
  - `egitmen1@flowedu.com` / `egitmen123` - Carlos Rodriguez (Arjantin Tango - Lider)
  - `egitmen2@flowedu.com` / `egitmen123` - Maria Garcia (Arjantin Tango - Takipçi)
  - `egitmen3@flowedu.com` / `egitmen123` - Diego Martinez (Milonga)
  - `egitmen4@flowedu.com` / `egitmen123` - Ana Lopez (Tango Vals)
  - `egitmen5@flowedu.com` / `egitmen123` - Fernando Sanchez (Yarışma Hazırlık)
  - `egitmen6@flowedu.com` / `egitmen123` - Lucia Fernandez (Bireysel Dersler)

> 📋 **Detaylı Bilgiler**: Tüm kullanıcıların detaylı bilgileri için `KULLANICI_BILGILERI.md` dosyasına bakın.

### Etkinlikler (5 Etkinlik)
1. Milonga Gecesi - Aylık Tango Buluşması
2. Tango Workshop - İleri Seviye Teknikler
3. Yarışma Hazırlık Semineri
4. Başlangıç Seviyesi Tanışma Etkinliği
5. Tango Vals Özel Dersi

### Bildirimler (4 Bildirim)
1. Hoş Geldiniz - FlowEdu Tango Dans Okulu
2. Yeni Ders Programı Yayınlandı
3. Milonga Gecesi Hatırlatması
4. Ödeme Hatırlatması

### Ödemeler (15 Ödeme)
- Farklı paketler için ödemeler
- Farklı durumlar (paid, pending)
- İndirimli ve normal fiyatlar

### Ders Programları
- Her paket için 4-6 ders programı
- Farklı günler ve saatler
- Eğitmen ve oda atamaları
- Öğrenci katılımları

## Sorun Giderme

### "User already exists" hatası
- Supabase Auth'da kullanıcılar zaten mevcut olabilir
- Bu durumda script devam eder ve mevcut kullanıcıları atlar

### "Role not found" hatası
- `docs/create-basic-tables.sql` scriptini çalıştırdığınızdan emin olun
- Roller tablosunda gerekli rollerin olduğunu kontrol edin

### "Group not found" hatası
- `docs/create-basic-tables.sql` scriptini çalıştırdığınızdan emin olun
- Gruplar tablosunda gerekli grupların olduğunu kontrol edin

## Notlar

- Tüm scriptler idempotent değildir (tekrar çalıştırıldığında hata verebilir)
- Production ortamında kullanmadan önce test edin
- Verileri silmeden önce yedek alın
- Auth.users tablosu Supabase tarafından yönetilir, bu scriptler sadece public schema'daki tabloları etkiler
- Tango dans okuluna özel örnekler ve içerikler kullanılmıştır

## Örnek Veri İstatistikleri

- **Toplam Kullanıcı:** 23 (2 admin + 15 öğrenci + 6 eğitmen)
- **Toplam Grup:** 10
- **Toplam Ekran:** 16
- **Toplam Oda:** 8
- **Toplam Paket:** 10
- **Toplam Etkinlik:** 5
- **Toplam Bildirim:** 4
- **Toplam Ödeme:** 15
- **Toplam Ders Programı:** ~30-40 (paketlere göre değişir)
