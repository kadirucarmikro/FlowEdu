-- Lesson Attendees (Ders Katılımcıları) tablosu
-- Bu dosya ders katılımcıları tablosunu oluşturur

-- 1. Ders katılımcıları (üye ataması)
CREATE TABLE IF NOT EXISTS public.lesson_attendees (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  schedule_id uuid NOT NULL REFERENCES public.lesson_schedules(id) ON DELETE CASCADE,
  member_id uuid NOT NULL REFERENCES public.members(id) ON DELETE CASCADE,
  assigned_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(schedule_id, member_id)
);

-- 2. lesson_price sütunu ekleme (migration)
-- Eğer sütun zaten varsa hata vermez
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'lesson_attendees' 
    AND column_name = 'lesson_price'
  ) THEN
    ALTER TABLE public.lesson_attendees 
    ADD COLUMN lesson_price numeric(10,2) NOT NULL DEFAULT 0.0 CHECK (lesson_price >= 0);
  END IF;
END $$;

-- 2. Index'ler
CREATE INDEX IF NOT EXISTS idx_lesson_attendees_schedule ON public.lesson_attendees(schedule_id);
CREATE INDEX IF NOT EXISTS idx_lesson_attendees_member ON public.lesson_attendees(member_id);

-- 3. RLS (Row Level Security)
ALTER TABLE public.lesson_attendees ENABLE ROW LEVEL SECURITY;

-- 4. RLS Politikaları
-- Policy'ler zaten varsa hata vermez
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename = 'lesson_attendees' 
    AND policyname = 'Attendees viewable by authenticated'
  ) THEN
    CREATE POLICY "Attendees viewable by authenticated" ON public.lesson_attendees 
      FOR SELECT USING (auth.role() = 'authenticated');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename = 'lesson_attendees' 
    AND policyname = 'Attendees manageable by admins'
  ) THEN
    CREATE POLICY "Attendees manageable by admins" ON public.lesson_attendees 
      FOR ALL USING (auth.role() = 'authenticated');
  END IF;
END $$;
