# Yeni Sayfa Ekleme Rehberi (Veritabanı Tabanlı)

Bu rehber, FlowEdu projesine yeni bir sayfa eklerken veritabanı tabanlı yetki matrisi sistemine nasıl entegre edileceğini açıklar.

## 📋 Adım Adım Rehber

### 1. **Yeni Sayfa Oluşturma**
```dart
// lib/features/yeni_modul/presentation/pages/yeni_sayfa.dart
class YeniSayfa extends ConsumerStatefulWidget {
  const YeniSayfa({super.key});
  
  @override
  ConsumerState<YeniSayfa> createState() => _YeniSayfaState();
}
```

### 2. **Veritabanına Otomatik Kayıt**
```dart
// Yeni sayfa ekleme - otomatik yetki tanımlama ile
await ScreenManager.addNewPage(
  name: 'Yeni Modül',
  route: '/yeni-modul',
  iconName: 'settings',
  requiredPermissions: ['read', 'create'],
  description: 'Yeni modül açıklaması',
  parentModule: 'yeni_modul',
  sortOrder: 13,
);
```

### 3. **Router'a Ekleme**
```dart
// lib/app/router/app_router.dart
static const String yeniModul = '/yeni-modul';

// routes listesine ekle
GoRoute(path: AppRoutes.yeniModul, builder: (_, __) => const YeniSayfa()),
```

### 4. **Navigation Drawer Otomatik Güncelleme**
```dart
// Navigation Drawer artık veritabanından otomatik olarak güncellenir
// Manuel ekleme gerekmez - veritabanında tanımlı sayfalar otomatik görünür
```

### 5. **Yetki Kontrolü Ekleme**
```dart
// Sayfa içinde yetki kontrolü - PermissionGuard ile
PermissionGuard(
  screenName: 'Yeni Modül',
  action: 'read',
  child: Scaffold(
    // Sayfa içeriği
  ),
)
```

### 6. **CRUD İşlemleri İçin Yetki Kontrolü**
```dart
// Oluşturma yetkisi
CreatePermissionGuard(
  screenName: 'Yeni Modül',
  child: ElevatedButton(...),
)

// Güncelleme yetkisi
UpdatePermissionGuard(
  screenName: 'Yeni Modül',
  child: ElevatedButton(...),
)

// Silme yetkisi
DeletePermissionGuard(
  screenName: 'Yeni Modül',
  child: ElevatedButton(...),
)
```

### 7. **Otomatik Yetki Tanımlama**
```dart
// ScreenManager.addNewPage() çağrıldığında:
// 1. Screens tablosuna yeni kayıt eklenir
// 2. Tüm roller için otomatik yetki tanımları oluşturulur
// 3. Navigation drawer otomatik güncellenir
// 4. Yetki matrisi otomatik güncellenir
```

## 🔧 Otomatik Yetki Tanımlama

### Yeni Sayfa Eklendiğinde Otomatik Yetki Oluşturma:
```dart
// Yeni sayfa eklendiğinde çağrılacak fonksiyon
void createPermissionsForNewScreen(String screenName) {
  final defaultPermissions = ScreenRegistry.createDefaultPermissionsForNewScreen(screenName);
  
  // Veritabanına kaydet
  for (final permission in defaultPermissions) {
    // Permission kaydetme işlemi
  }
}
```

## 📊 Yetki Matrisi Güncelleme

### Yeni Sayfa Eklendiğinde:
1. **Screen Registry'ye ekle**
2. **Router'a ekle**
3. **Navigation'a ekle**
4. **Veritabanında yetki tanımla**
5. **Yetki matrisi otomatik güncellenir**

## 🎯 Örnek: "Dersler" Modülü Ekleme

```dart
// 1. Screen Registry'ye ekle
'Dersler': ScreenInfo(
  name: 'Dersler',
  route: '/lessons',
  description: 'Ders yönetimi',
  module: 'lessons',
),

// 2. Router'a ekle
static const String lessons = '/lessons';
GoRoute(path: AppRoutes.lessons, builder: (_, __) => const LessonsPage()),

// 3. Navigation'a ekle
_buildDrawerItem(
  context,
  icon: Icons.school,
  title: 'Dersler',
  route: AppRoutes.lessons,
  isSelected: currentRoute == AppRoutes.lessons,
),

// 4. Sayfa içinde yetki kontrolü
if (PermissionService.canRead(member, 'Dersler', permissions)) {
  // Dersler sayfası içeriği
}
```

## ⚠️ Önemli Notlar

1. **Her yeni sayfa için yetki tanımlanmalı**
2. **Member rolü varsayılan olarak sadece Üyelik modülüne erişebilir**
3. **Admin ve SuperAdmin tüm modüllere erişebilir**
4. **Yetki değişiklikleri yetki matrisinden yapılmalı**
5. **Statik yetki tanımları kullanılmamalı**

## 🔄 Güncelleme Süreci

1. Yeni sayfa ekle
2. Screen Registry'ye kaydet
3. Router ve Navigation'a ekle
4. Veritabanında yetki tanımla
5. Yetki matrisini kontrol et
6. Test et
