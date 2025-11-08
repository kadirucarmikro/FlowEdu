# Ekran Görüntüsü Alma ve Markdown Entegrasyonu Rehberi

Bu rehber, FlowEdu projesinde uygulama ekran görüntülerini alıp markdown dosyalarına nasıl ekleyeceğinizi açıklar.

## 📸 Ekran Görüntüsü Alma Yöntemleri

### 1. Flutter Web (Chrome/Edge)

#### Yöntem A: Tarayıcı Developer Tools
1. Uygulamayı çalıştırın:
   ```bash
   flutter run -d chrome --web-port 5287
   ```
2. Chrome DevTools'u açın (F12 veya Cmd+Option+I)
3. **Device Toolbar**'ı aktif edin (Cmd+Shift+M veya Ctrl+Shift+M)
4. İstediğiniz ekran boyutunu seçin (ör: iPhone 12 Pro, iPad, Desktop)
5. Ekran görüntüsü alın:
   - **macOS**: Cmd+Shift+4 → Ekranı seçin
   - **Windows**: Win+Shift+S → Ekranı seçin
   - **Linux**: Print Screen veya özel ekran görüntüsü aracı

#### Yöntem B: Chrome DevTools Screenshot
1. DevTools'u açın (F12)
2. **Console** sekmesine gidin
3. Şu komutu çalıştırın:
   ```javascript
   // Tam sayfa ekran görüntüsü
   document.querySelector('flt-glass-pane').shadowRoot.querySelector('flt-scene-host').shadowRoot.querySelector('canvas').toDataURL('image/png')
   ```
   Veya daha basit:
   ```javascript
   // Viewport ekran görüntüsü
   html2canvas(document.body).then(canvas => {
     const link = document.createElement('a');
     link.download = 'screenshot.png';
     link.href = canvas.toDataURL();
     link.click();
   });
   ```

#### Yöntem C: Flutter DevTools
1. Flutter DevTools'u açın (terminal'de gösterilen link)
2. **Performance** sekmesine gidin
3. Ekran görüntüsü almak için tarayıcı araçlarını kullanın

### 2. Flutter Mobile (iOS/Android)

#### iOS Simulator
1. Simulator'ü açın
2. Ekran görüntüsü alın:
   ```bash
   # Terminal'den
   xcrun simctl io booted screenshot screenshot.png
   
   # Veya Cmd+S (Simulator menüsünden)
   ```
3. Dosya `~/Desktop/` klasörüne kaydedilir

#### Android Emulator
1. Emulator'ü açın
2. Ekran görüntüsü alın:
   ```bash
   # Terminal'den
   adb shell screencap -p /sdcard/screenshot.png
   adb pull /sdcard/screenshot.png ~/Desktop/screenshot.png
   
   # Veya Android Studio'dan
   # View > Tool Windows > Logcat > Camera icon
   ```

#### Fiziksel Cihazlar
- **iOS**: Cmd+Shift+3 (tam ekran) veya Cmd+Shift+4 (seçim)
- **Android**: Power + Volume Down (çoğu cihazda)

### 3. Programatik Yöntem (Flutter Screenshot Package)

Flutter uygulaması içinden ekran görüntüsü almak için `screenshot` paketini kullanabilirsiniz:

#### Paket Ekleme
```yaml
# pubspec.yaml
dependencies:
  screenshot: ^2.1.0
```

#### Temel Kullanım Örneği
```dart
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

// Widget'ınızı RepaintBoundary ile sarmalayın
Screenshot(
  controller: screenshotController,
  child: YourWidget(),
)

// Ekran görüntüsü almak için
final imageBytes = await screenshotController.capture();
if (imageBytes != null) {
  final directory = await getApplicationDocumentsDirectory();
  final imagePath = '${directory.path}/screenshot_${DateTime.now().millisecondsSinceEpoch}.png';
  final imageFile = File(imagePath);
  await imageFile.writeAsBytes(imageBytes);
}
```

**Not**: Bu yöntem manuel ekran görüntüsü almak için kullanılabilir. Otomatik ekran görüntüsü alma özelliği projeden kaldırılmıştır.

## 📁 Dosya Organizasyonu

### Klasör Yapısı
```
docs/
  screenshots/
    auth/
      - sign-in.png
      - sign-up.png
      - verify-email.png
    payments/
      - payments-list.png
      - payment-form.png
      - packages-list.png
    notifications/
      - notifications-list.png
      - notification-form.png
    ...
```

### Dosya İsimlendirme
- Küçük harf kullanın
- Kelimeler arası tire (-) kullanın
- Açıklayıcı isimler verin
- Örnek: `payment-form-dialog.png`, `notifications-list-mobile.png`

## 📝 Markdown'a Ekran Görüntüsü Ekleme

### Yöntem 1: Relatif Path (Önerilen)
```markdown
## Ekran Görüntüleri

### Giriş Sayfası
![Giriş Sayfası](../screenshots/auth/sign-in.png)

### Ödeme Formu
![Ödeme Formu](../screenshots/payments/payment-form.png)
```

### Yöntem Açıklama
- `../screenshots/` → `docs/screenshots/` klasörüne işaret eder
- Markdown dosyası `docs/modules/` içindeyse bu path doğru çalışır

### Yöntem 2: Absolute Path (GitHub için)
```markdown
![Giriş Sayfası](/docs/screenshots/auth/sign-in.png)
```

### Yöntem 3: Responsive Görüntüler
```markdown
### Desktop Görünümü
![Desktop Görünümü](../screenshots/payments/payments-list-desktop.png)

### Mobile Görünümü
![Mobile Görünümü](../screenshots/payments/payments-list-mobile.png)
```

## 🎨 Ekran Görüntüsü İyileştirme

### 1. Boyutlandırma
```bash
# ImageMagick ile (macOS: brew install imagemagick)
convert screenshot.png -resize 1200x screenshot-resized.png

# veya sips (macOS built-in)
sips -Z 1200 screenshot.png
```

### 2. Optimizasyon
```bash
# pngquant ile sıkıştırma (daha küçük dosya boyutu)
pngquant --quality=65-80 screenshot.png

# veya ImageOptim (GUI tool)
# https://imageoptim.com/
```

### 3. Çerçeve Ekleme (Opsiyonel)
```bash
# ImageMagick ile çerçeve
convert screenshot.png -bordercolor white -border 20x20 screenshot-framed.png
```

## 📋 Örnek: Modül Dokümantasyonuna Ekran Görüntüsü Ekleme

### Örnek: Payments Modülü
```markdown
# Ödemeler (Payments) Modülü

## Genel Bakış
Sistemdeki ödeme yönetim modülüdür...

## Ekran Görüntüleri

### Ödeme Listesi Sayfası
![Ödeme Listesi](../screenshots/payments/payments-list.png)

### Ödeme Form Dialog
![Ödeme Formu](../screenshots/payments/payment-form-dialog.png)

### Ders Paketleri Sayfası
![Ders Paketleri](../screenshots/payments/lesson-packages.png)

### Responsive Görünümler
#### Desktop (4 kolon)
![Desktop Görünümü](../screenshots/payments/payments-list-desktop.png)

#### Tablet (3 kolon)
![Tablet Görünümü](../screenshots/payments/payments-list-tablet.png)

#### Mobile (Liste görünümü)
![Mobile Görünümü](../screenshots/payments/payments-list-mobile.png)
```

## 🔧 Otomatikleştirme Script'i

### Bash Script ile Ekran Görüntüsü Alma (macOS)
```bash
#!/bin/bash
# save-screenshot.sh

MODULE=$1
SCREEN_NAME=$2
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Screenshots klasörünü oluştur
mkdir -p "docs/screenshots/$MODULE"

# Ekran görüntüsü al (macOS)
screencapture -i "docs/screenshots/$MODULE/$SCREEN_NAME-$TIMESTAMP.png"

echo "✅ Screenshot saved: docs/screenshots/$MODULE/$SCREEN_NAME-$TIMESTAMP.png"
```

Kullanım:
```bash
chmod +x save-screenshot.sh
./save-screenshot.sh payments payment-form
```

## 📱 Farklı Cihaz Boyutları için Ekran Görüntüsü

### Chrome DevTools Device Sizes
1. DevTools'u açın (F12)
2. Device Toolbar'ı aktif edin
3. Şu boyutları kullanın:
   - **Mobile**: 375x667 (iPhone SE)
   - **Tablet**: 768x1024 (iPad)
   - **Desktop**: 1920x1080

### Flutter Web için Responsive Test
```dart
// test_responsive.dart
void main() {
  // Farklı ekran boyutlarında test
  testWidgets('Payments page responsive', (tester) async {
    // Mobile
    await tester.binding.setSurfaceSize(const Size(375, 667));
    await tester.pumpWidget(const PaymentsPage());
    await expectLater(find.byType(PaymentsPage), matchesGoldenFile('payments-mobile.png'));
    
    // Tablet
    await tester.binding.setSurfaceSize(const Size(768, 1024));
    await tester.pumpWidget(const PaymentsPage());
    await expectLater(find.byType(PaymentsPage), matchesGoldenFile('payments-tablet.png'));
    
    // Desktop
    await tester.binding.setSurfaceSize(const Size(1920, 1080));
    await tester.pumpWidget(const PaymentsPage());
    await expectLater(find.byType(PaymentsPage), matchesGoldenFile('payments-desktop.png'));
  });
}
```

## 🎯 Best Practices

1. **Tutarlılık**: Tüm ekran görüntülerinde aynı cihaz boyutunu kullanın
2. **Kalite**: Yüksek çözünürlükte alın, sonra optimize edin
3. **İsimlendirme**: Açıklayıcı ve tutarlı dosya isimleri kullanın
4. **Organizasyon**: Modül bazlı klasör yapısı kullanın
5. **Güncellik**: Ekran görüntülerini düzenli olarak güncelleyin
6. **Alt Text**: Markdown'da her görüntüye açıklayıcı alt text ekleyin

## 🚀 Hızlı Başlangıç Checklist

- [ ] `docs/screenshots/` klasörünü oluşturun
- [ ] Her modül için alt klasör oluşturun
- [ ] Uygulamayı çalıştırın (`flutter run -d chrome`)
- [ ] İlk ekran görüntüsünü alın
- [ ] Markdown dosyasına ekleyin
- [ ] Test edin (GitHub'da görüntüleniyor mu?)

## 📚 Ek Kaynaklar

- [Flutter Screenshot Package](https://pub.dev/packages/screenshot)
- [Mermaid Diagram Support](https://mermaid.js.org/) (GitHub'da otomatik desteklenir)
- [Image Optimization Tools](https://imageoptim.com/)
- [Markdown Image Syntax](https://www.markdownguide.org/basic-syntax/#images)

