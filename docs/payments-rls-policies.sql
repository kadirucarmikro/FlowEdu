-- Payments Module RLS Policies
-- FlowEdu Project - Payments Security Policies

-- Enable RLS on payments table
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

-- Enable RLS on lesson_packages table
ALTER TABLE public.lesson_packages ENABLE ROW LEVEL SECURITY;

-- Payments: owner or admin can read; only admin can write
DROP POLICY IF EXISTS payments_read ON public.payments;
CREATE POLICY payments_read ON public.payments
FOR SELECT USING (
  public.is_admin() OR EXISTS (
    SELECT 1 FROM public.members m 
    WHERE m.id = payments.member_id AND m.user_id = auth.uid()
  )
);

DROP POLICY IF EXISTS payments_write ON public.payments;
CREATE POLICY payments_write ON public.payments
FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- Lesson Packages: everyone can read; only admin can write
DROP POLICY IF EXISTS lesson_packages_read ON public.lesson_packages;
CREATE POLICY lesson_packages_read ON public.lesson_packages
FOR SELECT USING (true);

DROP POLICY IF EXISTS lesson_packages_write ON public.lesson_packages;
CREATE POLICY lesson_packages_write ON public.lesson_packages
FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- Member Package Assignments: owner or admin can read
DROP POLICY IF EXISTS mpa_read ON public.member_package_assignments;
CREATE POLICY mpa_read ON public.member_package_assignments
FOR SELECT USING (
  public.is_admin() OR EXISTS (
    SELECT 1 FROM public.members m 
    WHERE m.id = member_id AND m.user_id = auth.uid()
  )
);

-- Member Package Assignments: only admin can write
DROP POLICY IF EXISTS mpa_write ON public.member_package_assignments;
CREATE POLICY mpa_write ON public.member_package_assignments
FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- Package Schedules: everyone can read; only admin can write
DROP POLICY IF EXISTS package_schedules_read ON public.package_schedules;
CREATE POLICY package_schedules_read ON public.package_schedules
FOR SELECT USING (true);

DROP POLICY IF EXISTS package_schedules_write ON public.package_schedules;
CREATE POLICY package_schedules_write ON public.package_schedules
FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- Cancelled Lessons: everyone can read; only admin can write
DROP POLICY IF EXISTS cancelled_lessons_read ON public.cancelled_lessons;
CREATE POLICY cancelled_lessons_read ON public.cancelled_lessons
FOR SELECT USING (true);

DROP POLICY IF EXISTS cancelled_lessons_write ON public.cancelled_lessons;
CREATE POLICY cancelled_lessons_write ON public.cancelled_lessons
FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_payments_member ON public.payments(member_id);
CREATE INDEX IF NOT EXISTS idx_payments_package ON public.payments(package_id);
CREATE INDEX IF NOT EXISTS idx_payments_status ON public.payments(status);
CREATE INDEX IF NOT EXISTS idx_payments_due_date ON public.payments(due_date);
CREATE INDEX IF NOT EXISTS idx_lesson_packages_active ON public.lesson_packages(is_active);
CREATE INDEX IF NOT EXISTS idx_member_package_assignments_member ON public.member_package_assignments(member_id);
CREATE INDEX IF NOT EXISTS idx_member_package_assignments_package ON public.member_package_assignments(package_id);
CREATE INDEX IF NOT EXISTS idx_package_schedules_package ON public.package_schedules(package_id);

-- Grant necessary permissions
GRANT SELECT ON public.payments TO authenticated;
GRANT SELECT ON public.lesson_packages TO authenticated;
GRANT SELECT ON public.member_package_assignments TO authenticated;
GRANT SELECT ON public.package_schedules TO authenticated;
GRANT SELECT ON public.cancelled_lessons TO authenticated;

-- Admin permissions
GRANT ALL ON public.payments TO authenticated;
GRANT ALL ON public.lesson_packages TO authenticated;
GRANT ALL ON public.member_package_assignments TO authenticated;
GRANT ALL ON public.package_schedules TO authenticated;
GRANT ALL ON public.cancelled_lessons TO authenticated;
