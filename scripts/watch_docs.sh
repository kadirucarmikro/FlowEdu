#!/bin/bash
# Dokümantasyon izleme scripti
# Kullanım: ./scripts/watch_docs.sh

echo "👀 Dokümantasyon izleme başlatılıyor..."
echo "📝 lib/features klasörü izleniyor..."
echo "🛑 Durdurmak için Ctrl+C tuşlarına basın"
echo ""

# macOS için fswatch, Linux için inotifywait kullan
if command -v fswatch &> /dev/null; then
    # macOS
    fswatch -o lib/features | while read f; do
        echo "🔄 Değişiklik tespit edildi, dokümantasyon güncelleniyor..."
        dart scripts/update_docs.dart
        echo ""
    done
elif command -v inotifywait &> /dev/null; then
    # Linux
    while inotifywait -r -e modify,create,delete lib/features; do
        echo "🔄 Değişiklik tespit edildi, dokümantasyon güncelleniyor..."
        dart scripts/update_docs.dart
        echo ""
    done
else
    echo "⚠️  fswatch veya inotifywait bulunamadı!"
    echo "📦 Kurulum:"
    echo "   macOS: brew install fswatch"
    echo "   Linux: sudo apt-get install inotify-tools"
    exit 1
fi

