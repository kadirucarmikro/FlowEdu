# Etkinlikler (Events) Modülü

## Genel Bakış
Sistemdeki etkinlik yönetim modülüdür. Admin kullanıcılar etkinlik oluşturabilir, üyeler etkinlikleri görüntüleyip katılım durumlarını belirtebilir.

## Özellikler
- ✅ 3 Etkinlik Türü:
  - **Normal**: Standart etkinlikler
  - **Etkileşimli**: Üyelerin yanıt verebileceği etkinlikler
  - **Anket**: Çoktan seçmeli anket etkinlikleri
- ✅ Katılım durumu takibi
- ✅ Rol bazlı form yapıları
- ✅ Responsive tasarım
- ✅ RLS politikaları

## Mimari Yapı

### Domain Layer
- **Entities**: `Event` entity
- **Repositories**: `EventsRepositoryInterface`
- **Use Cases**:
  - `GetEvents`: Etkinlikleri getir
  - `CreateEvent`: Etkinlik oluştur
  - `UpdateEvent`: Etkinlik güncelle
  - `DeleteEvent`: Etkinlik sil
  - `CreateEventResponse`: Etkinlik yanıtı oluştur

### Data Layer
- **Data Sources**: `EventsRemoteDataSource` (Supabase)
- **Models**: `EventModel` (DTO)
- **Repositories**: `EventsRepositoryImpl`

### Presentation Layer
- **Pages**:
  - `events_page.dart`: Etkinlik listesi sayfası
  - `event_detail_page.dart`: Etkinlik detay sayfası
- **Widgets**:
  - `event_card.dart`: Etkinlik kartı widget'ı
  - `event_form_dialog.dart`: Etkinlik form dialog'u
  - `event_response_dialog.dart`: Yanıt dialog'u
- **Providers**: `events_providers.dart` (Riverpod)

## Kullanım

### Etkinlikleri Getirme
```dart
final eventsAsync = ref.watch(eventsProvider);
```

### Yeni Etkinlik Oluşturma
```dart
final createEvent = ref.read(createEventProvider);
await createEvent(
  title: 'Etkinlik Başlığı',
  description: 'Açıklama',
  eventDate: DateTime.now(),
  type: EventType.normal,
);
```

### Etkinlik Güncelleme
```dart
final updateEvent = ref.read(updateEventProvider);
await updateEvent(id: eventId, title: 'Güncellenmiş Başlık');
```

### Etkinlik Yanıtı Oluşturma
```dart
final createResponse = ref.read(createEventResponseProvider);
await createResponse(
  eventId: eventId,
  response: 'Katılıyorum',
);
```

## Veritabanı Yapısı
- **Tablo**: `events`
- **Kolonlar**:
  - `id`: UUID (Primary Key)
  - `title`: String
  - `description`: String
  - `event_date`: Timestamp
  - `type`: Enum (normal, interactive, poll)
  - `question_text`: String (anket için)
  - `options`: JSON (anket seçenekleri)
  - `created_by`: UUID
  - `created_at`: Timestamp

## Etkinlik Türleri

### Normal Etkinlik
Standart etkinlikler. Üyeler sadece görüntüleyebilir.

### Etkileşimli Etkinlik
Üyelerin yanıt verebileceği etkinlikler. Serbest metin yanıt alınır.

### Anket Etkinliği
Çoktan seçmeli anket etkinlikleri. Önceden tanımlanmış seçenekler arasından seçim yapılır.

## Yetkilendirme
- **Admin**: Tüm etkinlikleri oluşturabilir, görüntüleyebilir ve yönetebilir
- **Member**: Etkinlikleri görüntüleyebilir ve yanıt verebilir

## RLS Politikaları
- Üyeler tüm etkinlikleri görebilir
- Admin kullanıcılar tüm etkinlikleri görebilir ve yönetebilir
- Yanıtlar sadece ilgili üye tarafından görüntülenebilir

