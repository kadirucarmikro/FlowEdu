# Ödemeler (Payments) Modülü

## Genel Bakış
Sistemdeki ödeme yönetim modülüdür. Ödeme kayıtları, ders paketleri ve indirim yönetimi yapılır.

## Özellikler
- ✅ Ödeme CRUD işlemleri
- ✅ Ders paketi yönetimi
- ✅ İndirim sistemi (tutar veya yüzde bazlı)
- ✅ Ödeme durumu takibi (pending, paid, failed)
- ✅ Üye bazlı ödeme görüntüleme
- ✅ Ders programı entegrasyonu
- ✅ Otomatik fiyat ve indirim yükleme
- ✅ Çift ödeme kontrolü
- ✅ Filtreleme ve arama
- ✅ Responsive tasarım
- ✅ RLS politikaları

## Mimari Yapı

### Domain Layer
- **Entities**:
  - `Payment`: Ödeme entity
  - `LessonPackage`: Ders paketi entity
  - `PaymentWithDetails`: Detaylı ödeme bilgisi
- **Repositories**: `PaymentsRepository`
- **Use Cases**:
  - `GetPayments`: Ödemeleri getir
  - `CreatePayment`: Ödeme oluştur
  - `UpdatePayment`: Ödeme güncelle
  - `DeletePayment`: Ödeme sil
- **Repository Methods**:
  - `getMemberPackagePriceAndDiscount`: Üye-paket için fiyat ve indirim getir
  - `checkExistingPaymentForSchedule`: Çift ödeme kontrolü
  - `getMemberPackageSchedules`: Üye-paket için ders programlarını getir

### Data Layer
- **Data Sources**: `PaymentsRemoteDataSource` (Supabase)
- **Models**: `PaymentModel`, `LessonPackageModel`, `PaymentWithDetailsModel`
- **Repositories**: `PaymentsRepositoryImpl`

### Presentation Layer
- **Pages**:
  - `payments_page.dart`: Ödeme listesi sayfası
  - `lesson_packages_page.dart`: Ders paketleri sayfası
- **Widgets**:
  - `payment_card.dart`: Ödeme kartı widget'ı
  - `payment_form_dialog.dart`: Ödeme form dialog'u
  - `lesson_package_card.dart`: Paket kartı widget'ı
  - `lesson_package_form_dialog.dart`: Paket form dialog'u
- **Providers**: `payments_providers.dart` (Riverpod)

## Kullanım

### Ödemeleri Getirme
```dart
final paymentsAsync = ref.watch(paymentsWithDetailsProvider);
```

### Yeni Ödeme Oluşturma
```dart
final createPayment = ref.read(createPaymentProvider);
await createPayment(
  memberId: memberId,
  packageId: packageId,
  amount: 1000.0,
  discountAmount: 100.0,
  status: PaymentStatus.pending,
);
```

### Ödeme Güncelleme
```dart
final updatePayment = ref.read(updatePaymentProvider);
await updatePayment(
  payment.copyWith(status: PaymentStatus.paid, paidAt: DateTime.now()),
);
```

## Veritabanı Yapısı
- **Tablo**: `payments`
- **Kolonlar**:
  - `id`: UUID (Primary Key)
  - `member_id`: UUID
  - `package_id`: UUID
  - `amount`: Decimal (Toplam tutar)
  - `discount_amount`: Decimal (İndirim tutarı)
  - `status`: Enum (pending, paid, failed)
  - `due_date`: Date
  - `paid_at`: Timestamp
  - `created_at`: Timestamp

- **Tablo**: `lesson_packages`
- **Kolonlar**:
  - `id`: UUID (Primary Key)
  - `name`: String
  - `lesson_count`: Integer
  - `price`: Decimal
  - `is_active`: Boolean
  - `created_at`: Timestamp

## Ödeme Durumları
- **pending**: Bekleyen ödeme
- **paid**: Ödenmiş
- **failed**: Başarısız ödeme

## İndirim Sistemi
Her ödeme için indirim tutarı veya yüzdesi belirlenebilir:
- **Tutar Bazlı İndirim**: Sabit tutar indirimi
- **Yüzde Bazlı İndirim**: Yüzde oranında indirim
- Final tutar = `amount - discountAmount` formülü ile hesaplanır

## Ders Programı Entegrasyonu
Ödeme formunda ders programı seçilebilir:
- Üye ve paket seçildiğinde ilgili ders programları otomatik yüklenir
- Ders programı seçildiğinde fiyat ve indirim bilgileri otomatik doldurulur
- `lesson_attendees` tablosundan mevcut fiyat ve indirim bilgileri alınır
- Aynı üye-paket-schedule kombinasyonu için çift ödeme kontrolü yapılır

## Otomatik Fiyat Yükleme
Ödeme formunda:
1. Üye ve paket seçildiğinde ilgili ders programları listelenir
2. Ders programı seçildiğinde `lesson_attendees` tablosundan fiyat bilgisi yüklenir
3. Varsa indirim bilgisi (tutar veya yüzde) otomatik doldurulur
4. Başlangıç ve bitiş tarihleri otomatik set edilir

## Yetkilendirme
- **Admin**: Tüm ödemeleri görüntüleyebilir ve yönetebilir
- **Member**: Sadece kendi ödemelerini görüntüleyebilir

## RLS Politikaları
- Üyeler sadece kendi ödemelerini görebilir
- Admin kullanıcılar tüm ödemeleri görebilir ve yönetebilir
- `member_id` ile otomatik filtreleme yapılır

## Filtreleme ve Arama
- Grup bazlı filtreleme
- Üye bazlı filtreleme
- Paket bazlı filtreleme
- Durum bazlı filtreleme
- Tarih aralığı filtreleme

## Akış Diagramları

### Ödeme Oluşturma Akışı
```mermaid
flowchart TD
    A[Ödeme Form Dialog] --> B[Üye Seç]
    B --> C[Paket Seç]
    C --> D{Ders Programı Seçildi mi?}
    D -->|Evet| E[lesson_attendees'tan Fiyat Yükle]
    D -->|Hayır| F[Manuel Fiyat Gir]
    E --> G[İndirim Bilgisi Yükle]
    G --> H[Çift Ödeme Kontrolü]
    H --> I{Mevcut Ödeme Var mı?}
    I -->|Evet| J[Hata: Zaten Ödeme Mevcut]
    I -->|Hayır| K[Ödeme Tutarı Hesapla]
    F --> K
    K --> L[Form Validasyonu]
    L --> M{Geçerli mi?}
    M -->|Hayır| A
    M -->|Evet| N[CreatePayment Use Case]
    N --> O[PaymentsRepository]
    O --> P[Supabase: Insert Payment]
    P --> Q{İşlem Başarılı?}
    Q -->|Hayır| R[Hata Mesajı]
    Q -->|Evet| S[Provider Invalidate]
    S --> T[Dialog Kapat]
```

### Otomatik Fiyat Yükleme Akışı
```mermaid
sequenceDiagram
    participant U as User
    participant F as PaymentForm
    participant P as PaymentsProvider
    participant R as PaymentsRepository
    participant DB as Supabase
    
    U->>F: Üye ve Paket Seç
    F->>P: getMemberPackageSchedules()
    P->>R: getMemberPackageSchedules()
    R->>DB: Query lesson_attendees
    DB-->>R: Schedule List
    R-->>P: Schedule List
    P-->>F: Schedule List
    
    U->>F: Ders Programı Seç
    F->>P: getMemberPackagePriceAndDiscount()
    P->>R: getMemberPackagePriceAndDiscount()
    R->>DB: Query lesson_attendees (price, discount)
    DB-->>R: Price & Discount
    R-->>P: Price & Discount
    P-->>F: Auto-fill Form Fields
```

### Ödeme Durum Yönetimi
```mermaid
stateDiagram-v2
    [*] --> Pending: Ödeme Oluşturuldu
    Pending --> Paid: Ödeme Yapıldı
    Pending --> Failed: Ödeme Başarısız
    Paid --> [*]: İşlem Tamamlandı
    Failed --> Pending: Tekrar Deneme
    Failed --> [*]: İptal Edildi
    
    note right of Pending
        due_date kontrol edilir
        Ödeme bekleniyor
    end note
    
    note right of Paid
        paid_at timestamp
        İşlem tamamlandı
    end note
```

### Clean Architecture - Payments Modülü
```mermaid
flowchart TB
    subgraph Presentation["Presentation Layer"]
        P1[PaymentsPage]
        P2[PaymentFormDialog]
        P3[PaymentCard]
        P4[PaymentsProviders]
    end
    
    subgraph Domain["Domain Layer"]
        D1[Payment Entity]
        D2[PaymentsRepository Interface]
        D3[Use Cases]
    end
    
    subgraph Data["Data Layer"]
        DA1[PaymentModel]
        DA2[PaymentsRepositoryImpl]
        DA3[PaymentsRemoteDataSource]
    end
    
    subgraph External["External"]
        E1[(Supabase)]
    end
    
    P1 --> P4
    P2 --> P4
    P3 --> P4
    P4 --> D3
    D3 --> D2
    D2 --> DA2
    DA2 --> DA3
    DA3 --> E1
    D1 --> DA1
    
    style Presentation fill:#e1f5ff
    style Domain fill:#fff4e1
    style Data fill:#e8f5e9
    style External fill:#f3e5f5
```

