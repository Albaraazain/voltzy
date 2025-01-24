-- Update default values for professional fields
ALTER TABLE professionals
ALTER COLUMN payment_info SET DEFAULT '{
  "account_name": null,
  "bank_name": null,
  "account_type": null,
  "account_number": null,
  "routing_number": null
}'::JSONB;

-- Add missing indexes if they don't exist
CREATE INDEX IF NOT EXISTS idx_professionals_profile_id ON professionals(profile_id);
CREATE INDEX IF NOT EXISTS idx_professionals_license_number ON professionals(license_number);
CREATE INDEX IF NOT EXISTS idx_professionals_years_of_experience ON professionals(years_of_experience);

-- Add constraints to ensure valid data
ALTER TABLE professionals
ADD CONSTRAINT valid_hourly_rate CHECK (hourly_rate >= 0),
ADD CONSTRAINT valid_years_of_experience CHECK (years_of_experience >= 0),
ADD CONSTRAINT valid_rating CHECK (rating >= 0 AND rating <= 5);

-- Update RLS policies
DROP POLICY IF EXISTS "Enable update for own professional profile" ON professionals;
CREATE POLICY "Enable update for own professional profile"
ON professionals FOR UPDATE
USING (auth.uid()::uuid = profile_id)
WITH CHECK (auth.uid()::uuid = profile_id); 