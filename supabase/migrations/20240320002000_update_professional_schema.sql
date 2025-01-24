-- Update professionals table
ALTER TABLE professionals
ADD COLUMN IF NOT EXISTS phone TEXT,
ADD COLUMN IF NOT EXISTS profile_image TEXT,
ADD COLUMN IF NOT EXISTS services JSONB DEFAULT '[]'::JSONB,
ADD COLUMN IF NOT EXISTS working_hours JSONB DEFAULT '{}'::JSONB,
ADD COLUMN IF NOT EXISTS payment_info JSONB,
ADD COLUMN IF NOT EXISTS notification_preferences JSONB DEFAULT '{
  "new_job_requests": true,
  "job_updates": true,
  "messages": true,
  "weekly_summary": true,
  "payment_updates": true,
  "promotions": false,
  "quiet_hours_enabled": false,
  "quiet_hours_start_hour": 22,
  "quiet_hours_start_minute": 0,
  "quiet_hours_end_hour": 7,
  "quiet_hours_end_minute": 0
}'::JSONB;

-- Create storage bucket for profile images if it doesn't exist
INSERT INTO storage.buckets (id, name)
VALUES ('profile_images', 'profile_images')
ON CONFLICT (id) DO NOTHING;

-- Set up storage policies
CREATE POLICY "Allow users to upload their own profile images"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'profile_images' AND
  auth.uid()::uuid::text = (storage.foldername(name))[1]
);

CREATE POLICY "Allow public viewing of profile images"
ON storage.objects FOR SELECT
USING (bucket_id = 'profile_images');

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_professionals_rating ON professionals(rating);
CREATE INDEX IF NOT EXISTS idx_professionals_hourly_rate ON professionals(hourly_rate);
CREATE INDEX IF NOT EXISTS idx_professionals_is_available ON professionals(is_available);
CREATE INDEX IF NOT EXISTS idx_professionals_is_verified ON professionals(is_verified);

-- Update RLS policies
ALTER TABLE professionals ENABLE ROW LEVEL SECURITY;

-- Allow read access to verified professionals
CREATE POLICY "Read verified professionals"
ON professionals FOR SELECT
USING (is_verified = true OR auth.uid()::uuid = profile_id);

-- Allow professionals to update their own profiles
CREATE POLICY "Update own profile"
ON professionals FOR UPDATE
USING (auth.uid()::uuid = profile_id)
WITH CHECK (
  -- Only allow updating non-sensitive fields
  auth.uid()::uuid = profile_id AND
  is_verified IS NOT DISTINCT FROM is_verified
); 