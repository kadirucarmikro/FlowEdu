# Gruplar (Groups) Modülü

## Genel Bakış
Sistemdeki kullanıcı gruplarını yöneten modüldür. Admin kullanıcılar grup oluşturma, güncelleme ve silme işlemlerini yapabilir.

## Özellikler
- ✅ CRUD işlemleri (Oluşturma, Okuma, Güncelleme, Silme)
- ✅ Grup aktif/pasif durumu yönetimi
- ✅ Admin/Member ayrımı
- ✅ Responsive tasarım
- ✅ RLS politikaları

## Mimari Yapı

### Domain Layer
- **Entities**: `Group` entity
- **Repositories**: `GroupsRepositoryInterface`
- **Use Cases**:
  - `GetGroups`: Tüm grupları getir
  - `CreateGroup`: Yeni grup oluştur
  - `UpdateGroup`: Grup güncelle
  - `DeleteGroup`: Grup sil

### Data Layer
- **Data Sources**: `GroupsRemoteDataSource` (Supabase)
- **Models**: `GroupModel` (DTO)
- **Repositories**: `GroupsRepositoryImpl`

### Presentation Layer
- **Pages**: `groups_page.dart`
- **Widgets**:
  - `group_card.dart`: Grup kartı widget'ı
  - `group_form_dialog.dart`: Grup form dialog'u
- **Providers**: `groups_providers.dart` (Riverpod)

## Kullanım

### Grupları Getirme
```dart
final groupsAsync = ref.watch(groupsListProvider);
```

### Yeni Grup Oluşturma
```dart
final createGroup = ref.read(createGroupProvider);
await createGroup(name: 'Yeni Grup', isActive: true);
```

### Grup Güncelleme
```dart
final updateGroup = ref.read(updateGroupProvider);
await updateGroup(id: groupId, name: 'Güncellenmiş Grup', isActive: false);
```

### Grup Silme
```dart
final deleteGroup = ref.read(deleteGroupProvider);
await deleteGroup(groupId);
```

## Veritabanı Yapısı
- **Tablo**: `groups`
- **Kolonlar**:
  - `id`: UUID (Primary Key)
  - `name`: String (Grup adı)
  - `is_active`: Boolean (Aktif durumu)
  - `created_at`: Timestamp

## Yetkilendirme
- **Admin**: Tüm CRUD işlemlerini yapabilir
- **Member**: Sadece görüntüleme yapabilir

## RLS Politikaları
- Admin kullanıcılar tüm grupları görebilir ve yönetebilir
- Member kullanıcılar sadece aktif grupları görebilir

