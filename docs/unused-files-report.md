# Kullanılmayan Dosyalar Raporu

Bu rapor, projede kullanılmayan SQL ve Markdown dosyalarını listeler.

## 📋 Kullanılmayan SQL Dosyaları

Aşağıdaki SQL dosyaları projede hiçbir yerde referans edilmiyor:

### 1. `docs/lesson-attendees-schema.sql`
- **Durum**: ❌ Kullanılmıyor
- **Açıklama**: Hiçbir dokümantasyonda veya kodda referans edilmiyor
- **Öneri**: Eğer artık gerekli değilse silinebilir veya `docs/scripts/README.md`'ye eklenebilir

### 2. `docs/rooms-schema.sql`
- **Durum**: ❌ Kullanılmıyor
- **Açıklama**: Hiçbir dokümantasyonda veya kodda referans edilmiyor
- **Öneri**: Eğer artık gerekli değilse silinebilir veya `docs/scripts/README.md`'ye eklenebilir

### 3. `docs/scripts/add-schedule-id-to-payments.sql`
- **Durum**: ❌ Kullanılmıyor
- **Açıklama**: Hiçbir dokümantasyonda veya kodda referans edilmiyor
- **Öneri**: Migration scripti gibi görünüyor. Eğer artık gerekli değilse silinebilir

### 4. `docs/scripts/update-package-prices.sql`
- **Durum**: ❌ Kullanılmıyor
- **Açıklama**: Hiçbir dokümantasyonda veya kodda referans edilmiyor
- **Öneri**: Migration scripti gibi görünüyor. Eğer artık gerekli değilse silinebilir

### 5. `docs/scripts/remove-reports-screen.sql`
- **Durum**: ❌ Kullanılmıyor
- **Açıklama**: Hiçbir dokümantasyonda veya kodda referans edilmiyor
- **Öneri**: Migration scripti gibi görünüyor. Eğer artık gerekli değilse silinebilir

## 📝 Kullanılmayan/Eksik Referanslı Markdown Dosyaları

### 1. `docs/notification-system-refactor.md`
- **Durum**: ⚠️ Eksik referans
- **Açıklama**: Bu dosya `docs/notification-system-refactor.sql` dosyasından bahsediyor (satır 98), ancak bu SQL dosyası projede bulunmuyor
- **Öneri**: 
  - Eğer SQL dosyası artık gerekli değilse, markdown dosyasındaki referans kaldırılmalı
  - Veya SQL dosyası oluşturulmalı/eğer varsa eklenmeli

## ✅ Kullanılan Dosyalar (Referans Edilen)

### SQL Dosyaları (Kullanılıyor)
- ✅ `docs/create-basic-tables.sql` - README.md'de referans ediliyor
- ✅ `docs/lesson-schedules-rls-policies.sql` - README.md'de referans ediliyor
- ✅ `docs/payments-rls-policies.sql` - README.md'de referans ediliyor
- ✅ `docs/about-rls-policies.sql` - README.md'de referans ediliyor
- ✅ `docs/scripts/delete-all-data.sql` - scripts/README.md'de referans ediliyor
- ✅ `docs/scripts/seed-sample-data.sql` - scripts/README.md'de referans ediliyor
- ✅ `docs/scripts/seed-auth-users.sql` - scripts/README.md'de referans ediliyor
- ✅ `docs/scripts/fix-instructor-roles.sql` - scripts/README.md'de referans ediliyor

### Markdown Dosyaları (Kullanılıyor)
- ✅ Tüm `docs/modules/*.md` dosyaları - README.md'de link olarak var
- ✅ `docs/ekran-goruntusu-rehberi.md` - README.md'de referans ediliyor
- ✅ `docs/teknik-analiz.md` - README.md'de referans ediliyor
- ✅ `docs/yeni-sayfa-ekleme-rehberi.md` - README.md'de referans ediliyor
- ✅ `docs/scripts/README.md` - scripts klasörü için ana dokümantasyon
- ✅ `docs/scripts/ADIM_ADIM_REHBER.md` - scripts/README.md'de referans ediliyor
- ✅ `docs/scripts/TAMAMLANDI_SONRASI.md` - scripts/README.md'de referans ediliyor
- ✅ `docs/scripts/KULLANICI_BILGILERI.md` - scripts/README.md'de referans ediliyor
- ✅ `docs/rules/*.md` dosyaları - README.md'de referans ediliyor

## 🎯 Öneriler

1. **Kullanılmayan SQL dosyalarını silin** veya `docs/scripts/README.md`'ye ekleyin
2. **notification-system-refactor.md** dosyasındaki eksik SQL referansını düzeltin
3. Eğer migration scriptleri artık gerekli değilse, bunları bir `migrations/archive/` klasörüne taşıyabilirsiniz
4. Gelecekte kullanılabilir scriptler için `docs/scripts/README.md`'ye eklemeler yapın

## 📊 Özet

- **Kullanılmayan SQL Dosyaları**: 5 adet
- **Eksik Referanslı Markdown**: 1 adet
- **Toplam Temizlenebilecek Dosya**: 6 adet

---

**Oluşturulma Tarihi**: 2025-01-27
**Kontrol Eden**: AI Assistant

