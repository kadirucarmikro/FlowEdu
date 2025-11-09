# Notification System Refactor

## Genel Bakış

Notification sistemi, yeni hedefleme sistemi ile güncellenmiştir. Artık admin kullanıcılar 4 farklı hedefleme türü ile bildirim gönderebilir:

1. **Rol bazlı**: Belirli role sahip üyelere gönder
2. **Grup bazlı**: Belirli gruba gönder  
3. **Üye bazlı**: Belirli üyeye gönder
4. **Doğum günü bazlı**: Doğum günü yaklaşan üyelere gönder (7 gün içinde)

## Database Değişiklikleri

### Silinen Kolonlar
- `notifications.type`
- `notifications.target_group_id`
- `notifications.is_birthday_notification`
- `notifications.scheduled_at`
- `notifications.question_text`
- `notifications.is_multiple_choice`
- `notifications.option_1` - `notifications.option_6`

### Yeni Tablolar
- `notification_targets`: Hedefleme bilgilerini tutar
- `notification_read_status`: Okuma durumunu tutar
- `notification_responses`: Yanıtları tutar

### Yeni View
- `member_notifications`: Üyelerin görebileceği bildirimleri filtreler

## Hedefleme Sistemi

### Target Types
- `role`: Belirli role sahip üyelere gönder
- `group`: Belirli gruba gönder
- `member`: Belirli üyeye gönder
- `birthday`: Doğum günü yaklaşan üyelere gönder

### Hedefleme Mantığı
```sql
-- Role-based targeting
(nt.target_type = 'role' AND nt.target_id = m.role_id)

-- Group-based targeting  
(nt.target_type = 'group' AND nt.target_id = m.group_id)

-- Member-based targeting
(nt.target_type = 'member' AND nt.target_id = m.id)

-- Birthday-based targeting
(nt.target_type = 'birthday' AND nt.target_id IS NULL AND 
 m.birth_date IS NOT NULL AND 
 EXTRACT(DOY FROM CURRENT_DATE) BETWEEN EXTRACT(DOY FROM m.birth_date) - 7 
 AND EXTRACT(DOY FROM m.birth_date) + 7)
```

## UI Değişiklikleri

### Form Güncellemeleri
- Rol seçimi varsayılan olarak seçili
- Doğum günü hedefleme seçeneği eklendi
- Hedef önizleme sistemi güncellendi
- Birthday selector UI eklendi

### Yeni Bileşenler
- `_buildBirthdaySelector()`: Doğum günü hedefleme UI'ı
- `_buildBirthdayPreview()`: Doğum günü hedefleme önizleme
- Birthday target validation

## API Değişiklikleri

### Data Source Güncellemeleri
- `getMemberNotifications()`: Yeni view kullanır
- `_loadTargetInfo()`: Birthday target desteği
- Target creation: Birthday target için null target_id

### Model Güncellemeleri
- `NotificationModel`: isRead, hasResponse alanları eklendi
- `NotificationTargetModel`: Birthday target validation
- Entity güncellemeleri: createdBy, isRead, hasResponse

## RLS Politikaları

### Notification Targets
- Sadece admin görebilir/yazabilir
- Member'lar kendi hedeflerini göremez

### Read Status
- Member kendi okuma durumunu yönetebilir
- Admin tüm okuma durumlarını görebilir

### Responses
- Member kendi cevaplarını yönetebilir
- Admin tüm cevapları görebilir

## Migration Adımları

1. **Model Güncellemeleri**: Entity ve model sınıfları güncellendi
2. **UI Güncellemeleri**: Form dialog'u güncellendi
3. **Data Source**: Remote data source güncellendi
4. **Test**: Yeni hedefleme sistemi test edilmeli

**Not**: Database değişiklikleri (yeni tablolar, view'lar) zaten `create-basic-tables.sql` ve ilgili RLS policy dosyalarında mevcuttur.

## Test Senaryoları

### Admin Testleri
1. Rol bazlı bildirim oluşturma
2. Grup bazlı bildirim oluşturma
3. Üye bazlı bildirim oluşturma
4. Doğum günü bazlı bildirim oluşturma
5. Hedef önizleme çalışması

### Member Testleri
1. Kendi bildirimlerini görme
2. Okuma durumu güncelleme
3. Yanıt verme
4. Doğum günü bildirimlerini alma

## Önemli Notlar

- Birthday target için `target_id` null olmalı
- Doğum günü hesaplaması 7 gün içinde yapılır
- RLS politikaları güvenlik için kritik
- Member notifications view performans için optimize edildi
- Tüm hedefleme türleri aynı anda kullanılabilir

## Sonraki Adımlar

1. Migration script'ini Supabase'de çalıştır
2. Uygulamayı test et
3. Performance monitoring yap
4. User feedback topla
5. Gerekirse ek optimizasyonlar yap
