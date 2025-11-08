# Ekranlar (Screens) Modülü

## Genel Bakış
Sistemdeki ekran/sayfa tanımlarını yöneten modüldür. Navigation drawer ve yetki sistemi için kullanılır.

## Özellikler
- ✅ CRUD işlemleri (Oluşturma, Okuma, Güncelleme, Silme)
- ✅ Ekran aktif/pasif durumu yönetimi
- ✅ Navigation entegrasyonu
- ✅ Responsive tasarım
- ✅ RLS politikaları

## Mimari Yapı

### Domain Layer
- **Entities**: `Screen` entity
- **Repositories**: `ScreensRepositoryInterface`
- **Use Cases**:
  - `GetScreens`: Tüm ekranları getir
  - `CreateScreen`: Yeni ekran oluştur
  - `UpdateScreen`: Ekran güncelle
  - `DeleteScreen`: Ekran sil

### Data Layer
- **Data Sources**: `ScreensRemoteDataSource` (Supabase)
- **Models**: `ScreenModel` (DTO)
- **Repositories**: `ScreensRepositoryImpl`

### Presentation Layer
- **Pages**: `screens_page.dart`
- **Widgets**:
  - `screen_card.dart`: Ekran kartı widget'ı
  - `screen_form_dialog.dart`: Ekran form dialog'u
- **Providers**: `screens_providers.dart` (Riverpod)

## Kullanım

### Ekranları Getirme
```dart
final screensAsync = ref.watch(screensListProvider);
```

### Yeni Ekran Oluşturma
```dart
final createScreen = ref.read(createScreenProvider);
await createScreen(name: 'Yeni Ekran', route: '/yeni-ekran', isActive: true);
```

### Ekran Güncelleme
```dart
final updateScreen = ref.read(updateScreenProvider);
await updateScreen(id: screenId, name: 'Güncellenmiş Ekran', isActive: false);
```

### Ekran Silme
```dart
final deleteScreen = ref.read(deleteScreenProvider);
await deleteScreen(screenId);
```

## Veritabanı Yapısı
- **Tablo**: `screens`
- **Kolonlar**:
  - `id`: UUID (Primary Key)
  - `name`: String (Ekran adı)
  - `route`: String (Route path)
  - `is_active`: Boolean (Aktif durumu)
  - `created_at`: Timestamp

## Yetkilendirme
- **Admin**: Tüm CRUD işlemlerini yapabilir
- **Member**: Sadece görüntüleme yapabilir

## Navigation Entegrasyonu
Ekranlar, navigation drawer'da otomatik olarak görüntülenir. Aktif ekranlar menüde gösterilir.

## RLS Politikaları
- Admin kullanıcılar tüm ekranları görebilir ve yönetebilir
- Member kullanıcılar sadece aktif ekranları görebilir

