-- FlowEdu - Ders Paketleri Fiyat Güncelleme Scripti
-- Bu script, lesson_packages tablosundaki tüm paketlerin fiyatlarını rastgele ama mantıklı değerlerle günceller
-- Kullanım: Supabase SQL Editor'da çalıştırın

-- ============================================
-- 1. PRICE KOLONUNU KONTROL ET VE EKLE
-- ============================================

-- Eğer price kolonu yoksa ekle
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_schema = 'public' 
      AND table_name = 'lesson_packages' 
      AND column_name = 'price'
  ) THEN
    ALTER TABLE public.lesson_packages 
    ADD COLUMN price numeric(10, 2) NOT NULL DEFAULT 0.00;
    
    RAISE NOTICE '✅ price kolonu eklendi';
  ELSE
    RAISE NOTICE 'ℹ️  price kolonu zaten mevcut';
  END IF;
END $$;

-- ============================================
-- 2. TÜM PAKETLERİN FİYATLARINI GÜNCELLE
-- ============================================

-- Tango Dans Okulu için rastgele ama mantıklı fiyatlandırma
-- Ders sayısına göre değişken fiyatlandırma (daha fazla ders = daha uygun ders başına fiyat)

UPDATE public.lesson_packages
SET price = CASE 
  -- 4 Derslik Deneme Paketi: 750-950 TL arası (187-237 TL/ders)
  WHEN lesson_count = 4 AND name LIKE '%Deneme%' THEN 
    (RANDOM() * 200 + 750)::numeric(10, 2)
  
  -- 4 Derslik Haftalık Pratik Paketi: 750-950 TL arası
  WHEN lesson_count = 4 AND name LIKE '%Pratik%' THEN 
    (RANDOM() * 200 + 750)::numeric(10, 2)
  
  -- 5 Derslik Bireysel Ders Paketi: 1800-2200 TL arası (360-440 TL/ders - bireysel daha pahalı)
  WHEN lesson_count = 5 AND name LIKE '%Bireysel%' THEN 
    (RANDOM() * 400 + 1800)::numeric(10, 2)
  
  -- 6 Derslik Workshop Paketi: 1100-1300 TL arası (183-216 TL/ders)
  WHEN lesson_count = 6 AND name LIKE '%Workshop%' THEN 
    (RANDOM() * 200 + 1100)::numeric(10, 2)
  
  -- 8 Derslik Başlangıç Paketi: 1300-1500 TL arası (162-187 TL/ders)
  WHEN lesson_count = 8 AND name LIKE '%Başlangıç%' THEN 
    (RANDOM() * 200 + 1300)::numeric(10, 2)
  
  -- 10 Derslik Bireysel Ders Paketi: 3200-3800 TL arası (320-380 TL/ders)
  WHEN lesson_count = 10 AND name LIKE '%Bireysel%' THEN 
    (RANDOM() * 600 + 3200)::numeric(10, 2)
  
  -- 12 Derslik Standart Paket: 1700-1900 TL arası (141-158 TL/ders)
  WHEN lesson_count = 12 AND name LIKE '%Standart%' THEN 
    (RANDOM() * 200 + 1700)::numeric(10, 2)
  
  -- 16 Derslik Yoğun Paket: 2100-2300 TL arası (131-143 TL/ders)
  WHEN lesson_count = 16 AND name LIKE '%Yoğun%' THEN 
    (RANDOM() * 200 + 2100)::numeric(10, 2)
  
  -- 20 Derslik Aylık Sınırsız Paket: 2400-2600 TL arası (120-130 TL/ders)
  WHEN lesson_count = 20 AND name LIKE '%Sınırsız%' THEN 
    (RANDOM() * 200 + 2400)::numeric(10, 2)
  
  -- 24 Derslik Yarışma Hazırlık Paketi: 3400-3800 TL arası (141-158 TL/ders)
  WHEN lesson_count = 24 AND name LIKE '%Yarışma%' THEN 
    (RANDOM() * 400 + 3400)::numeric(10, 2)
  
  -- Diğer paketler için ders sayısına göre otomatik hesaplama
  -- Temel fiyat: ders_sayısı * 200 TL, sonra rastgele %10-20 indirim
  ELSE 
    (lesson_count * 200.00 * (1 - (RANDOM() * 0.1 + 0.1)))::numeric(10, 2)
END
WHERE price IS NULL OR price = 0 OR price < 100;

-- Eğer yukarıdaki CASE yapısı çalışmazsa, tüm paketleri güncelle
-- (Rastgele fiyatlar ama mantıklı aralıklarda)
UPDATE public.lesson_packages
SET price = (
  CASE 
    WHEN lesson_count <= 4 THEN 
      (RANDOM() * 200 + 750)::numeric(10, 2)  -- 750-950 TL
    WHEN lesson_count <= 6 THEN 
      (RANDOM() * 300 + 1100)::numeric(10, 2)  -- 1100-1400 TL
    WHEN lesson_count <= 8 THEN 
      (RANDOM() * 200 + 1300)::numeric(10, 2)  -- 1300-1500 TL
    WHEN lesson_count <= 10 THEN 
      CASE 
        WHEN name LIKE '%Bireysel%' THEN 
          (RANDOM() * 600 + 3200)::numeric(10, 2)  -- 3200-3800 TL (bireysel daha pahalı)
        ELSE 
          (RANDOM() * 300 + 1500)::numeric(10, 2)  -- 1500-1800 TL
      END
    WHEN lesson_count <= 12 THEN 
      (RANDOM() * 200 + 1700)::numeric(10, 2)  -- 1700-1900 TL
    WHEN lesson_count <= 16 THEN 
      (RANDOM() * 200 + 2100)::numeric(10, 2)  -- 2100-2300 TL
    WHEN lesson_count <= 20 THEN 
      (RANDOM() * 200 + 2400)::numeric(10, 2)  -- 2400-2600 TL
    ELSE 
      (RANDOM() * 400 + 3400)::numeric(10, 2)  -- 3400-3800 TL (24+ ders)
  END
)
WHERE price IS NULL OR price = 0 OR price < 100;

-- ============================================
-- 3. FİYATLARI YUVARLA (2 ondalık basamak)
-- ============================================

UPDATE public.lesson_packages
SET price = ROUND(price, 2)
WHERE price IS NOT NULL;

-- ============================================
-- 4. KONTROL SORGUSU
-- ============================================

-- Tüm paketlerin fiyatlarını göster
SELECT 
  id,
  name,
  lesson_count,
  price,
  ROUND(price / NULLIF(lesson_count, 0), 2) as price_per_lesson,
  is_active,
  CASE 
    WHEN price > 0 AND price >= 100 THEN '✅ Fiyat Tanımlı'
    ELSE '❌ Fiyat Tanımlı Değil veya Çok Düşük'
  END as status
FROM public.lesson_packages
ORDER BY lesson_count, price;

-- Özet bilgi
SELECT 
  COUNT(*) as total_packages,
  COUNT(CASE WHEN price > 0 AND price >= 100 THEN 1 END) as packages_with_valid_price,
  COUNT(CASE WHEN price = 0 OR price < 100 THEN 1 END) as packages_without_valid_price,
  ROUND(AVG(price), 2) as average_price,
  ROUND(MIN(price), 2) as min_price,
  ROUND(MAX(price), 2) as max_price,
  ROUND(AVG(price / NULLIF(lesson_count, 0)), 2) as average_price_per_lesson
FROM public.lesson_packages;

-- Ders sayısına göre istatistikler
SELECT 
  lesson_count,
  COUNT(*) as package_count,
  ROUND(AVG(price), 2) as avg_price,
  ROUND(AVG(price / NULLIF(lesson_count, 0)), 2) as avg_price_per_lesson,
  ROUND(MIN(price), 2) as min_price,
  ROUND(MAX(price), 2) as max_price
FROM public.lesson_packages
GROUP BY lesson_count
ORDER BY lesson_count;

SELECT '✅ Tüm ders paketleri fiyatları rastgele değerlerle güncellendi!' as result;

