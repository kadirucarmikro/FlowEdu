# Roller (Roles) Modülü

## Genel Bakış
Sistemdeki kullanıcı rollerini yöneten modüldür. Admin kullanıcılar rol oluşturma, güncelleme ve silme işlemlerini yapabilir.

## Özellikler
- ✅ CRUD işlemleri (Oluşturma, Okuma, Güncelleme, Silme)
- ✅ Rol aktif/pasif durumu yönetimi
- ✅ Admin/Member ayrımı
- ✅ Responsive tasarım
- ✅ RLS politikaları

## Mimari Yapı

### Domain Layer
- **Entities**: `Role` entity
- **Repositories**: `RolesRepositoryInterface`
- **Use Cases**:
  - `GetRoles`: Tüm rolleri getir
  - `CreateRole`: Yeni rol oluştur
  - `UpdateRole`: Rol güncelle
  - `DeleteRole`: Rol sil

### Data Layer
- **Data Sources**: `RolesRemoteDataSource` (Supabase)
- **Models**: `RoleModel` (DTO)
- **Repositories**: `RolesRepositoryImpl`

### Presentation Layer
- **Pages**: `roles_page.dart`
- **Widgets**:
  - `role_card.dart`: Rol kartı widget'ı
  - `role_form_dialog.dart`: Rol form dialog'u
- **Providers**: `roles_providers.dart` (Riverpod)

## Kullanım

### Rolleri Getirme
```dart
final rolesAsync = ref.watch(rolesListProvider);
```

### Yeni Rol Oluşturma
```dart
final createRole = ref.read(createRoleProvider);
await createRole(name: 'Yeni Rol', isActive: true);
```

### Rol Güncelleme
```dart
final updateRole = ref.read(updateRoleProvider);
await updateRole(id: roleId, name: 'Güncellenmiş Rol', isActive: false);
```

### Rol Silme
```dart
final deleteRole = ref.read(deleteRoleProvider);
await deleteRole(roleId);
```

## Veritabanı Yapısı
- **Tablo**: `roles`
- **Kolonlar**:
  - `id`: UUID (Primary Key)
  - `name`: String (Rol adı)
  - `is_active`: Boolean (Aktif durumu)
  - `created_at`: Timestamp

## Yetkilendirme
- **Admin**: Tüm CRUD işlemlerini yapabilir
- **Member**: Sadece görüntüleme yapabilir

## RLS Politikaları
- Admin kullanıcılar tüm rolleri görebilir ve yönetebilir
- Member kullanıcılar sadece aktif rolleri görebilir

