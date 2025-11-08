-- Lesson Schedules (Package Schedules) RLS Policies
-- Bu dosya package_schedules tablosu için RLS politikalarını içerir

-- RLS'i etkinleştir
alter table public.package_schedules enable row level security;

-- Herkes okuyabilir (public read)
drop policy if exists package_schedules_read on public.package_schedules;
create policy package_schedules_read on public.package_schedules
for select using (true);

-- Sadece admin yazabilir (admin only write)
drop policy if exists package_schedules_write on public.package_schedules;
create policy package_schedules_write on public.package_schedules
for all using (public.is_admin()) with check (public.is_admin());

-- Yardımcı fonksiyonlar (eğer yoksa)
create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.admins a where a.user_id = auth.uid()
  );
$$;

-- Test verisi ekleme (opsiyonel)
-- Not: Bu veriler lesson_packages tablosunda mevcut paketler olmalı
-- Örnek test verisi (gerçek paket ID'leri ile değiştirin):
/*
insert into public.package_schedules (package_id, day_of_week, start_time, end_time) values
('package-id-1', 'Tuesday', '19:00', '20:30'),
('package-id-1', 'Thursday', '19:00', '20:30'),
('package-id-2', 'Monday', '18:00', '19:30'),
('package-id-2', 'Wednesday', '18:00', '19:30'),
('package-id-2', 'Friday', '18:00', '19:30')
on conflict do nothing;
*/
