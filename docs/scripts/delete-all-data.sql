-- FlowEdu - Tüm Verileri Silme Scripti
-- Bu script tüm tablolardaki verileri foreign key ilişkilerine göre sırayla siler
-- DİKKAT: Bu script tüm verileri kalıcı olarak siler!
-- Tabloların varlığı kontrol edilerek güvenli silme yapılır

-- Foreign key constraint'leri geçici olarak devre dışı bırak (opsiyonel, daha hızlı silme için)
-- SET session_replication_role = 'replica';

-- 1. Child tabloları sil (foreign key bağımlılıkları olan tablolar)
-- Tabloların varlığı kontrol edilerek silme işlemi yapılır

-- Notification ilişkili tablolar (varsa sil)
DO $$ 
BEGIN
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'notification_responses') THEN
    DELETE FROM public.notification_responses;
  END IF;
  
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'notification_targets') THEN
    DELETE FROM public.notification_targets;
  END IF;
  
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'scheduled_notifications') THEN
    DELETE FROM public.scheduled_notifications;
  END IF;
  
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'notification_options') THEN
    DELETE FROM public.notification_options;
  END IF;
END $$;

-- Event ilişkili tablolar (varsa sil)
DO $$ 
BEGIN
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'event_responses') THEN
    DELETE FROM public.event_responses;
  END IF;
  
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'event_question_options') THEN
    DELETE FROM public.event_question_options;
  END IF;
  
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'event_questions') THEN
    DELETE FROM public.event_questions;
  END IF;
  
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'event_media') THEN
    DELETE FROM public.event_media;
  END IF;
  
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'event_instructors') THEN
    DELETE FROM public.event_instructors;
  END IF;
  
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'event_organizers') THEN
    DELETE FROM public.event_organizers;
  END IF;
  
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'event_options') THEN
    DELETE FROM public.event_options;
  END IF;
END $$;

-- Lesson ilişkili tablolar (varsa sil)
DO $$ 
BEGIN
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'lesson_attendees') THEN
    DELETE FROM public.lesson_attendees;
  END IF;
  
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'lesson_schedules') THEN
    DELETE FROM public.lesson_schedules;
  END IF;
END $$;

-- Payment ve assignment tabloları (varsa sil)
DO $$ 
BEGIN
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'payments') THEN
    DELETE FROM public.payments;
  END IF;
  
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'member_package_assignments') THEN
    DELETE FROM public.member_package_assignments;
  END IF;
  
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'cancelled_lessons') THEN
    DELETE FROM public.cancelled_lessons;
  END IF;
  
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'package_schedules') THEN
    DELETE FROM public.package_schedules;
  END IF;
END $$;

-- Permission tablosu (varsa sil)
DO $$ 
BEGIN
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'permissions') THEN
    DELETE FROM public.permissions;
  END IF;
END $$;

-- Notification tabloları (varsa sil)
DO $$ 
BEGIN
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'notifications') THEN
    DELETE FROM public.notifications;
  END IF;
  
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'automatic_notification_settings') THEN
    DELETE FROM public.automatic_notification_settings;
  END IF;
END $$;

-- Event tablosu (varsa sil)
DO $$ 
BEGIN
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'events') THEN
    DELETE FROM public.events;
  END IF;
END $$;

-- About contents (varsa sil)
DO $$ 
BEGIN
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'about_contents') THEN
    DELETE FROM public.about_contents;
  END IF;
END $$;

-- Audit logs (varsa sil)
DO $$ 
BEGIN
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'audit_logs') THEN
    DELETE FROM public.audit_logs;
  END IF;
END $$;

-- Members ve Admins (auth.users'a bağlı, ama auth.users'ı silmiyoruz)
DO $$ 
BEGIN
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'members') THEN
    DELETE FROM public.members;
  END IF;
  
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'admins') THEN
    DELETE FROM public.admins;
  END IF;
END $$;

-- Lesson packages (varsa sil)
DO $$ 
BEGIN
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'lesson_packages') THEN
    DELETE FROM public.lesson_packages;
  END IF;
END $$;

-- Rooms (varsa sil)
DO $$ 
BEGIN
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'rooms') THEN
    DELETE FROM public.rooms;
  END IF;
END $$;

-- Screens (varsa sil)
DO $$ 
BEGIN
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'screens') THEN
    DELETE FROM public.screens;
  END IF;
END $$;

-- Groups (varsa sil)
DO $$ 
BEGIN
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'groups') THEN
    DELETE FROM public.groups;
  END IF;
END $$;

-- Roles (en son, çünkü members'a referans var ama members'ı zaten sildik)
DO $$ 
BEGIN
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'roles') THEN
    DELETE FROM public.roles;
  END IF;
END $$;

-- Foreign key constraint'leri tekrar etkinleştir
-- SET session_replication_role = 'origin';

-- Silme işlemi tamamlandı
SELECT 'Tüm veriler başarıyla silindi!' as result;

