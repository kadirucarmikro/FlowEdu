-- About Contents RLS Policies
-- Bu dosya about_contents tablosu için RLS politikalarını içerir

-- RLS'i etkinleştir
alter table public.about_contents enable row level security;

-- Herkes okuyabilir (public read)
drop policy if exists about_contents_read on public.about_contents;
create policy about_contents_read on public.about_contents
for select using (true);

-- Sadece admin yazabilir (admin only write)
drop policy if exists about_contents_write on public.about_contents;
create policy about_contents_write on public.about_contents
for all using (public.is_admin()) with check (public.is_admin());

-- Yardımcı fonksiyonlar (eğer yoksa)
create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.admins a where a.user_id = auth.uid()
  );
$$;

-- Test verisi ekleme (opsiyonel)
insert into public.about_contents (slug, title, type, content_text, sort_order, is_active) values
('hakkimizda', 'Hakkımızda', 'text', 'FlowEdu eğitim yönetim sistemi hakkında bilgiler...', 1, true),
('egitmenlerimiz', 'Eğitmenlerimiz', 'text', 'Deneyimli eğitmenlerimiz hakkında bilgiler...', 2, true),
('asistanlarimiz', 'Asistanlarımız', 'text', 'Yardımcı asistanlarımız hakkında bilgiler...', 3, true),
('uyelik-kurallari', 'Üyelik Kuralları', 'text', 'Üyelik kuralları ve şartları...', 4, true),
('ders-politikamiz', 'Ders Politikamız', 'text', 'Ders politikamız ve kuralları...', 5, true),
('yaptiklarimiz', 'Yaptıklarımız', 'text', 'Başarılarımız ve yaptıklarımız...', 6, true)
on conflict (slug) do nothing;
