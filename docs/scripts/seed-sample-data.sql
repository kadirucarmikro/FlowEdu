-- FlowEdu - Tango Dans Okulu Örnek Veri Ekleme Scripti
-- Bu script tüm tablolara tango dans okuluna uygun örnek veriler ekler
-- Önce delete-all-data.sql scriptini çalıştırın!

-- ============================================
-- 0. TABLO KONTROLÜ VE OLUŞTURMA (Gerekirse)
-- ============================================

-- Extension'ı etkinleştir
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================
-- 0.1. TEMEL TABLOLAR (Roles, Groups, Screens)
-- ============================================

-- Roles tablosunu oluştur (yoksa)
CREATE TABLE IF NOT EXISTS public.roles (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL UNIQUE,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamp with time zone NOT NULL DEFAULT now()
);

-- Groups tablosunu oluştur (yoksa)
CREATE TABLE IF NOT EXISTS public.groups (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL UNIQUE,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamp with time zone NOT NULL DEFAULT now()
);

-- Screens tablosunu oluştur (yoksa)
CREATE TABLE IF NOT EXISTS public.screens (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL UNIQUE,
    route text NOT NULL UNIQUE,
    description text,
    parent_module text,
    icon_name text DEFAULT 'info',
    required_permissions text[] DEFAULT ARRAY['read']::text[],
    is_active boolean DEFAULT TRUE,
    sort_order integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now()
);

-- ============================================
-- 0.2. PERMISSIONS TABLOSU
-- ============================================

-- Permissions tablosunu oluştur (yoksa)
CREATE TABLE IF NOT EXISTS public.permissions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    role_id uuid NOT NULL REFERENCES public.roles(id) ON DELETE CASCADE,
    screen_id uuid NOT NULL REFERENCES public.screens(id) ON DELETE CASCADE,
    can_create boolean DEFAULT FALSE,
    can_read boolean DEFAULT FALSE,
    can_update boolean DEFAULT FALSE,
    can_delete boolean DEFAULT FALSE,
    created_at timestamp with time zone DEFAULT now(),
    UNIQUE(role_id, screen_id)
);

-- Permissions tablosu için RLS politikalarını etkinleştir
DO $$ 
BEGIN
    -- RLS'yi etkinleştir (hata vermez, zaten etkinse)
    ALTER TABLE public.permissions ENABLE ROW LEVEL SECURITY;
    
    -- RLS politikalarını oluştur (yoksa)
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'permissions' 
        AND policyname = 'Permissions are viewable by authenticated users'
    ) THEN
        CREATE POLICY "Permissions are viewable by authenticated users" ON public.permissions
            FOR SELECT USING (auth.role() = 'authenticated');
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'permissions' 
        AND policyname = 'Permissions are manageable by admins'
    ) THEN
        CREATE POLICY "Permissions are manageable by admins" ON public.permissions
            FOR ALL USING (auth.role() = 'authenticated');
    END IF;
EXCEPTION
    WHEN undefined_table THEN
        -- Tablo yoksa sessizce devam et (CREATE TABLE IF NOT EXISTS zaten oluşturdu)
        NULL;
END $$;

-- ============================================
-- 1. ROLES (Roller)
-- ============================================
INSERT INTO public.roles (id, name, is_active, created_at) VALUES
('00000000-0000-0000-0000-000000000001', 'Admin', true, now()),
('00000000-0000-0000-0000-000000000002', 'SuperAdmin', true, now()),
('00000000-0000-0000-0000-000000000003', 'Member', true, now()),
('00000000-0000-0000-0000-000000000004', 'Instructor', true, now())
ON CONFLICT (name) DO NOTHING;

-- ============================================
-- 2. GROUPS (Tango Dans Grupları)
-- ============================================
INSERT INTO public.groups (id, name, is_active, created_at) VALUES
('00000000-0000-0000-0000-000000000101', 'Başlangıç Seviyesi Tango', true, now()),
('00000000-0000-0000-0000-000000000102', 'Orta Seviye Tango', true, now()),
('00000000-0000-0000-0000-000000000103', 'İleri Seviye Tango', true, now()),
('00000000-0000-0000-0000-000000000104', 'Milonga (Hızlı Tango)', true, now()),
('00000000-0000-0000-0000-000000000105', 'Tango Vals', true, now()),
('00000000-0000-0000-0000-000000000106', 'Pratik Seansları', true, now()),
('00000000-0000-0000-0000-000000000107', 'Yarışma Hazırlık Grubu', true, now()),
('00000000-0000-0000-0000-000000000108', 'Yetişkin Başlangıç', true, now()),
('00000000-0000-0000-0000-000000000109', 'Çift Dans Grubu', true, now()),
('00000000-0000-0000-0000-000000000110', 'Bireysel Dersler', true, now())
ON CONFLICT (name) DO NOTHING;

-- ============================================
-- 3. SCREENS (Ekranlar - Tüm Proje Ekranları)
-- ============================================
INSERT INTO public.screens (id, name, route, description, icon_name, sort_order, is_active, created_at) VALUES
-- Ana Modüller
('00000000-0000-0000-0000-000000000201', 'Üyelik', '/members', 'Üye yönetimi ve bilgileri', 'person', 1, true, now()),
('00000000-0000-0000-0000-000000000202', 'Admin Üyeler', '/admin-members', 'Admin üye yönetimi', 'admin_panel_settings', 2, true, now()),
('00000000-0000-0000-0000-000000000203', 'Roller', '/roles', 'Rol yönetimi ve yetkilendirme', 'badge', 3, true, now()),
('00000000-0000-0000-0000-000000000204', 'Gruplar', '/groups', 'Dans grupları yönetimi', 'group', 4, true, now()),
('00000000-0000-0000-0000-000000000205', 'Ekranlar', '/screens', 'Sistem ekranları yönetimi', 'screen_lock_portrait', 5, true, now()),

-- Ders ve Program Yönetimi
('00000000-0000-0000-0000-000000000206', 'Ders Programları', '/lesson-schedules', 'Ders programı görüntüleme ve yönetimi', 'calendar_today', 6, true, now()),
('00000000-0000-0000-0000-000000000207', 'Ders Detayı', '/lesson-schedules/:id', 'Ders detay sayfası', 'event_note', 7, true, now()),
('00000000-0000-0000-0000-000000000208', 'Yeni Ders Ekle', '/lesson-schedules/add', 'Yeni ders programı ekleme', 'add_circle', 8, true, now()),
('00000000-0000-0000-0000-000000000209', 'Ders Düzenle', '/lesson-schedules/:id/edit', 'Ders programı düzenleme', 'edit', 9, true, now()),

-- İçerik ve İletişim
('00000000-0000-0000-0000-000000000210', 'Bildirimler', '/notifications', 'Bildirim yönetimi ve görüntüleme', 'notifications', 10, true, now()),
('00000000-0000-0000-0000-000000000211', 'Etkinlikler', '/events', 'Tango etkinlikleri ve organizasyonlar', 'event', 11, true, now()),

-- Finansal İşlemler
('00000000-0000-0000-0000-000000000212', 'Ödemeler', '/payments', 'Ödeme takibi ve yönetimi', 'payment', 12, true, now()),
('00000000-0000-0000-0000-000000000213', 'Ders Paketleri', '/lesson-packages', 'Ders paketi yönetimi', 'inventory', 13, true, now()),

-- Bilgi ve Raporlama
('00000000-0000-0000-0000-000000000214', 'Hakkımızda', '/about', 'Okul hakkında bilgiler', 'info', 14, true, now()),

-- Fiziksel Kaynaklar
('00000000-0000-0000-0000-000000000216', 'Odalar', '/rooms', 'Dans salonları ve oda yönetimi', 'meeting_room', 16, true, now())
ON CONFLICT (name) DO NOTHING;

-- ============================================
-- 4. PERMISSIONS (Yetkilendirmeler)
-- ============================================
-- Admin için tüm ekranlara tam yetki
INSERT INTO public.permissions (id, role_id, screen_id, can_create, can_read, can_update, can_delete, created_at)
SELECT 
  gen_random_uuid(),
  '00000000-0000-0000-0000-000000000001'::uuid, -- Admin role
  s.id,
  true, true, true, true,
  now()
FROM public.screens s
ON CONFLICT (role_id, screen_id) DO NOTHING;

-- SuperAdmin için tüm ekranlara tam yetki
INSERT INTO public.permissions (id, role_id, screen_id, can_create, can_read, can_update, can_delete, created_at)
SELECT 
  gen_random_uuid(),
  '00000000-0000-0000-0000-000000000002'::uuid, -- SuperAdmin role
  s.id,
  true, true, true, true,
  now()
FROM public.screens s
ON CONFLICT (role_id, screen_id) DO NOTHING;

-- Member için sadece okuma yetkisi (belirli ekranlar)
INSERT INTO public.permissions (id, role_id, screen_id, can_create, can_read, can_update, can_delete, created_at)
SELECT 
  gen_random_uuid(),
  '00000000-0000-0000-0000-000000000003'::uuid, -- Member role
  s.id,
  false, true, false, false,
  now()
FROM public.screens s
WHERE s.name IN ('Üyelik', 'Ders Programları', 'Ders Detayı', 'Bildirimler', 'Etkinlikler', 'Hakkımızda', 'Odalar')
ON CONFLICT (role_id, screen_id) DO NOTHING;

-- Instructor için ders programları ve kendi bilgilerine yetki
INSERT INTO public.permissions (id, role_id, screen_id, can_create, can_read, can_update, can_delete, created_at)
SELECT 
  gen_random_uuid(),
  '00000000-0000-0000-0000-000000000004'::uuid, -- Instructor role
  s.id,
  CASE WHEN s.name IN ('Ders Programları', 'Yeni Ders Ekle', 'Ders Düzenle') THEN true ELSE false END,
  true,
  CASE WHEN s.name IN ('Ders Programları', 'Ders Düzenle') THEN true ELSE false END,
  false,
  now()
FROM public.screens s
WHERE s.name IN ('Üyelik', 'Ders Programları', 'Ders Detayı', 'Yeni Ders Ekle', 'Ders Düzenle', 'Bildirimler', 'Etkinlikler', 'Hakkımızda', 'Odalar')
ON CONFLICT (role_id, screen_id) DO NOTHING;

-- ============================================
-- 5. ROOMS (Tango Dans Salonları)
-- ============================================

-- Rooms tablosunu oluştur (yoksa)
CREATE TABLE IF NOT EXISTS public.rooms (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL UNIQUE,
    capacity integer NOT NULL CHECK (capacity > 0),
    features text,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamp with time zone NOT NULL DEFAULT now()
);

-- ============================================
-- 5.1. ROOMS VERİLERİ
-- ============================================
INSERT INTO public.rooms (id, name, capacity, features, is_active, created_at) VALUES
('00000000-0000-0000-0000-000000000301', 'Ana Tango Salonu', 40, 'Ayna duvarlar, Profesyonel ses sistemi, Parke zemin, Klima', true, now()),
('00000000-0000-0000-0000-000000000302', 'Milonga Salonu', 30, 'Ayna duvarlar, DJ ekipmanı, LED ışıklandırma, Parke zemin', true, now()),
('00000000-0000-0000-0000-000000000303', 'Pratik Salonu 1', 20, 'Ayna duvarlar, Müzik sistemi, Parke zemin', true, now()),
('00000000-0000-0000-0000-000000000304', 'Pratik Salonu 2', 20, 'Ayna duvarlar, Müzik sistemi, Parke zemin', true, now()),
('00000000-0000-0000-0000-000000000305', 'Bireysel Ders Odası', 4, 'Ayna, Müzik sistemi, Parke zemin', true, now()),
('00000000-0000-0000-0000-000000000306', 'Yarışma Hazırlık Salonu', 25, 'Ayna duvarlar, Profesyonel ses sistemi, Video kayıt ekipmanı, Parke zemin', true, now()),
('00000000-0000-0000-0000-000000000307', 'Workshop Salonu', 50, 'Ayna duvarlar, Projeksiyon, Ses sistemi, Parke zemin, Klima', true, now()),
('00000000-0000-0000-0000-000000000308', 'Bekleme Alanı', 15, 'Koltuklar, Müzik sistemi, Klima', true, now())
ON CONFLICT (name) DO NOTHING;

-- ============================================
-- 6. LESSON PACKAGES (Tango Ders Paketleri)
-- ============================================

-- Lesson packages tablosunu oluştur (yoksa)
CREATE TABLE IF NOT EXISTS public.lesson_packages (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL,
    lesson_count integer NOT NULL CHECK (lesson_count > 0),
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamp with time zone NOT NULL DEFAULT now()
);

-- ============================================
-- 6.1. LESSON PACKAGES VERİLERİ
-- ============================================
INSERT INTO public.lesson_packages (id, name, lesson_count, is_active, created_at) VALUES
('00000000-0000-0000-0000-000000000401', '4 Derslik Deneme Paketi', 4, true, now()),
('00000000-0000-0000-0000-000000000402', '8 Derslik Başlangıç Paketi', 8, true, now()),
('00000000-0000-0000-0000-000000000403', '12 Derslik Standart Paket', 12, true, now()),
('00000000-0000-0000-0000-000000000404', '16 Derslik Yoğun Paket', 16, true, now()),
('00000000-0000-0000-0000-000000000405', 'Aylık Sınırsız Paket', 20, true, now()),
('00000000-0000-0000-0000-000000000406', 'Yarışma Hazırlık Paketi', 24, true, now()),
('00000000-0000-0000-0000-000000000407', 'Bireysel Ders Paketi (5 Ders)', 5, true, now()),
('00000000-0000-0000-0000-000000000408', 'Bireysel Ders Paketi (10 Ders)', 10, true, now()),
('00000000-0000-0000-0000-000000000409', 'Haftalık Pratik Paketi', 4, true, now()),
('00000000-0000-0000-0000-000000000410', 'Workshop Paketi', 6, true, now())
ON CONFLICT DO NOTHING;

-- ============================================
-- 7. PACKAGE SCHEDULES (Paket Programları)
-- ============================================

-- Package schedules tablosunu oluştur (yoksa)
CREATE TABLE IF NOT EXISTS public.package_schedules (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    package_id uuid NOT NULL REFERENCES public.lesson_packages(id) ON DELETE CASCADE,
    day_of_week text NOT NULL,
    start_time time NOT NULL,
    end_time time NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT now()
);

-- ============================================
-- 7.1. PACKAGE SCHEDULES VERİLERİ
-- ============================================
INSERT INTO public.package_schedules (id, package_id, day_of_week, start_time, end_time, created_at) VALUES
-- 8 Derslik Başlangıç Paketi - Salı ve Perşembe
('00000000-0000-0000-0000-000000000501', '00000000-0000-0000-0000-000000000402', 'Tuesday', '19:00:00', '20:30:00', now()),
('00000000-0000-0000-0000-000000000502', '00000000-0000-0000-0000-000000000402', 'Thursday', '19:00:00', '20:30:00', now()),

-- 12 Derslik Standart Paket - Pazartesi, Çarşamba, Cuma
('00000000-0000-0000-0000-000000000503', '00000000-0000-0000-0000-000000000403', 'Monday', '18:00:00', '19:30:00', now()),
('00000000-0000-0000-0000-000000000504', '00000000-0000-0000-0000-000000000403', 'Wednesday', '18:00:00', '19:30:00', now()),
('00000000-0000-0000-0000-000000000505', '00000000-0000-0000-0000-000000000403', 'Friday', '18:00:00', '19:30:00', now()),

-- 16 Derslik Yoğun Paket - Hafta içi her gün
('00000000-0000-0000-0000-000000000506', '00000000-0000-0000-0000-000000000404', 'Monday', '19:00:00', '20:30:00', now()),
('00000000-0000-0000-0000-000000000507', '00000000-0000-0000-0000-000000000404', 'Tuesday', '19:00:00', '20:30:00', now()),
('00000000-0000-0000-0000-000000000508', '00000000-0000-0000-0000-000000000404', 'Wednesday', '19:00:00', '20:30:00', now()),
('00000000-0000-0000-0000-000000000509', '00000000-0000-0000-0000-000000000404', 'Thursday', '19:00:00', '20:30:00', now()),

-- Aylık Sınırsız Paket - Hafta sonu dahil
('00000000-0000-0000-0000-000000000510', '00000000-0000-0000-0000-000000000405', 'Saturday', '14:00:00', '16:00:00', now()),
('00000000-0000-0000-0000-000000000511', '00000000-0000-0000-0000-000000000405', 'Sunday', '14:00:00', '16:00:00', now()),

-- Yarışma Hazırlık Paketi - Cumartesi ve Pazar
('00000000-0000-0000-0000-000000000512', '00000000-0000-0000-0000-000000000406', 'Saturday', '10:00:00', '12:00:00', now()),
('00000000-0000-0000-0000-000000000513', '00000000-0000-0000-0000-000000000406', 'Sunday', '10:00:00', '12:00:00', now()),

-- Haftalık Pratik Paketi - Cuma akşamı
('00000000-0000-0000-0000-000000000514', '00000000-0000-0000-0000-000000000409', 'Friday', '20:00:00', '22:00:00', now())
ON CONFLICT DO NOTHING;

-- ============================================
-- 8. AUTOMATIC NOTIFICATION SETTINGS
-- ============================================

-- Automatic notification settings tablosunu oluştur (yoksa)
CREATE TABLE IF NOT EXISTS public.automatic_notification_settings (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    notification_type text NOT NULL,
    days_before integer NOT NULL,
    title_template text NOT NULL,
    body_template text NOT NULL,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamp with time zone NOT NULL DEFAULT now()
);

-- ============================================
-- 8.1. AUTOMATIC NOTIFICATION SETTINGS VERİLERİ
-- ============================================
INSERT INTO public.automatic_notification_settings (id, notification_type, days_before, title_template, body_template, is_active, created_at) VALUES
('00000000-0000-0000-0000-000000000601', 'birthday_reminder', 1, 'Doğum Gününüz Kutlu Olsun!', 'Sevgili {first_name}, doğum gününüzü kutlarız! Tango dans okulumuzda mutlu yıllar dileriz.', true, now()),
('00000000-0000-0000-0000-000000000602', 'payment_reminder', 3, 'Ödeme Hatırlatması', 'Sevgili {first_name}, ödemenizin {due_date} tarihinde sona ereceğini hatırlatırız. Lütfen zamanında ödemenizi yapınız.', true, now()),
('00000000-0000-0000-0000-000000000603', 'lesson_reminder', 1, 'Ders Hatırlatması', 'Merhaba {first_name}, yarın {day_of_week} günü saat {start_time} tango dersiniz var. Görüşmek üzere!', true, now()),
('00000000-0000-0000-0000-000000000604', 'package_expiry', 7, 'Paket Süresi Doluyor', 'Sevgili {first_name}, ders paketinizin süresi yakında dolacak. Yeni paket almak için bizimle iletişime geçin.', true, now()),
('00000000-0000-0000-0000-000000000605', 'event_reminder', 2, 'Etkinlik Hatırlatması', 'Merhaba {first_name}, {event_title} etkinliğimiz yaklaşıyor! {event_date} tarihinde görüşmek üzere.', true, now())
ON CONFLICT DO NOTHING;

-- ============================================
-- 9. ABOUT CONTENTS (Tango Dans Okulu Hakkında)
-- ============================================

-- Content type enum oluştur (yoksa)
DO $$ 
BEGIN
    CREATE TYPE content_type AS ENUM ('text', 'image', 'video');
EXCEPTION
    WHEN duplicate_object THEN
        NULL;
END $$;

-- About contents tablosunu oluştur (yoksa)
CREATE TABLE IF NOT EXISTS public.about_contents (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    slug text NOT NULL UNIQUE,
    title text NOT NULL,
    type content_type NOT NULL DEFAULT 'text',
    content_text text,
    media_url text,
    sort_order integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamp with time zone NOT NULL DEFAULT now()
);

-- ============================================
-- 9.1. ABOUT CONTENTS VERİLERİ
-- ============================================
INSERT INTO public.about_contents (id, slug, title, type, content_text, media_url, sort_order, is_active, created_at) VALUES
('00000000-0000-0000-0000-000000000701', 'hakkimizda', 'Hakkımızda', 'text', 
'FlowEdu Tango Dans Okulu, 2010 yılından beri tango dansı eğitimi veren profesyonel bir kurumdur. Arjantin tangosunun geleneksel değerlerini koruyarak, modern öğretim teknikleriyle birleştiriyoruz. 

Okulumuzda başlangıç seviyesinden ileri seviyeye kadar her seviyede eğitim verilmektedir. Deneyimli eğitmenlerimiz ve modern dans salonlarımızla, tango dansının büyülü dünyasını keşfetmenize yardımcı oluyoruz.

Misyonumuz, tango dansını her yaştan ve seviyeden insanlara sevdirmek ve bu güzel sanatı gelecek nesillere aktarmaktır.', 
null, 1, true, now()),

('00000000-0000-0000-0000-000000000702', 'egitmenlerimiz', 'Eğitmenlerimiz', 'text', 
'Okulumuzda alanında uzman, uluslararası sertifikalı tango eğitmenleri bulunmaktadır. Her eğitmenimiz en az 10 yıl deneyime sahip olup, Arjantin''de eğitim almış profesyonellerdir.

Eğitmenlerimiz:
- Arjantin Tango Federasyonu sertifikalı
- Uluslararası yarışmalarda jüri üyesi
- Yıllık eğitim seminerlerine katılım
- Sürekli kendini geliştiren profesyoneller

Eğitmenlerimiz sadece dans tekniklerini öğretmekle kalmaz, aynı zamanda tango kültürü, tarihi ve felsefesini de aktarırlar.', 
null, 2, true, now()),

('00000000-0000-0000-0000-000000000703', 'asistanlarimiz', 'Asistanlarımız', 'text', 
'Deneyimli asistanlarımız, derslerinizde size yardımcı olmak ve öğrenme sürecinizi desteklemek için buradalar. Asistanlarımız:

- İleri seviye tango dansçıları
- Eğitmen adayları
- Öğrenci mentorları
- Pratik seansları yöneticileri

Asistanlarımız, özellikle yeni başlayan öğrencilerimizin adaptasyon sürecinde önemli bir rol oynar ve bireysel ilgi gösterirler.', 
null, 3, true, now()),

('00000000-0000-0000-0000-000000000704', 'uyelik-kurallari', 'Üyelik Kuralları', 'text', 
'ÜYELİK KURALLARI VE ŞARTLAR:

1. Kayıt ve Ödeme:
   - Tüm ödemeler ders başlamadan önce yapılmalıdır
   - Paket derslerin süresi 3 aydır
   - İptal durumunda %50 iade yapılır (7 gün önceden bildirim şartıyla)

2. Ders Katılımı:
   - Derslere zamanında gelinmesi gerekmektedir
   - Geç kalma durumunda derse katılım sağlanamayabilir
   - Devamsızlık durumunda telafi dersi yapılmaz

3. Davranış Kuralları:
   - Dans salonunda saygılı davranılmalıdır
   - Eş değişimi zorunludur (grup derslerinde)
   - Telefonlar sessize alınmalıdır

4. Sağlık ve Güvenlik:
   - Dans ayakkabısı kullanılmalıdır
   - Sağlık sorunları önceden bildirilmelidir
   - Acil durumlarda ilk yardım ekipmanları mevcuttur', 
null, 4, true, now()),

('00000000-0000-0000-0000-000000000705', 'ders-politikamiz', 'Ders Politikamız', 'text', 
'DERS POLİTİKAMIZ:

1. Ders Programı:
   - Dersler haftalık programlar halinde düzenlenir
   - Hafta içi ve hafta sonu seçenekleri mevcuttur
   - Özel dersler için randevu alınmalıdır

2. İptal ve Telafi:
   - Ders iptali 24 saat önceden bildirilmelidir
   - Telafi dersleri aynı ay içinde yapılabilir
   - İptal edilen dersler bir sonraki aya aktarılamaz

3. Paket Dersler:
   - Paket dersler belirli bir süre içinde kullanılmalıdır
   - Süre dolmadan yeni paket alınabilir
   - Kullanılmayan dersler iade edilmez

4. Grup Dersleri:
   - Minimum 4 kişi ile açılır
   - Maksimum 20 kişi ile sınırlıdır
   - Seviye gruplarına göre ayrılır

5. Bireysel Dersler:
   - 1 saatlik seanslar halinde yapılır
   - Eğitmen ile birebir çalışma imkanı
   - Esnek saat seçenekleri', 
null, 5, true, now()),

('00000000-0000-0000-0000-000000000706', 'yaptiklarimiz', 'Yaptıklarımız', 'text', 
'YILLAR İÇİNDE GERÇEKLEŞTİRDİĞİMİZ BAŞARILAR:

🏆 Yarışmalar:
- 2015-2023 yılları arasında 50+ ulusal yarışmada birincilik
- 2018 Dünya Tango Şampiyonası''nda 3. sıra
- 2020 Avrupa Tango Festivali''nde en iyi performans ödülü

🎭 Etkinlikler:
- Yıllık tango geceleri ve milongalar
- Uluslararası tango festivalleri organizasyonu
- Workshop ve masterclass programları
- Arjantin''den misafir eğitmenler

📚 Eğitim:
- 1000+ mezun öğrenci
- 50+ sertifikalı eğitmen yetiştirme
- Online tango eğitim programları
- Tango kültürü ve tarihi seminerleri

🌍 Toplumsal Katkı:
- Sosyal sorumluluk projeleri
- Yaşlılar için özel tango programları
- Engelli bireyler için adapte edilmiş dersler
- Okullarda tango tanıtım programları', 
null, 6, true, now())
ON CONFLICT (slug) DO NOTHING;

-- Veri ekleme işlemi tamamlandı
SELECT 'Tango Dans Okulu örnek verileri başarıyla eklendi!' as result;

-- NOT: Members, Admins, Events, Notifications, Payments, Lesson Schedules gibi tablolara
-- veri eklemek için Flutter uygulaması üzerinden veya Supabase Dashboard'dan
-- kullanıcı oluşturulduktan sonra ekleme yapılmalıdır.
