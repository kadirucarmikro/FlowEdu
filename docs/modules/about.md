# Hakkımızda (About) Modülü

## Genel Bakış
CMS benzeri içerik yönetim modülüdür. Hakkımızda sayfası içeriklerini yönetmek için kullanılır.

## Özellikler
- ✅ İçerik CRUD işlemleri
- ✅ Slug bazlı içerik yönetimi
- ✅ Accordion/Tab layout desteği
- ✅ Medya yönetimi (resim, video)
- ✅ Responsive tasarım
- ✅ RLS politikaları

## Mimari Yapı

### Domain Layer
- **Entities**: `AboutContent` entity
- **Repositories**: `AboutRepository`
- **Use Cases**:
  - `GetAboutContents`: İçerikleri getir
  - `GetAboutContentBySlug`: Slug'a göre içerik getir
  - `CreateAboutContent`: İçerik oluştur
  - `UpdateAboutContent`: İçerik güncelle
  - `DeleteAboutContent`: İçerik sil

### Data Layer
- **Data Sources**: `AboutRemoteDataSource` (Supabase)
- **Models**: `AboutContentModel` (DTO)
- **Repositories**: `AboutRepositoryImpl`

### Presentation Layer
- **Pages**: `about_page.dart`
- **Widgets**:
  - `about_content_card.dart`: İçerik kartı widget'ı
  - `about_content_form_dialog.dart`: İçerik form dialog'u
- **Providers**: `about_providers.dart` (Riverpod)

## Kullanım

### İçerikleri Getirme
```dart
final contentsAsync = ref.watch(aboutContentsProvider);
```

### Slug'a Göre İçerik Getirme
```dart
final contentAsync = ref.watch(aboutContentBySlugProvider('hakkimizda'));
```

### Yeni İçerik Oluşturma
```dart
final createContent = ref.read(createAboutContentProvider);
await createContent(
  slug: 'hakkimizda',
  title: 'Hakkımızda',
  content: 'İçerik metni',
);
```

## Veritabanı Yapısı
- **Tablo**: `about_contents`
- **Kolonlar**:
  - `id`: UUID (Primary Key)
  - `slug`: String (Unique)
  - `title`: String
  - `content`: Text
  - `order`: Integer
  - `is_active`: Boolean
  - `created_at`: Timestamp
  - `updated_at`: Timestamp

## İçerik Yönetimi
- Her içerik benzersiz bir `slug` ile tanımlanır
- İçerikler `order` alanına göre sıralanır
- Aktif/pasif durumu yönetilebilir
- Rich text içerik desteği

## Yetkilendirme
- **Admin**: Tüm içerikleri oluşturabilir, görüntüleyebilir ve yönetebilir
- **Member**: Sadece aktif içerikleri görüntüleyebilir

## RLS Politikaları
- Üyeler sadece aktif içerikleri görebilir
- Admin kullanıcılar tüm içerikleri görebilir ve yönetebilir

