# Kimlik Doğrulama (Auth) Modülü

## Genel Bakış
FlowEdu uygulamasının kimlik doğrulama sistemini yöneten modüldür. Supabase Authentication kullanarak kullanıcı girişi, kayıt ve e-posta doğrulama işlemlerini gerçekleştirir.

## Özellikler
- ✅ E-posta/şifre ile giriş
- ✅ Kullanıcı kaydı
- ✅ E-posta doğrulama
- ✅ Otomatik member kaydı oluşturma
- ✅ Supabase Auth entegrasyonu

## Mimari Yapı

### Domain Layer
- **Entities**: Kullanıcı bilgileri için entity yapıları
- **Repositories**: `AuthRepository` interface

### Data Layer
- **Repository Implementation**: `AuthRepositoryImpl`
- **Supabase Integration**: Supabase Auth client kullanımı

### Presentation Layer
- **Pages**:
  - `sign_in_page.dart`: Giriş sayfası
  - `sign_up_page.dart`: Kayıt sayfası
  - `verify_email_page.dart`: E-posta doğrulama sayfası

## Kullanım

### Giriş Yapma
```dart
final authRepo = ref.read(authRepositoryProvider);
await authRepo.signInWithEmail(
  email: 'user@example.com',
  password: 'password123',
);
```

### Kayıt Olma
```dart
await authRepo.signUpWithEmail(
  email: 'user@example.com',
  password: 'password123',
);
```

### Çıkış Yapma
```dart
await authRepo.signOut();
```

## Otomatik Member Oluşturma
Kullanıcı kaydı veya girişi sırasında otomatik olarak `members` tablosuna kayıt oluşturulur. Varsayılan olarak "Member" rolü atanır.

## E-posta Şablonları
E-posta şablonları Supabase Dashboard'da yapılandırılmalıdır. Detaylar için `README.md` dosyasına bakın.

## Güvenlik
- Tüm kimlik doğrulama işlemleri Supabase Auth üzerinden yapılır
- Şifreler Supabase tarafından hash'lenir
- E-posta doğrulama zorunludur
- RLS politikaları ile veri güvenliği sağlanır

## Akış Diagramları

### Kullanıcı Kayıt Akışı
```mermaid
flowchart TD
    A[Kullanıcı Kayıt Formu] --> B{Form Validasyonu}
    B -->|Geçersiz| A
    B -->|Geçerli| C[Supabase Auth: signUp]
    C --> D{İşlem Başarılı?}
    D -->|Hayır| E[Hata Mesajı Göster]
    E --> A
    D -->|Evet| F[E-posta Doğrulama Gönder]
    F --> G[Verify Email Page]
    G --> H[E-posta Linkine Tıkla]
    H --> I[Supabase: Email Confirm]
    I --> J{Doğrulama Başarılı?}
    J -->|Hayır| K[Hata Mesajı]
    J -->|Evet| L[Otomatik Member Oluştur]
    L --> M[Varsayılan Role: Member]
    M --> N[Ana Sayfaya Yönlendir]
```

### Kullanıcı Giriş Akışı
```mermaid
flowchart TD
    A[Giriş Sayfası] --> B[Email/Password Gir]
    B --> C{Form Validasyonu}
    C -->|Geçersiz| B
    C -->|Geçerli| D[Supabase Auth: signIn]
    D --> E{Kimlik Doğrulama}
    E -->|Başarısız| F[Hata Mesajı]
    F --> B
    E -->|Başarılı| G{Email Doğrulandı mı?}
    G -->|Hayır| H[Email Doğrulama Sayfası]
    G -->|Evet| I{Member Kaydı Var mı?}
    I -->|Hayır| J[Otomatik Member Oluştur]
    J --> K[Ana Sayfaya Yönlendir]
    I -->|Evet| K
```

### Clean Architecture Akışı
```mermaid
flowchart LR
    A[Presentation Layer] --> B[Domain Layer]
    B --> C[Data Layer]
    C --> D[Supabase]
    
    A1[SignInPage] --> A2[AuthRepository Provider]
    A2 --> B1[AuthRepository Interface]
    B1 --> C1[AuthRepositoryImpl]
    C1 --> C2[Supabase Auth Client]
    C2 --> D
    
    style A fill:#e1f5ff
    style B fill:#fff4e1
    style C fill:#e8f5e9
    style D fill:#f3e5f5
```

