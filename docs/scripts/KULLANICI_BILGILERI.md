# FlowEdu - Test Kullanıcı Bilgileri

Bu dosya, veritabanı seed işlemi sonrası oluşturulan tüm test kullanıcılarının bilgilerini içerir.

## 🔐 Giriş Bilgileri

### Admin Kullanıcıları

#### 1. SuperAdmin
- **Email**: `admin@flowedu.com`
- **Şifre**: `admin123456`
- **Ad Soyad**: Ahmet Yönetim
- **Rol**: SuperAdmin
- **Yetkiler**: Tüm sistem yetkileri

#### 2. Admin
- **Email**: `yonetim@flowedu.com`
- **Şifre**: `yonetim123`
- **Ad Soyad**: Ayşe Yönetici
- **Rol**: Admin
- **Yetkiler**: Sistem yönetimi (SuperAdmin yetkileri hariç)

---

### Öğrenci Kullanıcıları (15 adet)

**Ortak Şifre**: `ogrenci123` (tüm öğrenciler için aynı)

| # | Email | Ad Soyad | Telefon | Grup |
|---|-------|----------|---------|------|
| 1 | `ogrenci1@flowedu.com` | Mehmet Kaya | 05551234567 | Başlangıç Seviyesi Tango |
| 2 | `ogrenci2@flowedu.com` | Zeynep Demir | 05551234568 | Başlangıç Seviyesi Tango |
| 3 | `ogrenci3@flowedu.com` | Can Yılmaz | 05551234569 | Başlangıç Seviyesi Tango |
| 4 | `ogrenci4@flowedu.com` | Elif Şahin | 05551234570 | Başlangıç Seviyesi Tango |
| 5 | `ogrenci5@flowedu.com` | Burak Çelik | 05551234571 | Orta Seviye Tango |
| 6 | `ogrenci6@flowedu.com` | Selin Arslan | 05551234572 | Orta Seviye Tango |
| 7 | `ogrenci7@flowedu.com` | Emre Öztürk | 05551234573 | Orta Seviye Tango |
| 8 | `ogrenci8@flowedu.com` | Deniz Kılıç | 05551234574 | İleri Seviye Tango |
| 9 | `ogrenci9@flowedu.com` | Gizem Kurt | 05551234575 | İleri Seviye Tango |
| 10 | `ogrenci10@flowedu.com` | Emre Koç | 05551234576 | İleri Seviye Tango |
| 11 | `ogrenci11@flowedu.com` | Cem Yıldız | 05551234577 | Milonga (Hızlı Tango) |
| 12 | `ogrenci12@flowedu.com` | Burcu Doğan | 05551234578 | Milonga (Hızlı Tango) |
| 13 | `ogrenci13@flowedu.com` | Kaan Polat | 05551234579 | Yarışma Hazırlık Grubu |
| 14 | `ogrenci14@flowedu.com` | Derya Aktaş | 05551234580 | Yarışma Hazırlık Grubu |
| 15 | `ogrenci15@flowedu.com` | Tolga Şen | 05551234581 | Yarışma Hazırlık Grubu |

**Kullanım:**
- Herhangi bir öğrenci ile giriş yapmak için: `ogrenci[1-15]@flowedu.com` / `ogrenci123`

---

### Eğitmen Kullanıcıları (6 adet)

**Ortak Şifre**: `egitmen123` (tüm eğitmenler için aynı)

| # | Email | Ad Soyad | Telefon | Uzmanlık Alanı | Deneyim |
|---|-------|----------|---------|----------------|---------|
| 1 | `egitmen1@flowedu.com` | Carlos Rodriguez | 05559876543 | Arjantin Tango - Lider | 20 yıl |
| 2 | `egitmen2@flowedu.com` | Maria Garcia | 05559876544 | Arjantin Tango - Takipçi | 15 yıl |
| 3 | `egitmen3@flowedu.com` | Diego Martinez | 05559876545 | Milonga | 12 yıl |
| 4 | `egitmen4@flowedu.com` | Ana Lopez | 05559876546 | Tango Vals | 18 yıl |
| 5 | `egitmen5@flowedu.com` | Fernando Sanchez | 05559876547 | Yarışma Hazırlık | 25 yıl |
| 6 | `egitmen6@flowedu.com` | Lucia Fernandez | 05559876548 | Bireysel Dersler | 10 yıl |

**Kullanım:**
- Herhangi bir eğitmen ile giriş yapmak için: `egitmen[1-6]@flowedu.com` / `egitmen123`

---

## 📋 Hızlı Referans

### En Sık Kullanılan Girişler

**Admin Test:**
```
Email: admin@flowedu.com
Şifre: admin123456
```

**Öğrenci Test:**
```
Email: ogrenci1@flowedu.com
Şifre: ogrenci123
```

**Eğitmen Test:**
```
Email: egitmen1@flowedu.com
Şifre: egitmen123
```

---

## ⚠️ Önemli Notlar

1. **Tüm şifreler test amaçlıdır** - Production ortamında mutlaka değiştirin
2. **Email doğrulaması** - Bazı kullanıcılarda email doğrulaması gerekebilir
3. **RLS Politikaları** - Her kullanıcı sadece kendi yetkileri dahilindeki verileri görebilir
4. **Güvenlik** - Bu bilgiler sadece development/test ortamı için geçerlidir

---

## 🔍 Kullanıcı Detayları

### Admin Detayları

**Ahmet Yönetim (SuperAdmin)**
- Email: `admin@flowedu.com`
- Şifre: `admin123456`
- Tüm sistem yetkilerine sahip
- Tüm sayfaları görüntüleyebilir ve yönetebilir

**Ayşe Yönetici (Admin)**
- Email: `yonetim@flowedu.com`
- Şifre: `yonetim123`
- Sistem yönetimi yetkileri (SuperAdmin hariç)
- Çoğu sayfayı görüntüleyebilir ve yönetebilir

### Öğrenci Detayları

Tüm öğrenciler:
- **Rol**: Member
- **Şifre**: `ogrenci123`
- Sadece kendi ders programlarını, bildirimlerini ve ödemelerini görebilir
- Etkinlikleri görüntüleyebilir
- Hakkımızda sayfasını görüntüleyebilir

### Eğitmen Detayları

Tüm eğitmenler:
- **Rol**: Instructor
- **Şifre**: `egitmen123`
- Kendi ders programlarını görebilir
- Bildirimleri görüntüleyebilir
- Etkinlikleri görüntüleyebilir
- Üye bilgilerini görüntüleyebilir (sınırlı)

---

## 📊 Kullanıcı İstatistikleri

- **Toplam Kullanıcı**: 23
  - 2 Admin (1 SuperAdmin + 1 Admin)
  - 15 Öğrenci (Member)
  - 6 Eğitmen (Instructor)

- **Grup Dağılımı**: Öğrenciler 10 farklı tango grubuna dağıtılmış
- **Seviye Dağılımı**: Başlangıç, Orta, İleri seviyelerde öğrenciler mevcut

---

## 🎯 Test Senaryoları

### Senaryo 1: Admin Paneli Testi
1. `admin@flowedu.com` / `admin123456` ile giriş yapın
2. Tüm sayfaları açın ve verilerin göründüğünü kontrol edin
3. Yeni kayıt ekleme, düzenleme, silme işlemlerini test edin

### Senaryo 2: Öğrenci Paneli Testi
1. `ogrenci1@flowedu.com` / `ogrenci123` ile giriş yapın
2. Sadece kendi ders programlarınızı görüntüleyin
3. Bildirimlerinizi kontrol edin
4. Ödemelerinizi görüntüleyin

### Senaryo 3: Eğitmen Paneli Testi
1. `egitmen1@flowedu.com` / `egitmen123` ile giriş yapın
2. Ders programlarınızı görüntüleyin
3. Bildirimleri kontrol edin
4. Etkinlikleri görüntüleyin

---

## 🔄 Şifre Sıfırlama

Eğer bir kullanıcının şifresini unuttuysanız veya değiştirmek isterseniz:

1. Supabase Dashboard → Authentication → Users
2. İlgili kullanıcıyı bulun
3. "Reset Password" butonuna tıklayın
4. Yeni şifre belirleyin

veya SQL ile:

```sql
UPDATE auth.users 
SET encrypted_password = crypt('yeni_sifre', gen_salt('bf'))
WHERE email = 'kullanici@flowedu.com';
```

---

## 📝 Notlar

- Bu bilgiler sadece development/test ortamı için geçerlidir
- Production ortamında mutlaka güçlü şifreler kullanın
- Email doğrulaması production'da aktif olmalıdır
- RLS politikaları production'da daha sıkı olmalıdır

