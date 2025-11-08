# Dokümantasyon Scriptleri

Bu klasörde otomatik dokümantasyon güncelleme scriptleri bulunur.

## Scriptler

### update_docs.dart
Ana dokümantasyon güncelleme scripti. Şunları yapar:
- Gereksiz markdown dosyalarını temizler
- Yeni modüller için dokümantasyon oluşturur
- README.md'yi günceller

**Kullanım:**
```bash
dart scripts/update_docs.dart
```

### watch_docs.sh
Dosya değişikliklerini izleyerek otomatik dokümantasyon güncelleme yapar.

**Kullanım:**
```bash
chmod +x scripts/watch_docs.sh
./scripts/watch_docs.sh
```

**Gereksinimler:**
- macOS: `brew install fswatch`
- Linux: `sudo apt-get install inotify-tools`

## Otomatik Çalıştırma

### Git Hooks (Önerilen)
Git hooks kullanarak commit öncesi otomatik güncelleme yapabilirsiniz:

```bash
# .git/hooks/pre-commit dosyası oluştur
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
dart scripts/update_docs.dart
git add README.md docs/modules/
EOF

chmod +x .git/hooks/pre-commit
```

### VS Code Task
`.vscode/tasks.json` dosyasına ekleyin:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Update Documentation",
      "type": "shell",
      "command": "dart scripts/update_docs.dart",
      "problemMatcher": []
    }
  ]
}
```

### Crontab (Linux/macOS)
Her saat başı çalıştırmak için:

```bash
# crontab -e
0 * * * * cd /path/to/FlowEdu && dart scripts/update_docs.dart
```

## Manuel Çalıştırma

Proje kök dizininde:
```bash
dart scripts/update_docs.dart
```

## Notlar

- Script, `lib/features` klasöründeki tüm modülleri tarar
- Yeni modüller için otomatik dokümantasyon şablonu oluşturur
- README.md'deki dokümantasyon bölümünü günceller
- Gereksiz markdown dosyalarını temizler

