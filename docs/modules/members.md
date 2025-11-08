# Üyeler (Members) Modülü

## Genel Bakış
Sistemdeki üye bilgilerini yöneten modüldür. Üyeler kendi bilgilerini görüntüleyip düzenleyebilir, admin kullanıcılar tüm üyeleri yönetebilir.

## Özellikler
- ✅ Kişisel bilgi görüntüleme ve düzenleme
- ✅ Admin üye yönetimi (CRUD)
- ✅ Rol bazlı form yapıları
- ✅ Responsive tasarım
- ✅ RLS politikaları

## Mimari Yapı

### Domain Layer
- **Entities**: `Member` entity
- **Repositories**: `MembersRepository` interface

### Data Layer
- **Data Sources**: Supabase entegrasyonu
- **Models**: `MemberModel` (DTO)
- **Repositories**: `MembersRepositoryImpl`

### Presentation Layer
- **Pages**:
  - `members_page.dart`: Üye listesi ve detay sayfası
  - `admin_members_page.dart`: Admin üye yönetim sayfası
- **Widgets**:
  - `member_card.dart`: Üye kartı widget'ı
  - `member_form_dialog.dart`: Üye form dialog'u
  - `quick_access_cards.dart`: Hızlı erişim kartları

## Kullanım

### Üye Bilgilerini Getirme
```dart
final member = await repository.getCurrentMember();
```

### Üye Güncelleme
```dart
await repository.updateMember(
  id: memberId,
  firstName: 'Yeni Ad',
  lastName: 'Yeni Soyad',
);
```

## Veritabanı Yapısı
- **Tablo**: `members`
- **Kolonlar**:
  - `id`: UUID (Primary Key)
  - `user_id`: UUID (Auth user ID)
  - `role_id`: UUID (Rol ID)
  - `group_id`: UUID (Grup ID)
  - `email`: String
  - `first_name`: String
  - `last_name`: String
  - `phone`: String
  - `birth_date`: Date
  - `address`: String
  - `created_at`: Timestamp

## Yetkilendirme
- **Admin**: Tüm üyeleri görüntüleyip yönetebilir
- **Member**: Sadece kendi bilgilerini görüntüleyip düzenleyebilir

## RLS Politikaları
- Üyeler sadece kendi kayıtlarını görebilir ve düzenleyebilir
- Admin kullanıcılar tüm üyeleri görebilir ve yönetebilir
- `user_id` ile otomatik filtreleme yapılır

## Özellikler
- Doğum günü takibi
- Telefon ve adres bilgileri
- Rol ve grup atamaları
- E-posta doğrulama

