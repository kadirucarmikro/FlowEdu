#!/usr/bin/env dart
// Otomatik dokümantasyon güncelleme scripti
// Kullanım: dart scripts/update_docs.dart

import 'dart:io';

void main() async {
  print('📚 Dokümantasyon güncelleme başlatılıyor...\n');

  final projectRoot = Directory.current;
  final featuresDir = Directory('${projectRoot.path}/lib/features');
  final docsModulesDir = Directory('${projectRoot.path}/docs/modules');
  final readmeFile = File('${projectRoot.path}/README.md');

  // 1. Gereksiz markdown dosyalarını temizle
  await _cleanupUnnecessaryMarkdownFiles(projectRoot);

  // 2. Modül dokümantasyonlarını güncelle
  await _updateModuleDocumentation(featuresDir, docsModulesDir);

  // 3. README.md'yi güncelle
  await _updateReadme(readmeFile, docsModulesDir);

  print('\n✅ Dokümantasyon güncelleme tamamlandı!');
}

Future<void> _cleanupUnnecessaryMarkdownFiles(Directory projectRoot) async {
  print('🧹 Gereksiz markdown dosyaları temizleniyor...');

  final unnecessaryFiles = [
    'ALTERNATIVE_ENGINE_DISPOSAL_SOLUTION.md',
    'ENGINE_DISPOSAL_FIXES.md',
  ];

  for (final fileName in unnecessaryFiles) {
    final file = File('${projectRoot.path}/$fileName');
    if (await file.exists()) {
      await file.delete();
      print('  ❌ Silindi: $fileName');
    }
  }
}

Future<void> _updateModuleDocumentation(
  Directory featuresDir,
  Directory docsModulesDir,
) async {
  print('\n📝 Modül dokümantasyonları güncelleniyor...');

  if (!await featuresDir.exists()) {
    print('  ⚠️  lib/features klasörü bulunamadı!');
    return;
  }

  // docs/modules klasörünü oluştur
  if (!await docsModulesDir.exists()) {
    await docsModulesDir.create(recursive: true);
    print('  📁 docs/modules klasörü oluşturuldu');
  }

  // Tüm modülleri tara
  final modules = await _scanModules(featuresDir);
  print('  📦 ${modules.length} modül bulundu');

  // Her modül için dokümantasyon kontrolü
  for (final module in modules) {
    final docFile = File('${docsModulesDir.path}/${module.toLowerCase()}.md');
    if (!await docFile.exists()) {
      print('  ➕ Yeni dokümantasyon oluşturuluyor: ${module.toLowerCase()}.md');
      await _createModuleDocumentation(docFile, module);
    } else {
      print('  ✓ Mevcut: ${module.toLowerCase()}.md');
    }
  }
}

Future<List<String>> _scanModules(Directory featuresDir) async {
  final modules = <String>[];

  if (!await featuresDir.exists()) {
    return modules;
  }

  await for (final entity in featuresDir.list()) {
    if (entity is Directory) {
      final moduleName = entity.path.split('/').last;
      // Boş klasörleri ve özel klasörleri atla
      if (moduleName != 'admin' && moduleName != 'instructors') {
        modules.add(moduleName);
      }
    }
  }

  return modules;
}

Future<void> _createModuleDocumentation(File docFile, String moduleName) async {
  final moduleTitle = _toTitleCase(moduleName);
  final content = '''# $moduleTitle Modülü

## Genel Bakış
$moduleTitle modülü hakkında genel bilgiler.

## Özellikler
- ✅ CRUD işlemleri
- ✅ Responsive tasarım
- ✅ RLS politikaları

## Mimari Yapı

### Domain Layer
- **Entities**: Entity tanımları
- **Repositories**: Repository interface'leri
- **Use Cases**: Use case'ler

### Data Layer
- **Data Sources**: Supabase entegrasyonu
- **Models**: DTO modelleri
- **Repositories**: Repository implementasyonları

### Presentation Layer
- **Pages**: Sayfa widget'ları
- **Widgets**: UI bileşenleri
- **Providers**: Riverpod provider'ları

## Kullanım

### Veri Getirme
\`\`\`dart
final dataAsync = ref.watch(dataProvider);
\`\`\`

## Veritabanı Yapısı
- **Tablo**: \`${moduleName.toLowerCase()}\`
- **Kolonlar**: Tablo kolonları

## Yetkilendirme
- **Admin**: Tüm işlemleri yapabilir
- **Member**: Sınırlı erişim

## RLS Politikaları
- RLS politikaları açıklaması
''';

  await docFile.writeAsString(content);
}

Future<void> _updateReadme(File readmeFile, Directory docsModulesDir) async {
  print('\n📄 README.md güncelleniyor...');

  if (!await readmeFile.exists()) {
    print('  ⚠️  README.md bulunamadı!');
    return;
  }

  final content = await readmeFile.readAsString();

  // Dokümantasyon bölümü var mı kontrol et
  if (content.contains('## Dokümantasyon')) {
    print('  ✓ Dokümantasyon bölümü mevcut');
    // Mevcut bölümü güncelle
    final updatedContent = await _updateDocumentationSection(
      content,
      docsModulesDir,
    );
    await readmeFile.writeAsString(updatedContent);
    print('  ✓ README.md güncellendi');
  } else {
    // Dokümantasyon bölümü ekle
    final modules = await _getModuleList(docsModulesDir);
    final docSection = _generateDocumentationSection(modules);
    final updatedContent = content + '\n\n$docSection';
    await readmeFile.writeAsString(updatedContent);
    print('  ➕ Dokümantasyon bölümü eklendi');
  }
}

Future<String> _updateDocumentationSection(
  String content,
  Directory docsModulesDir,
) async {
  final modules = await _getModuleList(docsModulesDir);
  final docSection = _generateDocumentationSection(modules);

  // Mevcut dokümantasyon bölümünü bul ve değiştir
  final startMarker = '## Dokümantasyon';
  final endMarker = RegExp(r'\n## [^#]|\n$');

  final startIndex = content.indexOf(startMarker);
  if (startIndex == -1) {
    return content + '\n\n$docSection';
  }

  final beforeSection = content.substring(0, startIndex);
  final afterMatch = endMarker.firstMatch(content.substring(startIndex + startMarker.length));
  final afterSection = afterMatch != null
      ? content.substring(startIndex + startMarker.length + afterMatch.start)
      : '';

  return beforeSection + docSection + afterSection;
}

Future<List<String>> _getModuleList(Directory docsModulesDir) async {
  final modules = <String>[];

  if (!await docsModulesDir.exists()) {
    return modules;
  }

  await for (final entity in docsModulesDir.list()) {
    if (entity is File && entity.path.endsWith('.md')) {
      final fileName = entity.path.split('/').last;
      final moduleName = fileName.replaceAll('.md', '');
      modules.add(moduleName);
    }
  }

  modules.sort();
  return modules;
}

String _generateDocumentationSection(List<String> modules) {
  final buffer = StringBuffer();
  buffer.writeln('## Dokümantasyon');
  buffer.writeln();
  buffer.writeln('### Modül Dokümantasyonları');

  // Modül isimlerini düzenle
  final moduleNames = {
    'auth': 'Kimlik Doğrulama (Auth)',
    'roles': 'Roller (Roles)',
    'groups': 'Gruplar (Groups)',
    'screens': 'Ekranlar (Screens)',
    'members': 'Üyeler (Members)',
    'notifications': 'Bildirimler (Notifications)',
    'events': 'Etkinlikler (Events)',
    'payments': 'Ödemeler (Payments)',
    'about': 'Hakkımızda (About)',
    'lesson_schedules': 'Ders Programları (Lesson Schedules)',
    'rooms': 'Odalar (Rooms)',
  };

  for (final module in modules) {
    final displayName = moduleNames[module] ?? _toTitleCase(module);
    buffer.writeln('- [$displayName](docs/modules/$module.md)');
  }

  buffer.writeln();
  buffer.writeln('### Geliştirme Rehberleri');
  buffer.writeln('- [Yeni Sayfa Ekleme Rehberi](docs/yeni-sayfa-ekleme-rehberi.md)');
  buffer.writeln('- [Teknik Analiz](docs/teknik-analiz.md)');
  buffer.writeln('- [Bildirim Sistemi Refactor](docs/notification-system-refactor.md)');
  buffer.writeln();
  buffer.writeln('### Geliştirme Kuralları');
  buffer.writeln('- [Genel Geliştirme Kuralları](docs/rules/general-development-rules.md)');
  buffer.writeln('- [Etkinlikler Kuralları](docs/rules/events-rules.md)');
  buffer.writeln('- [Bildirimler Kuralları](docs/rules/notifications-rules.md)');
  buffer.writeln('- [Ödemeler Kuralları](docs/rules/payments-rules.md)');

  return buffer.toString();
}

String _toTitleCase(String text) {
  if (text.isEmpty) return text;
  return text
      .split('_')
      .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
      .join(' ');
}

