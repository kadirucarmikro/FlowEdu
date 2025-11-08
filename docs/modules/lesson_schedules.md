# Ders Programları (Lesson Schedules) Modülü

## Genel Bakış
Ders programı yönetim modülüdür. Haftalık ders programları, paket bazlı program oluşturma ve üye atama sistemi içerir.

## Özellikler
- ✅ Ders programı CRUD işlemleri
- ✅ Paket bazlı program oluşturma
- ✅ Üye atama sistemi
- ✅ Eğitmen atama
- ✅ Oda rezervasyonu
- ✅ Ders durumu takibi (scheduled, completed, missed, rescheduled)
- ✅ Otomatik durum güncelleme
- ✅ Çakışma kontrolü
- ✅ Haftalık takvim görünümü
- ✅ Responsive tasarım
- ✅ RLS politikaları

## Mimari Yapı

### Domain Layer
- **Entities**:
  - `LessonSchedule`: Ders programı entity
  - `LessonScheduleWithPackage`: Paket bilgili ders programı
- **Repositories**: `LessonSchedulesRepository`
- **Use Cases**:
  - `GetLessonSchedules`: Ders programlarını getir
  - `GetLessonSchedulesWithPackages`: Paket bilgili programları getir
  - `GetLessonSchedulesByPackage`: Pakete göre programları getir
  - `GetMemberAssignedSchedules`: Üyeye atanan programları getir
  - `CreateLessonSchedule`: Program oluştur
  - `UpdateLessonSchedule`: Program güncelle
  - `DeleteLessonSchedule`: Program sil
- **Services**:
  - `AutoStatusUpdateService`: Otomatik durum güncelleme servisi

### Data Layer
- **Data Sources**: `LessonSchedulesRemoteDataSource` (Supabase)
- **Models**: `LessonScheduleModel` (DTO)
- **Repositories**: `LessonSchedulesRepositoryImpl`

### Presentation Layer
- **Pages**:
  - `lesson_schedules_page.dart`: Ders programı listesi
  - `lesson_schedule_detail_page.dart`: Ders detay sayfası
  - `lesson_schedule_add_page.dart`: Yeni ders ekleme
  - `lesson_schedule_update_page.dart`: Ders güncelleme
- **Widgets**:
  - `weekly_calendar_view.dart`: Haftalık takvim görünümü
  - `lesson_schedule_form_dialog.dart`: Ders form dialog'u
  - `schedule_generation_widget.dart`: Program oluşturma widget'ı
- **Providers**: `lesson_schedules_providers.dart` (Riverpod)

## Kullanım

### Ders Programlarını Getirme
```dart
final schedulesAsync = ref.watch(lessonSchedulesWithPackagesProvider);
```

### Yeni Ders Programı Oluşturma
```dart
final createSchedule = ref.read(createLessonScheduleProvider);
await createSchedule(
  packageId: packageId,
  dayOfWeek: 'Monday',
  startTime: '10:00',
  endTime: '11:00',
  attendeeIds: [memberId1, memberId2],
);
```

### Ders Durumu Güncelleme
```dart
final updateStatus = ref.read(updateLessonStatusProvider);
await updateStatus(
  scheduleId: scheduleId,
  status: LessonStatus.completed,
);
```

## Veritabanı Yapısı
- **Tablo**: `lesson_schedules`
- **Kolonlar**:
  - `id`: UUID (Primary Key)
  - `package_id`: UUID
  - `instructor_id`: UUID (nullable)
  - `room_id`: UUID (nullable)
  - `day_of_week`: String
  - `start_time`: String
  - `end_time`: String
  - `attendee_ids`: Array[UUID]
  - `lesson_number`: Integer
  - `total_lessons`: Integer
  - `status`: Enum (scheduled, completed, missed, rescheduled)
  - `actual_date_day`: Integer (nullable)
  - `actual_date_month`: Integer (nullable)
  - `actual_date_year`: Integer (nullable)
  - `rescheduled_date`: Timestamp (nullable)
  - `reschedule_reason`: String (nullable)
  - `created_at`: Timestamp

## Ders Durumları
- **scheduled**: Planlanmış
- **completed**: Tamamlanmış
- **missed**: Kaçırılmış
- **rescheduled**: Yeniden planlanmış

## Otomatik Durum Güncelleme
Geçmiş dersler otomatik olarak "missed" durumuna güncellenir. Bu işlem `AutoStatusUpdateService` tarafından yönetilir.

## Çakışma Kontrolü
- Oda çakışması kontrolü
- Eğitmen çakışması kontrolü
- Üye çakışması kontrolü

## Yetkilendirme
- **Admin**: Tüm ders programlarını oluşturabilir, görüntüleyebilir ve yönetebilir
- **Member**: Sadece kendisine atanan dersleri görüntüleyebilir

## RLS Politikaları
- Üyeler sadece kendilerine atanan dersleri görebilir
- Admin kullanıcılar tüm ders programlarını görebilir ve yönetebilir
- `attendee_ids` ile otomatik filtreleme yapılır

