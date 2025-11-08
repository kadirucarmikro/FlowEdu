-- FlowEdu - Auth Users ve İlişkili Veriler Ekleme Scripti
-- Bu script auth.users tablosuna kullanıcı ekler ve members, admins, events, vb. tablolara veri ekler
-- ÖNEMLİ: Bu script Supabase SQL Editor'da çalıştırılmalıdır
-- ÖNEMLİ: Önce delete-all-data.sql ve seed-sample-data.sql scriptlerini çalıştırın!
--
-- ⚠️  UYARI: Bu script auth.users tablosuna doğrudan erişim sağlar.
--     Güvenlik nedeniyle, production ortamında kullanmadan önce dikkatli olun!
--     Alternatif olarak, Supabase Auth API'sini kullanabilirsiniz (Flutter script).
--
-- 📝 NOT: Supabase'de auth.users tablosuna doğrudan INSERT yapmak için
--     özel izinler gerekebilir. Eğer hata alırsanız, Supabase Dashboard'dan
--     "Enable Database Extensions" ve "Enable Auth" ayarlarını kontrol edin.

-- ============================================
-- 0. HELPER FONKSİYONLAR
-- ============================================

-- Kullanıcı oluşturma fonksiyonu (Supabase auth.users için)
-- NOT: Bu fonksiyon auth.users tablosuna doğrudan erişim sağlar
CREATE OR REPLACE FUNCTION create_auth_user(
  email text,
  password text,
  user_metadata jsonb DEFAULT '{}'::jsonb
) RETURNS uuid AS $$
DECLARE
  user_id uuid;
  encrypted_password text;
BEGIN
  -- Şifreyi hash'le (bcrypt)
  encrypted_password := crypt(password, gen_salt('bf'));
  
  -- auth.users tablosuna kullanıcı ekle
  INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    recovery_sent_at,
    last_sign_in_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    email_change,
    email_change_token_new,
    recovery_token
  ) VALUES (
    '00000000-0000-0000-0000-000000000000'::uuid,
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    email,
    encrypted_password,
    now(),
    NULL,
    NULL,
    '{"provider":"email","providers":["email"]}'::jsonb,
    user_metadata,
    now(),
    now(),
    '',
    '',
    '',
    ''
  ) RETURNING id INTO user_id;
  
  RETURN user_id;
EXCEPTION
  WHEN unique_violation THEN
    -- Kullanıcı zaten varsa, mevcut kullanıcının ID'sini döndür
    SELECT id INTO user_id FROM auth.users WHERE email = create_auth_user.email LIMIT 1;
    RETURN user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 1. ADMIN KULLANICILARI
-- ============================================

DO $$
DECLARE
  admin_user_id_1 uuid;
  admin_user_id_2 uuid;
  admin_role_id uuid;
BEGIN
  -- Admin rolünü bul
  SELECT id INTO admin_role_id FROM public.roles WHERE name = 'Admin' LIMIT 1;
  
  IF admin_role_id IS NULL THEN
    RAISE EXCEPTION 'Admin rolü bulunamadı! Önce seed-sample-data.sql scriptini çalıştırın.';
  END IF;

  -- Admin 1: Ahmet Yönetim (SuperAdmin)
  BEGIN
    admin_user_id_1 := create_auth_user(
      'admin@flowedu.com',
      'admin123456',
      '{"first_name":"Ahmet","last_name":"Yönetim"}'::jsonb
    );
    
    -- admins tablosuna ekle
    INSERT INTO public.admins (user_id, is_superadmin, created_at)
    VALUES (admin_user_id_1, true, now())
    ON CONFLICT (user_id) DO UPDATE SET is_superadmin = true;
    
    -- members tablosuna ekle
    INSERT INTO public.members (user_id, role_id, email, first_name, last_name, is_suspended, created_at)
    VALUES (admin_user_id_1, admin_role_id, 'admin@flowedu.com', 'Ahmet', 'Yönetim', false, now())
    ON CONFLICT (user_id) DO UPDATE 
      SET role_id = admin_role_id, email = 'admin@flowedu.com', first_name = 'Ahmet', last_name = 'Yönetim';
    
    RAISE NOTICE '✅ Admin 1 (Ahmet Yönetim) eklendi';
  EXCEPTION
    WHEN OTHERS THEN
      RAISE NOTICE '⚠️  Admin 1 eklenirken hata: %', SQLERRM;
  END;

  -- Admin 2: Ayşe Yönetici (Normal Admin)
  BEGIN
    admin_user_id_2 := create_auth_user(
      'yonetim@flowedu.com',
      'yonetim123',
      '{"first_name":"Ayşe","last_name":"Yönetici"}'::jsonb
    );
    
    -- admins tablosuna ekle
    INSERT INTO public.admins (user_id, is_superadmin, created_at)
    VALUES (admin_user_id_2, false, now())
    ON CONFLICT (user_id) DO UPDATE SET is_superadmin = false;
    
    -- members tablosuna ekle
    INSERT INTO public.members (user_id, role_id, email, first_name, last_name, is_suspended, created_at)
    VALUES (admin_user_id_2, admin_role_id, 'yonetim@flowedu.com', 'Ayşe', 'Yönetici', false, now())
    ON CONFLICT (user_id) DO UPDATE 
      SET role_id = admin_role_id, email = 'yonetim@flowedu.com', first_name = 'Ayşe', last_name = 'Yönetici';
    
    RAISE NOTICE '✅ Admin 2 (Ayşe Yönetici) eklendi';
  EXCEPTION
    WHEN OTHERS THEN
      RAISE NOTICE '⚠️  Admin 2 eklenirken hata: %', SQLERRM;
  END;
END $$;

-- ============================================
-- 2. ÖRNEK ÜYELER (Tango Öğrencileri)
-- ============================================

DO $$
DECLARE
  member_user_id uuid;
  member_role_id uuid;
  group_ids uuid[];
  i integer;
BEGIN
  -- Member rolünü bul
  SELECT id INTO member_role_id FROM public.roles WHERE name = 'Member' LIMIT 1;
  
  IF member_role_id IS NULL THEN
    RAISE EXCEPTION 'Member rolü bulunamadı! Önce seed-sample-data.sql scriptini çalıştırın.';
  END IF;

  -- Grup ID'lerini al
  SELECT ARRAY_AGG(id) INTO group_ids 
  FROM (SELECT id FROM public.groups ORDER BY name LIMIT 10) sub;

  -- Örnek üyeler
  FOR i IN 1..15 LOOP
    BEGIN
      member_user_id := create_auth_user(
        'ogrenci' || i || '@flowedu.com',
        'ogrenci123',
        jsonb_build_object(
          'first_name', CASE i
            WHEN 1 THEN 'Mehmet'
            WHEN 2 THEN 'Zeynep'
            WHEN 3 THEN 'Can'
            WHEN 4 THEN 'Elif'
            WHEN 5 THEN 'Burak'
            WHEN 6 THEN 'Selin'
            WHEN 7 THEN 'Emre'
            WHEN 8 THEN 'Deniz'
            WHEN 9 THEN 'Kerem'
            WHEN 10 THEN 'Ayşe'
            WHEN 11 THEN 'Onur'
            WHEN 12 THEN 'Gizem'
            WHEN 13 THEN 'Fatih'
            WHEN 14 THEN 'Derya'
            WHEN 15 THEN 'Tolga'
            ELSE 'Öğrenci' || i
          END,
          'last_name', CASE i
            WHEN 1 THEN 'Kaya'
            WHEN 2 THEN 'Demir'
            WHEN 3 THEN 'Yılmaz'
            WHEN 4 THEN 'Şahin'
            WHEN 5 THEN 'Çelik'
            WHEN 6 THEN 'Arslan'
            WHEN 7 THEN 'Öztürk'
            WHEN 8 THEN 'Kılıç'
            WHEN 9 THEN 'Aydın'
            WHEN 10 THEN 'Doğan'
            WHEN 11 THEN 'Koç'
            WHEN 12 THEN 'Yıldız'
            WHEN 13 THEN 'Kurt'
            WHEN 14 THEN 'Aktaş'
            WHEN 15 THEN 'Şen'
            ELSE 'Soyadı' || i
          END
        )
      );
      
      -- members tablosuna ekle
      INSERT INTO public.members (
        user_id, role_id, email, first_name, last_name, phone, 
        group_id, birth_date, is_suspended, created_at
      ) VALUES (
        member_user_id,
        member_role_id,
        'ogrenci' || i || '@flowedu.com',
        CASE i
          WHEN 1 THEN 'Mehmet' WHEN 2 THEN 'Zeynep' WHEN 3 THEN 'Can'
          WHEN 4 THEN 'Elif' WHEN 5 THEN 'Burak' WHEN 6 THEN 'Selin'
          WHEN 7 THEN 'Emre' WHEN 8 THEN 'Deniz' WHEN 9 THEN 'Kerem'
          WHEN 10 THEN 'Ayşe' WHEN 11 THEN 'Onur' WHEN 12 THEN 'Gizem'
          WHEN 13 THEN 'Fatih' WHEN 14 THEN 'Derya' WHEN 15 THEN 'Tolga'
          ELSE 'Öğrenci' || i
        END,
        CASE i
          WHEN 1 THEN 'Kaya' WHEN 2 THEN 'Demir' WHEN 3 THEN 'Yılmaz'
          WHEN 4 THEN 'Şahin' WHEN 5 THEN 'Çelik' WHEN 6 THEN 'Arslan'
          WHEN 7 THEN 'Öztürk' WHEN 8 THEN 'Kılıç' WHEN 9 THEN 'Aydın'
          WHEN 10 THEN 'Doğan' WHEN 11 THEN 'Koç' WHEN 12 THEN 'Yıldız'
          WHEN 13 THEN 'Kurt' WHEN 14 THEN 'Aktaş' WHEN 15 THEN 'Şen'
          ELSE 'Soyadı' || i
        END,
        '055512345' || LPAD(i::text, 2, '0'),
        group_ids[((i - 1) % array_length(group_ids, 1)) + 1],
        (CURRENT_DATE - INTERVAL '20 years' - (i || ' days')::interval)::date,
        false,
        now()
      ) ON CONFLICT (user_id) DO NOTHING;
      
      RAISE NOTICE '✅ Öğrenci % eklendi', i;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE NOTICE '⚠️  Öğrenci % eklenirken hata: %', i, SQLERRM;
    END;
  END LOOP;
END $$;

-- ============================================
-- 3. ÖRNEK EĞİTMENLER
-- ============================================

DO $$
DECLARE
  instructor_user_id uuid;
  instructor_role_id uuid;
  group_ids uuid[];
  i integer;
BEGIN
  -- Instructor rolünü bul
  SELECT id INTO instructor_role_id FROM public.roles WHERE name = 'Instructor' LIMIT 1;
  
  IF instructor_role_id IS NULL THEN
    RAISE EXCEPTION 'Instructor rolü bulunamadı! Önce seed-sample-data.sql scriptini çalıştırın.';
  END IF;

  -- Grup ID'lerini al
  SELECT ARRAY_AGG(id) INTO group_ids 
  FROM (SELECT id FROM public.groups ORDER BY name LIMIT 10) sub;

  -- Örnek eğitmenler
  FOR i IN 1..6 LOOP
    BEGIN
      instructor_user_id := create_auth_user(
        'egitmen' || i || '@flowedu.com',
        'egitmen123',
        jsonb_build_object(
          'first_name', CASE i
            WHEN 1 THEN 'Carlos' WHEN 2 THEN 'Maria' WHEN 3 THEN 'Diego'
            WHEN 4 THEN 'Ana' WHEN 5 THEN 'Fernando' WHEN 6 THEN 'Lucia'
            ELSE 'Eğitmen' || i
          END,
          'last_name', CASE i
            WHEN 1 THEN 'Rodriguez' WHEN 2 THEN 'Garcia' WHEN 3 THEN 'Martinez'
            WHEN 4 THEN 'Lopez' WHEN 5 THEN 'Sanchez' WHEN 6 THEN 'Fernandez'
            ELSE 'Soyadı' || i
          END
        )
      );
      
      -- members tablosuna ekle
      INSERT INTO public.members (
        user_id, role_id, email, first_name, last_name, phone, 
        group_id, birth_date, is_suspended, created_at
      ) VALUES (
        instructor_user_id,
        instructor_role_id,
        'egitmen' || i || '@flowedu.com',
        CASE i
          WHEN 1 THEN 'Carlos' WHEN 2 THEN 'Maria' WHEN 3 THEN 'Diego'
          WHEN 4 THEN 'Ana' WHEN 5 THEN 'Fernando' WHEN 6 THEN 'Lucia'
          ELSE 'Eğitmen' || i
        END,
        CASE i
          WHEN 1 THEN 'Rodriguez' WHEN 2 THEN 'Garcia' WHEN 3 THEN 'Martinez'
          WHEN 4 THEN 'Lopez' WHEN 5 THEN 'Sanchez' WHEN 6 THEN 'Fernandez'
          ELSE 'Soyadı' || i
        END,
        '055598765' || LPAD(i::text, 2, '0'),
        group_ids[((i - 1) % array_length(group_ids, 1)) + 1],
        (CURRENT_DATE - INTERVAL '30 years' - (i || ' days')::interval)::date,
        false,
        now()
      ) ON CONFLICT (user_id) DO NOTHING;
      
      RAISE NOTICE '✅ Eğitmen % eklendi', i;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE NOTICE '⚠️  Eğitmen % eklenirken hata: %', i, SQLERRM;
    END;
  END LOOP;
END $$;

-- ============================================
-- 4. ÖRNEK ETKİNLİKLER
-- ============================================

DO $$
DECLARE
  admin_id uuid;
  event_id uuid;
BEGIN
  -- Bir admin ID'si al
  SELECT id INTO admin_id FROM public.admins LIMIT 1;
  
  IF admin_id IS NULL THEN
    RAISE EXCEPTION 'Admin bulunamadı! Önce admin kullanıcıları oluşturun.';
  END IF;

  -- Etkinlik 1: Milonga Gecesi
  INSERT INTO public.events (id, title, description, type, start_at, end_at, created_by, created_at)
  VALUES (
    gen_random_uuid(),
    'Milonga Gecesi - Aylık Tango Buluşması',
    'Her ayın son cuması düzenlenen geleneksel milonga gecemiz. Tüm seviyelerden tango severleri bir araya getiriyoruz. Canlı müzik eşliğinde dans edebilir, yeni insanlarla tanışabilirsiniz.',
    'normal',
    (CURRENT_DATE + INTERVAL '7 days' + INTERVAL '20 hours')::timestamptz,
    (CURRENT_DATE + INTERVAL '7 days' + INTERVAL '23 hours')::timestamptz,
    admin_id,
    now()
  ) ON CONFLICT DO NOTHING;

  -- Etkinlik 2: Tango Workshop
  INSERT INTO public.events (id, title, description, type, start_at, end_at, created_by, created_at)
  VALUES (
    gen_random_uuid(),
    'İleri Seviye Tango Workshop',
    'Deneyimli eğitmenlerimiz eşliğinde ileri seviye tango teknikleri üzerine yoğunlaşacağımız 3 saatlik workshop. Sınırlı kontenjan!',
    'interactive',
    (CURRENT_DATE + INTERVAL '14 days' + INTERVAL '14 hours')::timestamptz,
    (CURRENT_DATE + INTERVAL '14 days' + INTERVAL '17 hours')::timestamptz,
    admin_id,
    now()
  ) ON CONFLICT DO NOTHING;

  -- Etkinlik 3: Tango Semineri
  INSERT INTO public.events (id, title, description, type, start_at, end_at, created_by, created_at)
  VALUES (
    gen_random_uuid(),
    'Tango Tarihi ve Kültürü Semineri',
    'Arjantin tangosunun tarihsel gelişimi, kültürel önemi ve günümüze etkileri hakkında interaktif bir seminer.',
    'interactive',
    (CURRENT_DATE + INTERVAL '21 days' + INTERVAL '19 hours')::timestamptz,
    (CURRENT_DATE + INTERVAL '21 days' + INTERVAL '21 hours')::timestamptz,
    admin_id,
    now()
  ) ON CONFLICT DO NOTHING;

  -- Etkinlik 4: Yarışma Hazırlık
  INSERT INTO public.events (id, title, description, type, start_at, end_at, created_by, created_at)
  VALUES (
    gen_random_uuid(),
    'Uluslararası Tango Yarışması Hazırlık Programı',
    'Yarışmaya katılacak öğrencilerimiz için özel hazırlık programı. Teknik çalışmalar, koreografi ve performans ipuçları.',
    'normal',
    (CURRENT_DATE + INTERVAL '30 days' + INTERVAL '10 hours')::timestamptz,
    (CURRENT_DATE + INTERVAL '30 days' + INTERVAL '16 hours')::timestamptz,
    admin_id,
    now()
  ) ON CONFLICT DO NOTHING;

  -- Etkinlik 5: Yeni Başlayanlar Etkinliği
  INSERT INTO public.events (id, title, description, type, start_at, end_at, created_by, created_at)
  VALUES (
    gen_random_uuid(),
    'Yeni Başlayanlar Özel Etkinliği',
    'Tango dansına yeni başlayanlar için özel düzenlenen tanışma ve pratik etkinliği. Deneyimli eğitmenlerimiz eşliğinde temel adımları öğrenebilirsiniz.',
    'poll',
    (CURRENT_DATE + INTERVAL '10 days' + INTERVAL '18 hours')::timestamptz,
    (CURRENT_DATE + INTERVAL '10 days' + INTERVAL '20 hours')::timestamptz,
    admin_id,
    now()
  ) ON CONFLICT DO NOTHING;

  RAISE NOTICE '✅ 5 etkinlik eklendi';
END $$;

-- ============================================
-- 5. ÖRNEK BİLDİRİMLER
-- ============================================

-- Notification targets tablosunu oluştur (yeni şema ile - yoksa)
CREATE TABLE IF NOT EXISTS public.notification_targets (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    notification_id uuid NOT NULL REFERENCES public.notifications(id) ON DELETE CASCADE,
    target_type text NOT NULL, -- 'role', 'group', 'member', 'birthday'
    target_id uuid, -- role_id, group_id, member_id (birthday için null)
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    UNIQUE(notification_id, target_type, target_id)
);

DO $$
DECLARE
  admin_id uuid;
  group_id uuid;
  notification_id uuid;
  member_role_id uuid;
BEGIN
  -- Bir admin ID'si al
  SELECT id INTO admin_id FROM public.admins LIMIT 1;
  
  -- Bir grup ID'si al
  SELECT id INTO group_id FROM public.groups LIMIT 1;
  
  -- Member rolünü al (tüm üyelere göndermek için)
  SELECT id INTO member_role_id FROM public.roles WHERE name = 'Member' LIMIT 1;
  
  IF admin_id IS NULL THEN
    RAISE EXCEPTION 'Admin bulunamadı!';
  END IF;
  
  IF group_id IS NULL THEN
    RAISE EXCEPTION 'Grup bulunamadı!';
  END IF;

  -- Bildirim 1: Hoş Geldiniz
  INSERT INTO public.notifications (id, title, body, created_by, created_at)
  VALUES (
    gen_random_uuid(),
    'Hoş Geldiniz - FlowEdu Tango Dans Okulu',
    'FlowEdu Tango Dans Okuluna hoş geldiniz! Tango dansının büyülü dünyasını keşfetmeye hazır mısınız? Ders programlarımızı inceleyebilir, etkinliklerimize katılabilirsiniz.',
    admin_id,
    now()
  ) RETURNING id INTO notification_id;
  
  -- Grup hedefleme ekle
  INSERT INTO public.notification_targets (notification_id, target_type, target_id)
  VALUES (notification_id, 'group', group_id)
  ON CONFLICT DO NOTHING;

  -- Bildirim 2: Ders Programı Hatırlatması
  INSERT INTO public.notifications (id, title, body, created_by, created_at)
  VALUES (
    gen_random_uuid(),
    'Ders Programınız Hazır',
    'Sevgili öğrencilerimiz, bu haftanın ders programı hazırlandı. Derslerinize zamanında katılmanızı rica ederiz.',
    admin_id,
    now()
  ) RETURNING id INTO notification_id;
  
  -- Grup hedefleme ekle
  INSERT INTO public.notification_targets (notification_id, target_type, target_id)
  VALUES (notification_id, 'group', group_id)
  ON CONFLICT DO NOTHING;

  -- Bildirim 3: Etkinlik Duyurusu
  INSERT INTO public.notifications (id, title, body, created_by, created_at)
  VALUES (
    gen_random_uuid(),
    'Yaklaşan Etkinlik: Milonga Gecesi',
    'Bu ayın son cuması geleneksel milonga gecemiz var! Tüm öğrencilerimizi bekliyoruz. Katılmak ister misiniz?',
    admin_id,
    now()
  ) RETURNING id INTO notification_id;
  
  -- Grup hedefleme ekle
  INSERT INTO public.notification_targets (notification_id, target_type, target_id)
  VALUES (notification_id, 'group', group_id)
  ON CONFLICT DO NOTHING;

  -- Bildirim 4: Ödeme Hatırlatması
  INSERT INTO public.notifications (id, title, body, created_by, created_at)
  VALUES (
    gen_random_uuid(),
    'Ödeme Hatırlatması',
    'Sevgili öğrencilerimiz, ödemenizin yakında sona ereceğini hatırlatırız. Lütfen zamanında ödemenizi yapınız.',
    admin_id,
    now()
  ) RETURNING id INTO notification_id;
  
  -- Grup hedefleme ekle
  INSERT INTO public.notification_targets (notification_id, target_type, target_id)
  VALUES (notification_id, 'group', group_id)
  ON CONFLICT DO NOTHING;

  RAISE NOTICE '✅ 4 bildirim eklendi';
END $$;

-- ============================================
-- 6. ÖRNEK ÖDEMELER
-- ============================================

DO $$
DECLARE
  member_ids uuid[];
  package_ids uuid[];
  i integer;
  member_id uuid;
  package_id uuid;
BEGIN
  -- Member ID'lerini al
  SELECT ARRAY_AGG(id) INTO member_ids 
  FROM (SELECT id FROM public.members WHERE role_id = (SELECT id FROM public.roles WHERE name = 'Member' LIMIT 1) LIMIT 15) sub;
  
  -- Package ID'lerini al
  SELECT ARRAY_AGG(id) INTO package_ids 
  FROM (SELECT id FROM public.lesson_packages LIMIT 10) sub;
  
  IF array_length(member_ids, 1) IS NULL OR array_length(package_ids, 1) IS NULL THEN
    RAISE EXCEPTION 'Member veya Package bulunamadı!';
  END IF;

  -- Her üye için bir ödeme oluştur
  FOR i IN 1..LEAST(15, array_length(member_ids, 1)) LOOP
    member_id := member_ids[i];
    package_id := package_ids[((i - 1) % array_length(package_ids, 1)) + 1];
    
    INSERT INTO public.payments (
      id, member_id, package_id, amount, discount_amount, status, 
      due_date, paid_at, created_at
    ) VALUES (
      gen_random_uuid(),
      member_id,
      package_id,
      (500.00 + (i * 50.00))::numeric(10,2),
      CASE WHEN i % 3 = 0 THEN (50.00)::numeric(10,2) ELSE 0::numeric(10,2) END,
      CASE (i % 3)
        WHEN 0 THEN 'paid'
        WHEN 1 THEN 'pending'
        ELSE 'paid'
      END::payment_status,
      (CURRENT_DATE + INTERVAL '30 days')::date,
      CASE WHEN i % 3 = 0 THEN now() ELSE NULL END,
      now()
    ) ON CONFLICT DO NOTHING;
  END LOOP;

  RAISE NOTICE '✅ % ödeme eklendi', LEAST(15, array_length(member_ids, 1));
END $$;

-- ============================================
-- 7. ÖRNEK DERS PROGRAMLARI
-- ============================================

DO $$
DECLARE
  package_ids uuid[];
  room_ids uuid[];
  member_ids uuid[];
  i integer;
  j integer;
  package_id uuid;
  room_id uuid;
  member_id uuid;
  lesson_date date;
BEGIN
  -- Package ID'lerini al
  SELECT ARRAY_AGG(id) INTO package_ids 
  FROM (SELECT id FROM public.lesson_packages LIMIT 10) sub;
  
  -- Room ID'lerini al
  SELECT ARRAY_AGG(id) INTO room_ids 
  FROM (SELECT id FROM public.rooms LIMIT 8) sub;
  
  -- Member ID'lerini al
  SELECT ARRAY_AGG(id) INTO member_ids 
  FROM (SELECT id FROM public.members WHERE role_id = (SELECT id FROM public.roles WHERE name = 'Member' LIMIT 1) LIMIT 15) sub;
  
  IF array_length(package_ids, 1) IS NULL OR array_length(room_ids, 1) IS NULL THEN
    RAISE EXCEPTION 'Package veya Room bulunamadı!';
  END IF;

  -- Her paket için 4-6 ders programı oluştur
  FOR i IN 1..LEAST(10, array_length(package_ids, 1)) LOOP
    package_id := package_ids[i];
    room_id := room_ids[((i - 1) % array_length(room_ids, 1)) + 1];
    member_id := member_ids[((i - 1) % array_length(member_ids, 1)) + 1];
    
    -- Her paket için 4-6 ders oluştur
    FOR j IN 1..(4 + (i % 3)) LOOP
      lesson_date := (CURRENT_DATE + INTERVAL '7 days' + (j || ' days')::interval)::date;
      
      INSERT INTO public.lesson_schedules (
        id, package_id, room_id, day_of_week, start_time, end_time, 
        lesson_number, total_lessons, status, 
        actual_date_day, actual_date_month, actual_date_year,
        created_at
      ) VALUES (
        gen_random_uuid(),
        package_id,
        room_id,
        CASE EXTRACT(DOW FROM lesson_date)
          WHEN 0 THEN 'Sunday'
          WHEN 1 THEN 'Monday'
          WHEN 2 THEN 'Tuesday'
          WHEN 3 THEN 'Wednesday'
          WHEN 4 THEN 'Thursday'
          WHEN 5 THEN 'Friday'
          WHEN 6 THEN 'Saturday'
        END, -- day_of_week
        '19:00:00'::time,
        '20:30:00'::time,
        j, -- lesson_number
        (4 + (i % 3)), -- total_lessons
        'scheduled', -- status
        EXTRACT(DAY FROM lesson_date)::integer, -- actual_date_day
        EXTRACT(MONTH FROM lesson_date)::integer, -- actual_date_month
        EXTRACT(YEAR FROM lesson_date)::integer, -- actual_date_year
        now()
      ) ON CONFLICT DO NOTHING;
    END LOOP;
  END LOOP;

  RAISE NOTICE '✅ Ders programları eklendi';
END $$;

-- ============================================
-- 8. TEMİZLİK: HELPER FONKSİYONU KALDIR (İsteğe Bağlı)
-- ============================================

-- Güvenlik nedeniyle helper fonksiyonu kaldırmak isteyebilirsiniz
-- DROP FUNCTION IF EXISTS create_auth_user(text, text, jsonb);

SELECT '✅ Tüm auth.users ve ilişkili veriler başarıyla eklendi!' as result;

