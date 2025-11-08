import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Bu script Material Icons school ikonunu favicon olarak oluşturur
/// Çalıştırmak için: flutter run -d chrome lib/scripts/generate_favicon.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Favicon boyutları
  const sizes = [16, 32, 48, 64, 128, 192, 512];
  
  for (final size in sizes) {
    await _generateFavicon(size);
  }
  
  print('Favicon dosyaları oluşturuldu!');
}

Future<void> _generateFavicon(int size) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  
  // Tango kırmızı arka plan
  final paint = Paint()
    ..color = const Color(0xFFC41E3A)
    ..style = PaintingStyle.fill;
  canvas.drawRect(Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()), paint);
  
  // School ikonunu çiz
  final iconPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;
  
  // Material Icons school ikonunu basitleştirilmiş şekilde çiz
  // Bu basit bir okul binası şekli
  final iconSize = size * 0.6;
  final iconX = (size - iconSize) / 2;
  final iconY = (size - iconSize) / 2;
  
  // Okul binası çatısı (üçgen)
  final path = Path();
  path.moveTo(iconX + iconSize / 2, iconY);
  path.lineTo(iconX, iconY + iconSize * 0.3);
  path.lineTo(iconX + iconSize, iconY + iconSize * 0.3);
  path.close();
  canvas.drawPath(path, iconPaint);
  
  // Okul binası gövdesi (dikdörtgen)
  canvas.drawRect(
    Rect.fromLTWH(
      iconX + iconSize * 0.15,
      iconY + iconSize * 0.3,
      iconSize * 0.7,
      iconSize * 0.5,
    ),
    iconPaint,
  );
  
  // Kapı
  canvas.drawRect(
    Rect.fromLTWH(
      iconX + iconSize * 0.35,
      iconY + iconSize * 0.5,
      iconSize * 0.3,
      iconSize * 0.3,
    ),
    paint, // Kırmızı kapı
  );
  
  // Pencere (sol)
  canvas.drawRect(
    Rect.fromLTWH(
      iconX + iconSize * 0.2,
      iconY + iconSize * 0.4,
      iconSize * 0.15,
      iconSize * 0.15,
    ),
    paint, // Kırmızı pencere
  );
  
  // Pencere (sağ)
  canvas.drawRect(
    Rect.fromLTWH(
      iconX + iconSize * 0.65,
      iconY + iconSize * 0.4,
      iconSize * 0.15,
      iconSize * 0.15,
    ),
    paint, // Kırmızı pencere
  );
  
  final picture = recorder.endRecording();
  final image = await picture.toImage(size, size);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final bytes = byteData!.buffer.asUint8List();
  
  // Dosyayı kaydet
  final file = File('web/favicon.png');
  if (size == 32) {
    // 32x32 boyutunu favicon.png olarak kaydet
    await file.writeAsBytes(bytes);
  }
  
  // Diğer boyutları icons klasörüne kaydet
  if (size >= 192) {
    final iconFile = File('web/icons/Icon-$size.png');
    await iconFile.writeAsBytes(bytes);
    
    // Maskable versiyonu da oluştur
    final maskableFile = File('web/icons/Icon-maskable-$size.png');
    await maskableFile.writeAsBytes(bytes);
  }
  
  print('Favicon $size x $size oluşturuldu');
}

