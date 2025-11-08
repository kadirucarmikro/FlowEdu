-- FlowEdu - Raporlar Ekranını Veritabanından Kaldırma Scripti
-- Bu script, screens tablosundan Raporlar ekranını siler
-- Kullanım: Supabase SQL Editor'da çalıştırın

-- ============================================
-- RAPORLAR EKRANINI SİL
-- ============================================

-- Önce permissions tablosundan ilgili yetkileri sil
DELETE FROM public.permissions
WHERE screen_id IN (
  SELECT id FROM public.screens WHERE route = '/reports'
);

-- Sonra screens tablosundan Raporlar ekranını sil
DELETE FROM public.screens
WHERE route = '/reports' OR name = 'Raporlar';

-- ============================================
-- KONTROL SORGUSU
-- ============================================

-- Kalan screens'leri göster
SELECT 
  id,
  name,
  route,
  is_active,
  created_at
FROM public.screens
ORDER BY sort_order, name;

-- Raporlar ekranının silindiğini doğrula
SELECT 
  CASE 
    WHEN COUNT(*) = 0 THEN '✅ Raporlar ekranı başarıyla silindi'
    ELSE '❌ Raporlar ekranı hala mevcut: ' || COUNT(*)::text || ' kayıt'
  END as result
FROM public.screens
WHERE route = '/reports' OR name = 'Raporlar';

SELECT '✅ Raporlar ekranı ve ilgili yetkiler temizlendi!' as result;

