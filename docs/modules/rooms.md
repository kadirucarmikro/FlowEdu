# Odalar (Rooms) Modülü

## Genel Bakış
Oda yönetim modülüdür. Ders programları için oda rezervasyonu yapılır.

## Özellikler
- ✅ Oda CRUD işlemleri
- ✅ Kapasite yönetimi
- ✅ Özellik tanımlama
- ✅ Responsive tasarım
- ✅ RLS politikaları

## Mimari Yapı

### Domain Layer
- **Entities**: `Room` entity
- **Repositories**: `RoomsRepository`

### Data Layer
- **Data Sources**: `RoomsRemoteDataSource` (Supabase)
- **Models**: `RoomModel` (DTO)
- **Repositories**: `RoomsRepositoryImpl`

### Presentation Layer
- **Pages**: `rooms_page.dart`
- **Widgets**: `room_card.dart`
- **Providers**: `rooms_providers.dart` (Riverpod)

## Kullanım

### Odaları Getirme
```dart
final roomsAsync = ref.watch(roomsProvider);
```

## Veritabanı Yapısı
- **Tablo**: `rooms`
- **Kolonlar**:
  - `id`: UUID (Primary Key)
  - `name`: String
  - `capacity`: Integer
  - `features`: String (nullable)
  - `is_active`: Boolean
  - `created_at`: Timestamp

## Yetkilendirme
- **Admin**: Tüm odaları oluşturabilir, görüntüleyebilir ve yönetebilir
- **Member**: Sadece aktif odaları görüntüleyebilir

## RLS Politikaları
- Üyeler sadece aktif odaları görebilir
- Admin kullanıcılar tüm odaları görebilir ve yönetebilir

