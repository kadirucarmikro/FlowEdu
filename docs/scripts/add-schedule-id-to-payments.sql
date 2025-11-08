-- Migration: Add schedule_id column to payments table
-- This migration adds a schedule_id column to the payments table
-- to link payments with lesson schedules

-- Add schedule_id column to payments table
ALTER TABLE public.payments
ADD COLUMN IF NOT EXISTS schedule_id UUID REFERENCES public.lesson_schedules(id) ON DELETE SET NULL;

-- Add index for better query performance
CREATE INDEX IF NOT EXISTS idx_payments_schedule_id ON public.payments(schedule_id);

-- Add comment to the column
COMMENT ON COLUMN public.payments.schedule_id IS 'References the lesson schedule this payment is associated with';

