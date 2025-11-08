-- Temel tabloları oluştur
-- Bu script'i Supabase SQL Editor'da çalıştırın

-- 1. Screens tablosunu oluştur
CREATE TABLE IF NOT EXISTS public.screens (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
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

-- 2. Permissions tablosunu oluştur
CREATE TABLE IF NOT EXISTS public.permissions (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    role_id uuid NOT NULL REFERENCES public.roles(id) ON DELETE CASCADE,
    screen_id uuid NOT NULL REFERENCES public.screens(id) ON DELETE CASCADE,
    can_create boolean DEFAULT FALSE,
    can_read boolean DEFAULT FALSE,
    can_update boolean DEFAULT FALSE,
    can_delete boolean DEFAULT FALSE,
    created_at timestamp with time zone DEFAULT now(),
    UNIQUE(role_id, screen_id)
);

-- 3. RLS politikalarını etkinleştir
ALTER TABLE public.screens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.permissions ENABLE ROW LEVEL SECURITY;

-- 4. Screens için RLS politikaları
CREATE POLICY "Screens are viewable by authenticated users" ON public.screens
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Screens are manageable by admins" ON public.screens
    FOR ALL USING (auth.role() = 'authenticated');

-- 5. Permissions için RLS politikaları
CREATE POLICY "Permissions are viewable by authenticated users" ON public.permissions
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Permissions are manageable by admins" ON public.permissions
    FOR ALL USING (auth.role() = 'authenticated');

-- 6. Mevcut ekranları ekle
INSERT INTO public.screens (name, route, description, icon_name, sort_order) VALUES
('Üyelik', '/members', 'Üye yönetimi', 'person', 1),
('Roller', '/roles', 'Rol yönetimi', 'admin_panel_settings', 2),
('Gruplar', '/groups', 'Grup yönetimi', 'group', 3),
('Ekranlar', '/screens', 'Ekran yönetimi', 'screen_share', 4),
('Yetkiler', '/permissions', 'Yetki matrisi', 'security', 5),
('Bildirimler', '/notifications', 'Bildirim yönetimi', 'notifications', 6),
('Etkinlikler', '/events', 'Etkinlik yönetimi', 'event', 7),
('Ödemeler', '/payments', 'Ödeme yönetimi', 'payment', 8),
('Ders Paketleri', '/lesson-packages', 'Ders paketi yönetimi', 'school', 9),
('Hakkımızda', '/about', 'Hakkımızda içerik yönetimi', 'info', 10),
('Ders Programı', '/lesson-schedules', 'Ders programı yönetimi', 'schedule', 11),
ON CONFLICT (name) DO NOTHING;

-- 7. add_new_screen fonksiyonunu oluştur
CREATE OR REPLACE FUNCTION public.add_new_screen(
    p_name text,
    p_route text,
    p_icon_name text DEFAULT 'info',
    p_required_permissions text[] DEFAULT ARRAY['read']::text[],
    p_description text DEFAULT '',
    p_parent_module text DEFAULT NULL,
    p_sort_order integer DEFAULT 0
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    new_screen_id uuid;
    r record;
    default_can_create boolean;
    default_can_read boolean;
    default_can_update boolean;
    default_can_delete boolean;
BEGIN
    -- Insert the new screen
    INSERT INTO public.screens (name, route, description, parent_module, icon_name, required_permissions, sort_order)
    VALUES (p_name, p_route, p_description, p_parent_module, p_icon_name, p_required_permissions, p_sort_order)
    RETURNING id INTO new_screen_id;

    -- For each role, create default permissions for the new screen
    FOR r IN SELECT id AS role_id, name AS role_name FROM public.roles LOOP
        -- Determine default permissions based on role name
        default_can_create := FALSE;
        default_can_read := FALSE;
        default_can_update := FALSE;
        default_can_delete := FALSE;

        IF r.role_name = 'Admin' OR r.role_name = 'SuperAdmin' THEN
            default_can_create := TRUE;
            default_can_read := TRUE;
            default_can_update := TRUE;
            default_can_delete := TRUE;
        ELSIF r.role_name = 'Editör' THEN
            default_can_create := TRUE;
            default_can_read := TRUE;
            default_can_update := TRUE;
            default_can_delete := FALSE;
        ELSIF r.role_name = 'Moderator' THEN
            default_can_read := TRUE;
            default_can_update := TRUE;
            default_can_create := FALSE;
            default_can_delete := FALSE;
        ELSIF r.role_name = 'Member' THEN
            -- Members can only read and update their own 'Üyelik' (Membership)
            IF p_name = 'Üyelik' THEN
                default_can_read := TRUE;
                default_can_update := TRUE;
            END IF;
        END IF;

        INSERT INTO public.permissions (role_id, screen_id, can_create, can_read, can_update, can_delete)
        VALUES (r.role_id, new_screen_id, default_can_create, default_can_read, default_can_update, default_can_delete);
    END LOOP;

    RETURN new_screen_id;
END;
$$;

-- 8. Mevcut roller için varsayılan yetkileri oluştur
DO $$
DECLARE
    r record;
    s record;
    admin_role_id uuid;
    superadmin_role_id uuid;
    editor_role_id uuid;
    moderator_role_id uuid;
    member_role_id uuid;
BEGIN
    -- Rol ID'lerini al
    SELECT id INTO admin_role_id FROM public.roles WHERE name = 'Admin';
    SELECT id INTO superadmin_role_id FROM public.roles WHERE name = 'SuperAdmin';
    SELECT id INTO editor_role_id FROM public.roles WHERE name = 'Editör';
    SELECT id INTO moderator_role_id FROM public.roles WHERE name = 'Moderator';
    SELECT id INTO member_role_id FROM public.roles WHERE name = 'Member';

    -- Her ekran için her rol için yetki oluştur
    FOR s IN SELECT id, name FROM public.screens WHERE is_active = true LOOP
        -- Admin: Tam yetki
        IF admin_role_id IS NOT NULL THEN
            INSERT INTO public.permissions (role_id, screen_id, can_create, can_read, can_update, can_delete)
            VALUES (admin_role_id, s.id, true, true, true, true)
            ON CONFLICT (role_id, screen_id) DO NOTHING;
        END IF;

        -- SuperAdmin: Tam yetki
        IF superadmin_role_id IS NOT NULL THEN
            INSERT INTO public.permissions (role_id, screen_id, can_create, can_read, can_update, can_delete)
            VALUES (superadmin_role_id, s.id, true, true, true, true)
            ON CONFLICT (role_id, screen_id) DO NOTHING;
        END IF;

        -- Editör: CRU yetki (Delete hariç)
        IF editor_role_id IS NOT NULL THEN
            INSERT INTO public.permissions (role_id, screen_id, can_create, can_read, can_update, can_delete)
            VALUES (editor_role_id, s.id, true, true, true, false)
            ON CONFLICT (role_id, screen_id) DO NOTHING;
        END IF;

        -- Moderator: RU yetki (Create/Delete hariç)
        IF moderator_role_id IS NOT NULL THEN
            INSERT INTO public.permissions (role_id, screen_id, can_create, can_read, can_update, can_delete)
            VALUES (moderator_role_id, s.id, false, true, true, false)
            ON CONFLICT (role_id, screen_id) DO NOTHING;
        END IF;

        -- Member: Sadece Üyelik sayfasında RU yetki
        IF member_role_id IS NOT NULL AND s.name = 'Üyelik' THEN
            INSERT INTO public.permissions (role_id, screen_id, can_create, can_read, can_update, can_delete)
            VALUES (member_role_id, s.id, false, true, true, false)
            ON CONFLICT (role_id, screen_id) DO NOTHING;
        END IF;
    END LOOP;

    RAISE NOTICE 'Varsayılan yetkiler oluşturuldu';
END $$;

-- 9. Sonuçları kontrol et
SELECT 
    r.name as role_name,
    COUNT(p.id) as permission_count,
    COUNT(CASE WHEN p.can_read = true THEN 1 END) as read_permissions,
    COUNT(CASE WHEN p.can_create = true THEN 1 END) as create_permissions,
    COUNT(CASE WHEN p.can_update = true THEN 1 END) as update_permissions,
    COUNT(CASE WHEN p.can_delete = true THEN 1 END) as delete_permissions
FROM public.roles r
LEFT JOIN public.permissions p ON r.id = p.role_id
LEFT JOIN public.screens s ON p.screen_id = s.id AND s.is_active = true
GROUP BY r.id, r.name
ORDER BY r.name;
