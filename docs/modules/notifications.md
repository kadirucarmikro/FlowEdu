# Bildirimler (Notifications) Modülü

## Genel Bakış
Sistemdeki bildirim yönetim modülüdür. Admin kullanıcılar bildirim oluşturabilir, üyeler kendi bildirimlerini görüntüleyip yanıtlayabilir.

## Özellikler
- ✅ 3 Bildirim Türü:
  - **Otomatik**: Sistem tarafından otomatik oluşturulan bildirimler
  - **Manuel**: Admin tarafından manuel oluşturulan bildirimler
  - **Etkileşimli**: Üyelerin yanıt verebileceği bildirimler
- ✅ Hedefleme Sistemi:
  - Rol bazlı hedefleme
  - Grup bazlı hedefleme
  - Üye bazlı hedefleme
  - Doğum günü bazlı hedefleme
- ✅ Okuma durumu takibi
- ✅ Yanıt sistemi
- ✅ Responsive tasarım
- ✅ RLS politikaları

## Mimari Yapı

### Domain Layer
- **Entities**:
  - `Notification`: Ana bildirim entity
  - `NotificationTarget`: Hedefleme bilgisi
  - `NotificationResponse`: Yanıt bilgisi
- **Repositories**: `NotificationsRepository` interface
- **Use Cases**:
  - `GetNotifications`: Bildirimleri getir
  - `GetMemberNotifications`: Üye bildirimlerini getir
  - `CreateNotification`: Bildirim oluştur
  - `UpdateNotification`: Bildirim güncelle
  - `DeleteNotification`: Bildirim sil
  - `MarkAsRead`: Okundu olarak işaretle
  - `CreateResponse`: Yanıt oluştur

### Data Layer
- **Data Sources**: `NotificationsRemoteDataSource` (Supabase)
- **Models**: `NotificationModel`, `NotificationTargetModel`, `NotificationResponseModel`
- **Repositories**: `NotificationsRepositoryImpl`

### Presentation Layer
- **Pages**: `notifications_page.dart`
- **Widgets**:
  - `notification_card.dart`: Bildirim kartı widget'ı
  - `notification_form_dialog.dart`: Bildirim form dialog'u
  - `notification_response_dialog.dart`: Yanıt dialog'u
- **Providers**: `notifications_providers.dart` (Riverpod)

## Kullanım

### Bildirimleri Getirme
```dart
final notificationsAsync = ref.watch(memberNotificationsProvider);
```

### Yeni Bildirim Oluşturma
```dart
final createNotification = ref.read(createNotificationProvider);
await createNotification(
  title: 'Başlık',
  content: 'İçerik',
  type: NotificationType.manual,
  targets: [
    NotificationTarget(type: 'role', targetId: roleId),
  ],
);
```

### Okundu Olarak İşaretleme
```dart
final markAsRead = ref.read(markAsReadProvider);
await markAsRead(notificationId);
```

### Yanıt Verme
```dart
final createResponse = ref.read(createResponseProvider);
await createResponse(notificationId: notificationId, response: 'Yanıt metni');
```

## Veritabanı Yapısı
- **Tablo**: `notifications`
- **Kolonlar**:
  - `id`: UUID (Primary Key)
  - `title`: String
  - `content`: String
  - `type`: Enum (automatic, manual, interactive)
  - `created_by`: UUID
  - `created_at`: Timestamp

- **Tablo**: `notification_targets`
- **Kolonlar**:
  - `id`: UUID (Primary Key)
  - `notification_id`: UUID
  - `target_type`: String (role, group, member, birthday)
  - `target_id`: UUID (nullable for birthday)

- **Tablo**: `notification_read_status`
- **Kolonlar**:
  - `notification_id`: UUID
  - `member_id`: UUID
  - `is_read`: Boolean
  - `read_at`: Timestamp

- **Tablo**: `notification_responses`
- **Kolonlar**:
  - `id`: UUID (Primary Key)
  - `notification_id`: UUID
  - `member_id`: UUID
  - `response`: String
  - `created_at`: Timestamp

## Hedefleme Sistemi
Bildirimler 4 farklı yöntemle hedeflenebilir:
1. **Rol Bazlı**: Belirli role sahip üyelere gönderilir
2. **Grup Bazlı**: Belirli gruba gönderilir
3. **Üye Bazlı**: Belirli üyeye gönderilir
4. **Doğum Günü Bazlı**: Doğum günü yaklaşan üyelere gönderilir (7 gün içinde)

## Yetkilendirme
- **Admin**: Tüm bildirimleri oluşturabilir, görüntüleyebilir ve yönetebilir
- **Member**: Sadece kendi bildirimlerini görüntüleyebilir ve yanıtlayabilir

## RLS Politikaları
- Üyeler sadece kendilerine gönderilen bildirimleri görebilir
- Admin kullanıcılar tüm bildirimleri görebilir ve yönetebilir
- `member_notifications` view ile filtreleme yapılır

## Akış Diagramları

### Bildirim Oluşturma ve Dağıtım Akışı
```mermaid
flowchart TD
    A[Admin: Bildirim Formu] --> B[Bildirim Türü Seç]
    B --> C{Tür?}
    C -->|Otomatik| D[Sistem Oluşturur]
    C -->|Manuel| E[Admin Oluşturur]
    C -->|Etkileşimli| E
    E --> F[Hedefleme Seç]
    F --> G{Hedef Tipi?}
    G -->|Rol| H[Rol Üyelerini Bul]
    G -->|Grup| I[Grup Üyelerini Bul]
    G -->|Üye| J[Belirli Üyeyi Seç]
    G -->|Doğum Günü| K[7 Gün İçinde Doğum Günü Olanları Bul]
    H --> L[NotificationTarget Oluştur]
    I --> L
    J --> L
    K --> L
    D --> L
    L --> M[Supabase: Bildirim Kaydet]
    M --> N[Her Hedef İçin Read Status Oluştur]
    N --> O[Üyelere Bildirim Göster]
```

### Bildirim Okuma ve Yanıt Akışı
```mermaid
sequenceDiagram
    participant M as Member
    participant P as NotificationsPage
    participant PR as NotificationsProvider
    participant R as NotificationsRepository
    participant DB as Supabase
    
    M->>P: Bildirimleri Görüntüle
    P->>PR: memberNotificationsProvider
    PR->>R: getMemberNotifications()
    R->>DB: Query member_notifications view
    DB-->>R: Notification List
    R-->>PR: Notification List
    PR-->>P: Display Notifications
    
    M->>P: Bildirime Tıkla
    P->>PR: markAsRead()
    PR->>R: markAsRead()
    R->>DB: Update notification_read_status
    DB-->>R: Success
    R-->>PR: Success
    PR-->>P: Update UI
    
    alt Etkileşimli Bildirim
        M->>P: Yanıt Ver
        P->>PR: createResponse()
        PR->>R: createResponse()
        R->>DB: Insert notification_responses
        DB-->>R: Success
        R-->>PR: Success
        PR-->>P: Show Success Message
    end
```

### Hedefleme Sistemi Akışı
```mermaid
flowchart LR
    A[Bildirim Oluştur] --> B{Hedefleme Tipi}
    B -->|Rol| C[role_members View]
    B -->|Grup| D[group_members View]
    B -->|Üye| E[Belirli member_id]
    B -->|Doğum Günü| F[birthday_members Function]
    
    C --> G[Üye Listesi]
    D --> G
    E --> G
    F --> G
    
    G --> H[Her Üye İçin]
    H --> I[notification_targets Kaydet]
    I --> J[notification_read_status Oluştur]
    J --> K[Bildirim Dağıtımı Tamamlandı]
    
    style A fill:#e1f5ff
    style G fill:#fff4e1
    style K fill:#e8f5e9
```

### Bildirim Türleri ve İş Akışı
```mermaid
stateDiagram-v2
    [*] --> Created: Bildirim Oluşturuldu
    
    Created --> Distributed: Hedeflere Dağıtıldı
    
    Distributed --> Unread: Üye Görmedi
    Distributed --> Read: Üye Okudu
    
    Unread --> Read: Üye Okudu Olarak İşaretledi
    
    Read --> Responded: Etkileşimli Bildirim Yanıtlandı
    Read --> [*]: Normal Bildirim Tamamlandı
    Responded --> [*]: Yanıt Verildi
    
    note right of Created
        Admin veya Sistem
        tarafından oluşturuldu
    end note
    
    note right of Distributed
        notification_targets
        notification_read_status
        kayıtları oluşturuldu
    end note
```

