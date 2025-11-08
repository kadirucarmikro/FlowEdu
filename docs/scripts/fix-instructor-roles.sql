-- FlowEdu - Eğitmen Rollerini Düzeltme Scripti
-- Bu script, Member rolündeki eğitmenlerin rollerini Instructor olarak günceller
-- Kullanım: Supabase SQL Editor'da çalıştırın

-- ============================================
-- EĞİTMEN ROLLERİNİ DÜZELT
-- ============================================

DO $$
DECLARE
  instructor_role_id uuid;
  member_role_id uuid;
  updated_count integer := 0;
BEGIN
  -- Instructor rolünü bul
  SELECT id INTO instructor_role_id FROM public.roles WHERE name = 'Instructor' LIMIT 1;
  
  -- Member rolünü bul (kontrol için)
  SELECT id INTO member_role_id FROM public.roles WHERE name = 'Member' LIMIT 1;
  
  IF instructor_role_id IS NULL THEN
    RAISE EXCEPTION 'Instructor rolü bulunamadı! Önce seed-sample-data.sql scriptini çalıştırın.';
  END IF;

  -- Eğitmen email'lerine sahip kullanıcıların rollerini Instructor olarak güncelle
  -- (egitmen1@flowedu.com - egitmen6@flowedu.com)
  UPDATE public.members
  SET role_id = instructor_role_id
  WHERE email LIKE 'egitmen%@flowedu.com'
    AND role_id != instructor_role_id;
  
  GET DIAGNOSTICS updated_count = ROW_COUNT;
  
  RAISE NOTICE '✅ % eğitmenin rolü Instructor olarak güncellendi', updated_count;
  
  -- is_instructor kolonu varsa ve false veya NULL olan eğitmenleri de güncelle
  -- (Kolon yoksa hata vermemesi için kontrol ediyoruz)
  BEGIN
    UPDATE public.members
    SET is_instructor = true
    WHERE email LIKE 'egitmen%@flowedu.com'
      AND (is_instructor = false OR is_instructor IS NULL);
    
    GET DIAGNOSTICS updated_count = ROW_COUNT;
    IF updated_count > 0 THEN
      RAISE NOTICE '✅ % eğitmenin is_instructor flagi true olarak güncellendi', updated_count;
    END IF;
  EXCEPTION
    WHEN undefined_column THEN
      RAISE NOTICE 'ℹ️  is_instructor kolonu bulunamadı, sadece rol güncellendi';
  END;
  
  RAISE NOTICE '';
  RAISE NOTICE '✅ Eğitmen rolleri güncellendi!';
END $$;

-- ============================================
-- KONTROL SORGUSU
-- ============================================

-- Tüm eğitmenlerin mevcut rollerini ve durumlarını göster
SELECT 
  m.email,
  m.first_name || ' ' || m.last_name as full_name,
  r.name as current_role,
  CASE 
    WHEN r.name = 'Instructor' THEN '✅ Doğru'
    ELSE '❌ Düzeltilmeli (Member rolünde)'
  END as status
FROM public.members m
JOIN public.roles r ON m.role_id = r.id
WHERE m.email LIKE 'egitmen%@flowedu.com'
ORDER BY m.email;

SELECT '✅ Eğitmen rolleri kontrol edildi ve güncellendi!' as result;
