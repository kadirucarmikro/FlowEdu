# FlowEdu - Eğitim Yönetim Sistemi

FlowEdu, eğitim kurumları için geliştirilmiş kapsamlı bir yönetim sistemidir. Üye yönetimi, ders programları, ödemeler, etkinlikler ve bildirimler gibi tüm eğitim süreçlerini tek bir platformda birleştirir.

## 🎯 Özellikler

### Temel Modüller

- **👥 Üye Yönetimi**: Üyelerin kişisel bilgilerini yönetme, rol atama ve grup organizasyonu
- **📅 Ders Programları**: Haftalık ders programları oluşturma, paket bazlı program yönetimi ve üye atama
- **💰 Ödeme Yönetimi**: Ödeme takibi, indirim sistemi, ders paketi yönetimi ve otomatik fiyatlandırma
- **📢 Bildirimler**: Otomatik, manuel ve etkileşimli bildirim sistemi
- **🎉 Etkinlikler**: Normal, etkileşimli ve anket türünde etkinlik yönetimi
- **🏢 Oda Yönetimi**: Ders ve etkinlikler için oda rezervasyon sistemi
- **📄 Hakkımızda**: CMS benzeri içerik yönetim sistemi
- **🔐 Rol ve Yetki Yönetimi**: Admin ve Member rolleri ile yetkilendirme sistemi

### Teknik Özellikler

- ✅ **Responsive Tasarım**: Web, tablet ve mobil cihazlarda mükemmel görünüm
- ✅ **Gerçek Zamanlı Güncellemeler**: Supabase ile anlık veri senkronizasyonu
- ✅ **Güvenli Veri Yönetimi**: Row Level Security (RLS) politikaları ile güvenli veri erişimi
- ✅ **Modern UI/UX**: Material Design prensipleri ile kullanıcı dostu arayüz

## 🚀 Hızlı Başlangıç

### Gereksinimler

- Flutter SDK (3.8.1 veya üzeri)
- Supabase hesabı ve projesi
- Node.js (opsiyonel, geliştirme için)

### Kurulum

1. **Projeyi klonlayın**
   ```bash
   git clone <repository-url>
   cd FlowEdu
   ```

2. **Bağımlılıkları yükleyin**
   ```bash
   flutter pub get
   ```

3. **Ortam değişkenlerini ayarlayın**
   
   Proje kök dizininde `.env` dosyası oluşturun:
   ```env
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   SUPABASE_REDIRECT_URL=http://localhost:5287
   ```

4. **Supabase veritabanını yapılandırın**
   
   `docs/` klasöründeki SQL dosyalarını kullanarak veritabanı şemasını oluşturun:
   - `create-basic-tables.sql`
   - `lesson-schedules-rls-policies.sql`
   - `payments-rls-policies.sql`
   - `about-rls-policies.sql`

5. **Uygulamayı çalıştırın**
   ```bash
   # Web için
   flutter run -d chrome --web-port 5287
   
   # Mobil için
   flutter run
   ```

## 📖 Kullanım

### İlk Giriş

1. Uygulamayı açtığınızda giriş sayfasına yönlendirilirsiniz
2. Eğer hesabınız yoksa "Kayıt Ol" butonuna tıklayarak yeni hesap oluşturabilirsiniz
3. E-posta doğrulama linkini kontrol edin ve hesabınızı doğrulayın
4. Giriş yaptıktan sonra ana sayfaya (Üyeler) yönlendirilirsiniz

### Ana Özellikler

#### Üye Yönetimi
- Sol menüden "Üyeler" seçeneğine tıklayın
- Üye listesini görüntüleyin, yeni üye ekleyin veya mevcut üyeleri düzenleyin
- Admin kullanıcılar tüm üyeleri yönetebilir, Member kullanıcılar sadece kendi bilgilerini görebilir

#### Ders Programları
- "Ders Programı" menüsünden haftalık programları görüntüleyin
- Yeni ders programı oluşturun ve üyelere atayın
- Paket bazlı programlar oluşturarak toplu ders atamaları yapın

#### Ödeme Yönetimi
- "Ödemeler" menüsünden tüm ödemeleri görüntüleyin
- Yeni ödeme kaydı oluşturun, indirim uygulayın
- Ders paketleri ile entegre ödeme sistemi kullanın

#### Etkinlikler ve Bildirimler
- Etkinlikler oluşturun ve üyelere duyurun
- Bildirimler gönderin ve takip edin
- Etkileşimli etkinlikler ve anketler oluşturun

## 🛠️ Geliştirme

### Proje Yapısı

Proje Clean Architecture prensiplerine göre yapılandırılmıştır:

```
lib/
├── app/              # Uygulama konfigürasyonu
├── core/             # Ortak widget'lar ve servisler
└── features/         # Modül bazlı özellikler
    ├── members/
    ├── payments/
    ├── lesson_schedules/
    └── ...
```

### Teknoloji Stack

- **Framework**: Flutter 3.8.1+
- **State Management**: Riverpod
- **Backend**: Supabase (PostgreSQL)
- **Navigation**: GoRouter
- **UI**: Material Design 3

### Geliştirme Komutları

```bash
# Web'de çalıştırma (sabit port)
flutter run -d chrome --web-port 5287

# Kod analizi
flutter analyze

# Test çalıştırma
flutter test

# Build (Web)
flutter build web
```

## 📚 Dokümantasyon

### Modül Dokümantasyonları

Detaylı modül dokümantasyonları için `docs/modules/` klasörüne bakın:

- [Hakkımızda (About)](docs/modules/about.md) - CMS benzeri içerik yönetimi
- [Kimlik Doğrulama (Auth)](docs/modules/auth.md) - Kullanıcı girişi ve kayıt sistemi
- [Etkinlikler (Events)](docs/modules/events.md) - Etkinlik yönetimi ve katılım takibi
- [Gruplar (Groups)](docs/modules/groups.md) - Grup organizasyonu ve yönetimi
- [Ders Programları (Lesson Schedules)](docs/modules/lesson_schedules.md) - Haftalık ders programı yönetimi
- [Üyeler (Members)](docs/modules/members.md) - Üye bilgileri ve yönetimi
- [Bildirimler (Notifications)](docs/modules/notifications.md) - Bildirim sistemi ve yönetimi
- [Ödemeler (Payments)](docs/modules/payments.md) - Ödeme takibi ve yönetimi
- [Roller (Roles)](docs/modules/roles.md) - Rol ve yetki yönetimi
- [Odalar (Rooms)](docs/modules/rooms.md) - Oda rezervasyon ve yönetimi
- [Ekranlar (Screens)](docs/modules/screens.md) - Ekran ve navigasyon yönetimi

### Geliştirme Rehberleri

- [Yeni Sayfa Ekleme Rehberi](docs/yeni-sayfa-ekleme-rehberi.md)
- [Teknik Analiz](docs/teknik-analiz.md)
- [Bildirim Sistemi Refactor](docs/notification-system-refactor.md)
- [Ekran Görüntüsü Alma Rehberi](docs/ekran-goruntusu-rehberi.md)

### Geliştirme Kuralları

- [Genel Geliştirme Kuralları](docs/rules/general-development-rules.md)
- [Etkinlikler Kuralları](docs/rules/events-rules.md)
- [Bildirimler Kuralları](docs/rules/notifications-rules.md)
- [Ödemeler Kuralları](docs/rules/payments-rules.md)

## ⚙️ Yapılandırma

### Supabase E-posta Şablonları

Supabase Authentication ayarlarında kullanılacak Türkçe e-posta şablonları için aşağıdaki bölüme bakın.

### Ortam Değişkenleri

`.env` dosyasında aşağıdaki değişkenleri tanımlayın:

- `SUPABASE_URL`: Supabase proje URL'iniz
- `SUPABASE_ANON_KEY`: Supabase anonim anahtarınız
- `SUPABASE_REDIRECT_URL`: Web için redirect URL (örn: `http://localhost:5287`)

### Redirect URL Ayarları

Supabase Dashboard → Authentication → URL Configuration bölümünde:
- Site URL: `http://localhost:5287` (geliştirme için)
- Redirect URLs: `.env` dosyasındaki `SUPABASE_REDIRECT_URL` değerini ekleyin

## 📧 Supabase E-posta Şablonları (TR)

Aşağıdaki şablonları Supabase → Authentication → Email Templates alanına kopyalayın. Değişkenler Supabase tarafından otomatik doldurulur.

### 1) Confirm signup (Hesap Doğrulama)
- Subject: `FlowEdu Hesabınızı Doğrulayın`
- Body (HTML):
```html
<h2>FlowEdu'ya Hoş Geldiniz</h2>
<p>Merhaba, FlowEdu hesabınızı doğrulamak için aşağıdaki butona tıklayın.</p>
<p>
  <a href="{{ .ConfirmationURL }}" style="display:inline-block;padding:12px 20px;border-radius:8px;background:#4F46E5;color:#fff;text-decoration:none">Hesabımı Doğrula</a>
  <br/>
  <small>Buton çalışmazsa bu bağlantıyı tarayıcınıza kopyalayın:<br/>{{ .ConfirmationURL }}</small>
  <br/>
  <small>Bu isteği siz yapmadıysanız, bu e-postayı yok sayabilirsiniz.</small>
  <br/>
  <small>Teşekkürler, FlowEdu Ekibi</small>
</p>
```

### 2) Magic link / Email OTP (Giriş Bağlantısı)
- Subject: `FlowEdu Giriş Bağlantınız`
- Body (HTML):
```html
<h2>Giriş Bağlantısı</h2>
<p>FlowEdu hesabınıza giriş yapmak için aşağıdaki butona tıklayın.</p>
<p>
  <a href="{{ .ConfirmationURL }}" style="display:inline-block;padding:12px 20px;border-radius:8px;background:#4F46E5;color:#fff;text-decoration:none">Giriş Yap</a>
  <br/>
  <small>Buton çalışmazsa bu bağlantıyı tarayıcınıza kopyalayın:<br/>{{ .ConfirmationURL }}</small>
  <br/>
  <small>İsteği siz yapmadıysanız, bu e-postayı yok sayabilirsiniz.</small>
</p>
```

### 3) Invite user (Davet)
- Subject: `FlowEdu'ya Davet Edildiniz`
- Body (HTML):
```html
<h2>FlowEdu Daveti</h2>
<p>Bir yönetici sizi FlowEdu'ya davet etti. Hesap oluşturmak için aşağıdaki butona tıklayın.</p>
<p>
  <a href="{{ .ActionURL }}" style="display:inline-block;padding:12px 20px;border-radius:8px;background:#4F46E5;color:#fff;text-decoration:none">Daveti Kabul Et</a>
  <br/>
  <small>Buton çalışmazsa bu bağlantıyı tarayıcınıza kopyalayın:<br/>{{ .ActionURL }}</small>
</p>
```

### 4) Reset password (Şifre Sıfırlama)
- Subject: `FlowEdu Şifre Sıfırlama`
- Body (HTML):
```html
<h2>Şifre Sıfırlama</h2>
<p>Şifrenizi sıfırlamak için aşağıdaki butona tıklayın.</p>
<p>
  <a href="{{ .ConfirmationURL }}" style="display:inline-block;padding:12px 20px;border-radius:8px;background:#4F46E5;color:#fff;text-decoration:none">Şifreyi Sıfırla</a>
  <br/>
  <small>Buton çalışmazsa bu bağlantıyı tarayıcınıza kopyalayın:<br/>{{ .ConfirmationURL }}</small>
</p>
```

### 5) Change email (E-posta Değiştirme Onayı)
- Subject: `FlowEdu E-posta Değişikliği`
- Body (HTML):
```html
<h2>E-posta Değişikliği</h2>
<p>Yeni e-posta adresinizi doğrulamak için aşağıdaki butona tıklayın.</p>
<p>
  <a href="{{ .ConfirmationURL }}" style="display:inline-block;padding:12px 20px;border-radius:8px;background:#4F46E5;color:#fff;text-decoration:none">E-postamı Doğrula</a>
  <br/>
  <small>Buton çalışmazsa bu bağlantıyı tarayıcınıza kopyalayın:<br/>{{ .ConfirmationURL }}</small>
</p>
```

### 6) Reauthenticate (Yeniden Doğrulama)
- Subject: `FlowEdu Yeniden Doğrulama`
- Body (HTML):
```html
<h2>Yeniden Doğrulama</h2>
<p>Güvenlik amacıyla işlemi tamamlamak için aşağıdaki butona tıklayın.</p>
<p>
  <a href="{{ .ConfirmationURL }}" style="display:inline-block;padding:12px 20px;border-radius:8px;background:#4F46E5;color:#fff;text-decoration:none">Devam Et</a>
  <br/>
  <small>Buton çalışmazsa bu bağlantıyı tarayıcınıza kopyalayın:<br/>{{ .ConfirmationURL }}</small>
</p>
```

## 🤝 Katkıda Bulunma

1. Projeyi fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add some amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## 📄 Lisans

Bu proje özel bir projedir. Tüm hakları saklıdır.

## 📞 İletişim

Sorularınız veya önerileriniz için lütfen issue açın veya proje yöneticisi ile iletişime geçin.

---

**FlowEdu** - Modern eğitim yönetimi için tasarlandı 🎓
