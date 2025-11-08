# ✅ Veritabanı Seed İşlemi Tamamlandı - Sonraki Adımlar

Tebrikler! Veritabanı seed işlemi başarıyla tamamlandı. Şimdi yapmanız gerekenler:

> 📋 **Kullanıcı Bilgileri**: Tüm test kullanıcılarının detaylı bilgileri için `KULLANICI_BILGILERI.md` dosyasına bakın.

## 📋 Kontrol Listesi

### 1. ✅ Veritabanını Kontrol Edin

Supabase Dashboard'da aşağıdaki tabloları kontrol edin:

#### Temel Tablolar
- **roles**: 4 rol olmalı (Admin, SuperAdmin, Member, Instructor)
- **groups**: 10 tango dans grubu olmalı
- **screens**: 16 ekran olmalı
- **permissions**: Her rol için yetkiler olmalı
- **rooms**: 8 dans salonu olmalı
- **lesson_packages**: 10 ders paketi olmalı
- **package_schedules**: Her paket için programlar olmalı
- **automatic_notification_settings**: 5 bildirim ayarı olmalı
- **about_contents**: Hakkımızda içerikleri olmalı

#### Kullanıcı Tabloları
- **auth.users**: 23 kullanıcı olmalı (2 admin + 15 öğrenci + 6 eğitmen)
- **members**: 23 üye kaydı olmalı
- **admins**: 2 admin kaydı olmalı

#### İçerik Tabloları
- **events**: 5 etkinlik olmalı
- **notifications**: 4 bildirim olmalı
- **notification_targets**: Her bildirim için hedefleme kayıtları olmalı
- **payments**: 15 ödeme kaydı olmalı
- **lesson_schedules**: Her paket için 4-6 ders programı olmalı

### 2. 🚀 Flutter Uygulamasını Başlatın

```bash
# Proje dizininde
flutter run -d chrome
```

veya

```bash
flutter run -d macos
```

### 3. 🔐 Test Kullanıcıları ile Giriş Yapın

#### Admin Kullanıcıları
- **Email**: `admin@flowedu.com`
- **Şifre**: `admin123456`
- **Rol**: SuperAdmin

- **Email**: `yonetim@flowedu.com`
- **Şifre**: `yonetim123`
- **Rol**: Admin

#### Öğrenci Kullanıcıları
- **Email**: `ogrenci1@flowedu.com` - `ogrenci15@flowedu.com`
- **Şifre**: `ogrenci123`
- **Rol**: Member

#### Eğitmen Kullanıcıları
- **Email**: `egitmen1@flowedu.com` - `egitmen6@flowedu.com`
- **Şifre**: `egitmen123`
- **Rol**: Instructor

### 4. ✅ Uygulama Özelliklerini Test Edin

#### Admin Paneli
- [ ] Roller sayfasını açın ve 4 rolü görüntüleyin
- [ ] Gruplar sayfasını açın ve 10 grubu görüntüleyin
- [ ] Üyeler sayfasını açın ve 23 üyeyi görüntüleyin
- [ ] Ekranlar sayfasını açın ve 16 ekranı görüntüleyin
- [ ] Yetkilendirmeler sayfasını açın ve matrisi görüntüleyin
- [ ] Odalar sayfasını açın ve 8 odayı görüntüleyin
- [ ] Ders Paketleri sayfasını açın ve 10 paketi görüntüleyin
- [ ] Ders Programları sayfasını açın ve programları görüntüleyin
- [ ] Bildirimler sayfasını açın ve 4 bildirimi görüntüleyin
- [ ] Etkinlikler sayfasını açın ve 5 etkinliği görüntüleyin
- [ ] Ödemeler sayfasını açın ve 15 ödemeyi görüntüleyin
- [ ] Hakkımızda sayfasını açın ve içerikleri görüntüleyin

#### Öğrenci Paneli
- [ ] Öğrenci hesabı ile giriş yapın
- [ ] Ders programlarınızı görüntüleyin
- [ ] Bildirimlerinizi görüntüleyin
- [ ] Etkinlikleri görüntüleyin
- [ ] Ödemelerinizi görüntüleyin
- [ ] Hakkımızda sayfasını görüntüleyin

#### Eğitmen Paneli
- [ ] Eğitmen hesabı ile giriş yapın
- [ ] Ders programlarınızı görüntüleyin
- [ ] Bildirimlerinizi görüntüleyin
- [ ] Etkinlikleri görüntüleyin

### 5. 🔍 Veri Doğrulama

#### Supabase SQL Editor'da Kontrol Sorguları

```sql
-- Toplam kullanıcı sayısı
SELECT COUNT(*) as total_users FROM auth.users;

-- Toplam üye sayısı
SELECT COUNT(*) as total_members FROM public.members;

-- Rol dağılımı
SELECT r.name, COUNT(m.id) as member_count
FROM public.roles r
LEFT JOIN public.members m ON m.role_id = r.id
GROUP BY r.name;

-- Grup dağılımı
SELECT g.name, COUNT(m.id) as member_count
FROM public.groups g
LEFT JOIN public.members m ON m.group_id = g.id
GROUP BY g.name;

-- Ödeme durumları
SELECT status, COUNT(*) as count
FROM public.payments
GROUP BY status;

-- Ders programı sayısı
SELECT COUNT(*) as total_schedules FROM public.lesson_schedules;

-- Bildirim sayısı
SELECT COUNT(*) as total_notifications FROM public.notifications;
```

### 6. 🐛 Olası Sorunlar ve Çözümleri

#### Sorun: Kullanıcı giriş yapamıyor
**Çözüm**: 
- Email doğrulaması gerekebilir. Supabase Dashboard → Authentication → Users bölümünden kullanıcıların `email_confirmed_at` alanını kontrol edin.
- Eğer `null` ise, manuel olarak `now()` ile güncelleyin.

#### Sorun: Veriler görünmüyor
**Çözüm**:
- RLS (Row Level Security) politikalarını kontrol edin
- Kullanıcının doğru role sahip olduğundan emin olun
- Supabase Dashboard → Authentication → Policies bölümünü kontrol edin

#### Sorun: Bildirimler görünmüyor
**Çözüm**:
- `notification_targets` tablosunda hedefleme kayıtlarının olduğundan emin olun
- Kullanıcının `notification_targets` ile eşleştiğinden emin olun

#### Sorun: Ders programları görünmüyor
**Çözüm**:
- `lesson_schedules` tablosunda kayıtların olduğundan emin olun
- `package_id` ve `room_id` değerlerinin doğru olduğundan emin olun

### 7. 📊 Örnek Veriler Özeti

#### Kullanıcılar
- **2 Admin** (1 SuperAdmin, 1 Normal Admin)
- **15 Öğrenci** (farklı seviyelerde, farklı gruplarda)
- **6 Eğitmen** (farklı uzmanlık alanları)

#### İçerik
- **5 Etkinlik** (Milonga, Workshop, Seminer, Yarışma Hazırlık, Yeni Başlayanlar)
- **4 Bildirim** (Hoş Geldiniz, Ders Programı, Etkinlik, Ödeme)
- **15 Ödeme** (farklı paketler, farklı durumlar)
- **30-40 Ders Programı** (paketlere göre)

#### Temel Veriler
- **4 Rol** (Admin, SuperAdmin, Member, Instructor)
- **10 Grup** (Başlangıç, Orta, İleri, Milonga, Vals, vb.)
- **16 Ekran** (tüm proje ekranları)
- **8 Oda** (Ana Salon, Milonga Salonu, Pratik Salonları, vb.)
- **10 Ders Paketi** (4-24 ders arası)

### 8. 🎯 Sonraki Geliştirmeler

Artık veritabanı hazır! Şunları yapabilirsiniz:

1. **Uygulama Testleri**: Tüm özellikleri test edin
2. **UI/UX İyileştirmeleri**: Kullanıcı deneyimini geliştirin
3. **Yeni Özellikler**: İhtiyaca göre yeni özellikler ekleyin
4. **Performans Optimizasyonu**: Büyük veri setlerinde performansı test edin
5. **Güvenlik Kontrolleri**: RLS politikalarını gözden geçirin

### 9. 📝 Notlar

- Tüm şifreler test amaçlıdır, production'da mutlaka değiştirin
- Email doğrulaması devre dışı olabilir, gerekirse aktif edin
- RLS politikaları production'da daha sıkı olmalıdır
- Veritabanı yedeklerini düzenli olarak alın

## 🎉 Başarılar!

Artık FlowEdu Tango Dans Okulu uygulamanız örnek verilerle dolu ve test edilmeye hazır!

Herhangi bir sorunla karşılaşırsanız, hata mesajlarını ve ekran görüntülerini paylaşın, yardımcı olabilirim.

