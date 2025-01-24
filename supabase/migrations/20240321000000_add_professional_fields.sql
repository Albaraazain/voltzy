-- Add new columns to professionals table
ALTER TABLE professionals
ADD COLUMN IF NOT EXISTS phone TEXT,
ADD COLUMN IF NOT EXISTS services JSONB DEFAULT '[]'::JSONB,
ADD COLUMN IF NOT EXISTS working_hours JSONB DEFAULT '{
  "monday": {"start": "09:00", "end": "17:00"},
  "tuesday": {"start": "09:00", "end": "17:00"},
  "wednesday": {"start": "09:00", "end": "17:00"},
  "thursday": {"start": "09:00", "end": "17:00"},
  "friday": {"start": "09:00", "end": "17:00"},
  "saturday": null,
  "sunday": null
}'::JSONB,
ADD COLUMN IF NOT EXISTS payment_info JSONB DEFAULT '{
  "bank_name": null,
  "account_number": null,
  "routing_number": null,
  "account_type": null
}'::JSONB,
ADD COLUMN IF NOT EXISTS notification_preferences JSONB DEFAULT '{
  "new_job_requests": true,
  "job_updates": true,
  "messages": true,
  "weekly_summary": true,
  "payment_updates": true,
  "promotions": false,
  "quiet_hours_enabled": false,
  "quiet_hours_start": "22:00",
  "quiet_hours_end": "07:00"
}'::JSONB;

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_professionals_phone ON professionals(phone);
CREATE INDEX IF NOT EXISTS idx_professionals_services ON professionals USING gin(services);
CREATE INDEX IF NOT EXISTS idx_professionals_working_hours ON professionals USING gin(working_hours);
CREATE INDEX IF NOT EXISTS idx_professionals_payment_info ON professionals USING gin(payment_info);
CREATE INDEX IF NOT EXISTS idx_professionals_notification_preferences ON professionals USING gin(notification_preferences); 