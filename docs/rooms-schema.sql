-- Rooms (Odalar) tablosu
-- Bu dosya odalar tablosunu ve ilgili yapıları oluşturur

-- 1. Rooms (Odalar) tablosu
CREATE TABLE IF NOT EXISTS public.rooms (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE, -- "A-101", "Dans Salonu-1"
  capacity integer NOT NULL CHECK (capacity > 0), -- Kapasite
  features text, -- Özellikler (JSON veya text): "Ses sistemi, Ayna, Projeksiyon"
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- 2. Index'ler
CREATE INDEX IF NOT EXISTS idx_rooms_active ON public.rooms(is_active);
CREATE INDEX IF NOT EXISTS idx_rooms_name ON public.rooms(name);

-- 3. RLS (Row Level Security)
ALTER TABLE public.rooms ENABLE ROW LEVEL SECURITY;

-- 4. RLS Politikaları
CREATE POLICY "Rooms viewable by authenticated" ON public.rooms 
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Rooms manageable by admins" ON public.rooms 
  FOR ALL USING (auth.role() = 'authenticated');

-- 5. Örnek oda verileri
INSERT INTO public.rooms (name, capacity, features) VALUES
('A-101', 15, 'Projeksiyon, Tahta'),
('A-102', 20, 'Projeksiyon, Tahta, Klima'),
('Dans Salonu-1', 25, 'Ayna, Ses sistemi, Dans parkesi'),
('Dans Salonu-2', 30, 'Ayna, Ses sistemi, Dans parkesi, Klima'),
('Konferans Salonu', 50, 'Projeksiyon, Mikrofon, Klima'),
('B-201', 12, 'Tahta, Klima')
ON CONFLICT (name) DO NOTHING;
